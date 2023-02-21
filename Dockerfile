FROM rocker/tidyverse:4.2.2

WORKDIR /ce-bverfg

RUN sudo apt-get update

RUN sudo apt-get remove -y rstudio-server

RUN sudo apt-get install -y pandoc pandoc-citeproc texlive-science

RUN sudo apt-get install -y libatlas3-base libopenblas-base libxml2-dev libcurl4-openssl-dev libssl-dev libmagick++-dev libpoppler-cpp-dev libsodium-dev libudunits2-dev libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev

RUN R -q -e 'install.packages(c("future", "future.apply", "targets", "tarchetypes", "RcppTOML", "mgsub", "quanteda", "quanteda.textstats", "quanteda.textplots", "igraph", "ggraph", "kableExtra", "pdftools", "readtext", "udpipe", "renv", "qs"))'

CMD "R"