#' Segmentierten Datensatz finalisieren
#'
#' Der segmentierte Datensatz wird mit dieser Funktion um bereits berechnete Variablen angereichert und in Reihenfolge der Variablen-Dokumentation des Codebooks sortiert.

#' @param dt.segmented Data.table. Die segmentierte Variante des Datensatzes.
#' @param dt.bverfg.intermediate Data.table. Der nach Datum sortierte und im Text bereinigte Hauptdatensatz mit allen zusätzlichen Variablen.
#' @param dt.download.final Data.table. Die Tabelle mit den Informationen zum Download.
#' @param varnames Character. Die im Datensatz erlaubten Variablen, in der im Codebook vorgegebenen Reihenfolge.




f.finalize_segmented <- function(dt.segmented,
                                 dt.bverfg.intermediate,
                                 dt.download.final,
                                 varnames){


    ## Unit Test
    test_that("Argumente entsprechen Erwartungen.", {
        expect_s3_class(dt.segmented, "data.table")
        expect_s3_class(dt.bverfg.intermediate, "data.table")
        expect_s3_class(dt.download.final, "data.table")
        expect_type(varnames, "character")
    })
    
    
    ## Merge Main and Segmented

    dt <- merge(dt.segmented,
                dt.bverfg.intermediate[,!"text"],
                by = "ecli",
                all.x = TRUE,
                sort = FALSE)


    ## Prepare Download Table

    dt.download.final$doc_id <- gsub("\\.pdf",
                                     "\\.txt",
                                     dt.download.final$doc_id)

    index.en <- grep("en.html", dt.download.final$url_html)

    if(length(index.en) != 0){
        dt.download.final <- dt.download.final[-index.en] # remove english docs
    }
    

    ## Merge Download Table
    dt.final <- merge(dt,
                      dt.download.final,
                      by = "doc_id",
                      all.x = TRUE)

    ## Order by Date
    setorder(dt.final,
             datum)


    ## Unit Test: Check variables and set column order
    
    varnames <- gsub("\\\\", "", varnames) # Remove LaTeX escape characters
    data.table::setcolorder(dt.final, varnames)


    ## Unit Test
    test_that("Ergebnis entspricht Erwartungen.", {
        expect_s3_class(dt.final, "data.table")
        expect_equal(dt.final[,.N], dt.segmented[,.N])
        expect_lte(uniqueN(dt.final$doc_id), uniqueN(dt.download.final$doc_id))
        expect_gte(dt.final[,.N], dt.bverfg.intermediate[,.N])
    })

    
    return(dt.final)
    
}


