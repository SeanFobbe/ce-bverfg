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
                       "\\s*\\d{1,4}/", # Eingangsnummer
                       "\\d{2}") # Jahr
    
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
                                 "\\d{1,3},\\s*", # Volume
                                 "\\d{1,3}") # Page


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

    ## Remove non-citations
    dt.az <- dt.az[!is.na(target)]
    dt.bverfge <- dt.bverfge[!is.na(target)]

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
    dt$source <- gsub("([A-Z])(\\d)", "\\1 \\2", dt$source)
    dt$target <- gsub("([A-Z])(\\d)", "\\1 \\2", dt$target)

    dt$source <- gsub("(\\d)B", "\\1 B", dt$source)
    dt$target <- gsub("(\\d)B", "\\1 B", dt$target)
    

    ## Remove self-citations    
    dt <- dt[!(dt$source == dt$target)]
    

    ## Create Graph Object
    g  <- igraph::graph_from_data_frame(dt,
                                        directed = TRUE)

    
    ## Convert Parallel Edges to Weights
    igraph::E(g)$weight <- 1
    g <- igraph::simplify(g, edge.attr.comb = list(weight = "sum"))



    return(g)
    

}





## DEBUGGING Code

## library(stringi)
## library(data.table)                     
## library(igraph)
## dt.final <-  tar_read(dt.bverfg.final)  
## tar_load(az.brd)



## ## Create BVerfGE REGEX (single cite: "BVerfGE 131, 152"; multiples with semicola TBD!
## regex.bverfge <- paste0("BVerfGE\\s*", # hook
##                         "\\d{1,3},\\s", # Band
##                         "\\d{1,4}") # Seite


## ## Extract BVerfG citations to BVerfGE targets
## target.bverfge <- stringi::stri_extract_all(dt.final$text,
##                                             regex = regex.bverfge)
