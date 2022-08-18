


#' Aus HTML gewonnene Metadaten zu Entscheidungen des BVerfG bereinigen.

#' @param x Data.table. Rohe Metadaten aus Entscheidungen des BVerfG im HTML-Format.

#' @return Data.table. Bereinigte Metadaten.





f.clean_meta <- function(x){

    

    ## === ECLI korrigieren ===
    
    ## Metadaten mit ECLI-Duplikaten entfernen: Für eine Entscheidung wird versehentlich auch die englischsprachige Zusammenfassung abgerufen, diese wird hier entfernt.

    x <- x[grep("Order",
                x$zitiervorschlag,
                invert = TRUE)]


    ## Fehlerhafte ECLI korrigieren (HTML Meta)


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


    entscheidung_typ.main <- mgsub::mgsub(entscheidung_typ.main,
                                          lang.etyp,
                                          kurz.etyp,
                                          ignore.case = TRUE)


    ## Einfügen
    txt.bverfg$entscheidung_typ <- entscheidung_typ


    


    return(x)

    

}
