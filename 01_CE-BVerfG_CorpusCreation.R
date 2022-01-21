#'---
#'title: "Compilation Report | Corpus der Entscheidungen des Bundesverfassungsgerichts"
#'author: Seán Fobbe
#'papersize: a4
#'geometry: margin=3cm
#'fontsize: 11pt
#'output:
#'  pdf_document:
#'    toc: true
#'    toc_depth: 3
#'    number_sections: true
#'    pandoc_args: --listings
#'    includes:
#'      in_header: tex/Preamble_DE.tex
#'      before_body: [temp/CE-BVerfG_Definitions.tex, tex/CE-BVerfG_CompilationTitle.tex]
#'bibliography: temp/packages.bib
#'nocite: '@*'
#' ---

#+ echo = FALSE 
knitr::opts_chunk$set(echo = TRUE,
                      warning = TRUE,
                      message = TRUE)



#'\newpage
#+
#'# Einleitung
#'
#+
#'## Überblick
#' Dieses R-Skript lädt alle auf www.bundesverfassungsgericht.de verfügbaren Entscheidungen des Bundesverfassungsgerichts (BVerfG) herunter und verarbeitet sie in einen reichhaltigen menschen- und maschinenlesbaren Korpus. Es ist die Grundlage für den \textbf{\datatitle\ (\datashort )}.
#'
#' Alle mit diesem Skript erstellten Datensätze werden dauerhaft kostenlos und urheberrechtsfrei auf Zenodo, dem wissenschaftlichen Archiv des CERN, veröffentlicht. Alle Versionen sind mit einem persistenten Digital Object Identifier (DOI) versehen. Die neueste Version des Datensatzes ist immer über den Link der Concept DOI erreichbar: \dataconcepturldoi



#+
#'## Funktionsweise

#' Primäre Endprodukte des Skripts (im Ordner 'output') sind folgende ZIP-Archive:
#' 
#' \begin{enumerate}
#' \item Der volle Datensatz im CSV-Format
#' \item Die reinen Metadaten im CSV-Format (wie unter 1, nur ohne Entscheidungstexte)
#' \item (Optional) Tokenisierte Form aller Texte mit linguistischen Annotationen im CSV-Format
#' \item Alle Entscheidungen im TXT-Format (reduzierter Umfang an Metadaten)
#' \item Alle Entscheidungen im PDF-Format (reduzierter Umfang an Metadaten)
#' \item Alle Analyse-Ergebnisse (Tabellen als CSV, Grafiken als PDF und PNG)
#' \item Der Source Code und alle weiteren Quelldaten
#' \end{enumerate}
#'
#' Zusätzlich werden für alle ZIP-Archive kryptographische Signaturen (SHA2-256 und SHA3-512) berechnet und in einer CSV-Datei hinterlegt. Die Analyse-Ergebnisse werden zum Ende hin nicht gelöscht, damit sie für die Codebook-Erstellung verwendet werden können.  Weiterhin kann optional ein PDF-Bericht erstellt werden (siehe unter "Kompilierung").



#+
#'## Kompilierung
#' Mit der Funktion **render()** von **rmarkdown** können der **vollständige Datensatz** und das **Codebook** kompiliert und die Skripte mitsamt ihrer Rechenergebnisse in ein gut lesbares PDF-Format überführt werden.
#'
#' Alle Kommentare sind im roxygen2-Stil gehalten. Die beiden Skripte können daher auch **ohne render()** regulär als R-Skripte ausgeführt werden. Es wird in diesem Fall kein PDF-Bericht erstellt und Diagramme werden nicht abgespeichert.
#' 
#' Um den **vollständigen Datensatz** zu kompilieren, sowie Compilation Report und Codebook zu erstellen, kopieren Sie bitte alle im Source-Archiv bereitgestellten Dateien in einen leeren Ordner und führen mit R diesen Befehl aus:

#+ eval = FALSE

source("00_CE-BVerfG_FullCompile.R")

#+
#'## Systemanforderungen
#' Das Skript in seiner veröffentlichten Form kann nur unter Linux ausgeführt werden, da es Linux-spezifische Optimierungen (z.B. Fork Cluster) und Shell-Kommandos (z.B. OpenSSL) nutzt. Das Skript wurde unter Fedora Linux entwickelt und getestet. Die zur Kompilierung benutzte Version entnehmen Sie bitte dem **sessionInfo()**-Ausdruck am Ende dieses Berichts.
#'
#' In der Standard-Einstellung wird das Skript vollautomatisch die maximale Anzahl an Rechenkernen/Threads auf dem System zu nutzen. Wenn die Anzahl Threads (Variable "fullCores") auf 1 gesetzt wird, ist die Parallelisierung deaktiviert.
#'
#' Auf der Festplatte sollten 8 GB Speicherplatz vorhanden sein.
#' 
#' Um die PDF-Berichte kompilieren zu können benötigen Sie das R package **rmarkdown**, eine vollständige Installation von \LaTeX\ und alle in der Präambel-TEX-Datei angegebenen \LaTeX\ Packages.







#'# Vorbereitung

#'## Datumsstempel
#' Dieser Datumsstempel wird in alle Dateinamen eingefügt. Er wird am Anfang des Skripts gesetzt, für den den Fall, dass die Laufzeit die Datumsbarriere durchbricht.

datestamp <- Sys.Date()
print(datestamp)


#'## Datum und Uhrzeit (Beginn)
begin.script <- Sys.time()
print(begin.script)





#+
#'## Packages Laden

library(RcppTOML)     # Verarbeitung von TOML-Format
library(mgsub)        # Mehrfache simultane String-Substitutions
library(httr)         # HTTP-Werkzeuge
library(rvest)        # HTML/XML-Extraktion
library(knitr)        # Professionelles Reporting
library(kableExtra)   # Verbesserte Kable Tabellen
library(pdftools)     # Verarbeitung von PDF-Dateien
#library(doParallel)   # Parallelisierung; to be deprecated
library(ggplot2)      # Fortgeschrittene Datenvisualisierung
library(scales)       # Skalierung von Diagrammen
library(data.table)   # Fortgeschrittene Datenverarbeitung
library(readtext)     # TXT-Dateien einlesen
library(quanteda)     # Fortgeschrittene Computerlinguistik
library(spacyr)       # Linguistische Annotationen
library(future)       # Parallelisierung mit Futures
library(future.apply) # Apply-Funtionen für Futures



#'## Zusätzliche Funktionen einlesen
#' **Hinweis:** Die hieraus verwendeten Funktionen werden jeweils vor der ersten Benutzung in vollem Umfang angezeigt um den Lesefluss zu verbessern.

source("functions/f.bverfg.extract.content.R")
source("functions/f.bverfg.extract.meta.R")

source("R-fobbe-proto-package/f.remove.specialunderline.R")
source("R-fobbe-proto-package/f.linkextract.R")

source("R-fobbe-proto-package/f.hyphen.remove.R")
source("R-fobbe-proto-package/f.year.iso.R")
source("R-fobbe-proto-package/f.fast.freqtable.R")

#source("R-fobbe-proto-package/f.lingsummarize.iterator.R") # to be deprecated
#source("R-fobbe-proto-package/f.dopar.spacyparse.R") # to be deprecated
#source("R-fobbe-proto-package/f.dopar.multihashes.R") # to be deprecated
#source("R-fobbe-proto-package/f.dopar.pdfextract.R") # to be deprecated

source("R-fobbe-proto-package/f.future_lingsummarize.R")
source("R-fobbe-proto-package/f.future_multihashes.R")
source("R-fobbe-proto-package/f.future_pdf_to_txt.R")


#source("General_Source_Functions.R") # deprecated



#'## Verzeichnis für Analyse-Ergebnisse und Diagramme definieren

dir.analysis <- paste0(getwd(),
                    "/analyse") 


#'## Weitere Verzeichnisse definieren

dirs <- c("output",
          "temp")



#'## Dateien aus vorherigen Runs bereinigen

unlink(dir.analysis,
       recursive = TRUE)

unlink(dirs,
       recursive = TRUE)

files.delete <- list.files(pattern = "\\.zip|\\.pdf|\\.txt|\\.html",
                           ignore.case = TRUE)

unlink(files.delete)




#'## Verzeichnisse anlegen

dir.create(dir.analysis)

lapply(dirs, dir.create)




#'## Vollzitate statistischer Software schreiben
knitr::write_bib(c(.packages()),
                 "temp/packages.bib")





#'## Allgemeine Konfiguration

#+
#'### Konfiguration einlesen
config <- parseTOML("CE-BVerfG_Config.toml")

#'### Konfiguration anzeigen
print(config)



#+
#'### Knitr Optionen setzen
knitr::opts_chunk$set(fig.path = paste0(dir.analysis, "/"),
                      dev = config$fig$format,
                      dpi = config$fig$dpi,
                      fig.align = config$fig$align)


#'### Download Timeout setzen
options(timeout = config$download$timeout)



#'### Quellenangabe für Diagramme definieren

caption <- paste("Fobbe | DOI:",
                 config$doi$data$version)
print(caption)


#'### Präfix für Dateien definieren

prefix.files <- paste0(config$project$shortname,
                 "_",
                 datestamp)
print(prefix.files)


#'### Präfix für Diagramme definieren

prefix.figuretitle <- paste(config$project$shortname,
                            "| Version",
                            datestamp)


#'### Quanteda-Optionen setzen
quanteda_options(tokens_locale = config$quanteda$tokens_locale)




#'## LaTeX Konfiguration

#+
#'### LaTeX Parameter definieren

