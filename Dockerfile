FROM rocker/r-ver:4.2.2

WORKDIR /ce-bverfg

#RUN sudo apt-get remove -y rstudio-server # only if tidyverse or verse base images used


# TeX layer
RUN apt-get update && apt-get install -y pandoc pandoc-citeproc texlive-science texlive-latex-extra texlive-lang-german


# System dependency layer

COPY requirements-system.txt .
RUN apt-get update && apt-get -y install $(cat requirements-system.txt)

#RUN apt-get update && apt-get install -y libatlas3-base libopenblas-base libxml2-dev libcurl4-openssl-dev libssl-dev libmagick++-dev libpoppler-cpp-dev libsodium-dev libudunits2-dev libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev libglpk-dev pip python3 tesseract-ocr tesseract-ocr-deu

# Python layer
COPY requirements-python.txt .
RUN pip install -r requirements-python.txt

# R layer
COPY requirements.R .
RUN Rscript requirements.R

CMD "R"
