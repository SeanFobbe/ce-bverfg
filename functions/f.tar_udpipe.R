

#' @param x Data.frame. Must contain variables "doc_id" and "text.
#' @param language Character. The language model to use for udpipe.
#' @param model_dir Character. The directory to store the model in.
#' @param cores Character. The number of cores to use for parallel processing. Defaults to max threads minus 1.




f.tar_udpipe <- function(x,
                         language = "german-hdt",
                         model_dir = "temp",
                         cores = parallel::detectCores()-1){


    
    model <- udpipe::udpipe_download_model(language = language,
                                           model_dir = model_dir,
                                           overwrite = FALSE)


    annotated <- udpipe::udpipe(x = x,
                                object = model,
                                parallel.cores = cores)

    annotated$sentence <- NULL
    

    return(annotated)


    
}
