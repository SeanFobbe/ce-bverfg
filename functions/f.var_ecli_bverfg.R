#' Experimentelle Erstellung von ECLIs für Entscheidungen des Bundesverfassungsgerichts.


#' Struktur und Inhalt der ECLI für deutsche Gerichte sind auf dem Europäischen Justizportal näher erläutert: https://e-justice.europa.eu/content_european_case_law_identifier_ecli-175-de-de.do?member=1



#' @param x Data.table. Ein BVerfG-Datensatz mit den Variablen "datum", "spruchkoerper_typ", "spruchkoerper_az", "registerzeichen", "eingangsnummer", "eingangsjahr_az"  und "kollision".


#' @param return Ein Vektor mit ECLIs für das Bundesverfassungsgericht.






f.var_ecli_bverfg <- function(x){


    ## Unit Test
    test_that("Argumente entsprechen Erwartungen.", {
        expect_s3_class(x, "data.table")
    })
    

    ## ECLI-Ordinalzahl erstellen

    ecli.ordinalzahl <- paste0(gsub("Bv([A-Z])",
                                    "\\1",
                                    x$registerzeichen),
                               x$spruchkoerper_typ,
                               x$datum,
                               x$kollision,
                               ".",
                               x$spruchkoerper_az,
                               x$registerzeichen,
                               formatC(x$eingangsnummer,
                                       width = 4,
                                       flag = "0"),
                               formatC(x$eingangsjahr_az,
                                       width = 2,
                                       flag = "0"))

    ecli.ordinalzahl <- gsub("NA",
                             "",
                             ecli.ordinalzahl)

    ecli.ordinalzahl <- gsub("-",
                             "",
                             ecli.ordinalzahl)


    ecli.ordinalzahl <- tolower(ecli.ordinalzahl)

    ecli.ordinalzahl <- gsub("vzb",
                             "vb",
                             ecli.ordinalzahl)

    ecli.ordinalzahl <- gsub("pup",
                             "up",
                             ecli.ordinalzahl)



    ## Vollständige ECLI erstellen

    ecli <- paste0("ECLI:DE:BVerfG:",
                   x$entscheidungsjahr,
                   ":",
                   ecli.ordinalzahl)



    
    ## REGEX-Validierung: Gesamte ECLI

    regex.test <- grep(paste0("ECLI:DE:BVerfG", # Präambel
                              ":[0-9]{4}:", # Entscheidungsjahr
                              "[a-z]{2}", # Spruchkörper                              
                              "[0-9]{8}", # Datum
                              "[a-z]*", # ggf. Kollision
                              "\\.",
                              "[0-9]", # Senatsnummer
                              "p?bv[a-z]", # Registerzeichen
                              "[0-9]{4}", # Eingangsnummer
                              "[0-9]{2}" # Eingangsjahr 
                              ),
                       ecli,
                       value = TRUE,
                       invert = TRUE)


    ## Fehlerhafte ECLI

    if(length(regex.test) != 0){
        warning("Fehlerhafte ECLI:")
        warning(regex.test)
    }

    ## Unit Test
    test_that("ECLI entsprechen Erwartungen.", {
        expect_type(ecli, "character")
        expect_length(regex.test,  0)
        expect_length(ecli, nrow(x))
    })
    

    
    return(ecli)


}

