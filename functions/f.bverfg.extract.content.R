#'# f.bverfg.extract.content
#' Diese Funktion extrahiert relevante Teile des Entscheidungstextes aus einer auf einer HTML-Seite dargestellten Entscheidung auf www.bundesverfassungsgericht.de 

f.bverfg.extract.content <- function(HTML){

    ## Leitsätze
    leitsaetze <- unique(html_elements(HTML, ".ls") %>% html_text(trim = TRUE))

    if (length(leitsaetze) != 0){
        segment <- paste0("leitsatz-",
                          1:length(leitsaetze))

        dt.leitsaetze <- data.table(leitsaetze,
                                    segment)
        
    }else{
        dt.leitsaetze <- data.table("NA",
                                    "NA")
        
    }


    ## Gegenstand 
    gegenstand <- html_elements(HTML, ".vgt3") %>% html_text(trim = TRUE)

    if (length(gegenstand) == 0){
        gegenstand <- html_elements(HTML, ".vg1") %>% html_text(trim = TRUE)
        }

    if (length(gegenstand) != 0){
    
    segment <- paste0("gegenstand-",
                      1:length(gegenstand))

    dt.gegenstand <- data.table(gegenstand,
                                segment)

    }else{
        dt.gegenstand <- data.table("NA",
                                    "NA")
        
    }



    ## Formel
    formel <- paste(html_elements(HTML, "[class='bf']") %>% html_text(trim = TRUE),
                    collapse = " ")

    if (length(formel) != 0){
        
        segment <- "formel"

        dt.formel <- data.table(formel,
                                segment)

    }else{
        dt.formel <- data.table("NA",
                                "NA")
        
    }

    ## Tenor
    tenor <- html_elements(HTML, "ol .bs, .hr") %>% html_text(trim = TRUE) # Mehrere Tenorpunkte

    if (length(tenor) == 0){
    
        tenor <- html_elements(HTML, ".bs, .hr") %>% html_text(trim = TRUE) # Ein Tenorpunkt

    }


    if (length(tenor) != 0){
        segment <- paste0("tenor-",
                          1:length(tenor))

        dt.tenor <-  data.table(tenor,
                                segment)

    }else{
        dt.tenor <- data.table("NA",
                               "NA")
        
    }

    

    ## Gründe der Entscheidung
    gruende.nodes <- html_elements(HTML, ".std, .lszb")

    if (length(gruende.nodes) != 0){
        
        if(html_attr(gruende.nodes, "class")[1] == "lszb"){

            ## Entferne Leitsatzüberschriften
            gruende.classes <- html_attr(gruende.nodes, "class")
            ueberschrift.indizes <- grep("lszb", gruende.classes[1:5])
            
            gruende.nodes <- gruende.nodes[-ueberschrift.indizes]
        }

        inhaltsverzeichnis.indizes <- grep("inhvz", html_attr(gruende.nodes, "class"))

        if (length(inhaltsverzeichnis.indizes) > 0){
            gruende.nodes <- gruende.nodes[-inhaltsverzeichnis.indizes] # Entferne Inhaltsverzeichnis
        }


        etstd.indizes <- grep("et std", html_attr(gruende.nodes, "class"))

        if (length(etstd.indizes) > 0){

            gruende.nodes <- gruende.nodes[-etstd.indizes] # Entferne Langzitate
            
        }

        etzstd.indizes <- grep("(etz std)|(std etz)", html_attr(gruende.nodes, "class"))

        if (length(etzstd.indizes) > 0){

            gruende.nodes <- gruende.nodes[-etzstd.indizes] # Entferne Langzitatüberschriften
            
        }


        
        abw.vorhanden <- "lszb" %in% html_attr(gruende.nodes, "class")
        
        if (abw.vorhanden == TRUE){

            gruende.classes <- html_attr(gruende.nodes, "class")
            
            abw.logical <- gruende.classes %in% "lszb"
            
            abw.pos.all <- which(abw.logical)
            abw.pos.first <- abw.pos.all[1]

            gruende.nodes <- gruende.nodes[-abw.pos.all] # Entferne Abw-Meinung-Überschriften
            
        }
        
        gruende <- html_text(gruende.nodes,
                             trim = TRUE)

        segment <- paste0("gruende-",
                          1:length(gruende))

        if (abw.vorhanden == TRUE){

            abw.indizes <- abw.pos.first:length(segment)
            segment[abw.indizes] <- paste0(segment[abw.indizes],
                                           "-sondervotum")
        }
        

        dt.gruende <- data.table(gruende,
                                 segment)

    }else{
        dt.gruende <- data.table("NA",
                                 "NA")
    }


    ## Unterschriften
    unterschriften <- paste(html_elements(HTML, "[class='st']") %>% html_elements("td") %>%  html_text(trim = TRUE),
                            collapse = " ")

    segment <- "unterschriften"
    dt.unterschriften <- data.table(unterschriften,
                                    segment)

    ## Segmentierter Inhalt

    inhalt <- rbind(dt.leitsaetze,
                    dt.gegenstand,
                    dt.formel,
                    dt.tenor,
                    dt.gruende,
                    dt.unterschriften,
                    use.names = FALSE)

    setnames(inhalt,
             new = c("text",
                     "segment"))

    inhalt <- inhalt[grep("NA", inhalt$segment, invert = TRUE)]


    inhalt[, text := lapply(.(text), f.remove.specialunderline)]


    return(inhalt)

}
