#+
#'## f.remove.specialunderline
#' This function removes a special underline character, possible a non-breaking space.

#+ results = 'hide'
f.remove.specialunderline <- function(text){
    text.out <- gsub(" ",
                     " ",
                     text)
    return(text.out)
}

