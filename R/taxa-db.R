
## Or this totally nut-so approach will go straight into the database
## library(sparklyr)
## sparklyr::spark_install()
sc <- sparklyr::spark_connect("local")
spark_df <- sparklyr::spark_read_csv(sc, "taxa", "data/taxa.tsv.bz2", delimiter = "\\t")

library(dplyr)
spark_df %>% right_join(data_frame(name = "Gadus morhua"), copy=TRUE)


library(DBI)
library(RSQLite)
library(dplyr)



## left_join(data.frame(name = "Gadus morhua"))

#' df <- data_frame(name = gsub("_", " ", primates$phy$tip.label))
#' ex <- taxa_join(df)
#' 
#' ## How many distinct matches did we get? 
#' ex %>% select(name) %>% distinct()
#' 
#' ## How many of those have NCBII matches? 
#' ex %>% select(id, name, rank) %>% distinct() %>% filter(grepl("^NCBI:", id))
taxa_join <- function(df, dbname = "data/taxa.sql", collect = TRUE){
  con <- dbConnect(RSQLite::SQLite(), dbname = dbname)
  ## y is copied into x, so this is fast for most y
  out <- inner_join(tbl(con, "taxa"), df, copy = TRUE)
  
  if(collect)
    out <- collect(out)
  
  out 
}


taxa_id <- function(name = NULL, id = NULL, rank = NULL, partial_match){
  
  con <- dbConnect(RSQLite::SQLite(), dbname="data/taxa.sql")
  taxa <- tbl(con, "taxa") %>% 
    select(id, name, rank) %>% 
    distinct()
  
  if(partial_match){
    taxa %>% 
      filter(name %like% paste0("%", name, "%"))
  }
  taxa %>% filter(name == name)
}

system.time({
  tbl(con, "taxa") %>% select(id, name, rank) %>% distinct()  %>% filter(name %like% "%Gadus%")
})


system.time({
  tbl(con, "taxa") %>% filter(name %like% "%Gadus%") %>% select(id, name, rank) %>% distinct() %>% explain()
})


tbl(con, "taxa") %>% filter(name %like% "Gadus")

tbl(con, "taxa") %>% filter(name == "Gadus" & rank == "Genus")
tbl(con, "taxa") %>% filter(name %like% "%Gadus%" & rank == "Species")

tbl(con, "taxa") %>% filter(name == "Gadus morhua" & rank == "Species") %>% collect() -> cod

tbl(con, "taxa") %>% filter(name == "Pinus ponderosa")%>% collect() -> pine

tbl(con, "taxa") %>% filter(path == "Gymnospermia")
tbl(con, "taxa") %>% filter(path %like% "%Spermatophyta%")

tbl(con, "taxa") %>% filter(path %like% "%Angiospermae%")
tbl(con, "taxa") %>% filter(path %like% "%Coniferae%")

tbl(con, "taxa") %>% filter(name == "Coniferae")


tbl(con, "taxa") %>% filter(name == "Pinopsida") %>% summarise(n())

tbl(con, "taxa") %>% filter(pathIds == "NCBI:122248")

tbl(con, "taxa") %>% filter(name == "Allocebus trichotis")