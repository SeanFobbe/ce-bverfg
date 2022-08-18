



#' Aus HTML gewonnene segmentierte Fassungen der Entscheidungen des BVerfG bereinigen.

#' @param x Data.table. Aus HTML gewonnene segmentierte Fassungen der Entscheidungen des BVerfG.

#' @return Data.table. Bereinigte segmentierte Entscheidungen.





f.clean_segmented <- function(x){



    ## === ECLI korrigieren ===


    x$ecli <- gsub("ECLI:DE:BVerfG:1951:rs19580115.1bvr040051",
                   "ECLI:DE:BVerfG:1958:rs19580115.1bvr040051",
                   x$ecli) ## Lüth

    x$ecli <- gsub("ECLI:DE:BVerfG:2003:rk20030407.2bvr212902",
                   "ECLI:DE:BVerfG:2003:rk20030407.1bvr212902",
                   x$ecli)


    x$ecli <- gsub("ECLI:DE:BVerfG:2007:rk20060529.1bvr043003",
                   "ECLI:DE:BVerfG:2006:rk20060529.1bvr043003",
                   x$ecli)

    
    ## Die folgende ECLI ist auf der Homepage des BVerfG fehlerhaft. Sie betrifft das Vorverfahren statt die Verzögerungsbeschwerde. Auf rechtsprechung-im-internet.de ist sie korrekt nachgewiesen.\footnote{\url{https://www.rechtsprechung-im-internet.de/jportal/?quelle=jlink&docid=KVRE412291501&psml=bsjrsprod.psml&max=true}}

    x$ecli <- gsub("ECLI:DE:BVerfG:2015:rs20151208a.1bvr009911",
                   "ECLI:DE:BVerfG:2015:vb20151208.vz000115",
                   x$ecli)




    
    ## === Entscheidungstyp aus Zitiervorschlägen extrahieren ===



    ## Zitiervorschläge parsen
    
    entscheidung_typ <- gsub(".*(Beschluss|Urteil|Verfügung).*",
                             "\\1",
                             x$zitiervorschlag,
                             ignore.case = TRUE)



    ## Kürzen

    lang.etyp <- c("Urteil",
                   "Beschluss",
                   "Verfügung")

    kurz.etyp <- c("U",
                   "B",
                   "V")


    entscheidung_typ <- mgsub::mgsub(entscheidung_typ,
                                          lang.etyp,
                                          kurz.etyp,
                                          ignore.case = TRUE)


    ## Einfügen
    x$entscheidung_typ <- entscheidung_typ


    


    return(x)
    


}
