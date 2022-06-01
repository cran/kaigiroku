## generate kaiki joho table

library(rvest)
library(tidyverse)
library(stringi)

url <- "https://www.shugiin.go.jp/internet/itdb_annai.nsf/html/statics/shiryo/kaiki.htm"
webpage <- read_html(url)
tab <- webpage %>% html_table() %>% .[[1]]

tab <- tab %>%
  mutate(会期終了日 = stri_trans_nfkc(会期終了日)) %>%
  mutate(会期終了日 = ifelse(nchar(会期終了日)==0, NA, 会期終了日)) %>%
  mutate(会期終了日 = stri_replace_first_regex(会期終了日, "\\(", "")) %>%
  mutate(会期終了日 = stri_replace_first_regex(会期終了日, " 解散.*", "")) %>%
  mutate(sessionNumber = stri_extract_first_regex(国会回次, "\\d+") %>% as.integer) %>%
  mutate(startDate = zipangu::convert_jdate(召集日)) %>%
  mutate(endDate = zipangu::convert_jdate(会期終了日)) %>%
  mutate(sessionLength = stri_extract_first_regex(会期, "\\d+") %>% as.integer) %>%
  mutate(st = 国会回次 %>% stri_trans_nfkc %>%
           stri_extract_first_regex("\\(.+\\)") %>% 
           stri_replace_all_regex("\\W", "")) %>%
  mutate(sessionType = case_when(
    st == "常会" ~ "Ordinary", 
    st == "臨時会" ~ "Extraordinary", 
    st == "特別会" ~ "Special"
  )) %>%
  select(-st)

session_info <- as.data.frame(tab) %>% select(7:11)
save(session_info, file = 'data/session_info.rda')
