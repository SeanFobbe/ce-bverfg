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


    ## Create full Aktenzeichen search REGEX, example: "2 BvR 454/71"
    regex.az <- paste0("[12][[:space:]]*", # Senatsnummer 
                       registerzeichen.regex, # Registerzeichen
                       "[[:space:]]*[0-9]{1,5}/", # Eingangsnummer
                       "[0-9]{2}") # Jahr
    
    ## Extract BVerfG citations to Aktenzeichen targets
    target.az <- stringi::stri_extract_all(dt.final$text,
                                        regex = regex.az)
    

    
    ## Create BVerfGE REGEX (single cite: BVerfGE 131, 152; multiples with semicola TBD!
    regex.bverfge <- paste0("BVerfGE[[:space:]]*", # hook
                            "[0-9]{1,3},[[:space:]]", # Band
                            "[0-9]{1,4}") # Seite

    
    ## Extract BVerfG citations to BVerfGE targets
    target.bverfge <- stringi::stri_extract_all(dt.final$text,
                                                regex = regex.bverfge)



    ## Define source Aktenzeichen
    source <- dt.final$aktenzeichen

    
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

    
    ## Combine Tables
    dt <- rbind(dt.az, dt.bverfge)
    
    
    ## Clean whitespace
    dt$source <- gsub("[[:space:]]+", " ", dt$source)
    dt$target <- gsub("[[:space:]]+", " ", dt$target)

    dt$source <- trimws(dt$source)
    dt$target <- trimws(dt$target)


    ## Resolve BVerfGE to Aktenzeichen
    

    ## Remove self-citations    
    dt <- dt[!(dt$source == dt$target)]
    

    ## Create Graph Object
    g  <- igraph::graph_from_data_frame(dt,
                                        directed = TRUE)
    

}



## DEBUGGING Code

## library(stringi)
## library(data.table)                     
## library(igraph)
## dt.final <-  tar_read(dt.bverfg.final)  
## tar_load(az.brd)
