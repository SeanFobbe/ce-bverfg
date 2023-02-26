#' f.download_finalize
#'
#' Finalize download table and check for duplicate filenames
#'
#' @param dt.download Data.table. Original download table
#' @param filenames.final String. Corrected filenames.
#'
#' @return Data.table. Finalized download table.





f.download_finalize <- function(dt.download,
                                filenames.final){


    ## Unit Test
    test_that("Argumente entsprechen Erwartungen.", {
        expect_s3_class(dt.download, "data.table")
        expect_type(filenames.final, "character")
    })

    
    dt <- data.table(dt.download,
                     doc_id = filenames.final)


    ## Doppelten/fehlerhaften Link entfernen
    dt.return <- dt[url_html != "https://www.bundesverfassungsgericht.de/SharedDocs/Entscheidungen/DE/2017/09/rk20170724_2bvr148717.html"]


    
    ## Unit Test
    test_that("Ergebnis entspricht Erwartungen.", {
        expect_s3_class(dt.return, "data.table")
        expect_setequal(FALSE, duplicated(dt.return$doc_id))        
        expect_gte(dt.download[,.N], dt.return[,.N])
    })
    


    return(dt.return)
    



}



