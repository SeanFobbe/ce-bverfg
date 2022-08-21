

#' Tabelle aller URLs zu Entscheidungen des Bundesverfassungsgerichts erstellen (PDF und HTML).


#' @param debug.toggle Logical. Ob der Debugging-Modus aktiviert werden soll.
#' @param debug.pages Integer. Die Anzahl Datenbankseiten, die ausgewertet werden soll. Jede Seite enthält idR 10 Entscheidungen.


#' @return Data.table. Eine Tabelle mit URLs zu Entscheidungen des Bundesverfassungsgerichts erstellen (PDF und HTML).





f.download_table_make <- function(debug.toggle = FALSE,
                                  debug.pages = 50){




    ## Maximale Seitenzahl auslesen

    temp <- f.linkextract("https://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?language_=de")

    temp1 <- grep("list.*253D([0-9]+).*",
                  temp,
                  value = TRUE)

    temp2 <- gsub(".*253D([0-9]+).*",
                  "\\1",
                  temp1)


    ## Auszuwertende Seiten
    
    maxpage <- max(as.numeric(temp2))
    pages <- seq_len(maxpage)



    ## [Debugging Modus] Reduzierung der Seitenzahl

    if (debug.toggle == TRUE){
        pages <- sort(sample(pages,
                             debug.pages))
    }



    
    ## === Linkliste erstellen: Erstversuch ===

    breaks <- sort(sample(pages, 10))


    indices <- seq_along(pages)

    links.list <- vector("list",
                         length(indices))


    for (i in indices){

        URL  <- paste0("https://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?gtp=5403124_list%253D",
                       pages[i],
                       "&language_=de")
        
        volatile <- f.linkextract(URL)
        
        links.l1 <- grep ("SharedDocs/Entscheidungen",
                          volatile,
                          ignore.case = TRUE,
                          value = TRUE)

        links.list[[i]] <- links.l1
        
        Sys.sleep(runif(1, 0.8, 2))
        
        if (i %in% breaks) Sys.sleep(runif(1, 2, 7))
        
    }


    Sys.sleep(runif(1, 20, 40))




    ##=== Linkliste erstellen: Zweitversuch ===

    ## Jede Seite der Datenbank sollte im Idealfall 10 Entscheidungen enthalten. Alle Seiten, die diese Bedingung nicht erfüllen werden noch einmal geprüft. Die letzte Seite enthält fast immer weniger als 10 Entscheidungen, wird sicherheitshalber aber trotzdem geprüft, statt sie auszusortieren. Dabei entstehende Duplikate werden später durch unique() entfernt.

    retry.pages <- which(unlist(lapply(links.list,
                                       function(x)length(x)<10)))

    retry.indices <- seq_along(retry.pages)

    retry.links.list <- vector("list",
                               length(retry.pages))



    for (i in retry.indices){

        URL  <- paste0("https://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?gtp=5403124_list%253D",
                       retry.pages[i],
                       "&language_=de")
        
        volatile <- f.linkextract(URL)
        
        links.l1 <- grep ("SharedDocs/Entscheidungen",
                          volatile,
                          ignore.case = TRUE,
                          value = TRUE)

        retry.links.list[[i]] <- links.l1
        
        Sys.sleep(runif(1, 0.8, 2))
        
    }




    ## Listen aus Erstversuch und Zweitversuch zusammenfügen

    links.relative <- c(unlist(links.list),
                        unlist(retry.links.list))



    ## Bereinigte HTML-Links definieren

    links.raw <- paste0("https://www.bundesverfassungsgericht.de/",
                        links.relative)

    links.html <- gsub("(.+\\.html).*",
                       "\\1",
                       links.raw)

    links.html <- unique(links.html)



    

    ## Bereinigte PDF-Links definieren

    links.pdf <- gsub("Entscheidungen",
                      "Downloads",
                      links.html)

    links.pdf <- gsub("\\.html.*",
                      "\\.pdf\\?__blob=publicationFile\\&v\\=1",
                      links.pdf)


    links.pdf <- unique(links.pdf)


    

    
    ## Return Value erstellen

    dt.final <- data.table(url_pdf = links.pdf,
                           url_html = links.html)


    ## Remove english docs
    index.en <- grep("en.html", dt.final$url_html)

    if(length(index.en) != 0){
    dt.final <- dt.final[-index.en]
    }
    
    return(dt.final)


}
