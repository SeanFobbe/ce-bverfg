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




    ## Merge Download Table

    download.table$doc_id <- gsub("\\.pdf",
                                  "\\.txt",
                                  download.table$doc_id)

    dt.final <- merge(dt,
                      download.table,
                      by = "doc_id")

    


    ## Unit Test: Check variables and set column order
    
    varnames <- gsub("\\\\", "", varnames) # Remove LaTeX escape characters
    data.table::setcolorder(dt.final, varnames)


    ## Unit Test
    test_that("Ergebnis entspricht Erwartungen.", {
        expect_s3_class(dt.final, "data.table")
    })

    
    return(dt.final)
    
}
