#' f.citation_extraction
#'
#' Extract citations to decisions of the German Constitutional Court (BVerfG) and convert to igraph object.
#'
#' @param dt.final Data.table. The final data set.
#' @return Igraph object. All internal citations as a graph object.




f.citation_extraction_bverfg <- function(dt.final,
                                         az.brd){



    ## Extract outgoing BVerfG citations, example: "2 BvR 454/71"

    registerzeichen <- az.brd[stelle == "BVerfG"]$zeichen_original
    registerzeichen.regex <- paste0(registerzeichen, collapse = "|")
    registerzeichen.regex <- paste0("(", registerzeichen.regex, ")")
    
    regex <- paste0("[1-2][[:space:]]", # Senatsnummer 
                    registerzeichen.regex, # Registerzeichen
                    "[[:space:]][0-9]{1,5}/", # Eingangsnummer
                    "[0-9]{2}") # Jahr
    
    
    target <- stringi::stri_extract_all(dt.final$text,
                                        regex = regex)



    }



## DEBUGGING Code

## dt.final <-  tar_read(dt.bverfg.final)  
## tar_load(az.brd)
