

#' Vorläufige Dateinamen aus URLs des BVerfG erstellen.


#' @param url.pdf Character. Ein Vektor an URLs zu Entscheidungen des BVerfG im PDF-Format.

#' @return Character. Ein Vektor an bereinigten, vorläufigen Dateinamen.




f.filenames_raw <- function(url.pdf){


    ## Unit Test
    test_that("Argumente entsprechen Erwartungen.", {
        expect_type(url.pdf, "character")
    })

    

    ## Die Links zu jeder Entscheidung enthalten das Ordinalzahl-Element ihres jeweiligen ECLI-Codes. Struktur und Inhalt der ECLI für deutsche Gerichte sind auf dem Europäischen Justizportal näher erläutert. \footnote{\url{https://e-justice.europa.eu/content_european_case_law_identifier_ecli-175-de-de.do?member=1}}

    filenames <- basename(url.pdf)

    filenames <- gsub("[?].*",
                      "",
                      filenames)


    ## Normale Struktur

    filenames <- gsub("[a-z]([a-z])([0-9]{4})([0-9]{2})([0-9]{2})_([0-9])([a-z]*)([0-9]{4})([0-9]{2}).*",
                      "BVerfG_\\2-\\3-\\4_\\1_\\5_\\6_\\7_\\8_NA",
                      filenames)


    ## Struktur von Verzögerungsrügen

    filenames <- gsub("_vz", "NA_Vz", filenames)

    filenames <- gsub("[a-z]([a-z])([0-9]{4})([0-9]{2})([0-9]{2})(NA)_(Vz)([0-9]{4})([0-9]{2}).*",
                      "BVerfG_\\2-\\3-\\4_\\1_\\5_\\6_\\7_\\8_NA",
                      filenames)



    
    ## Struktur von Entscheidungen mit Kollisions-Variable

    filenames <- gsub("[a-z]([a-z])([0-9]{4})([0-9]{2})([0-9]{2})([a-z0-9])_([0-9])([a-z]*)([0-9]{4})([0-9]{2}).*",
                      "BVerfG_\\2-\\3-\\4_\\1_\\6_\\7_\\8_\\9_\\5",
                      filenames)




    ## Formatierung von Registerzeichen anpassen

    filenames <- gsub("_bv([a-z])_",
                      "_Bv\\U\\1_",
                      perl = TRUE,
                      filenames)


    filenames <- gsub("pbvu",
                      "PBvU",
                      filenames)


    ## Formatierung von Spruchkörper-Typ anpassen

    filenames <- gsub("_([kpsb])_",
                      "_\\U\\1_",
                      perl = TRUE,
                      filenames)


    ## REGEX Test

    regex.test <- grep(paste0("BVerfG", # gericht
                              "_",
                              "[0-9]{4}-[0-9]{2}-[0-9]{2}", # datum
                              "_",
                              "[A-Z]", # spruchkoerper_typ 
                              "_",
                              "[0-9NA]+", # spruchkoerper_az
                              "_",
                              "[A-Za-z]+", # registerzeichen
                              "_",
                              "[0-9]{4}", # eingangsnummer
                              "_",
                              "[0-9]{2}", # eingangsjahr
                              "_",
                              "[0-9a-zNA]+$"), # kollision
                       filenames,
                       invert = TRUE,
                       value = TRUE)



    ## Fehlerhafte Dateinamen

    if(length(regex.test) != 0){
        warning("Fehlerhafte rohe Dateinamen:")
        warning(regex.test)
        
    }

    ## Unit Test
    test_that("Rohe Dateinamen entsprechen Erwartungen.", {
        expect_type(filenames, "character")
        expect_length(regex.test,  0)
        expect_length(filenames, length(url.pdf))
    })

    

    

}
