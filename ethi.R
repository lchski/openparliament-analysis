library(tidyverse)
library(textclean)

library(RPostgreSQL)
library(DBI)
library(dbplyr)

library(wordcloud)

con <- DBI::dbConnect(
    drv = dbDriver("PostgreSQL"),
    host = "localhost",
    dbname = "openparliament"
  )

ethi_statements <- tbl(con, "hansards_statement") %>%
  left_join(tbl(con, "committees_committeemeeting"), by = c("document_id" = "evidence_id")) %>%
  filter(committee_id == 56 & session_id == "42-1") %>%
  select(
    number,
    date,
    sequence,
    id = "id.x",
    time,
    slug,
    member_id,
    who_en,
    who_context_en,
    politician_id,
    content_en,
    statement_type,
    procedural,
    written_question,
    wordcount,
    urlcache
  ) %>%
  collect() %>%
  mutate(
    content_en_plaintext = replace_html(content_en)
  )


ethi_mps <- tbl(con, "core_electedmember") %>%
  right_join(tbl(con, "core_party"), by = c("party_id" = "id")) %>%
  right_join(tbl(con, "core_politician"), by = c("politician_id" = "id")) %>%
  collect() %>%
  filter(! is.na(id) & id %in% (
      ethi_statements %>%
        select(member_id) %>%
        unique() %>%
        pull()
    )
  )

# count of questions by MP
question_data_by_mp <- function(queried_statements, filename = "out") {
  number_of_meetings <- (queried_statements %>% select(number) %>% unique() %>% count() %>% pull())
  
  print(number_of_meetings)
  
  questions <- queried_statements %>% filter(
    procedural != "true",
    ! is.na(member_id),
    str_detect(content_en_plaintext, "\\?")
  )
  
  out <- questions %>%
    group_by(member_id) %>%
    summarize(count = n(), avg = count / number_of_meetings) %>%
    inner_join(ethi_mps, by = c("member_id" = "id")) %>%
    select(member_id, name, short_name_en, count, avg) %>%
    arrange(-avg)
  
  out %>% write_csv(paste0("data/out/", filename, ".csv"))
  
  questions %>% write_csv(paste0("data/out/", filename, "-questions.csv"))
  
  questions
    
  out
}

## overall
question_data_by_mp(ethi_statements)

# just statements from ETHI meetings 96 and 97, on the Privacy in Digital Government Report
question_data_by_mp(ethi_statements %>% filter(number %in% c(96, 97)), "privacy-in-digital-government")

## since 2018
question_data_by_mp(ethi_statements %>% filter(date > "2018-01-29"), "since-2018-01-29")


wordcloud(words = ethi_statements$content_en_plaintext, max.words = 100)
