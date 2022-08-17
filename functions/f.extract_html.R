





f.parse_html_bverfg <- function(html){



    ## HTML-Dateien einlesen

    html.list <- lapply(html,
                        rvest::read_html)


    ## HTML-Dateien parsen

    meta.list <- lapply(html.list,
                        f.bverfg.extract.meta)

    content.list <- lapply(html.list,
                           f.bverfg.extract.content)

    segmented.full.list <- vector("list",
                                  length(meta.list))

    for (i in 1:length(meta.list)){
        
        content.rows <- content.list[[i]][,.N]
        
        meta.replicate <- meta.list[[i]][rep(1, content.rows)]
        
        segmented.full.list[[i]] <- cbind(content.list[[i]],
                                          meta.replicate)

    }


    ## Data Table mit allen Metadaten (inkl. ECLI)
    dt.meta.html <-  rbindlist(meta.list)


    ## Data Table mit vollständiger segmentierter Variante
    dt.segmented.full <- rbindlist(segmented.full.list)


    ## Return Value erstellen
    out.list <- list(dt.meta.html = dt.meta.html,
                     dt.segmented.full = dt.segmented.full)


    return(out.list)




}