latexdefs <- c("%===========================\n% Definitionen\n%===========================",
               "\n% NOTE: Diese Datei wurde während des Kompilierungs-Prozesses automatisch erstellt.\n",
               "\n%-----Autor-----",
               paste0("\\newcommand{\\projectauthor}{",
                      config$project$author,
                      "}"),
               "\n%-----Version-----",
               paste0("\\newcommand{\\version}{",
                      datestamp,
                      "}"),
               "\n%-----Titles-----",
               paste0("\\newcommand{\\datatitle}{",
                      config$project$fullname,
                      "}"),
               paste0("\\newcommand{\\datashort}{",
                      config$project$shortname,
                      "}"),
               paste0("\\newcommand{\\softwaretitle}{Source Code des \\enquote{",
                      config$project$fullname,
                      "}}"),
               paste0("\\newcommand{\\softwareshort}{",
                      config$project$shortname,
                      "-Source}"),
               "\n%-----Data DOIs-----",
               paste0("\\newcommand{\\dataconceptdoi}{",
                      config$doi$data$concept,
                      "}"),
               paste0("\\newcommand{\\dataversiondoi}{",
                      config$doi$data$version,
                      "}"),
               paste0("\\newcommand{\\dataconcepturldoi}{https://doi.org/",
                      config$doi$data$concept,
                      "}"),
               paste0("\\newcommand{\\dataversionurldoi}{https://doi.org/",
                      config$doi$data$version,
                      "}"),
               "\n%-----Software DOIs-----",
               paste0("\\newcommand{\\softwareconceptdoi}{",
                      config$doi$software$concept,
                      "}"),
               paste0("\\newcommand{\\softwareversiondoi}{",
                      config$doi$software$version,
                      "}"),

               paste0("\\newcommand{\\softwareconcepturldoi}{https://doi.org/",
                      config$doi$software$concept,
                      "}"),
               paste0("\\newcommand{\\softwareversionurldoi}{https://doi.org/",
                      config$doi$software$version,
                      "}"))




#'### LaTeX Parameter schreiben

writeLines(latexdefs,
           paste0("temp/",
                  config$project$shortname,
                  "_Definitions.tex"))






#'## Parallelisierung aktivieren
#' Parallelisierung wird zur Beschleunigung der Konvertierung von PDF zu TXT und der Datenanalyse mittels **quanteda** und **data.table** verwendet. Die Anzahl threads wird automatisch auf das verfügbare Maximum des Systems gesetzt, kann aber auch nach Belieben auf das eigene System angepasst werden. Die Parallelisierung kann deaktiviert werden, indem die Variable **fullCores** auf 1 gesetzt wird.
#'
#' Die hier verwendete Funktion **makeForkCluster()** ist viel schneller, funktioniert aber nur auf Unix-basierten Systemen (Linux, MacOS). Bei einer Ausführung unter Windows sollten Sie **makecluster()** verwenden.


#+
#'### Anzahl logischer Kerne festlegen

if (config$cores$max == TRUE){
    fullCores <- detectCores()
}


if (config$cores$max == FALSE){
    fullCores <- as.integer(config$cores$number)
}



print(fullCores)

#'### Quanteda
quanteda_options(threads = fullCores) 

#'### Data.table
setDTthreads(threads = fullCores)  











#'# Download: Weitere Datensätze

#+
#'## Registerzeichen und Verfahrensarten
#'Die Registerzeichen werden im Laufe des Skripts mit ihren detaillierten Bedeutungen aus dem folgenden Datensatz abgeglichen: "Seán Fobbe (2021). Aktenzeichen der Bundesrepublik Deutschland (AZ-BRD). Version 1.0.1. Zenodo. DOI: 10.5281/zenodo.4569564." Das Ergebnis des Abgleichs wird in die Variable "verfahrensart" in den Datensatz eingefügt.


if (file.exists("data/AZ-BRD_1-0-1_DE_Registerzeichen_Datensatz.csv") == FALSE){
    download.file("https://zenodo.org/record/4569564/files/AZ-BRD_1-0-1_DE_Registerzeichen_Datensatz.csv?download=1",
 "data/AZ-BRD_1-0-1_DE_Registerzeichen_Datensatz.csv")
    }



#'## Personendaten zu Präsident:innen
#' Die Personendaten stammen aus folgendem Datensatz: \enquote{Seán Fobbe and Tilko Swalve (2021). Presidents and Vice-Presidents of the Federal Courts of Germany (PVP-FCG). Version 2021-04-08. Zenodo. DOI: 10.5281/zenodo.4568682}.


if (file.exists("data/PVP-FCG_2021-04-08_GermanFederalCourts_Presidents.csv") == FALSE){
    download.file("https://zenodo.org/record/4568682/files/PVP-FCG_2021-04-08_GermanFederalCourts_Presidents.csv?download=1",
                  "data/PVP-FCG_2021-04-08_GermanFederalCourts_Presidents.csv")
}




#'## Personendaten zu Vize-Präsident:innen
#' Die Personendaten stammen aus folgendem Datensatz: \enquote{Seán Fobbe and Tilko Swalve (2021). Presidents and Vice-Presidents of the Federal Courts of Germany (PVP-FCG). Version 2021-04-08. Zenodo. DOI: 10.5281/zenodo.4568682}.


if (file.exists("data/PVP-FCG_2021-04-08_GermanFederalCourts_VicePresidents.csv") == FALSE){
    download.file("https://zenodo.org/record/4568682/files/PVP-FCG_2021-04-08_GermanFederalCourts_VicePresidents.csv?download=1",
                  "data/PVP-FCG_2021-04-08_GermanFederalCourts_VicePresidents.csv")
}







#'# Download vorbereiten: Alle Entscheidungen des BVerfG

#+
#'## Zeitstempel: Linksammlung Beginn

begin.links <- Sys.time()
print(begin.links)


#+
#'## Funktion zeigen

print(f.linkextract)


#'## Maximale Seitenzahl auslesen

temp <- f.linkextract("https://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?language_=de")

temp1 <- grep("list.*253D([0-9]+).*",
              temp,
              value = TRUE)

temp2 <- gsub(".*253D([0-9]+).*",
              "\\1",
              temp1)

maxpage <- max(as.numeric(temp2))

print(maxpage)


#'## Auszuwertende Seiten

pages <- seq_len(maxpage)



#'## [Debugging Modus] Reduzierung der Seitenzahl

if (config$debug$toggle == TRUE){
    pages <- sort(sample(pages,
                    config$debug$sample))
    }


#'## Linkliste erstellen: Erstversuch

breaks <- sort(sample(pages, 10))


indices <- seq_along(pages)

links.list <- vector("list",
                     length(indices))


print(pages)




for (i in indices){

    URL  <- paste0("https://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?gtp=5403124_list%253D",
                   pages[i],
                   "&language_=de")
    
    volatile <- f.linkextract(URL)
    
    links.l1 <- grep ("SharedDocs/Entscheidungen",
                      volatile,
                      ignore.case = TRUE,
                      value = TRUE)

    links.list[[i]] <- links.l1
    
    Sys.sleep(runif(1, 0.8, 2))
    
    if (i %in% breaks) Sys.sleep(runif(1, 2, 7))
    
    }


Sys.sleep(runif(1, 20, 40))




#'## Linkliste erstellen: Zweitversuch
#'

#+
#'### Seiten für Zweitversuch definieren 
#' Jede Seite der Datenbank sollte im Idealfall 10 Entscheidungen enthalten. Alle Seiten, die diese Bedingung nicht erfüllen werden noch einmal geprüft. Die letzte Seite enthält fast immer weniger als 10 Entscheidungen, wird sicherheitshalber aber trotzdem geprüft, statt sie auszusortieren. Dabei entstehende Duplikate werden später durch **unique()** entfernt.

retry.pages <- which(unlist(lapply(links.list,
                                   function(x)length(x)<10)))

retry.indices <- seq_along(retry.pages)

retry.links.list <- vector("list",
                           length(retry.pages))


#'### Anzeigen der Seiten die noch einmal geprüft werden.

print(retry.pages)

#'### Seiten prüfen

for (i in retry.indices){

    URL  <- paste0("https://www.bundesverfassungsgericht.de/SiteGlobals/Forms/Suche/Entscheidungensuche_Formular.html?gtp=5403124_list%253D",
                   retry.pages[i],
                   "&language_=de")
    
    volatile <- f.linkextract(URL)
    
    links.l1 <- grep ("SharedDocs/Entscheidungen",
                      volatile,
                      ignore.case = TRUE,
                      value = TRUE)

    retry.links.list[[i]] <- links.l1
    
    Sys.sleep(runif(1, 0.8, 2))
    
    }


#'### Anzeigen der Links die beim Wiederholungsversuch gesammelt wurden.

print(retry.links.list)


#'## Zeitstempel: Linksammlung Ende

end.links <- Sys.time()
print(end.links)


#'## Dauer: Linksammlung
end.links - begin.links


#'## Listen aus Erstversuch und Zweitversuch zusammenfügen

links.relative <- c(unlist(links.list),
                    unlist(retry.links.list))



#'## Bereinigte HTML-Links definieren

links.raw <- paste0("https://www.bundesverfassungsgericht.de/",
                    links.relative)

links.html <- gsub("(.+\\.html).*",
                   "\\1",
                   links.raw)

links.html <- unique(links.html)



#'## Bereinigte PDF-Links definieren

links.pdf <- gsub("Entscheidungen",
                  "Downloads",
                  links.html)

links.pdf <- gsub("\\.html.*",
                  "\\.pdf\\?__blob=publicationFile\\&v\\=1",
                  links.pdf)


links.pdf <- unique(links.pdf)






#'## Dateinamen erstellen

