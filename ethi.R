library(tidyverse)
library(textclean)

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
    content_en,
    content_en_plaintext,
    statement_type,
    procedural,
    written_question,
    wordcount,
    urlcache
  )

