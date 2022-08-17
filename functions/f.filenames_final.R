






f.filenames_final <- function(filenames.raw,
                              var.bverfge){

    ## Unit Test
    test_that("Argumente entsprechen Erwartungen.", {        
        expect_type(filenames.raw, "character")
        expect_s3_class(var.bverfge, "data.table")
    })
    

    

    ## Variablen für BVerfGE-Entscheidungen einfügen

    var.bverfge$newname <- paste(var.bverfge$oldname,
                                 var.bverfge$name,
                                 var.bverfge$band,
                                 var.bverfge$seite,
                                 sep = "_")

    var.bverfge$newname <- paste0(var.bverfge$newname,
                                  ".pdf")





    targetindices <- match(var.bverfge$oldname,
                           filenames.raw)

    newname <- var.bverfge$newname

    dt <- data.table(targetindices, newname)[complete.cases(targetindices)]



    if(dt[,.N] > 0){
        
        filenames.raw <- replace(filenames.raw,
                                 dt$targetindices,
                                 dt$newname)
    }



    ## NAs einfügen für nicht benannte Entscheidungen

    values <- grep(".pdf",
                   filenames.raw,
                   invert = TRUE,
                   value = TRUE)

    indices <- grep(".pdf",
                    filenames.raw,
                    invert = TRUE)

    filenames.raw[indices] <- paste0(values,
                                     "_NA_NA_NA.pdf")




    ## REGEX-Test
    
    regex.test <- grep(paste0("^BVerfG", # gericht
                              "_",
                              "[0-9]{4}-[0-9]{2}-[0-9]{2}", # datum
                              "_",
                              "[SPKB]", # spruchkoerper_typ
                              "_",
                              "[0-9NA]+", # spruchkoerper_az
                              "_",
                              "[A-Za-z]+", # registerzeichen
                              "_",
                              "[0-9]{4}", # eingangsnummer
                              "_",
                              "[0-9]{2}", # eingangsjahr_az
                              "_",
                              "[0-9a-zNA]+", # kollision
                              "_",
                              "[0-9ÄÜÖäüöA-Za-z\\-]+", # name
                              "_",
                              "[NA0-9]+", # band
                              "_",
                              "[NA0-9]+", # seite
                              "\\.pdf$"), # Dateiendung
                       filenames.raw,
                       value = TRUE,
                       invert = TRUE)



    
    ## Fehlerhafte Dateinamen

    if(length(regex.test) != 0){
        warning("Fehlerhafte finale Dateinamen:")
        warning(regex.test)
        
    }

    ## Unit Test
    test_that("Finale Dateinamen entsprechen Erwartungen.", {
        expect_type(filenames, "character")
        expect_length(regex.test,  0)
        expect_length(filenames, length(url.pdf))
    })

    
    ## Return
    return(filenames)

}
