# Ajatus: kaivetaan lause ja kaivetaan kohde-elin

#
## Jos haluttaisiin kaivaa lisää tietoa siitä lauseesta jossa TNM on 
if(F) {
  #
  ## TNM to Stage
  tnm_data %>%
    dplyr::filter(FORMAT == "TNM") %>% #dplyr::pull(TNM) %>% table() %>% as.data.table() %>% arrange(desc(N)) %>% view 
    dplyr::filter( FORMAT == "TNM") %>%
    dplyr::mutate( T_arvo = str_extract( TNM , "T[^N]*" ) ,
                   N_arvo = str_extract( TNM , "N[^M]*" ) ,
                   M_arvo = str_extract( TNM , "M.*"    ) ) -> tnm_2 # %>% View
  
  tnm_2$FROM %>% table
  colnames(tekstit)
  
  merge(tnm_2 %>% dplyr::filter( "text_mine.v_teksti" == FROM) , tekstit %>% dplyr::select(TEKSTI,POTILASKERTOMUS_NUMERO), by.x="ID", by.y = "POTILASKERTOMUS_NUMERO" ) -> tnm_teksti
  
  tnm_teksti %>% 
    dplyr::mutate( LAUSE = str_split(TEKSTI,"(?<=[[:punct:]])\\s(?=[A-Z])") ) %>% head() %>%
    tidyr::unnest( LAUSE ) %>%
    dplyr::filter( str_detect(LAUSE,TNM) ) %>% View
  
  tnm_teksti %>%
    dplyr::mutate()
  
  tnm_teksti %>% 
    dplyr::mutate( TNM_LAUSE = str_extract(paste0(".{0,120}","T1N0M0",".{0,100}"),TEKSTI))
    
    dplyr::mutate( T_arvo_2 = str_extract( TNM , "T.*(?=N)" ) ,
                   N_arvo_2 = str_extract( TNM , "N.*(?=M)" ) ,
                   M_arvo_2 = str_extract( TNM , "M.*" )) %>% 
    dplyr::filter( T_arvo != T_arvo_2 | N_arvo != N_arvo_2 | M_arvo != M_arvo_2)
  View
  
    dplyr::mutate( T_arvo = str_extract( TNM , "T[01234]{0,1}[abAB]{0,1}" ) ,
                   N_arvo = str_extract( TNM , "N[01234]{0,1}[abAB]{0,1}" ) ,
                   M_arvo = str_extract( TNM , "M[01234]{0,1}[abAB]{0,1}" )) %>% View

}
##
#
