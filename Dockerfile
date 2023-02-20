FROM rocker/verse:4.2.2

WORKDIR /ce-bverfg

RUN sudo apt-get update

RUN sudo apt-get remove -y rstudio-server

RUN sudo apt-get install pandoc

RUN R -q -e 'install.packages(c("future", "future.apply", "targets", "tarchetypes", "RcppTOML", "mgsub", "quanteda", "quanteda.textstats", "quanteda.textplots", "igraph", "ggraph", "kableExtra", "pdftools", "readtext", "udpipe"))'

CMD "R"