#'# f.bverfg.extract.meta 
#' Diese Funktion extrahiert relevante Metadaten aus einer auf einer HTML-Seite dargestellten Entscheidung auf www.bundesverfassungsgericht.de 

f.bverfg.extract.meta <- function(HTML){

    ## ECLI
    ecli <- html_elements(HTML, "[class='ecli']") %>% html_text(trim = TRUE)

    ## Alle Aktenzeichen
    aktenzeichen_alle <- html_elements(HTML, "[class='az2']") %>% html_text(trim = TRUE)
    aktenzeichen_alle <- gsub("-|,|",
                   "",
                   aktenzeichen_alle)
    aktenzeichen_alle <- gsub(" +",
                   " ",
                   aktenzeichen_alle)
    aktenzeichen_alle <- tstrsplit(aktenzeichen_alle,
                               split = "\n")
    aktenzeichen_alle <- unlist(aktenzeichen_alle)
    aktenzeichen_alle <- na.omit(aktenzeichen_alle)
    aktenzeichen_alle <- trimws(aktenzeichen_alle)
    aktenzeichen_alle <- unique(aktenzeichen_alle)
    aktenzeichen_alle <- paste(aktenzeichen_alle, collapse = "|")

    ## Pressemitteilungen
    pressemitteilung <- html_elements(HTML, "[class='pm']") %>% html_text(trim = TRUE)

    if(length(pressemitteilung) == 0){
        pressemitteilung <-  "NA"
    }else{
        pressemitteilung <- pressemitteilung[1]
    }

    ## Kurzbeschreibung
    kurzbeschreibung <- HTML %>% html_elements("title") %>% html_text(trim = TRUE)
    kurzbeschreibung <- gsub(".*Bundesverfassungsgericht.*-.*Entscheidungen.*-(.*)",
                             "\\1",
                             kurzbeschreibung)
    kurzbeschreibung <- trimws(kurzbeschreibung)

    
    ## Verkündung ## hier treten noch Probleme auf
    ##verkuendung <- html_elements(HTML, "[class='vvm2']") %>% html_text(trim = TRUE)

    ##if(length(verkuendung) == 0){
    ##    verkuendung <-  "NA"
    ##}

    
    ## Zitiervorschlag
    zitiervorschlag <- html_elements(HTML, "[class='cite']") %>% html_text(trim = TRUE)

    ## Richter:innen
    richter <- html_elements(HTML, "[class='st']") %>% html_elements("td") %>%  html_text(trim = TRUE)
    richter <- tstrsplit(richter,
                         split = "\n")
    richter <- unlist(richter)
    richter <- na.omit(richter)
    richter <- unique(richter)
    #richter <- richter[grep("ausgeschieden|gehindert|verhindert", richter, invert = TRUE)] # optional Verhinderungen entfernen; Verhinderungen werden zunächst nicht entfernt, da sie durchaus wertvolle Informationen enthalten.
    richter <- paste(richter, collapse = "|")
    richter <- gsub("\\|+",
                    "\\|",
                    richter)
    richter <- gsub("(^\\.*\\|)|(\\|$)",
                    "",
                    richter)
    
    ## Beschwerdeführer (idR anonymisiert, daher nicht aufgenommen)
    ##beschwerdefuehrer <- html_elements(HTML, "[class='vb3']") %>% html_text(trim = TRUE)

    meta <- data.table(ecli,
                       pressemitteilung,
                       aktenzeichen_alle,
                       ##verkuendung,
                       kurzbeschreibung,
                       zitiervorschlag,
                       richter)
    

    return(meta)

}

