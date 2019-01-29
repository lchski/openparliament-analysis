library(tidyverse)
library(textclean)
library(wordcloud)

mps <- read_tsv("data/mps.tsv")

statements <- read_tsv("data/42-1-ethi.tsv")

#statements <- statements %>%
#  mutate(
#    meeting_number = str_extract_all(urlcache, "/committees/ethics/42-1/([0-9]{1,3})/"),
#    meeting_number = str_replace(meeting_number, "/committees/ethics/42-1/", ""),
#    meeting_number = str_replace(meeting_number, "/", ""),
#    meeting_number = as.numeric(meeting_number)
#  )

statements <- statements %>%
  rename(committee_meeting_id = id_1) %>%
  arrange(number, sequence)

ethi_statements <- statements %>%
  mutate(
    content_en_plaintext = replace_html(content_en)
  ) %>%
  select(
    number,
    date,
    sequence,
    id,
    time,
    slug,
    member_id,
    who_en,
    who_context_en,
    politician_id,
    content_en_plaintext,
    statement_type,
    procedural,
    written_question,
    wordcount,
    urlcache
  )

ethi_mp_ids <- ethi_statements %>% select(member_id) %>% unique() %>% pull()

ethi_mps <- mps %>% filter(id %in% ethi_mp_ids) %>% filter(! is.na(id))


# just statements from ETHI meetings 96 and 97, on the Privacy in Digital Government Report
ethi_statements_dig_gov_priv <- ethi_statements %>% filter(number %in% c(96, 97))

# count of questions by MP
question_data_by_mp <- function(queried_statements) {
  queried_statements %>% filter(
    ! procedural,
    ! is.na(member_id),
    str_detect(content_en_plaintext, "\\?")
  ) %>%
    group_by(member_id) %>%
    summarize(count = n(), avg = count / (queried_statements %>% select(number) %>% unique() %>% count() %>% pull())) %>%
    inner_join(ethi_mps, by = c("member_id" = "id")) %>%
    select(member_id, name, short_name_en, count, avg) %>%
    arrange(-avg)
}
