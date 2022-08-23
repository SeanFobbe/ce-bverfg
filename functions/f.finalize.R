#' Datensatz finalisieren
#'
#' Der Datensatz wird mit dieser Funktion um bereits berechnete Variablen angereichert und in Reihenfolge der Variablen-Dokumentation des Codebooks sortiert.

#' @param x Data.table. Der nach Datum sortierte und im Text bereinigte Datensatz mit allen zusätzlichen Variablen.
#' @param downlod.table Data.table. Die Tabelle mit den Informationen zum Download. Wird mit dem Hauptdatensatz vereinigt.
#' @param html.meta Data.table. Die aus den HTML-Dateien extrahierten Metadaten
#' @param varnames Character. Die im Datensatz erlaubten Variablen, in der im Codebook vorgegebenen Reihenfolge.




f.finalize <- function(x,
                       download.table,
                       html.meta,
                       varnames){


    ## Unit Test
    test_that("Argumente entsprechen Erwartungen.", {
        expect_s3_class(x, "data.table")
        expect_s3_class(download.table, "data.table")
        expect_s3_class(html.meta, "data.table")
        expect_type(varnames, "character")
    })
    


    
    ## Merge HTML Metadata

    dt <- merge(x,
                html.meta,
                by = "ecli",
                all.x = TRUE,
                sort = FALSE)




    ## Prepare Download Table

    download.table$doc_id <- gsub("\\.pdf",
                                  "\\.txt",
                                  download.table$doc_id)

    index.en <- grep("en.html", download.table$url_html)

    if(length(index.en) != 0){
    download.table <- download.table[-index.en] # remove english docs
    }
    

    ## Merge Download Table
    dt.final <- merge(dt,
                      download.table,
                      by = "doc_id")

    


    ## Unit Test: Check variables and set column order
    
    varnames <- gsub("\\\\", "", varnames) # Remove LaTeX escape characters
    varnames <- varnames[!varnames == "segment"]
    data.table::setcolorder(dt.final, varnames)


    ## Unit Test
    test_that("Ergebnis entspricht Erwartungen.", {
        expect_s3_class(dt.final, "data.table")
        expect_equal(dt.final[,.N], x[,.N])
        expect_lte(dt.final[,.N], html.meta[,.N])
        expect_lte(dt.final[,.N], download.table[,.N])
    })

    
    return(dt.final)
    
}
