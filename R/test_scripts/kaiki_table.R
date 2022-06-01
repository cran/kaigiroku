## generate kaiki joho table

library(RCurl)
library(XML)
library(data.table)
library(magrittr)

url <- "http://kokkai.ndl.go.jp/SENTAKU/kaiki.htm"
webpage <- htmlParse(url)
tab <- readHTMLTable(webpage)[[1]] %>% data.table


tab[, sessionNumber := as.integer(as.character(国会回次))]
endpattern <- ".+～.+\\((\\d+)\\).+(\\d+)月(\\d+)日.*"
tab[, endDate := (会期 %>% sub(".+～.+\\((\\d+)\\)年(\\d+)月(\\d+)日.*", "\\1-\\2-\\3", .))]
tab[endDate %>% grep("年", .), endDate:= NA]
tab[, endDate:= as.Date(endDate)]

tab[, startDate := (会期 %>% sub(".+\\((\\d+)\\)年(\\d+)月(\\d+)日～.+", "\\1-\\2-\\3", .))]
tab[ startDate %>% grep("年", .), startDate:= NA]
tab[, startDate:= as.Date(startDate)]

tab[, sessionLength := sub("日", "", 期間) %>% as.integer()]
tab[, sessionType := V2]
levels(tab$sessionType) <- c("Extraordinary", "Special", "Ordinary")
tab[, c("国会回次", "期間") := NULL]
# tab[, V4 := NULL]
# tab[, V5 := NULL]
setnames(tab, "V2", "sessionTypeJ")
setnames(tab, "会期", "datesJ")

session_info <- data.frame(tab)
save(session_info, file = 'data/session_info.rda')
