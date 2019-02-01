library(RPostgreSQL)
library(DBI)

library(tidyverse)
library(dbplyr)

con <- DBI::dbConnect(drv = dbDriver("PostgreSQL"), host = "localhost", dbname = "openparliament")

db_ethi_statements <- tbl(con, "hansards_statement") %>%
  filter(str_detect(urlcache, "/committees/ethics/42-1/")) %>%
  select(
    time,
    sequence,
    id,
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
  )

db_ethi_statements <- tbl(con, "hansards_statement") %>%
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
  )
  