#+
#'### Extrahieren relevanter Metadaten
#' Die Links zu jeder Entscheidung enthalten das Ordinalzahl-Element ihres jeweiligen ECLI-Codes. Struktur und Inhalt der ECLI für deutsche Gerichte sind auf dem Europäischen Justizportal näher erläutert. \footnote{\url{https://e-justice.europa.eu/content_european_case_law_identifier_ecli-175-de-de.do?member=1}}

filenames <- basename(links.pdf)

filenames <- gsub("[?].*",
                  "",
                  filenames)


#' **Normale Struktur**

filenames1 <- gsub("[a-z]([a-z])([0-9]{4})([0-9]{2})([0-9]{2})_([0-9])([a-z]*)([0-9]{4})([0-9]{2}).*",
                   "BVerfG_\\2-\\3-\\4_\\1_\\5_\\6_\\7_\\8_NA",
                   filenames)


#' **Struktur von Verzögerungsrügen**

filenames1 <- gsub("_vz", "NA_Vz", filenames1)

filenames1 <- gsub("[a-z]([a-z])([0-9]{4})([0-9]{2})([0-9]{2})(NA)_(Vz)([0-9]{4})([0-9]{2}).*",
                   "BVerfG_\\2-\\3-\\4_\\1_\\5_\\6_\\7_\\8_NA",
                   filenames1)


#' **Struktur von Entscheidungen mit Kollisions-Variable**

filenames1 <- gsub("[a-z]([a-z])([0-9]{4})([0-9]{2})([0-9]{2})([a-z0-9])_([0-9])([a-z]*)([0-9]{4})([0-9]{2}).*",
                   "BVerfG_\\2-\\3-\\4_\\1_\\6_\\7_\\8_\\9_\\5",
                   filenames1)




#'### Formatierung von Registerzeichen anpassen

filenames1 <- gsub("_bv([a-z])_",
                   "_Bv\\U\\1_",
                   perl = TRUE,
                   filenames1)


filenames1 <- gsub("pbvu",
                   "PBvU",
                   filenames1)


#'### Formatierung von Spruchkörper-Typ anpassen

filenames1 <- gsub("_([kpsb])_",
                   "_\\U\\1_",
                   perl = TRUE,
                   filenames1)




#'### Erste strenge REGEX-Validierung der Dateinamen

#regex.test1 <- grep("BVerfG_[0-9]{4}-[0-9]{2}-[0-9]{2}_[A-Z]_[0-9NA]+_[A-Za-z]+_[0-9]{4}_[0-9]{2}_[0-9a-zNA]+$",
#                    filenames1,
#                    invert = TRUE,
#                    value = TRUE)


regex.test1 <- grep(paste0("BVerfG", # gericht
                           "_",
                           "[0-9]{4}-[0-9]{2}-[0-9]{2}", # datum
                           "_",
                           "[A-Z]", # spruchkoerper_typ 
                           "_",
                           "[0-9NA]+", # spruchkoerper_az
                           "_",
                           "[A-Za-z]+", # registerzeichen
                           "_",
                           "[0-9]{4}", # eingangsnummer
                           "_",
                           "[0-9]{2}", # eingangsjahr
                           "_",
                           "[0-9a-zNA]+$"), # kollision
                    filenames1,
                    invert = TRUE,
                    value = TRUE)




#'### Ergebnis der ersten REGEX-Validierung
#' Das Ergebnis sollte ein leerer Vektor sein!

print(regex.test1)


#'### Skript stoppen falls erste REGEX-Validierung gescheitert

if (length(regex.test1) != 0){
    stop("REGEX VALIDIERUNG 1 GESCHEITERT: AKTENZEICHEN ENTSPRECHEN NICHT DEM CODEBOOK-SCHEMA!")
    }






#'### Zusätzliche Variablen einfügen

extravariablen <- fread("data/BVerfGE_Variablen_NameBandSeite_2021_09_19.csv")

extravariablen$newname <- paste(extravariablen$oldname,
                                extravariablen$name,
                                extravariablen$band,
                                extravariablen$seite,
                                sep = "_")

extravariablen$newname <- paste0(extravariablen$newname,
                                 ".pdf")


filenames2 <- filenames1


targetindices <- match(extravariablen$oldname,
                       filenames2)

newname <- extravariablen$newname

dt <- data.table(targetindices, newname)[complete.cases(targetindices)]



if(dt[,.N] > 0){
    
filenames2 <- replace(filenames2,
                      dt$targetindices,
                      dt$newname)
}



#'### NAs einfügen für nicht benannte Entscheidungen

values <- grep(".pdf",
               filenames2,
               invert = TRUE,
               value = TRUE)

indices <- grep(".pdf",
                filenames2,
                invert = TRUE)

filenames2[indices] <- paste0(values,
                              "_NA_NA_NA.pdf")




#'### Zweite strenge REGEX-Validierung der Dateinamen

#regex.test2 <- grep("^BVerfG_[0-9]{4}-[0-9]{2}-[0-9]{2}_[SPKB]_[0-9NA]+_[A-Za-z]+_[0-9]{4}_[0-9]{2}_[0-9a-zNA]+_[0-9ÄÜÖäüöA-Za-z\\-]+_[NA0-9]+_[NA0-9]+\\.pdf$",
#                    filenames2,
#                    value = TRUE,
#                    invert = TRUE)


regex.test2 <- grep(paste0("^BVerfG", # gericht
                           "_",
                           "[0-9]{4}-[0-9]{2}-[0-9]{2}", # datum
                           "_",
                           "[SPKB]", # spruchkoerper_typ
                           "_",
                           "[0-9NA]+", # spruchkoerper_az
                           "_",
                           "[A-Za-z]+", # registerzeichen
                           "_",
                           "[0-9]{4}", # eingangsnummer
                           "_",
                           "[0-9]{2}", # eingangsjahr_az
                           "_",
                           "[0-9a-zNA]+", # kollision
                           "_",
                           "[0-9ÄÜÖäüöA-Za-z\\-]+", # name
                           "_",
                           "[NA0-9]+", # band
                           "_",
                           "[NA0-9]+", # seite
                           "\\.pdf$"), # Dateiendung
                    filenames2,
                    value = TRUE,
                    invert = TRUE)



#'### Ergebnis der zweiten REGEX-Validierung
#' Das Ergebnis sollte ein leerer Vektor sein!

print(regex.test2)


#'### Skript stoppen falls zweite REGEX-Validierung gescheitert

if (length(regex.test2) != 0){
    stop("REGEX VALIDIERUNG 2 GESCHEITERT: AKTENZEICHEN ENTSPRECHEN NICHT DEM CODEBOOK-SCHEMA!")
    }





#'# PDF-Download

#+
#'## Data Table für PDF-Download erstellen

dt <- data.table(links.pdf,
                 filenames2)



#'## Zeitstempel: PDF-Download Beginn

begin.download <- Sys.time()
print(begin.download)



#'## PDF-Download durchführen
#' **Hinweis:** Es ist nötig jeden Link auf das Vorhandensein einer PDF-Datei zu prüfen, weil für manche Entscheidungen zwar HTML-Seiten vorhanden sind, aber keine korrespondierende PDF-Datei.


for (i in seq_len(dt[,.N])){
    
    response <- GET(dt$links.pdf[i])
    
    Sys.sleep(runif(1, 0.25, 0.75))
    
    if (response$headers$"content-type" == "application/pdf;charset=UTF-8" & response$status_code == 200){
        tryCatch({download.file(url = dt$links.pdf[i],
                                destfile = dt$filenames2[i])
        },
        error=function(cond) {
            return(NA)}
        )     
    }else{
        print(paste0(dt$filenames2[i],
                     " : kein PDF vorhanden"))  
    }
    Sys.sleep(runif(1, 0.3, 1))
}   


#'## Zeitstempel: PDF-Download Ende

end.download <- Sys.time()
print(end.download)


#'## Dauer: PDF-Download 
end.download - begin.download




#'## PDF-Download: Ergebnis

#+
#'### Anzahl herunterzuladender Dateien
dt[,.N]

#'### Anzahl heruntergeladener Dateien
files.pdf <- list.files(pattern = "\\.pdf")
length(files.pdf)

#'### Fehlbetrag
N.missing.pdf <- dt[,.N] - length(files.pdf)
print(N.missing.pdf)

#'### Fehlende Dateien
missing.pdf <- setdiff(dt$filenames2,
                   files.pdf)

print(missing.pdf)





#'## PDF-Wiederholungsversuch
#' Download für fehlende Dokumente wiederholen.

if(N.missing.pdf > 0){

    dt.retry <- dt[filenames2 %in% missing.pdf]
    
    for (i in seq_len(dt.retry[,.N])){
        
        response <- GET(dt.retry$links.pdf[i])
        
        Sys.sleep(runif(1, 0.25, 0.75))
        
        if (response$headers$"content-type" == "application/pdf;charset=UTF-8" & response$status_code == 200){
            
            tryCatch({download.file(url = dt.retry$links.pdf[i],
                                    destfile = dt.retry$filenames2[i])
                                    
            },
            error = function(cond) {
                return(NA)}
            )     
        }else{
            print(paste0(dt.retry$filenames2[i],
                         " : kein PDF vorhanden"))  
        }
        Sys.sleep(runif(1, 0.5, 1.5))
    } 
}


#'## PDF-Download: Gesamtergebnis

#+
#'### Anzahl herunterzuladender Dateien
dt[,.N]

#'### Anzahl heruntergeladener Dateien
files.pdf <- list.files(pattern = "\\.pdf")
length(files.pdf)

#'### Fehlbetrag
N.missing.pdf <- dt[,.N] - length(files.pdf)
print(N.missing.pdf)

