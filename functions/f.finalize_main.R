#' Hauptdatensatz finalisieren
#'
#' Der Hauptdatensatz wird mit dieser Funktion um bereits berechnete Variablen angereichert und in Reihenfolge der Variablen-Dokumentation des Codebooks sortiert.

#' @param dt.bverfg.intermediate Data.table. Der nach Datum sortierte und im Text bereinigte Hauptdatensatz mit allen zusätzlichen Variablen.
#' @param downlod.table Data.table. Die Tabelle mit den Informationen zum Download. Wird mit dem Hauptdatensatz vereinigt.
#' @param dt.html.meta Data.table. Die aus den HTML-Dateien extrahierten Metadaten
#' @param varnames Character. Die im Datensatz erlaubten Variablen, in der im Codebook vorgegebenen Reihenfolge.




f.finalize_main <- function(dt.bverfg.intermediate,
                            dt.download.final,
                            dt.html.meta,
                            varnames){


    ## Unit Test
    test_that("Argumente entsprechen Erwartungen.", {
        expect_s3_class(dt.bverfg.intermediate, "data.table")
        expect_s3_class(dt.download.final, "data.table")
        expect_s3_class(dt.html.meta, "data.table")
        expect_type(varnames, "character")
    })
    


    
    ## Merge HTML Metadata

    dt <- merge(dt.bverfg.intermediate,
                dt.html.meta,
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
                      by = "doc_id")

    ## Order by Date
    setorder(dt.final,
             datum)


    ## Unit Test: Check variables and set column order
    
    varnames <- gsub("\\\\", "", varnames) # Remove LaTeX escape characters
    varnames <- varnames[!varnames == "segment"]
    data.table::setcolorder(dt.final, varnames)


    ## Unit Test
    test_that("Ergebnis entspricht Erwartungen.", {
        expect_s3_class(dt.final, "data.table")
        expect_equal(dt.final[,.N], dt.bverfg.intermediate[,.N])
        expect_lte(dt.final[,.N], dt.html.meta[,.N])
        expect_lte(dt.final[,.N], dt.download.final[,.N])
    })

    
    return(dt.final)
    
}



## DEBUGGING


## library(data.table)
## library(testthat)
## tar_load(dt.bverfg.intermediate)
## tar_load(dt.download.final)
## tar_load(dt.html.meta)
## varnames  <-  tar_read(dt.var_codebook)$varname


## setdiff(dt.bverfg.intermediate$ecli, dt.html.meta$ecli)


## uniqueN(dt.bverfg.intermediate$ecli)
## uniqueN(dt.html.meta$ecli)
