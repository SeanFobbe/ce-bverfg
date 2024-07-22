#' f.citation_extraction
#'
#' Extract citations to decisions of the German Constitutional Court (BVerfG) and convert to igraph object.
#'
#' @param dt.final Data.table. The final data set.
#' @return Igraph object. All internal citations as a graph object.


# Draws and expands Coupette, Juristische Netzwerkforschung (Mohr Siebeck 2019), 241-244


#' TODO:
#' - Distinguish decisions by date
#' - extract Vz decisions


#' Example citation blocks BVerfGE
#' 
#' - "BVerfGE 79, 240 <243>; 149, 1 <10 Rn. 21>; 157, 223 <250 Rn. 70>),"
#' - "(vgl. BVerfGE 152, 345 <371 Rn. 65 f.> m.w.N.)"



f.citation_extraction_bverfg <- function(dt.final,
                                         az.brd){


    ## Combine Registerzeichen into REGEX
    registerzeichen <- az.brd[stelle == "BVerfG"]$zeichen_original
    registerzeichen.regex <- paste0(registerzeichen, collapse = "|")
    registerzeichen.regex <- paste0("(", registerzeichen.regex, ")")


    ## Create full Aktenzeichen search REGEX, example: "2 BvR 454/71"
    regex.az <- paste0("[12]\\s*", # Senatsnummer 
                       registerzeichen.regex, # Registerzeichen
                       "\\s*[0-9]{1,5}/", # Eingangsnummer
                       "[0-9]{2}") # Jahr
    
    ## Extract BVerfG citations to Aktenzeichen targets
    target.az <- stringi::stri_extract_all(dt.final$text,
                                        regex = regex.az)
    

    ## Extract BVerfGE citation blocks
    regex.bverfge.blocks <- "BVerfGE[\\s\\d;,\\.<>Rnf-]+"
    
    target.bverfge.blocks.list <- stringi::stri_extract_all(dt.final$text,
                                                            regex = regex.bverfge.blocks)
    
    target.bverfge.blocks <- lapply(target.bverfge.blocks.list, paste0, collapse = " ")

    ## Extract individual BVerfGE citations from blocks
    regex.bverfge.cite <- paste0("(BVerfGE|;)\\s*", # hooks
                                 "[0-9]{1,3},\\s*", # Volume
                                 "[0-9]{1,3}") # Page


    target.bverfge <- stringi::stri_extract_all(target.bverfge.blocks,
                                                regex = regex.bverfge.cite)

    
    ## Define source Aktenzeichen
    source <- ifelse(is.na(dt.final$band),
                     dt.final$aktenzeichen,
                     paste0("BVerfGE ", dt.final$band, ", ", dt.final$seite))

        

    
    ## Combine source Aktenzeichen and target Aktenzeichen
    bind <- mapply(cbind, source, target.az)
    bind <- lapply(bind, as.data.table)
    dt.az <- rbindlist(bind)
    setnames(dt.az, new = c("source", "target"))


    ## Combine source Aktenzeichen and target BVerfGE
    bind <- mapply(cbind, source, target.bverfge)
    bind <- lapply(bind, as.data.table)
    dt.bverfge <- rbindlist(bind)
    setnames(dt.bverfge, new = c("source", "target"))

    ## Clean BVerfGE hooks
    dt.bverfge$target <-  gsub(";", "BVerfGE", dt.bverfge$target)
    
    ## Combine Tables
    dt <- rbind(dt.az, dt.bverfge)    
    
    ## Clean whitespace
    dt$source <- gsub("\\s+", " ", dt$source)
    dt$target <- gsub("\\s+", " ", dt$target)

    dt$source <- trimws(dt$source)
    dt$target <- trimws(dt$target)

    ## Add whitespace if missing; example "1 BvL100/58"
    dt$source <- gsub("([A-Z])([0-9])", "\\1 \\2", dt$source)
    dt$target <- gsub("([A-Z])([0-9])", "\\1 \\2", dt$target)

    
    ## Resolve BVerfGE to Aktenzeichen
    

    ## Remove self-citations    
    dt <- dt[!(dt$source == dt$target)]
    

    ## Create Graph Object
    g  <- igraph::graph_from_data_frame(dt,
                                        directed = TRUE)
    

}




test3.na <- is.na(test3)

test[test3.na]

test[unlist(!is.na(test))]

length(test)

length(test2)

test2 <- lapply(test, gsub, pattern = "\\d{1,3}\\s*\\d{1,3}\\s*<.+?>", replacement = "")

test2[8193]

length(unlist(test))



regex.test <- paste0(regex.bverfge,
                     "\\s*;\\s*[0-9]{1,3},\\s*[0-9]{1,4}")

test <- stringi::stri_extract_all(dt.final$text,
                                  regex = regex.test)




## DEBUGGING Code

## library(stringi)
## library(data.table)                     
## library(igraph)
## dt.final <-  tar_read(dt.bverfg.final)  
## tar_load(az.brd)



## ## Create BVerfGE REGEX (single cite: "BVerfGE 131, 152"; multiples with semicola TBD!
## regex.bverfge <- paste0("BVerfGE\\s*", # hook
##                         "[0-9]{1,3},\\s", # Band
##                         "[0-9]{1,4}") # Seite


## ## Extract BVerfG citations to BVerfGE targets
## target.bverfge <- stringi::stri_extract_all(dt.final$text,
##                                             regex = regex.bverfge)
