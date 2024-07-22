#' f.citation_extraction
#'
#' Extract citations to decisions of the German Constitutional Court (BVerfG) and convert to igraph object.
#'
#' @param dt.final Data.table. The final data set.
#' @return Igraph object. All internal citations as a graph object.




f.citation_extraction_bverfg <- function(dt.final,
                                         az.brd){


    ## Combine Registerzeichen into REGEX
    registerzeichen <- az.brd[stelle == "BVerfG"]$zeichen_original
    registerzeichen.regex <- paste0(registerzeichen, collapse = "|")
    registerzeichen.regex <- paste0("(", registerzeichen.regex, ")")


    ## Create full REGEX, example: "2 BvR 454/71"
    regex <- paste0("[12][[:space:]]*", # Senatsnummer 
                    registerzeichen.regex, # Registerzeichen
                    "[[:space:]]*[0-9]{1,5}/", # Eingangsnummer
                    "[0-9]{2}") # Jahr
    
    ## Extract BVerfG citations to target Aktenzeichen
    target <- stringi::stri_extract_all(dt.final$text,
                                        regex = regex)

    ## Define source Aktenzeichen
    source <- dt.final$aktenzeichen

    ## Bind source and target
    bind <- mapply(cbind, source, target)
    bind2 <- lapply(bind, as.data.table)
    
    dt <- rbindlist(bind2)
    setnames(dt, new = c("source", "target"))
    
    ## Clean whitespace
    dt$source <- gsub("[[:space:]]+", " ", dt$source)
    dt$target <- gsub("[[:space:]]+", " ", dt$target)

    dt$source <- trimws(dt$source)
    dt$target <- trimws(dt$target)



    
    

}



## DEBUGGING Code

## dt.final <-  tar_read(dt.bverfg.final)  
## tar_load(az.brd)
