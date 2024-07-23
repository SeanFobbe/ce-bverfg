#' f.citation_extraction
#'
#' Extract citations to decisions of the German Constitutional Court (BVerfG) and convert to igraph object.
#'
#' @param dt.final Data.table. The final data set.
#' @return Igraph object. All internal citations as a graph object.


# Draws and expands Coupette, Juristische Netzwerkforschung (Mohr Siebeck 2019), 241-244


#' TODO:
#' - Distinguish decisions by date
#' - Extract Vz decisions
#' - Add metadata


#' Example citation blocks BVerfGE
#' 
#' - "BVerfGE 79, 240 <243>; 149, 1 <10 Rn. 21>; 157, 223 <250 Rn. 70>),"
#' - "(vgl. BVerfGE 152, 345 <371 Rn. 65 f.> m.w.N.)"



f.citation_extraction_bverfg <- function(dt.final){


    ## Create full Aktenzeichen search REGEX, example: "2 BvR 454/71"
    regex.az <- paste0("[12]\\s*", # Senatsnummer 
                       "(AR|Bv[A-Z]|PBv[SUV]|PKH|Vz)", # Registerzeichen
                       "\\s*\\d{1,4}/", # Eingangsnummer
                       "\\d{2}") # Jahr

    
    ## Extract BVerfG citations to Aktenzeichen targets
    target.az <- stringi::stri_extract_all(dt.final$text,
                                        regex = regex.az)
    

    ## Extract BVerfGE citation blocks
    regex.bverfge.blocks <- "BVerfGE[\\s\\d\\[\\];,\\.<>Rnfu-]+"
    
    target.bverfge.blocks <- stringi::stri_extract_all(dt.final$text,
                                                            regex = regex.bverfge.blocks,
                                                            case_insensitive = TRUE)
    
    target.bverfge.blocks <- lapply(target.bverfge.blocks, paste0, collapse = " ")
    target.bverfge.blocks <- lapply(target.bverfge.blocks, # Fix case typos
                                    gsub,
                                    pattern = "BVerfG",
                                    replacement = "BVerfG",
                                    ignore.case = TRUE)

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

    ## Add BVerfGE attribute
    g <- igraph::set_vertex_attr(graph = g,
                                 name = "bverfge",
                                 value = ifelse(grepl("BVerfGE",
                                                      igraph::vertex_attr(g, "name")),
                                                TRUE,
                                                FALSE))
    


    return(g)
    

}





## DEBUGGING Code

## library(stringi)
## library(data.table)                     
## library(igraph)
## dt.final <-  tar_read(dt.bverfg.final)  