#'### Fehlende Dateien
missing.pdf <- setdiff(dt$filenames2, files.pdf)
print(missing.pdf)


#'### Abschließende Hinweise
#' **Hinweis:** Für die Entscheidung vom 1.10.2001 zur Rückgabe von EDV-Anlagen im Rahmen des NPD-Verfahrens war auch nach manueller Suche keine PDF-Datei auffindbar.




#+
#'# HTML-Download

#+
#'## Data Table für HTML-Download erstellen

names.html <- basename(links.html)

dt.download.html <- data.table(links.html,
                               names.html)



#'## Zeitstempel: HTML-Download Beginn

begin.download <- Sys.time()
print(begin.download)


#'## HTML-Download durchführen


for (i in sample(dt.download.html[,.N])){
    
        tryCatch({download.file(dt.download.html$links.html[i],
                                dt.download.html$names.html[i])
        },
        error = function(cond) {
            return(NA)}
        )
    
    Sys.sleep(runif(1, 0.3, 1))
    
}



#'## Zeitstempel: HTML-Download Ende

end.download <- Sys.time()
print(end.download)


#'## Dauer: HTML-Download 
end.download - begin.download




#'## HTML-Download: Ergebnis

#+
#'### Anzahl herunterzuladender Dateien
dt.download.html[,.N]

#'### Anzahl heruntergeladener Dateien
files.html <- list.files(pattern = "\\.html")
length(files.html)

#'### Fehlbetrag
N.missing <- dt.download.html[,.N] - length(files.html)
print(N.missing)

#'### Fehlende Dateien
missing <- setdiff(dt.download.html$names.html,
                   files.html)

print(missing)





#'## HTML-Wiederholungsversuch
#' Download für fehlende Dokumente wiederholen.

if(N.missing > 0){

    dt.retry <- dt.download.html[names.html %in% missing]
    
    for (i in seq_len(dt.retry[,.N])){
        
        tryCatch({download.file(dt.retry$links.html[i],
                                dt.retry$names.html[i])
        },
        error = function(cond) {
            return(NA)}
        )
        
        Sys.sleep(runif(1, 0.5, 1.5))
    } 
}




#'## HTML-Download: Gesamtergebnis

#+
#'### Anzahl herunterzuladender Dateien
dt.download.html[,.N]

#'### Anzahl heruntergeladener Dateien
files.html <- list.files(pattern = "\\.html")
length(files.html)

#'### Fehlbetrag
N.missing <- dt.download.html[,.N] - length(files.html)
print(N.missing)

#'### Fehlende Dateien
missing <- setdiff(dt.download.html$names.html,
                   files.html)

print(missing)







#'# HTML verarbeiten

#+
#'## Funktion anzeigen: f.bverfg.extract.meta

print(f.bverfg.extract.meta)

#+
#'## Funktion anzeigen: f.bverfg.extract.content


print(f.bverfg.extract.content)


#+
#'## HTML-Dateien definieren

files.html <- list.files(pattern = "\\.html")


#'## HTML-Dateien einlesen

html.list <- lapply(files.html,
                    read_html)


#'## HTML-Dateien parsen

meta.list <- lapply(html.list,
                    f.bverfg.extract.meta)

content.list <- lapply(html.list,
                       f.bverfg.extract.content)

segmented.full.list <- vector("list",
                              length(meta.list))

for (i in 1:length(meta.list)){
    content.rows <- content.list[[i]][,.N]
    meta.replicate <- meta.list[[i]][rep(1, content.rows)]
    segmented.full.list[[i]] <- cbind(content.list[[i]],
                                      meta.replicate)

    }


#'## Data Table mit allen Metadaten (inkl. ECLI)
dt.meta.html <-  rbindlist(meta.list)


#'## Data Table mit vollständiger segmentierter Variante
dt.segmented.full <- rbindlist(segmented.full.list)


#'## Special Character entfernen
#' An dieser Stelle wird ein mysteriöser Unterstricht entfernt, vermutlich ein non-breaking space. Es ist allerdings unklar wieso dieser in den Daten auftaucht. Der Code wird nicht im Compilation Report angezeigt, weil sich dieses Zeichen bei dem listings package zu Fehlern führt.

#+ echo = FALSE
dt.meta.html$richter <- gsub(" ",
                             " ",
                             dt.meta.html$richter)

#+ echo = FALSE
dt.segmented.full$richter <- gsub(" ",
                                  " ",
                                  dt.segmented.full$richter)

#+ echo = FALSE
dt.meta.html$aktenzeichen_alle <- gsub(" ",
                                       " ",
                                       dt.meta.html$aktenzeichen_alle)

#+ echo = FALSE
dt.segmented.full$aktenzeichen_alle <- gsub(" ",
                                            " ",
                                            dt.segmented.full$aktenzeichen_alle)


#+ echo = FALSE
dt.meta.html$kurzbeschreibung <- gsub(" ",
                                       " ",
                                       dt.meta.html$kurzbeschreibung)

#+ echo = FALSE
dt.segmented.full$kurzbeschreibung <- gsub(" ",
                                            " ",
                                            dt.segmented.full$kurzbeschreibung)


#+ echo = FALSE
dt.segmented.full$text <- gsub(" ",
                               " ",
                               dt.segmented.full$text)



#'## Stichprobe Metadaten
fwrite(dt.meta.html[sample(.N, 50)],
       file.path(dir.analysis,
                 "QA_Stichprobe_HTML-Metadaten.csv"))


#'## Stichprobe Segmentierte Variante
fwrite(dt.segmented.full[sample(.N, 50)],
       file.path(dir.analysis,
                 "QA_Stichprobe_HTML-SegmentierterVolltext.csv"))






#+
#'# Text-Extraktion aus PDF

#+
#'## Vektor der zu extrahierenden Dateien erstellen

files.pdf <- list.files(pattern = "\\.pdf$",
                        ignore.case = TRUE)


#'## Anzahl zu extrahierender Dateien
length(files.pdf)



#'## PDF extrahieren: Funktion anzeigen
#+ results = "asis"
print(f.dopar.pdfextract)


#'## Text Extrahieren

#+ results = "hide"
result <- f.dopar.pdfextract(files.pdf,
                             threads = fullCores)






#'# Korpus Erstellen

#+
#'## TXT-Dateien Einlesen

txt.bverfg <- readtext("./*.txt",
                    docvarsfrom = "filenames", 
                    docvarnames = c("gericht",
                                    "datum",
                                    "spruchkoerper_typ",
                                    "spruchkoerper_az",
                                    "registerzeichen",
                                    "eingangsnummer",
                                    "eingangsjahr_az",
                                    "kollision",
                                    "name",
                                    "band",
                                    "seite"),
                    dvsep = "_", 
                    encoding = "UTF-8")


#'## In Data Table umwandeln
setDT(txt.bverfg)



#'## Durch Zeilenumbruch getrennte Wörter zusammenfügen
#' Durch Zeilenumbrüche getrennte Wörter stellen bei aus PDF-Dateien gewonnene Text-Korpora ein erhebliches Problem dar. Wörter werden dadurch in zwei sinnentleerte Tokens getrennt, statt ein einzelnes und sinnvolles Token zu bilden. Dieser Schritt entfernt die Bindestriche, den Zeilenumbruch und ggf. dazwischenliegende Leerzeichen.

#+
#'### Funktion anzeigen
print(f.hyphen.remove)

#'### Funktion ausführen
txt.bverfg[, text := lapply(.(text), f.hyphen.remove)]
dt.segmented.full[, text := lapply(.(text), f.hyphen.remove)]



#'## Variable "datum" als Datentyp "IDate" kennzeichnen
txt.bverfg$datum <- as.IDate(txt.bverfg$datum)


#'## Variable "entscheidungsjahr" hinzufügen
txt.bverfg$entscheidungsjahr <- year(txt.bverfg$datum)


#'## Variable "eingangsjahr_iso" hinzufügen
txt.bverfg$eingangsjahr_iso <- f.year.iso(txt.bverfg$eingangsjahr_az)




#'## Datensatz nach Datum sortieren
#' Aufgrund der Position der Datums-Variable ist der Datensatz vermutlich schon von Linux nach Datum sortiert worden. Die Erstellung der Variablen für Präsidenten und Vize-Präsidenten trifft allerdings die starke Annahme, dass eine aufsteigende Sortierung nach Datum besteht. Wäre das nicht der Fall, würden dort Fehler auftreten. Diese Sortierung ist als fail-safe gedacht.

setorder(txt.bverfg,
         datum)



#'## Variable "praesi" hinzufügen
#' Diese Variable dokumentiert für jede Entscheidung welche/r Präsident:in am Tag der Entscheidung im Amt war.

#+
#'### Lebensdaten einlesen

praesi <- fread(file.path("data",
                          "PVP-FCG_2021-04-08_GermanFederalCourts_Presidents.csv"))
praesi <- praesi[court == "BVerfG", c(1:3, 5:6)]


#'### Personaldaten anzeigen

kable(praesi,
      format = "latex",
      align = "r",
      booktabs = TRUE,
      longtable = TRUE) %>% kable_styling(latex_options = "repeat_header")



#'### Hypothethisches Amtsende für PräsidentIn
#' Weil der/die aktuelle PräsidentIn noch im Amt ist, ist der Wert für das Amtsende "NA". Dieser ist aber für die verwendete Logik nicht greifbar, weshalb an dieser Stelle ein hypothetisches Amtsende in einem Jahr ab dem Tag der Datensatzerstellung fingiert wird. Es wird nur an dieser Stelle verwendet und danach verworfen.

praesi[is.na(term_end_date)]$term_end_date <- Sys.Date() + 365


#'### Schleife vorbereiten

