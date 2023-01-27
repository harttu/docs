dplyr::tbl(yhteys, dbplyr::in_schema("stage_uraods","mv_diagnoosi")) %>% head() %>% collect() %>% View()

db <- dplyr::tbl(yhteys, dbplyr::in_schema("stage_uraods","mv_diagnoosi")) %>%
  dplyr::transmute(henkilotunnus, diagnoosi, vuosi = date_part('year',tapahtuma_aikaleima))

db %>% head(10^5) %>% pull(diagnoosi) %>% unique -> tmp

db %>%
  head( 10^4) %>%
  transmute(diagnoosi, selite = tolower(selite) ) %>%
  mutate( selite = REGEXP_REPLACE( selite, "[,;]", " " ),
          selite = REGEXP_REPLACE( selite, "  ", " " ),
          selite_pituus = nchar(selite)
          ) %>%
  distinct() %>%
  group_by(diagnoosi) %>%
  arrange(desc(selite_pituus))
  mutate( jarj = row_number(), n = n() ) %>%
  ungroup() %>%
  filter( n != 1)
  count(diagnoosi, sort = T)


db %>%
  head( 10 ^ 5 ) %>%
  group_by(henkilotunnus,diagnoosi) #%>%
  arrange(henkilotunnus,diagnoosi,vuosi) %>%
  filter( row_number() == 1 ) %>%
  ungroup() %>%
  count(diagnoosi, vuosi) %>%
  collect() %>%
  spread(vuosi,n,fill = 0) %>%
  ungroup() %>%
  mutate_if( is.integer64, as.integer ) %>%
  mutate(diagnoosi_summa = rowSums(across(where(is.integer)))) %>%
  relocate( diagnoosi, diagnoosi_summa ) %>%
  arrange(-diagnoosi_summa)
