## generate kaiki joho table

library(RCurl)
library(XML)
library(data.table)
library(magrittr)

url <- "http://www.shugiin.go.jp/internet/itdb_iinkai.nsf/html/iinkai/iinkai_jounin.htm"
webpage <- htmlParse(url)
tab_j <- readHTMLTable(webpage)[[1]] %>% data.table(stringsAsFactors = FALSE)

url <- "http://www.shugiin.go.jp/internet/itdb_english.nsf/html/statics/guide/committees.html"
webpage <- htmlParse(url)
tab_e <- readHTMLTable(webpage)[[1]] %>% data.table(stringsAsFactors = FALSE) %>% .[-1]
tab <- cbind(as.character(tab_e$V1), tab_j[, 1])
tab[15, 2] <- "決算行政監視委員会"
tab_lower <- tab

# url <- "http://www.sangiin.go.jp/japanese/joho1/kousei/eng/committ/iinkaie.htm"
# webpage <- htmlParse(url)
# tab <- readHTMLTable(webpage)[[1]] %>% data.table(stringsAsFactors = FALSE)
# tab[, V2 := as.character(V2)][, V1 := as.character(V1)][, V3 := as.character(V3)]
# tab[!is.na(V3), "V1"] <- tab[!is.na(V3), "V2"]
# tab[!is.na(V3), "V2"] <- tab[!is.na(V3), "V3"]


url <- "https://ja.wikipedia.org/wiki/常任委員会"
contents <- getURL(url, ssl.verifypeer = FALSE)
webpage <- htmlParse(contents)
tab_j <- readHTMLTable(webpage)[[3]] %>% data.table(stringsAsFactors = FALSE)
standing_committee_list <- cbind(tab_lower, tab_j[ , 2])
names(standing_committee_list) <- c("nameEnglish", "nameJapaneseLower", "nameJapaneseUpper")
standing_committee_list[, nameJapaneseLower := as.character(nameJapaneseLower)]
standing_committee_list[, nameJapaneseUpper := as.character(nameJapaneseUpper)]
save(standing_committee_list, file = "data/standing_committee_list.rda")