N <- praesi[,.N]

praesi.list <- vector("list", N)


#'### Vektor erstellen

for (i in seq_len(N)){
    praesi.N <- txt.bverfg[datum >= praesi$term_begin_date[i] & datum <= praesi$term_end_date[i], .N]
    praesi.list[[i]] <- rep(praesi$name_last[i],
                            praesi.N)
}



#'### Vektor einfügen
txt.bverfg$praesi <- unlist(praesi.list)



#'## Variable "v_praesi" hinzufügen
#' Diese Variable dokumentiert für jede Entscheidung welche/r Vize-PräsidentIn am Tag der Entscheidung im Amt war.


#+
#'### Personaldaten einlesen

vpraesi <- fread(file.path("data",
                          "PVP-FCG_2021-04-08_GermanFederalCourts_VicePresidents.csv"))
vpraesi <- vpraesi[court == "BVerfG", c(1:3, 5:6)]


#'### Personaldaten anzeigen

kable(vpraesi,
      format = "latex",
      align = "r",
      booktabs = TRUE,
      longtable = TRUE) %>% kable_styling(latex_options = "repeat_header")



#'### Hypothethisches Amtsende für Vize-PräsidentIn
#' Weil der/die aktuelle Vize-PräsidentIn noch im Amt ist, ist der Wert für das Amtsende "NA". Dieser ist aber für die verwendete Logik nicht greifbar, weshalb an dieser Stelle ein hypothetisches Amtsende in einem Jahr ab dem Tag der Datensatzerstellung fingiert wird. Es wird nur an dieser Stelle verwendet und danach verworfen.

vpraesi[is.na(term_end_date)]$term_end_date <- Sys.Date() + 365


#'### Schleife vorbereiten

N <- vpraesi[,.N]

vpraesi.list <- vector("list", N)



#'### Vektor erstellen

for (i in seq_len(N)){
    vpraesi.N <- txt.bverfg[datum >= vpraesi$term_begin_date[i] & datum < vpraesi$term_end_date[i], .N]
    vpraesi.list[[i]] <- rep(vpraesi$name_last[i],
                            vpraesi.N)
}



#'### Vektor einfügen

txt.bverfg$v_praesi <- unlist(vpraesi.list)




#'## Variable "verfahrensart" hinzufügen
#'Die Registerzeichen werden an dieser Stelle mit ihren detaillierten Bedeutungen aus dem folgenden Datensatz abgeglichen: "Seán Fobbe (2021). Aktenzeichen der Bundesrepublik Deutschland (AZ-BRD). Version 1.0.1. Zenodo. DOI: 10.5281/zenodo.4569564." Das Ergebnis des Abgleichs wird in der Variable "verfahrensart" in den Datensatz eingefügt.



#+
#'### Datensatz einlesen
az.source <- fread(file.path("data",
                          "AZ-BRD_1-0-1_DE_Registerzeichen_Datensatz.csv"))




#'### Datensatz auf relevante Daten reduzieren
az.bverfg <- az.source[stelle == "BVerfG" & position == "hauptzeichen"]


#'### Indizes bestimmen
targetindices <- match(txt.bverfg$registerzeichen,
                       az.bverfg$zeichen_code)

#'### Vektor der Verfahrensarten erstellen und einfügen
txt.bverfg$verfahrensart <- az.bverfg$bedeutung[targetindices]





#'## Variable "aktenzeichen" hinzufügen

txt.bverfg$aktenzeichen <- paste0(txt.bverfg$spruchkoerper_az,
                                  " ",
                                  txt.bverfg$registerzeichen,
                                  " ",
                                  txt.bverfg$eingangsnummer,
                                  "/",
                                  txt.bverfg$eingangsjahr_az)




#' Bei Entscheidungen der Verzögerungskammer fehlt das Spruchkörper-Element des Aktenzeichens. Diese Zeile entfernt die "NA"-Angabe um ein korrektes Aktenzeichen herzustellen.

txt.bverfg$aktenzeichen <- gsub("NA ",
                                "",
                                txt.bverfg$aktenzeichen)




#'## Variable "doi_concept" hinzufügen

txt.bverfg$doi_concept <- rep(config$doi$data$concept,
                              txt.bverfg[,.N])


#'## Variable "doi_version" hinzufügen

txt.bverfg$doi_version <- rep(config$doi$data$version,
                              txt.bverfg[,.N])


#'## Variable "version" hinzufügen

txt.bverfg$version <- as.character(rep(datestamp,
                                       txt.bverfg[,.N]))


#'## Variable "lizenz" hinzufügen
txt.bverfg$lizenz <- as.character(rep(config$license$data,
                                   txt.bverfg[,.N]))







#'## Variable "ecli" hinzufügen
#' Struktur und Inhalt der ECLI für deutsche Gerichte sind auf dem Europäischen Justizportal näher erläutert. \footnote{\url{https://e-justice.europa.eu/content_european_case_law_identifier_ecli-175-de-de.do?member=1}}
#'
#' Sofern die Variablen korrekt extrahiert wurden lässt sich die ECLI vollständig rekonstruieren.

ecli.ordinalzahl <- paste0(gsub("Bv([A-Z])",
                                "\\1",
                                txt.bverfg$registerzeichen),
                           txt.bverfg$spruchkoerper_typ,
                           txt.bverfg$datum,
                           txt.bverfg$kollision,
                           ".",
                           txt.bverfg$spruchkoerper_az,
                           txt.bverfg$registerzeichen,
                           formatC(txt.bverfg$eingangsnummer,
                                   width = 4,
                                   flag = "0"),
                           formatC(txt.bverfg$eingangsjahr_az,
                                   width = 2,
                                   flag = "0"))

ecli.ordinalzahl <- gsub("NA",
                         "",
                         ecli.ordinalzahl)

ecli.ordinalzahl <- gsub("-",
                         "",
                         ecli.ordinalzahl)


ecli.ordinalzahl <- tolower(ecli.ordinalzahl)

ecli.ordinalzahl <- gsub("vzb",
                         "vb",
                         ecli.ordinalzahl)

ecli.ordinalzahl <- gsub("pup",
                         "up",
                         ecli.ordinalzahl)



txt.bverfg$ecli <- paste0("ECLI:DE:BVerfG:",
                          txt.bverfg$entscheidungsjahr,
                          ":",
                          ecli.ordinalzahl)




#'### Metadaten mit ECLI-Duplikaten entfernen
#' Für eine Entscheidung wird versehentlich auch die englischsprachige Zusammenfassung abgerufen, diese wird hier entfernt.

dt.meta.html <- dt.meta.html[grep("Order",
                                  dt.meta.html$zitiervorschlag,
                                  invert = TRUE)]


#'### Fehlerhafte ECLI korrigieren (HTML Meta)


dt.meta.html$ecli <- gsub("ECLI:DE:BVerfG:1951:rs19580115.1bvr040051",
                          "ECLI:DE:BVerfG:1958:rs19580115.1bvr040051",
                          dt.meta.html$ecli) ## Lüth

dt.meta.html$ecli <- gsub("ECLI:DE:BVerfG:2003:rk20030407.2bvr212902",
                          "ECLI:DE:BVerfG:2003:rk20030407.1bvr212902",
                          dt.meta.html$ecli)


dt.meta.html$ecli <- gsub("ECLI:DE:BVerfG:2007:rk20060529.1bvr043003",
                          "ECLI:DE:BVerfG:2006:rk20060529.1bvr043003",
                          dt.meta.html$ecli)

#' Die folgende ECLI ist auf der Homepage des BVerfG fehlerhaft. Sie betrifft das Vorverfahren statt die Verzögerungsbeschwerde. Auf rechtsprechung-im-internet.de ist sie korrekt nachgewiesen.\footnote{\url{https://www.rechtsprechung-im-internet.de/jportal/?quelle=jlink&docid=KVRE412291501&psml=bsjrsprod.psml&max=true}}

dt.meta.html$ecli <- gsub("ECLI:DE:BVerfG:2015:rs20151208a.1bvr009911",
                          "ECLI:DE:BVerfG:2015:vb20151208.vz000115",
                          dt.meta.html$ecli)





#'### Fehlerhafte ECLI korrigieren (HTML Full)


dt.segmented.full$ecli <- gsub("ECLI:DE:BVerfG:1951:rs19580115.1bvr040051",
                               "ECLI:DE:BVerfG:1958:rs19580115.1bvr040051",
                               dt.segmented.full$ecli) ## Lüth

dt.segmented.full$ecli <- gsub("ECLI:DE:BVerfG:2003:rk20030407.2bvr212902",
                          "ECLI:DE:BVerfG:2003:rk20030407.1bvr212902",
                          dt.segmented.full$ecli)


dt.segmented.full$ecli <- gsub("ECLI:DE:BVerfG:2007:rk20060529.1bvr043003",
                          "ECLI:DE:BVerfG:2006:rk20060529.1bvr043003",
                          dt.segmented.full$ecli)

#' Die folgende ECLI ist auf der Homepage des BVerfG fehlerhaft. Sie betrifft das Vorverfahren statt die Verzögerungsbeschwerde. Auf rechtsprechung-im-internet.de ist sie korrekt nachgewiesen.\footnote{\url{https://www.rechtsprechung-im-internet.de/jportal/?quelle=jlink&docid=KVRE412291501&psml=bsjrsprod.psml&max=true}}

dt.segmented.full$ecli <- gsub("ECLI:DE:BVerfG:2015:rs20151208a.1bvr009911",
                          "ECLI:DE:BVerfG:2015:vb20151208.vz000115",
                          dt.segmented.full$ecli)





