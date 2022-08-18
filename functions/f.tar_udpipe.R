




f.tar_udpipe <- function(x,
                         language = "german-hdt",
                         model_dir = "temp",
                         cores = parallel::detectCores()-1){


    
    model <- udpipe_download_model(language = language,
                                   model_dir = model_dir,
                                   overwrite = FALSE)


    annotated <- udpipe(x = x,
                        object = model,
                        parallel.cores = cores)
    

    return(annotated)


    
}
