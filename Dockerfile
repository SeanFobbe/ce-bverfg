FROM rocker/r-ver:4.2.2

WORKDIR /ce-bverfg

RUN apt-get update

#RUN sudo apt-get remove -y rstudio-server

RUN apt-get install -y libatlas3-base libopenblas-base libxml2-dev libcurl4-openssl-dev libssl-dev libmagick++-dev libpoppler-cpp-dev libsodium-dev libudunits2-dev libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev

RUN apt-get install -y pandoc pandoc-citeproc texlive-science texlive-latex-extra texlive-lang-german


RUN R -q -e 'install.packages(c("future", "future.apply", "targets", "tarchetypes", "RcppTOML", "mgsub", "quanteda", "quanteda.textstats", "quanteda.textplots", "igraph", "ggraph", "kableExtra", "pdftools", "readtext", "udpipe", "renv", "qs"))'

CMD "R"