#'### ECLI-Test 1: ECLI die in PDF, aber nicht in HTML vorhanden sind
sort(setdiff(txt.bverfg$ecli, dt.segmented.full$ecli))


#'### ECLI-Test 2: ECLI die in HTML, aber nicht in PDF vorhanden sind
sort(setdiff(dt.segmented.full$ecli, txt.bverfg$ecli))

#'### Zum Vergleich: Beim Download fehlende PDF-Dateien
print(sort(missing.pdf))



#'### ECLI Merge: Metadaten aus Hauptdatensatz in segmentierte Variante mergen

meta.bverfg <- txt.bverfg[,!"text"]

dt.segmented.full <- merge(dt.segmented.full,
                           meta.bverfg,
                           by = "ecli",
                           all.x = TRUE,
                           sort = FALSE)



#'### ECLI Merge: Metadaten aus HTML-Extraktion in Hauptdatensatz mergen

txt.bverfg <- merge(txt.bverfg,
                    dt.meta.html,
                    by = "ecli",
                    all.x = TRUE,
                    sort = FALSE)






#'## Variable "entscheidung_typ" hinzufügen


#+
#'### Zitiervorschläge parsen
entscheidung_typ.main <- gsub(".*(Beschluss|Urteil|Verfügung).*",
                              "\\1",
                              txt.bverfg$zitiervorschlag,
                              ignore.case = TRUE)


entscheidung_typ.segmented <- gsub(".*(Beschluss|Urteil|Verfügung).*",
                                   "\\1",
                                   dt.segmented.full$zitiervorschlag,
                                   ignore.case = TRUE)



#'### Kürzen

lang.etyp <- c("Urteil",
               "Beschluss",
               "Verfügung")

kurz.etyp <- c("U",
               "B",
               "V")


entscheidung_typ.main <- mgsub(entscheidung_typ.main,
                               lang.etyp,
                               kurz.etyp,
                               ignore.case = TRUE)

entscheidung_typ.segmented <- mgsub(entscheidung_typ.segmented,
                                    lang.etyp,
                                    kurz.etyp,
                                    ignore.case = TRUE)



#'### Vektor in Datensatz einfügen

txt.bverfg$entscheidung_typ <- entscheidung_typ.main

dt.segmented.full$entscheidung_typ <- entscheidung_typ.segmented








#'# Frequenztabellen erstellen

#+
#'## Funktion anzeigen

#+ results = "asis"
print(f.fast.freqtable)


#'## Ignorierte Variablen
print(config$freqtable$ignore)



#'## Liste zu prüfender Variablen

varlist <- names(txt.bverfg)
varlist <- grep(paste(config$freqtable$ignore,
                      collapse = "|"),
                varlist,
                invert = TRUE,
                value = TRUE)
print(varlist)



#'## Frequenztabellen erstellen

prefix <- paste0(config$project$shortname,
                 "_01_Frequenztabelle_var-")


#+ results = "asis"
f.fast.freqtable(txt.bverfg,
                 varlist = varlist,
                 sumrow = TRUE,
                 output.list = FALSE,
                 output.kable = TRUE,
                 output.csv = TRUE,
                 outputdir = dir.analysis,
                 prefix = prefix,
                 align = c("p{5cm}",
                           rep("r", 4)))





#'# Frequenztabellen visualisieren

#'## Präfix erstellen

prefix <- file.path(dir.analysis,
                    paste0(config$project$shortname,
                           "_01_Frequenztabelle_var-"))


#'## Tabellen einlesen


table.entsch.typ <- fread(paste0(prefix,
                                 "entscheidung_typ.csv"))

table.spruch.typ <- fread(paste0(prefix,
                                 "spruchkoerper_typ.csv"))

table.spruch.az <- fread(paste0(prefix,
                                "spruchkoerper_az.csv"))

table.regz <- fread(paste0(prefix,
                           "registerzeichen.csv"))

table.jahr.eingangISO <- fread(paste0(prefix,
                                      "eingangsjahr_iso.csv"))

table.jahr.entscheid <- fread(paste0(prefix,
                                     "entscheidungsjahr.csv"))

table.output.praesi <- fread(paste0(prefix,
                                    "praesi.csv"))

table.output.vpraesi <- fread(paste0(prefix,
                                     "v_praesi.csv"))






#'\newpage
#'## Diagramm: Typ der Entscheidung

freqtable <- table.entsch.typ[-.N]


#+ CE-BVerfG_02_Barplot_Entscheidung_Typ, fig.height = 6, fig.width = 9
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(entscheidung_typ,
                             -N),
                 y = N),
             stat = "identity",
             fill = "#ca2129",
             color = "black",
             width = 0.4) +
    theme_bw() +
    labs(
        title = paste(prefix.figuretitle,
                      "| Entscheidungen je Entscheidungs-Typ"),
        caption = caption,
        x = "Typ der Entscheidung",
        y = "Entscheidungen"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )







#'\newpage
#'## Diagramm: Typ des Spruchkörpers

freqtable <- table.spruch.typ[-.N]


#+ CE-BVerfG_03_Barplot_Spruchkoerper_Typ, fig.height = 6, fig.width = 9
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(spruchkoerper_typ,
                             -N),
                 y = N),
             stat = "identity",
             fill = "#ca2129",
             color = "black",
             width = 0.4) +
    theme_bw() +
    labs(
        title = paste(prefix.figuretitle,
                      "| Entscheidungen je Spruchkörper-Typ"),
        caption = caption,
        x = "Typ des Spruchkörpers",
        y = "Entscheidungen"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )




#'\newpage
#'## Diagramm: Spruchkörper nach Aktenzeichen

freqtable <- table.spruch.az[-.N]


