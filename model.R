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

top_terms <- speeches_lda_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

reorder <- top_terms %>%
  mutate(term = reorder(term, -beta))

reorder_grouped <- top_terms %>%
  group_by(topic) %>%
  mutate(term = reorder(term, -beta)) %>%
  ungroup()

reorder_grouped_2 <- top_terms %>%
  arrange(topic, beta) %>%
  mutate(order = row_number())

## how to make a "grouped" facet: https://drsimonj.svbtle.com/ordering-categories-within-ggplot2-facets
reorder_grouped_2 %>% ggplot(aes(order, beta)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ topic, scales = "free_y") +
  xlab("Term") +
  ylab("Beta (term weight)") +
  theme_bw() +
  scale_x_continuous(
    breaks = reorder_grouped_2$order,
    labels = reorder_grouped_2$term,
    expand = c(0,0)
  ) +
  coord_flip()

top_terms %>%
  mutate(term = reorder(topic, term, -beta)) %>%
  ggplot(aes(term, beta)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ topic, scales = "free_y") +
  theme(axis.text.x = element_text(size = 10, angle = 90, hjust = 1)) +
  coord_flip()

top_terms_20 <- speeches_lda_td %>%
  group_by(topic) %>%
  top_n(20, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)
