source("ethi.R")

library(tidyverse)
library(tidytext)
library(topicmodels)

statements_to_model <- ethi_statements %>%
  select(id, text = content_en_plaintext)

statements_to_model_word <- statements_to_model %>%
  unnest_tokens(word, text)

statements_to_model_word_counts <- statements_to_model_word %>%
  anti_join(stop_words) %>%
  count(word, sort = TRUE)

statements_to_model_word_counts_by_speech <- statements_to_model_word %>%
  anti_join(stop_words) %>%
  count(id, word, sort = TRUE)

speeches_dtm <- statements_to_model_word_counts_by_speech %>%
  cast_dtm(id, word, n)

speeches_lda <- LDA(speeches_dtm, k = 10, control = list(seed = 1))

speeches_lda_td <- tidy(speeches_lda)

terms_by_topic <- speeches_lda_td %>%
  group_by(topic) %>%
  top_n(20, beta) %>%
  ungroup() %>%
  arrange(topic, -beta) %>%
  group_by(topic) %>%
  summarize(terms = paste(term, collapse=" "))

## how to make a "grouped" facet: https://drsimonj.svbtle.com/ordering-categories-within-ggplot2-facets
top_terms_ordered <- speeches_lda_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, beta) %>%
  mutate(order = row_number()) %>%
  inner_join(terms_by_topic, by = c("topic" = "topic")) %>%
  mutate(topic = paste(topic, terms)) %>%
  select(topic, term, beta, order)

top_terms_ordered %>% ggplot(aes(order, beta)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ topic, scales = "free_y", ncol = 2) +
  xlab("Term") +
  ylab("Beta (term weight)") +
  theme_bw() +
  scale_x_continuous(
    breaks = top_terms_ordered$order,
    labels = top_terms_ordered$term,
    expand = c(0,0)
  ) +
  coord_flip() +
  theme(strip.text = element_text(hjust = 0))