#+ CE-BVerfG_04_Barplot_Spruchkoerper_AZ, fig.height = 6, fig.width = 9
ggplot(data = freqtable) +
    geom_bar(aes(x = spruchkoerper_az,
                 y = N),
             stat = "identity",
             fill = "#ca2129",
             color = "black",
             width = 0.4) +
    theme_bw() +
    labs(
        title = paste(prefix.figuretitle,
                      "| Entscheidungen je Senat (Aktenzeichen)"),
        caption = caption,
        x = "Senat",
        y = "Entscheidungen"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'## Diagramm: Registerzeichen

freqtable <- table.regz[-.N]

#+ CE-BVerfG_05_Barplot_Registerzeichen, fig.height = 10, fig.width = 8
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(registerzeichen,
                             N),
                 y = N),
             stat = "identity",
             fill = "#ca2129",
             color = "black") +
    coord_flip()+
    theme_bw() +
    labs(
        title = paste(prefix.figuretitle,
                      "| Entscheidungen je Registerzeichen"),
        caption = caption,
        x = "Registerzeichen",
        y = "Entscheidungen"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'## Diagramm: Präsident:in

freqtable <- table.output.praesi[-.N]

#+ CE-BVerfG_06_Barplot_PraesidentIn, fig.height = 6, fig.width = 9
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(praesi,
                             N),
                 y = N),
             stat = "identity",
             fill = "#ca2129",
             color = "black") +
    coord_flip()+
    theme_bw() +
    labs(
        title = paste(prefix.figuretitle,
                      "| Entscheidungen je Präsident:in"),
        caption = caption,
        x = "Präsident:in",
        y = "Entscheidungen"
    )+
    theme(
        axis.title.y = element_blank(),
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'## Diagramm: Vize-Präsident:in

freqtable <- table.output.vpraesi[-.N]

#+ CE-BVerfG_07_Barplot_VizePraesidentIn, fig.height = 6, fig.width = 9
ggplot(data = freqtable) +
    geom_bar(aes(x = reorder(v_praesi,
                             N),
                 y = N),
             stat = "identity",
             fill = "#ca2129",
             color = "black") +
    coord_flip()+
    theme_bw() +
    labs(
        title = paste(prefix.figuretitle,
                      "| Entscheidungen je Vize-Präsident:in"),
        caption = caption,
        x = "Vize-Präsident:in",
        y = "Entscheidungen"
    )+
    theme(
        axis.title.y = element_blank(),
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'## Diagramm: Entscheidungsjahr

freqtable <- table.jahr.entscheid[-.N][,lapply(.SD, as.numeric)]

#+ CE-BVerfG_08_Barplot_Entscheidungsjahr, fig.height = 6, fig.width = 9
ggplot(data = freqtable) +
    geom_bar(aes(x = entscheidungsjahr,
                 y = N),
             stat = "identity",
             fill = "#ca2129") +
    theme_bw() +
    labs(
        title = paste(prefix.figuretitle,
                      "| Entscheidungen je Entscheidungsjahr"),
        caption = caption,
        x = "Entscheidungsjahr",
        y = "Entscheidungen"
    )+
    theme(
        text = element_text(size = 16),
        plot.title = element_text(size = 16,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'## Diagramm: Eingangsjahr (ISO)

freqtable <- table.jahr.eingangISO[-.N][,lapply(.SD, as.numeric)]



#+ CE-BVerfG_09_Barplot_EingangsjahrISO, fig.height = 6, fig.width = 9
ggplot(data = freqtable) +
    geom_bar(aes(x = eingangsjahr_iso,
                 y = N),
             stat = "identity",
             fill = "#ca2129") +
    theme_bw() +
    labs(
        title = paste(prefix.figuretitle,
                      "| Entscheidungen je Eingangsjahr (ISO)"),
        caption = caption,
        x = "Eingangsjahr (ISO)",
        y = "Entscheidungen"
    )+
    theme(
        text = element_text(size = 16),
        plot.title = element_text(size = 16,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )





#'# Korpus-Analytik
#'

#+
#'## Berechnung linguistischer Kennwerte
#' An dieser Stelle werden für jedes Dokument die Anzahl Zeichen, Tokens, Typen und Sätze berechnet und mit den jeweiligen Metadaten verknüpft. Das Ergebnis ist grundsätzlich identisch mit dem eigentlichen Datensatz, nur ohne den Text der Entscheidungen.


#+
#'### Funktion anzeigen
print(f.lingsummarize.iterator)




#'### Berechnung durchführen
summary.corpus <- f.lingsummarize.iterator(txt.bverfg,
                                           threads = fullCores,
                                           chunksize = 1)



#'## Variablen-Namen anpassen

setnames(summary.corpus,
         old = c("nchars",
                 "ntokens",
                 "ntypes",
                 "nsentences"),
         new = c("zeichen",
                 "tokens",
                 "typen",
                 "saetze"))


#'## Kennwerte dem Korpus hinzufügen

txt.bverfg <- cbind(txt.bverfg,
                    summary.corpus)


#'## Variante mit Metadaten erstellen
meta.bverfg <- txt.bverfg[, !"text"]



#'## Linguistische Kennwerte

#+
#'### Zusammenfassungen berechnen

dt.summary.ling <- meta.bverfg[, lapply(.SD,
                                           function(x)unclass(summary(x))),
                                  .SDcols = c("zeichen",
                                              "tokens",
                                              "typen",
                                              "saetze")]


dt.sums.ling <- meta.bverfg[,
                            lapply(.SD, sum),
                            .SDcols = c("zeichen",
                                        "tokens",
                                        "typen",
                                        "saetze")]



tokens.temp <- tokens(corpus(txt.bverfg),
                      what = "word",
                      remove_punct = FALSE,
                      remove_symbols = FALSE,
                      remove_numbers = FALSE,
                      remove_url = FALSE,
                      remove_separators = TRUE,
                      split_hyphens = FALSE,
                      include_docvars = FALSE,
                      padding = FALSE
                      )


dt.sums.ling$typen <- nfeat(dfm(tokens.temp))




dt.stats.ling <- rbind(dt.sums.ling,
                       dt.summary.ling)

dt.stats.ling <- transpose(dt.stats.ling,
                           keep.names = "names")


setnames(dt.stats.ling, c("Variable",
                          "Sum",
                          "Min",
                          "Quart1",
                          "Median",
                          "Mean",
                          "Quart3",
                          "Max"))



#'### Zusammenfassungen anzeigen

kable(dt.stats.ling,
      format.args = list(big.mark = ","),
      format = "latex",
      booktabs = TRUE,
      longtable = TRUE)




#'### Zusammenfassungen speichern

fwrite(dt.stats.ling,
       file.path(dir.analysis,
                 paste0(config$project$shortname,
                        "_00_KorpusStatistik_ZusammenfassungLinguistisch.csv")),
       na = "NA")





#'\newpage
#'## Quantitative Variablen


#+
#'### Entscheidungsdatum

summary(as.IDate(meta.bverfg$datum))



#'### Zusammenfassungen berechnen

dt.summary.docvars <- meta.bverfg[,
                                  lapply(.SD, function(x)unclass(summary(na.omit(x)))),
                                  .SDcols = c("entscheidungsjahr",
                                              "eingangsjahr_iso",
                                              "band",
                                              "eingangsnummer")]


dt.unique.docvars <- meta.bverfg[,
                                 lapply(.SD, function(x)length(unique(na.omit(x)))),
                                 .SDcols = c("entscheidungsjahr",
                                             "eingangsjahr_iso",
                                             "band",
                                             "eingangsnummer")]


dt.stats.docvars <- rbind(dt.unique.docvars,
                          dt.summary.docvars)

dt.stats.docvars <- transpose(dt.stats.docvars,
                              keep.names = "names")


setnames(dt.stats.docvars, c("Variable",
                             "Anzahl",
                             "Min",
                             "Quart1",
                             "Median",
                             "Mean",
                             "Quart3",
                             "Max"))


#'\newpage
#'### Zusammenfassungen anzeigen

kable(dt.stats.docvars,
      format = "latex",
      booktabs = TRUE,
      longtable = TRUE)



#'### Zusammenfassungen speichern

fwrite(dt.stats.docvars,
       file.path(dir.analysis,
                 paste0(config$project$shortname,
                        "_00_KorpusStatistik_ZusammenfassungDocvarsQuantitativ.csv")),
       na = "NA")




#'\newpage
#'## Verteilungen linguistischer Kennwerte

#+
#'### Diagramm: Verteilung Zeichen

#+ CE-BVerfG_10_Density_Zeichen, fig.height = 6, fig.width = 9
ggplot(data = meta.bverfg)+
    geom_density(aes(x = zeichen),
                 fill = "#ca2129")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Zeichen je Dokument"),
        caption = caption,
        x = "Zeichen",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#+
#'### Diagramm: Verteilung Tokens

#+ CE-BVerfG_11_Density_Tokens, fig.height = 6, fig.width = 9
ggplot(data = meta.bverfg)+
    geom_density(aes(x = tokens),
                 fill = "#ca2129")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Tokens je Dokument"),
        caption = caption,
        x = "Tokens",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'### Diagramm: Verteilung Typen

#+ CE-BVerfG_12_Density_Typen, fig.height = 6, fig.width = 9
ggplot(data = meta.bverfg)+
    geom_density(aes(x = typen),
                 fill = "#ca2129")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Typen je Dokument"),
        caption = caption,
        x = "Typen",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )



#'\newpage
#'### Diagramm: Verteilung Sätze

#+ CE-BVerfG_13_Density_Saetze, fig.height = 6, fig.width = 9
ggplot(data = meta.bverfg)+
    geom_density(aes(x = saetze),
                 fill = "#ca2129")+
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    coord_cartesian(xlim = c(1, 10^6))+
    theme_bw()+
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Sätze je Dokument"),
        caption = caption,
        x = "Sätze",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        plot.margin = margin(10, 20, 10, 10)
    )







#'# Linguistische Annotationen berechnen

if (config$annotate$toggle == TRUE){

    txt.annotated <- f.dopar.spacyparse(txt.bverfg,
                                        threads = fullCores,
                                        chunksize = 1,
                                        model = "de_core_news_sm",
                                        pos = TRUE,
                                        tag = TRUE,
                                        lemma = TRUE,
                                        entity = TRUE,
                                        dependency = TRUE,
                                        nounphrase = TRUE)

}




#'# Kontrolle der Variablen

#+
#'## Semantische Sortierung der Variablen

#+
#'### Variablen sortieren: Hauptdatensatz


setcolorder(txt.bverfg,
            c("doc_id",
              "text",
              "gericht",
              "datum",
              "entscheidung_typ", 
              "spruchkoerper_typ",
              "spruchkoerper_az",
              "registerzeichen",
              "verfahrensart",
              "eingangsnummer",
              "eingangsjahr_az",
              "eingangsjahr_iso",
              "entscheidungsjahr",
              "kollision",
              "name",
              "band",
              "seite",  
              "aktenzeichen",
              "aktenzeichen_alle",
              "ecli",
              "zitiervorschlag",
              "kurzbeschreibung",
              "pressemitteilung",
              "praesi",
              "v_praesi",
              "richter",
              "zeichen",
              "tokens",
              "typen",            
              "saetze",
              "version",
              "doi_concept",      
              "doi_version",
              "lizenz"))


#'\newpage
#+
#'### Variablen sortieren: Metadaten

setcolorder(meta.bverfg,
            c("doc_id",
              "gericht",
              "datum",
              "entscheidung_typ", 
              "spruchkoerper_typ",
              "spruchkoerper_az",
              "registerzeichen",
              "verfahrensart",
              "eingangsnummer",
              "eingangsjahr_az",
              "eingangsjahr_iso",
              "entscheidungsjahr",
              "kollision",
              "name",
              "band",
              "seite",  
              "aktenzeichen",
              "aktenzeichen_alle",
              "ecli",
              "zitiervorschlag",
              "kurzbeschreibung",
              "pressemitteilung",
              "praesi",
              "v_praesi",
              "richter",
              "zeichen",
              "tokens",
              "typen",            
              "saetze",
              "version",
              "doi_concept",      
              "doi_version",
              "lizenz"))

#'\newpage
#+
#'### Variablen sortieren: Segmentiert


setcolorder(dt.segmented.full,
            c("doc_id",
              "text",
              "segment",
              "gericht",
              "datum",
              "entscheidung_typ", 
              "spruchkoerper_typ",
              "spruchkoerper_az",
              "registerzeichen",
              "verfahrensart",
              "eingangsnummer",
              "eingangsjahr_az",
              "eingangsjahr_iso",
              "entscheidungsjahr",
              "kollision",
              "name",
              "band",
              "seite",  
              "aktenzeichen",
              "aktenzeichen_alle",
              "ecli",
              "zitiervorschlag",
              "kurzbeschreibung",
              "pressemitteilung",
              "praesi",
              "v_praesi",
              "richter",
              "version",
              "doi_concept",      
              "doi_version",
              "lizenz"))


#'\newpage
#'## Anzahl Variablen der Datensätze

length(txt.bverfg)
length(meta.bverfg)
length(txt.annotated)
length(dt.segmented.full)


#'## Alle Variablen-Namen der Datensätze

names(txt.bverfg)
names(meta.bverfg)
names(txt.annotated)
names(dt.segmented.full)




#'# CSV-Dateien erstellen

#'## CSV mit vollem Datensatz speichern

csvname.full <- paste(prefix.files,
                      "DE_CSV_Datensatz.csv",
                      sep = "_")

fwrite(txt.bverfg,
       csvname.full,
       na = "NA")




#'## CSV mit Metadaten speichern
#' Diese Datei ist grundsätzlich identisch mit dem eigentlichen Datensatz, nur ohne den Text der Entscheidungen.

csvname.meta <- paste(prefix.files,
                      "DE_CSV_Metadaten.csv",
                      sep = "_")

fwrite(meta.bverfg,
       csvname.meta,
       na = "NA")



#'## CSV mit Segmenten speichern

csvname.segmented <- paste(prefix.files,
                           "DE_CSV_Segmentiert.csv",
                           sep = "_")

fwrite(dt.segmented.full,
       csvname.segmented,
       na = "NA")



#'## CSV mit Annotationen speichern

if (config$annotate$toggle == TRUE){

    csvname.annotated <- paste(prefix.files,
                               "DE_CSV_Annotiert.csv",
                               sep = "_")

    fwrite(txt.annotated,
           csvname.annotated,
           na = "NA")

}




#'# Dateigrößen analysieren

#+
#'## Gesamtgröße

#'### Korpus-Objekt in RAM (MB)

print(object.size(txt.bverfg),
      standard = "SI",
      humanReadable = TRUE,
      units = "MB")


#'### CSV Korpus (MB)
file.size(csvname.full) / 10 ^ 6

#'### CSV Metadaten (MB)
file.size(csvname.meta) / 10 ^ 6

#'### CSV Annotiert (MB)
file.size(csvname.annotated) / 10 ^ 6

#'### CSV Segmentiert (MB)
file.size(csvname.segmented) / 10 ^ 6


#'### PDF-Dateien (MB)

files.pdf <- list.files(pattern = "\\.pdf$",
                        ignore.case = TRUE)

pdf.MB <- file.size(files.pdf) / 10^6
sum(pdf.MB)



#'### TXT-Dateien (MB)

files.txt <- list.files(pattern = "\\.txt$",
                        ignore.case = TRUE)

txt.MB <- file.size(files.txt) / 10^6
sum(txt.MB)





#'\newpage
#'## Diagramm: Verteilung der Dateigrößen (PDF)

dt.plot <- data.table(pdf.MB)

#+ CE-BVerfG_14_Density_Dateigroessen_PDF, fig.height = 6, fig.width = 9
ggplot(data = dt.plot,
       aes(x = pdf.MB)) +
    geom_density(fill = "#ca2129") +
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    theme_bw() +
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Dateigrößen (PDF)"),
        caption = caption,
        x = "Dateigröße in MB",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        panel.spacing = unit(0.1, "lines"),
        plot.margin = margin(10, 20, 10, 10)
    )


#'\newpage
#'## Diagramm: Verteilung der Dateigrößen (TXT)

dt.plot <- data.table(txt.MB)

#+ CE-BVerfG_15_Density_Dateigroessen_TXT, fig.height = 6, fig.width = 9
ggplot(data = dt.plot,
       aes(x = txt.MB)) +
    geom_density(fill = "#ca2129") +
    scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
                  labels = trans_format("log10", math_format(10^.x)))+
    annotation_logticks(sides = "b")+
    theme_bw() +
    labs(
        title = paste(prefix.figuretitle,
                      "| Verteilung der Dateigrößen (TXT)"),
        caption = caption,
        x = "Dateigröße in MB",
        y = "Dichte"
    )+
    theme(
        text = element_text(size = 14),
        plot.title = element_text(size = 14,
                                  face = "bold"),
        legend.position = "none",
        panel.spacing = unit(0.1, "lines"),
        plot.margin = margin(10, 20, 10, 10)
    )



#'# Erstellen der ZIP-Archive

#+
#'## Verpacken der CSV-Dateien

#+
#'### Vollständiger Datensatz


#+ results = 'hide'
csvname.full.zip <- gsub(".csv",
                         ".zip",
                         csvname.full)

zip(csvname.full.zip,
    csvname.full)

unlink(csvname.full)


#+
#'### Metadaten


#+ results = 'hide'
csvname.meta.zip <- gsub(".csv",
                         ".zip",
                         csvname.meta)

zip(csvname.meta.zip,
    csvname.meta)

unlink(csvname.meta)


#+
#'### Segmentiert

#+ results = 'hide'
csvname.segmented.zip <- gsub(".csv",
                              ".zip",
                              csvname.segmented)

zip(csvname.segmented.zip,
    csvname.segmented)

unlink(csvname.segmented)


#+
#'### Annotiert


#+ results = 'hide'
if (config$annotate$toggle == TRUE){

    csvname.annotated.zip <- gsub(".csv",
                                  ".zip",
                                  csvname.annotated)

    zip(csvname.annotated.zip,
        csvname.annotated)

    unlink(csvname.annotated)

}


#'## Verpacken der PDF-Dateien

files.pdf <- list.files(pattern = "\\.pdf",
                         ignore.case = TRUE)

#+ results = 'hide'
zip(paste(prefix.files,
          "DE_PDF_Datensatz.zip",
          sep = "_"),
    files.pdf)

unlink(files.pdf)



#'## Verpacken der HTML-Dateien

files.html <- list.files(pattern = "\\.html",
                         ignore.case = TRUE)

#+ results = 'hide'
zip(paste(prefix.files,
          "DE_HTML_Datensatz.zip",
          sep = "_"),
    files.html)

unlink(files.html)




#'## Verpacken der TXT-Dateien


files.txt <- list.files(pattern = "\\.txt",
                        ignore.case = TRUE)

#+ results = 'hide'
zip(paste(prefix.files,
          "DE_TXT_Datensatz.zip",
          sep = "_"),
    files.txt)

unlink(files.txt)




#'## Verpacken der Analyse-Dateien

zip(paste0(prefix.files,
           "_DE_ANALYSE.zip"),
    basename(dir.analysis))




#'## Verpacken der Source-Dateien

files.source <- c(list.files(pattern = "\\.R$|\\.toml$"),
                  "R-fobbe-proto-package",
                  "buttons",
                  "data",
                  "functions",
                  "tex",
                  "gpg",
                  list.files(pattern = "renv\\.lock|\\.Rprofile",
                             all.files = TRUE),
                  list.files("renv",
                             pattern = "activate\\.R",
                             full.names = TRUE))


files.source <- grep("spin",
                     files.source,
                     value = TRUE,
                     ignore.case = TRUE,
                     invert = TRUE)

zip(paste(prefix.files,
           "Source_Files.zip",
          sep = "_"),
    files.source)





#'# Kryptographische Hashes
#' Dieses Modul berechnet für jedes ZIP-Archiv zwei Arten von Hashes: SHA2-256 und SHA3-512. Mit diesen kann die Authentizität der Dateien geprüft werden und es wird dokumentiert, dass sie aus diesem Source Code hervorgegangen sind. Die SHA-2 und SHA-3 Algorithmen sind äußerst resistent gegenüber *collision* und *pre-imaging* Angriffen, sie gelten derzeit als kryptographisch sicher. Ein SHA3-Hash mit 512 bit Länge ist nach Stand von Wissenschaft und Technik auch gegenüber quantenkryptoanalytischen Verfahren unter Einsatz des *Grover-Algorithmus* hinreichend resistent.


#+
#'## Liste der ZIP-Archive erstellen
files.zip <- list.files(pattern = "\\.zip$",
                        ignore.case = TRUE)


#'## Funktion anzeigen
#+ results = "asis"
print(f.dopar.multihashes)


#'## Hashes berechnen
multihashes <- f.dopar.multihashes(files.zip)


#'## In Data Table umwandeln
setDT(multihashes)



#'## Index hinzufügen
multihashes$index <- seq_len(multihashes[,.N])

#'\newpage
#'## In Datei schreiben
fwrite(multihashes,
       file.path("output",
                 paste(prefix.files,
                       "KryptographischeHashes.csv",
                       sep = "_")),
       na = "NA")


#'## Leerzeichen hinzufügen um Zeilenumbruch zu ermöglichen
#' Hierbei handelt es sich lediglich um eine optische Notwendigkeit. Die normale 128 Zeichen lange Zeichenfolge wird ansonsten nicht umgebrochen und verschwindet über die Seitengrenze. Das Leerzeichen erlaubt den automatischen Zeilenumbruch und damit einen für Menschen sinnvoll lesbaren Abdruck im Codebook. Diese Variante wird nur zur Anzeige verwendet und danach verworfen.

multihashes$sha3.512 <- paste(substr(multihashes$sha3.512, 1, 64),
                              substr(multihashes$sha3.512, 65, 128))



#'## In Bericht anzeigen

kable(multihashes[,.(index,filename)],
      format = "latex",
      align = c("p{1cm}",
                "p{13cm}"),
      booktabs = TRUE,
      longtable = TRUE)


#'\newpage
kable(multihashes[,.(index,sha2.256)],
      format = "latex",
      align = c("c",
                "p{13cm}"),
      booktabs = TRUE,
      longtable = TRUE)


kable(multihashes[,.(index,sha3.512)],
      format = "latex",
      align = c("c",
                "p{13cm}"),
      booktabs = TRUE,
      longtable = TRUE)



#'# Aufräumen

files.output <- list.files(pattern = "\\.zip")

output.destination <- file.path("output",
                                 files.output)

print(files.output)

file.rename(files.output,
            output.destination)






#'# Abschluss


#+
#'## Datumsstempel
print(datestamp)


#'## Datum und Uhrzeit (Anfang)
print(begin.script)


#'## Datum und Uhrzeit (Ende)
end.script <- Sys.time()
print(end.script)

#'## Laufzeit des gesamten Skriptes
print(end.script - begin.script)


#'## Warnungen
warnings()



#'# Parameter für strenge Replikationen

system2("openssl", "version", stdout = TRUE)

sessionInfo()


#'# Literaturverzeichnis
