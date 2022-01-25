#'---
#'title: "Codebook | Corpus der Entscheidungen des Bundesverfassungsgerichts"
#'author: Seán Fobbe
#'geometry: margin=3cm
#'papersize: a4
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

#'\newpage

#+ echo = FALSE 
knitr::opts_chunk$set(fig.pos = "center",
                      echo = FALSE,
                      warning = FALSE,
                      message = FALSE)


############################
### Packages
############################

#+

library(RcppTOML)     # Verarbeitung von TOML-Format
library(knitr)        # Professionelles Reporting
library(kableExtra)   # Verbesserte Automatisierte Tabellen
library(magick)       # Fortgeschrittene Verarbeitung von Grafiken
library(parallel)     # Parallelisierung in Base R
library(ggplot2)      # Fortgeschrittene Datenvisualisierung
library(scales)       # Skalierung von Diagrammen
library(data.table)   # Fortgeschrittene Datenverarbeitung


setDTthreads(threads = detectCores()) 


############################
### Vorbereitung
############################

## Konfiguration einlesen
config <- parseTOML("CE-BVerfG_Config.toml")


files.zip <- list.files("output",
                        pattern = "\\.zip")

datestamp <- unique(tstrsplit(files.zip,
                              split = "_")[[2]])


prefix <- paste0("analyse/",
                 config$project$shortname,
                 "_")

prefix.date <- file.path("output",
                         paste0(config$project$shortname,
                                "_",
                                datestamp,
                                "_"))




############################
### Registerzeichen
############################

## Die Registerzeichen und ihre Bedeutungen stammen aus dem folgenden Datensatz: "Seán Fobbe (2021). Aktenzeichen der Bundesrepublik Deutschland (AZ-BRD). Version 1.0.1. Zenodo. DOI: 10.5281/zenodo.4569564."


## Datensatz herunterladen

if (file.exists("data/AZ-BRD_1-0-1_DE_Registerzeichen_Datensatz.csv") == FALSE){
    download.file("https://zenodo.org/record/4569564/files/AZ-BRD_1-0-1_DE_Registerzeichen_Datensatz.csv?download=1",
 "data/AZ-BRD_1-0-1_DE_Registerzeichen_Datensatz.csv")
    }


## Datensatz einlesen
az.source <- fread("data/AZ-BRD_1-0-1_DE_Registerzeichen_Datensatz.csv")

## Datensatz auf relevante Daten reduzieren
table.registerzeichen <- az.source[stelle == "BVerfG" & position == "hauptzeichen"]



################################
### Einlesen: Frequenztabellen
################################


table.entsch.typ <- fread(paste0(prefix,
                                 "01_Frequenztabelle_var-entscheidung_typ.csv"),
                          drop = 3)

table.spruch.typ <- fread(paste0(prefix,
                                 "01_Frequenztabelle_var-spruchkoerper_typ.csv"),
                          drop = 3)

table.spruch.az <- fread(paste0(prefix,
                                "01_Frequenztabelle_var-spruchkoerper_az.csv"),
                         drop = 3)

table.regz <- fread(paste0(prefix,
                           "01_Frequenztabelle_var-registerzeichen.csv"),
                    drop = 3)

table.jahr.eingangISO <- fread(paste0(prefix,
                                      "01_Frequenztabelle_var-eingangsjahr_iso.csv"),
                               drop = 3)

table.jahr.entscheid <- fread(paste0(prefix,
                                     "01_Frequenztabelle_var-entscheidungsjahr.csv"),
                              drop = 3)

table.output.praesi <- fread(paste0(prefix,
                                    "01_Frequenztabelle_var-praesi.csv"),
                             drop = 3)

table.output.vpraesi <- fread(paste0(prefix,
                                     "01_Frequenztabelle_var-v_praesi.csv"),
                              drop = 3)



######################################
### Einlesen: Personaldaten
######################################


#+
## Personaldaten herunterladen

if (file.exists("data/PVP-FCG_2021-04-08_GermanFederalCourts_Presidents.csv") == FALSE){
    download.file("https://zenodo.org/record/4568682/files/PVP-FCG_2021-04-08_GermanFederalCourts_Presidents.csv?download=1",
 "data/PVP-FCG_2021-04-08_GermanFederalCourts_Presidents.csv")
    }


#+
## Personaldaten einlesen

table.praesi <- fread("data/PVP-FCG_2021-04-08_GermanFederalCourts_Presidents.csv")

table.praesi.daten <- table.praesi[court == "BVerfG", c(2:3, 5:8)]
table.praesi.alter <- table.praesi[court == "BVerfG", c(2:3, 13:15)]


#+
## Personaldaten herunterladen

if (file.exists("data/PVP-FCG_2021-04-08_GermanFederalCourts_VicePresidents.csv") == FALSE){
    download.file("https://zenodo.org/record/4568682/files/PVP-FCG_2021-04-08_GermanFederalCourts_VicePresidents.csv?download=1",
 "data/PVP-FCG_2021-04-08_GermanFederalCourts_VicePresidents.csv")
    }



#+
## Personaldaten einlesen

table.vpraesi <- fread("data/PVP-FCG_2021-04-08_GermanFederalCourts_VicePresidents.csv")

table.vpraesi.daten <- table.vpraesi[court == "BVerfG", c(2:3, 5:8)]
table.vpraesi.alter <- table.vpraesi[court == "BVerfG", c(2:3, 13:15)]




######################################
### Einlesen: Linguistische Kennwerte
######################################


stats.ling <-  fread(paste0(prefix,
                            "00_KorpusStatistik_ZusammenfassungLinguistisch.csv"))

stats.docvars <- fread(paste0(prefix,
                              "00_KorpusStatistik_ZusammenfassungDocvarsQuantitativ.csv"))




######################################
### Einlesen: Datensatz
######################################

### Metadaten

summary.zip <- paste0(prefix.date,
                      "DE_CSV_Metadaten.zip")

summary.corpus <- fread(cmd = paste("unzip -cq",
                                    summary.zip))


### Datensatz
data.zip <- paste0(prefix.date,
                      "DE_CSV_Datensatz.zip")

data.corpus <- fread(cmd = paste("unzip -cq",
                                 data.zip))

### Annotationen
# Hinweis: Direktes einlesen aus ZIP-Datei führt zu segfault. Grund unbekannt.

annotated.zip <- paste(config$project$shortname,
                       datestamp,
                       "DE_CSV_Annotiert.zip",
                       sep = "_")

annotated.csv <- gsub("\\.zip",
                      "\\.csv",
                      annotated.zip)

unzip(file.path("output",
                annotated.zip),
      exdir = ".")

annotated.corpus <- fread(annotated.csv)

unlink(annotated.csv)



################################
### Signaturen bestimmen
################################



hashfile <- paste0(prefix.date,
                  "KryptographischeHashes.csv")

signaturefile <- paste0(prefix.date,
                        "FobbeSignaturGPG_Hashes.gpg")



################################
### Beginn Text
################################



#'# Einführung

#' Das **Bundesverfassungsgericht (BVerfG)** ist das höchste Gericht der Bundesrepublik Deutschland und ein Verfassungsorgan. Als \enquote{Hüter der Verfassung} ist es seit seiner Gründung im Jahr 1951 mit der Auslegung und Durchsetzung des Grundgesetzes betraut.
#'
#' Seine Bedeutung im Verfassungsgefüge der Bundesrepublik Deutschland ist kaum zu überschätzen. So richtet es nicht nur über Streitigkeiten zwischen Verfassungsorganen und über Normenkontrollanträge, welche die Nichtigkeit von Gesetzen zur Folge haben können, sondern auch über \enquote{Verfassungsbeschwerden, die von jedermann mit der Behauptung erhoben werden können, durch die öffentliche Gewalt in einem seiner Grundrechte oder in einem seiner [grundrechtsgleichen Rechte] verletzt zu sein} (Art. 93 Abs. 4b GG). Das Instrument der Verfassungsbeschwerde ist in seiner Beliebtheit und Effektivität in der Geschichte Deutschlands beispiellos und von hoher wissenschaftlicher und praktischer Bedeutung. In nicht wenigen Verfahrensarten haben die Entscheidungen des BVerfG zudem Gesetzeskraft (§ 31 Abs. 2 BVerfGG).
#'
#' 
#'Die quantitative Analyse von juristischen Texten, insbesondere denen des Bundesverfassungsgerichts, ist in den deutschen Rechtswissenschaften ein noch junges und kaum bearbeitetes Feld.\footnote{Besonders positive Ausnahmen finden sich unter: \url{https://www.quantitative-rechtswissenschaft.de/}} Zu einem nicht unerheblichen Teil liegt dies auch daran, dass die Anzahl an frei nutzbaren Datensätzen außerordentlich gering ist.
#' 
#'Die meisten hochwertigen Datensätze lagern (fast) unerreichbar in kommerziellen Datenbanken und sind wissenschaftlich gar nicht oder nur gegen Entgelt zu nutzen. Frei verfügbare Datenbanken wie \emph{Opinio Iuris}\footnote{\url{https://opinioiuris.de/}} und \emph{openJur}\footnote{\url{https://openjur.de/}} verbieten ausdrücklich das maschinelle Auslesen der Rohdaten. Wissenschaftliche Initiativen wie der Juristische Referenzkorpus (JuReKo) sind nach jahrelanger Arbeit hinter verschlossenen Türen verschwunden.
#' 
#'In einem funktionierenden Rechtsstaat muss die Rechtsprechung öffentlich, transparent und nachvollziehbar sein. Im 21. Jahrhundert bedeutet dies auch, dass sie systematischer Überprüfung mittels quantitativen Analysen zugänglich sein muss. Der Erstellung und Aufbereitung des Datensatzes liegen daher die Prinzipien der allgemeinen Verfügbarkeit durch Urheberrechtsfreiheit, strenge Transparenz und vollständige wissenschaftliche Reproduzierbarkeit zugrunde. Die FAIR-Prinzipien (Findable, Accessible, Interoperable and Reusable) für freie wissenschaftliche Daten inspirieren sowohl die Konstruktion, als auch die Art der Publikation.\footnote{Wilkinson, M., Dumontier, M., Aalbersberg, I. et al. The FAIR Guiding Principles for Scientific Data Management and Stewardship. Sci Data 3, 160018 (2016). \url{https://doi.org/10.1038/sdata.2016.18}}



#+
#'# Nutzung

#' Die Daten sind in offenen, interoperablen und weit verbreiteten Formaten (CSV, TXT, PDF) veröffentlicht. Sie lassen sich grundsätzlich mit allen modernen Programmiersprachen (z.B. Python oder R), sowie mit grafischen Programmen nutzen.
#'
#' **Wichtig:** Nicht vorhandene Werte sind sowohl in den Dateinamen als auch in der CSV-Datei mit "NA" codiert.

#+
#'## CSV-Dateien
#' Am einfachsten ist es die **CSV-Dateien** einzulesen. CSV\footnote{Das CSV-Format ist in RFC 4180 definiert, siehe \url{https://tools.ietf.org/html/rfc4180}} ist ein einfaches und maschinell gut lesbares Tabellen-Format. In diesem Datensatz sind die Werte komma-separiert. Jede Spalte entspricht einer Variable, jede Zeile einer Entscheidung. Die Variablen sind unter Punkt \ref{mainvars} genauer erläutert.
#'
#' Hier empfehle ich für **R** dringend das package **data.table** (via CRAN verfügbar). Dessen Funktion **fread()** ist etwa zehnmal so schnell wie die normale **read.csv()**-Funktion in Base-R. Sie erkennt auch den Datentyp von Variablen sicherer. Ein Vorschlag:

#+ eval = FALSE, echo = TRUE
library(data.table)
dt.bverfg <- fread("filename.csv")


#+
#'## TXT-Dateien
#'Die **TXT-Dateien** inklusive Metadaten können zum Beispiel mit **R** und dem package **readtext** (via CRAN verfügbar) eingelesen werden. Ein Vorschlag:

#+ eval = FALSE, echo = TRUE
library(readtext)
df.bverfg <- readtext("*.txt",
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




#+
#'# Konstruktion


#+
#'## Beschreibung des Datensatzes
#'Dieser Datensatz ist eine digitale Zusammenstellung von möglichst allen Entscheidungen, die auf der amtlichen Internetpräsenz des Bundesverfassungsgerichts (BVerfG) veröffentlicht sind. Er enthält alle Entscheidungen, die auf der offiziellen Webseite des Bundesverfassungsgerichts am jeweiligen Stichtag veröffentlicht waren. Die Stichtage für jede Version entsprechen exakt der Versionsnummer.
#'
#'Zusätzlich zu den einfach maschinenlesbaren Formaten (TXT und CSV) sind die PDF-Rohdaten enthalten, damit Analyst:innen gegebenenfalls ihre eigene Konvertierung vornehmen können. Die PDF-Rohdaten wurden inhaltlich nicht verändert und nur die Dateinamen angepasst um die Lesbarkeit für Mensch und Maschine zu verbessern.




#+
#'## Datenquellen

#'\begin{centering}
#'\begin{longtable}{P{5cm}p{9cm}}

#'\toprule

#' Datenquelle & Fundstelle \\

#'\midrule

#' Primäre Datenquelle & \url{https://www.bundesverfassungsgericht.de}\\
#' Source Code & \url{\softwareversionurldoi}\\
#' Entscheidungsnamen & \url{\softwareversionurldoi}\\
#' BVerfGE-Fundstellen & \url{\softwareversionurldoi}\\
#' Personendaten & \url{\personendatenurldoi}\\
#' Registerzeichen & \url{\aktenzeichenurldoi}\\

#'\bottomrule

#'\end{longtable}
#'\end{centering}


#' Die Personendaten stammen aus folgendem Datensatz: \enquote{Seán Fobbe and Tilko Swalve (2021). Presidents and Vice-Presidents of the Federal Courts of Germany (PVP-FCG). Version 2021-04-08. Zenodo. DOI: 10.5281/zenodo.4568682}.
#' 
#' Die Tabelle der Registerzeichen und der ihnen zugeordneten Verfahrensarten stammt aus dem folgenden Datensatz: "Seán Fobbe (2021). Aktenzeichen der Bundesrepublik Deutschland (AZ-BRD). Version 1.0.1. Zenodo. DOI: 10.5281/zenodo.4569564."


#+
#'## Sammlung der Daten
#'Die Daten wurden unter Beachtung des Robot Exclusion Standard (RES) gesammelt. Der Abruf geschieht ausschließlich über TLS-verschlüsselte Verbindungen. Die Entscheidungen sind laut dem Gericht anonymisiert, aber ungekürzt.
#'

#+
#'## Source Code und Compilation Report
#' Der gesamte Source Code --- sowohl für die Erstellung des Datensatzes, als auch für dieses Codebook --- ist öffentlich einsehbar und dauerhaft erreichbar im wissenschaftlichen Archiv des CERN unter dieser Addresse hinterlegt: \softwareversionurldoi
#'
#' 
#' Mit jeder Kompilierung des vollständigen Datensatzes wird auch ein umfangreicher **Compilation Report** in einem attraktiv designten PDF-Format erstellt (ähnlich diesem Codebook). Der Compilation Report enthält den vollständigen Source Code, dokumentiert relevante Rechenergebnisse, gibt sekundengenaue Zeitstempel an und ist mit einem klickbaren Inhaltsverzeichnis versehen. Er ist zusammen mit dem Source Code hinterlegt. Wenn Sie sich für Details des Erstellungs-Prozesses interessieren, lesen Sie diesen bitte zuerst.

#+
#'## Grenzen des Datensatzes
#'Nutzer sollten folgende wichtige Grenzen beachten:
#' 
#'\begin{enumerate}
#'\item Der Datensatz enthält nur das, was das Gericht auch tatsächlich veröffentlicht, nämlich begründete Entscheidungen (\emph{publication bias}). Laut dem BVerfG sind dies \enquote{alle Senatsentscheidungen (nicht aber Nebenentscheidungen wie z.B. Streitwertbeschlüsse und Kostenfestsetzungen) und viele begründete Kammerbeschlüsse}.\footnote{\url{https://www.bundesverfassungsgericht.de/DE/Entscheidungen/Entscheidungen/Entscheidungen.html}} Bei mehreren gleichgelagerten Sachverhalten wird nur das Pilotverfahren veröffentlicht.
#'\item Es kann aufgrund technischer Grenzen bzw. Fehler sein, dass manche --- im Grunde verfügbare --- Entscheidungen nicht oder nicht korrekt abgerufen werden (\emph{automation bias}).
#'\item Es werden nur PDF- und HTML-Dateien abgerufen (\emph{file type bias}). Manche Entscheidungen sind nur als HTML verfügbar. Die Metadaten der Entscheidungen ohne PDF-Datei werden explizit im Compilation Report dokumentiert.
#'\item Erst ab dem Jahr 1998 sind begründete Entscheidungen des BVerfG einigermaßen vollständig veröffentlicht, auch wenn frühere Entscheidungen vereinzelt auf der Webseite verfügbar sind (\emph{temporal bias}). Die Frequenztabellen geben hierzu genauer Auskunft.
#'\end{enumerate}


#+
#'## Urheberrechtsfreiheit von Rohdaten und Datensatz 

#'An den Entscheidungstexten und amtlichen Leitsätzen besteht gem. § 5 Abs. 1 UrhG kein Urheberrecht, da sie amtliche Werke sind. § 5 UrhG ist auf amtliche Datenbanken analog anzuwenden (BGH, Beschluss vom 28.09.2006, I ZR 261/03, \enquote{Sächsischer Ausschreibungsdienst}).
#'
#' Der HTML-Quelltext wurde --- wie in jeder HTML-Datei selbst dokumentiert ist --- mit dem \enquote{Government Site Builder} der Bundesverwaltung erstellt, d.h. computergeneriert. Durch Maschinen generierte Texte sind keine \enquote{persönliche geistige Schöpfung} iSv § 2 Abs. 2 UrhG und daher urheberrechtlich nicht geschützt. Den verbleibenden Text-Bestandteilen (z.B. Buttons) fehlt es mindestens an der Schöpfungshöhe. Bilder oder andere Texte als Entscheidungstexte werden nicht abgerufen.
#'
#' Alle eigenen Beiträge (z.B. durch Zusammenstellung und Anpassung der Metadaten) und damit den gesamten Datensatz stelle ich gemäß einer \emph{CC0 1.0 Universal Public Domain Lizenz} vollständig urheberrechtsfrei.



#+
#'## Metadaten

#+
#'### Allgemein
#'Die Metadaten wurden weitgehend aus den Hyperlinks zur jeweiligen Datei und dem HTML-Quelltext extrahiert. Hinzugefügt wurden von mir eine Reihe weitere Variablen, sowie Unter- und Trennstriche um die Maschinenlesbarkeit zu erleichten. Der volle Satz an Metadaten ist nur in den CSV-Dateien enthalten. Alle hinzugefügten Metadaten sind zusammen mit dem Source Code vollständig maschinenlesbar dokumentiert und liegen entweder im CSV-Format vor oder sind direkt im Source Code enthalten.
#' 
#'Die Dateinamen der PDF- und TXT-Dateien enthalten Gerichtsname, Datum (Langform nach ISO-8601, d.h. YYYY-MM-DD), den Typ des Spruchkörpers, das offizielle Aktenzeichen, eine Kollisions-ID, den Namen der Entscheidung, sowie die BVerfGE-Fundstelle (Band und Seite).


#+
#'### Schema für die Dateinamen

#'\begin{verbatim}
#'[gericht]_[datum]_[spruchkoerper_typ]_[spruchkoerper_az]_[registerzeichen]_
#'[eingangsnummer]_[eingangsjahr_az]_[kollision]_[name]_[band]_[seite]
#'\end{verbatim}

#+
#'### Beispiel eines Dateinamens

#'\begin{verbatim}
#'BVerfG_1997-07-08_S_1_BvR_1243_95_NA_Parteilehrer_96_152.txt
#'\end{verbatim}

#+
#'## Qualitätsprüfung

#'Die Typen der Variablen wurden mit \emph{regular expressions} strikt validiert. Die möglichen Werte der jeweiligen Variablen wurden zudem durch Frequenztabellen und Visualisierungen auf ihre Plausibilität geprüft. Insgesamt werden zusammen mit jeder Kompilierung Dutzende Tests zur Qualitätsprüfung durchgeführt. Alle Ergebnisse der Qualitätsprüfungen sind aggregiert im Compilation Report und einzeln im Archiv \enquote{ANALYSE} zusammen mit dem Datensatz veröffentlicht.

#+
#'## Grafische Darstellung
#'
#' Die Robenfarbe der Bundesverfassungsrichter ist \enquote{scharlachrot}. Der Hex-Wert hierfür ist \#ca2129. Das ist besonders bei der Erstellung thematisch passender Graphen hilfreich. Alle im Compilation Report und diesem Codebook präsentierten Graphen sind in diesem scharlachrot gehalten.






#+
#'# Varianten und Zielgruppen

#' Dieser Datensatz ist in verschiedenen Varianten verfügbar, die sich an unterschiedliche Zielgruppen richten. Zielgruppe sind nicht nur quantitativ forschende Rechtswissenschaftler:innen, sondern auch traditionell arbeitende Jurist:innen. Idealerweise müssen quantitative Methoden ohnehin immer durch qualitative Interpretation, Theoriebildung und kritische Auseinandersetzung verstärkt werden (\emph{mixed methods approach}).
#'
#' Lehrende werden zudem von den vorbereiteten Tabellen und Diagrammen besonders profitieren, die bei der Erläuterung der Charakteristika der Daten hilfreich sein können und Zeit im universitären Alltag sparen. Alle Tabellen und Diagramme liegen auch als separate Dateien vor um sie einfach z.B. in Präsentations-Folien oder Handreichungen zu integrieren.

#'\begin{centering}
#'\begin{longtable}{P{3.5cm}p{10.5cm}}

#'\toprule

#'Variante & Zielgruppe und Beschreibung\\

#'\midrule
#'
#'\endhead

#'PDF & \textbf{Traditionelle juristische Forschung.} Die PDF-Dokumente wie sie vom Bundesverfassungsgericht auf der amtlichen Webseite bereitgestellt werden, jedoch verbessert durch semantisch hochwertige Dateinamen, die der leichteren Auffindbarkeit von Entscheidungen dienen. Die Dateinamen sind so konzipiert, dass sie auch für die traditionelle qualitative juristische Arbeit einen erheblichen Mehrwert bieten. Im Vergleich zu den CSV-Dateien enthalten die Dateinamen nur einen reduzierten Umfang an Metadaten, um Kompatibilitätsprobleme zu vermeiden und die Lesbarkeit zu verbessern.\\
#' CSV\_Datensatz & \textbf{Legal Tech/Quantitative Forschung.} Diese CSV-Datei ist die für statistische Analysen empfohlene Variante des Datensatzes. Sie enthält den Volltext aller Entscheidungen, sowie alle in diesem Codebook beschriebenen Metadaten. Jede Spalte entspricht einer Variable, jede Zeile einer Entscheidung.\\
#' CSV\_Metadaten & \textbf{Legal Tech/Quantitative Forschung.} Wie die vorige CSV-Variante, nur ohne die Entscheidungstexte. Sinnvoll für Analyst:innen, die sich nur für die Metadaten interessieren und Speicherplatz sparen wollen.  Jede Spalte entspricht einer Variable, jede Zeile einer Entscheidung.\\
#' CSV\_Annotiert & \textbf{Legal Tech/Quantitative Forschung.} Alle Entscheidungen in tokenisierter Form mit linguistischen Annotationen. Beachten Sie bitte die besondere Variablen-Struktur unter Punkt \ref{annovars}.  Jede Spalte entspricht einer Variable, jede Zeile einem Token.\\
#' CSV\_Segmentiert & \textbf{Legal Tech/Quantitative Forschung. Experimentell!} Alle Entscheidungen in segmentierter Form, d.h. sie sind in einzelne Text-Abschnitte unterteilt (z.B. Leitsätze, Entscheidungsformel, Begründung, Unterschriften). Manche Teile einer Entscheidung sind bewusst nicht enthalten (z.B. lange Zitate aus Gesetzen), weil diese nicht die eigentliche Aktivität des Gerichts wiedergeben. Die Nummerierung der Leitsätze und Absätze der Begründung sollte in der Regel (aber nicht immer!) der originalen Nummerierung in der PDF-Fassung entsprechen. Diese Fassung wurde aus den HTML-Dateien gewonnen und ist noch experimentell. \\
#' HTML & \textbf{Legal Tech/Quantitative Forschung.} Die HTML-Dokumente wie sie vom Bundesverfassungsgericht auf der amtlichen Webseite bereitgestellt werden, mit originalen Dateinamen.\\
#' TXT & \textbf{Subsidiär für alle Zielgruppen.} Diese Variante enthält die vollständigen aus den PDF-Dateien extrahierten Entscheidungstexte, aber nur einen reduzierten Umfang an Metadaten, der dem der PDF-Dateien entspricht. Die TXT-Dateien sind optisch an das Layout der PDF-Dateien angelehnt. Geeignet für qualitative Forscher:innen, die nur wenig Speicherplatz oder eine langsame Internetverbindung zur Verfügung haben oder für quantitative Forscher:innen, die beim Einlesen der CSV-Dateien Probleme haben.\\
#' ANALYSE & \textbf{Alle Lehrenden und Forschenden.} Dieses Archiv enthält alle während dem Kompilierungs- und Prüfprozess erstellten Tabellen (CSV) und Diagramme (PDF, PNG) im Original. Sie sind inhaltsgleich mit den in diesem Codebook verwendeten Tabellen und Diagrammen. Das PDF-Format eignet sich besonders für die Verwendung in gedruckten Publikationen, das PNG-Format besonders für die Darstellung im Internet. Analyst:innen mit fortgeschrittenen Kenntnissen in R können auch auf den Source Code zurückgreifen. Empfohlen für Nutzer:innen die einzelne Inhalte aus dem Codebook für andere Zwecke (z.B. Präsentationen, eigene Publikationen) weiterverwenden möchten.\\


#'\bottomrule

#'\end{longtable}
#'\end{centering}



#+
#'\newpage



#+
#'# Variablen (Allgemein)
#'\label{mainvars}

#+
#'## Hinweise

#'\begin{itemize}
#'\item Fehlende Werte sind immer mit \enquote{NA} codiert
#'\item Strings können grundsätzlich alle in UTF-8 definierten Zeichen (insbesondere Buchstaben, Zahlen und Sonderzeichen) enthalten.
#'\end{itemize}

#+
#'## Erläuterungen der einzelnen Variablen

#'\ra{1.3}
#' 
#'\begin{centering}
#'\begin{longtable}{P{3.5cm}P{3cm}p{8cm}}
#' 
#'\toprule
#' 
#'Variable & Typ & Erläuterung\\
#'
#' 
#'\midrule
#'
#'\endhead
#' 
#' doc\_id & String & (Nur CSV-Datei) Der Name der extrahierten TXT-Datei.\\
#' text  & String & (Nur CSV-Datei) Der vollständige Inhalt der Entscheidung, so wie er in der von www.bundesverfassungsgericht.de heruntergeladenen PDF-Datei dokumentiert ist. In der segmentierten Variante stammt der Text aus der HTML-Dateien.\\
#' segment & String & (Nur segmentierte Variante) Das Segment der Entscheidung. Bezieht sich auf die Variable \enquote{text}. Segmentarten sind \enquote{leitsatz} (Leitsätze)), \enquote{gegenstand} (Entscheidungsgegenstand), \enquote{formel} (Entscheidungsformel), \enquote{tenor} (Tenor), \enquote{gruende} (Entscheidungsgründe, ggf. mit Anmerkung ob Sondervotum) und \enquote{unterschriften} (Unterschriften der Richter:innen). Die Erkennung von Sondervoten ist noch fehleranfällig. Einzelne Segmente sind mit einer Kombination aus Art und Ordinalzahl definiert, z.B. \enquote{gruende-133-sondervotum}.\\
#' gericht & String & In diesem Datensatz ist nur der Wert \enquote{BVerfG} vergeben. Dies ist der ECLI-Gerichtscode für \enquote{Bundesverfassungsgericht}. Diese Variable dient vor allem zur einfachen und transparenten Verbindung der Daten mit anderen Datensätzen.\\
#' datum & Datum (ISO) & Das Datum der Entscheidung im Format YYYY-MM-DD (Langform nach ISO-8601). Die Langform ist für Menschen einfacher lesbar und wird maschinell auch öfter automatisch als Datumsformat erkannt.\\
#' entscheidung\_typ & String &  (Nur CSV-Datei) Der Typ der Entscheidung. Es sind die Werte \enquote{B} (Beschluss) und \enquote{U} (Urteil) vergeben. Wurde durch \emph{regular expressions} aus der Variable \enquote{zitiervorschlag} berechnet.\\
#' spruchkoerper\_typ & String & Der Typ des Spruchkörpers. Es sind die Werte \enquote{K} (Kammer), \enquote{S} (Senat), \enquote{P} (Plenum) und \enquote{B} (Beschwerdekammer gem. § 97c BVerfGG) vergeben.\\
#' spruchkoerper\_az & Natürliche Zahl & Der im Aktenzeichen angegebene Spruchkörper. Es sind nur die Werte \enquote{1} und \enquote{2} vergeben. Die Werte stehen für den 1. oder 2. Senat des Gerichts. Für Verzögerungsentscheidungen der Beschwerdekammer ist der Wert \enquote{NA}. \textbf{Achtung:} Um die Entscheidungen eines bestimmten Senats zu analysieren reicht es nicht, die Variable \enquote{spruchkoerper\_az} zu nutzen, es muss zusätzlich noch die Variable \enquote{spruchkoerper\_typ} auf \enquote{S} gesetzt werden, weil ansonsten noch mit dem Senat assoziierte Entscheidungen seiner Kammern und des Plenums mit ausgewählt werden. \\
#' registerzeichen & String & Das amtliche Registerzeichen. Es gibt die Verfahrensart an, in der die Entscheidung ergangen ist. Eine Erläuterung der Registerzeichen findet sich unter Punkt \ref{register}.\\
#' verfahrensart & String &  Die ausführliche Beschreibung der Verfahrensart, die dem Registerzeichen zugeordnet ist.  Eine Erläuterung der Registerzeichen und der zugehörigen Verfahrensarten findet sich unter Punkt \ref{register}.\\
#' eingangsnummer & Natürliche Zahl & Verfahren des gleichen Eingangsjahres erhalten vom Gericht eine Nummer in der Reihenfolge ihres Eingangs. Die Zahl ist in den Dateinamen mit führenden Nullen (falls <1000) codiert.\\
#' eingangsjahr\_az & Natürliche Zahl & Das im Aktenzeichen angegebene Jahr in dem das Verfahren beim Gericht anhängig wurde. Das Format ist eine zweistellige Jahreszahl (YY).\\
#' eingangsjahr\_iso & Natürliche Zahl &  (Nur CSV-Datei) Das nach ISO-8601 codierte Jahr in dem das Verfahren beim Bundesverfassungsgericht anhängig wurde. Das Format ist eine vierstellige Jahreszahl (YYYY), um eine maschinenlesbare und eindeutige Jahreszahl für den Eingang zur Verfügung zu stellen. Wurde aus der Variable \enquote{eingangsjahr\_az} durch den Autor des Datensatzes berechnet, unter der Annahme, dass Jahreszahlen über 50 dem 20. Jahrhundert zugeordnet sind und andere Jahreszahlen dem 21. Jahrhundert.\\
#' entscheidungsjahr & Natürliche Zahl & (Nur CSV-Datei) Das Jahr in dem die Entscheidung ergangen ist. Das Format ist eine vierstellige Jahreszahl (YYYY). Wurde aus der Variable \enquote{datum} durch den Autor des Datensatzes berechnet.\\
#' kollision & String & In wenigen Fällen sind am gleichen Tag mehrere Entscheidungen zum gleichen Aktenzeichen ergangen. Diese werden ab der zweiten Entscheidung pro Tag durch eine Kollisions-ID mit einem Kleinbuchstaben ausdifferenziert. Für die erste Entscheidung ist der Wert der Variable \enquote{NA}, also nicht vorhanden. Die zweite Entscheidung ist mit \enquote{a} identifiziert, die dritte mit \enquote{b} und so fort. In der offiziellen Beschreibung der ECLI-Ordinalzahl wird diese Variable als \enquote{Kollisionsnummer} bezeichnet. Buchstaben sind allerdings keine Nummern, daher die abweichende Bezeichnung. In einem einzigen Fall ist tatsächlich eine \enquote{1} vergeben. Es handelt sich hier vermutlich um einen Fehler.\\
#' name & String & Der Name der Entscheidung. Für viele Entscheidungen aus der amtlichen Sammlung sind bekannte Namen vorhanden, diese wurden benutzt soweit möglich und auffindbar. Für weniger bekannte Entscheidungen wurde ein möglichst informativer Name vom Autor vergeben. Die konkrete Darstellung (ohne Leerzeichen, mit Bindestrichen usw.) ist Gründen der maschinellen Lesbarkeit geschuldet.\\
#' band & Natürliche Zahl & Der Band der amtlichen Sammlung in dem die Entscheidung veröffentlicht ist.\\
#' seite & Natürliche Zahl & Die genaue Fundstelle (Seitenzahl) der Entscheidung im jeweiligen Band der amtlichen Sammlung. Nur sinnvoll nutzbar im Zusammenspiel mit der Variable \enquote{band}.\\
#' aktenzeichen & String & (Nur CSV-Datei) Das amtliche Aktenzeichen. Die Variable wurde aus den Variablen \enquote{spruchkoerper\_az}, \enquote{registerzeichen}, \enquote{eingangsnummer} und \enquote{eingangsjahr\_az} durch den Autor des Datensatzes berechnet. Im Falle mehrere verbundener Verfahren mit einer einheitlichen Entscheidung ist dies das Aktenzeichen des Pilotverfahrens.\\
#' aktenzeichen\_alle & String & (Nur CSV-Datei) Alle Aktenzeichen der von der Entscheidung betroffenen Verfahren, falls es sich um verbunden Verfahren mit einheitlicher Entscheidung handelt. Ansonsten ist der Wert dieser Variable identisch mit der Variable \enquote{aktenzeichen}.\\ 
#' ecli & String & (Nur CSV-Datei) Der European Case Law Identifier (ECLI) der Entscheidung. Jeder Entscheidung ist eine einzigartige ECLI zugewiesen, ggf. mit Kollisisions-ID. Die ECLI ist vor allem dann hilfreich, wenn dieser Datensatz mit anderen Datensätzen zusammengeführt werden und Dopplungen vermieden werden sollen. Alle inhaltlichen Bestandteile der ECLI sind in diesem Datensatz zusätzlich auch anderen und besser verständlichen Variablen zugewiesen. Nutzen Sie bevorzugt diese anderen Variablen, statt Informationen aus der ECLI zu extrahieren. Die Variable wurde aus den Variablen \enquote{entscheidungsjahr}, \enquote{spruchkoerper\_typ}, \enquote{datum}, \enquote{kollision}, \enquote{spruchkoerper\_az}, \enquote{registerzeichen},  \enquote{eingangsnummer} und \enquote{eingangsjahr\_az} durch den Autor des Datensatzes berechnet.\\
#' zitiervorschlag & String & Der vom BVerfG vorgegebene Zitiervorschlag.\\
#' kurzbeschreibung & String & Kurzbeschreibung des Inhalts des Verfahrens wie auf der Website des BVerfG angegeben.\\
#' pressemitteilung & String & Nummer und Datum der zugehörigen Pressemitteilung, falls vorhanden. Ansonsten \enquote{NA}.\\
#' praesi & String & (Nur CSV-Datei) Der Nachname des oder der Präsident:in in dessen/deren Amtszeit das Datum der Entscheidung fällt.\\
#' v\_praesi & String & (Nur CSV-Datei) Der Nachname des oder der Vize-Präsident:in in dessen/deren Amtszeit das Datum der Entscheidung fällt.\\
#' richter & String & (Nur CSV-Datei) Die Nachnamen der Richter:innen, die die Entscheidung unterschrieben haben. Ggf. mit Angabe falls die Person verhindert war. Die einzelnen Namen sind jeweils durch vertikale Striche (\enquote{|}) voneinander getrennt.\\
#' zeichen & Natürliche Zahl & (Nur CSV-Datei) Die Anzahl Zeichen eines Dokumentes.\\
#' tokens & Natürliche Zahl & (Nur CSV-Datei) Die Anzahl Tokens (beliebige Zeichenfolge getrennt durch whitespace) eines Dokumentes. Diese Zahl kann je nach Tokenizer und verwendeten Einstellungen erheblich schwanken. Für diese Berechnung wurde eine reine Tokenisierung ohne Entfernung von Inhalten durchgeführt. Benutzen Sie diesen Wert eher als Anhaltspunkt für die Größenordnung denn als exakte Aussage und führen sie ggf. mit ihrer eigenen Software eine Kontroll-Rechnung durch.\\
#' typen & Natürliche Zahl & (Nur CSV-Datei) Die Anzahl \emph{einzigartiger} Tokens (beliebige Zeichenfolge getrennt durch whitespace) eines Dokumentes. Diese Zahl kann je nach Tokenizer und verwendeten Einstellungen erheblich schwanken. Für diese Berechnung wurde eine reine Tokenisierung und Typenzählung ohne Entfernung von Inhalten durchgeführt. Benutzen Sie diesen Wert eher als Anhaltspunkt für die Größenordnung denn als exakte Aussage und führen sie ggf. mit ihrer eigenen Software eine Kontroll-Rechnung durch.\\
#' saetze & Natürliche Zahl & (Nur CSV-Datei) Die Anzahl Sätze. Die Definition entspricht in etwa dem üblichen Verständnis eines Satzes. Die Regeln für die Bestimmung von Satzanfang und Satzende sind im Detail allerdings sehr komplex und in \enquote{Unicode Standard Annex No 29} beschrieben. Diese Zahl kann je nach Software und verwendeten Einstellungen erheblich schwanken. Für diese Berechnung wurde eine reine Zählung ohne Entfernung von Inhalten durchgeführt. Benutzen Sie diesen Wert eher als Anhaltspunkt für die Größenordnung denn als exakte Aussage und führen sie ggf. mit ihrer eigenen Software eine Kontroll-Rechnung durch.\\
#' version & Datum (ISO) & (Nur CSV-Datei) Die Versionsnummer des Datensatzes im Format YYYY-MM-DD (Langform nach ISO-8601). Die Versionsnummer entspricht immer dem Datum an dem der Datensatz erstellt und die Daten von der Webseite des Gerichts abgerufen wurden.\\
#' doi\_concept & String & (Nur CSV-Datei) Der Digital Object Identifier (DOI) des Gesamtkonzeptes des Datensatzes. Dieser ist langzeit-stabil (persistent). Über diese DOI kann via www.doi.org immer die \textbf{aktuellste Version} des Datensatzes abgerufen werden. Prinzip F1 der FAIR-Data Prinzipien (\enquote{data are assigned globally unique and persistent identifiers}) empfiehlt die Dokumentation jeder Messung mit einem persistenten Identifikator. Selbst wenn die CSV-Dateien ohne Kontext weitergegeben werden kann ihre Herkunft so immer zweifelsfrei und maschinenlesbar bestimmt werden.\\
#' doi\_version & String & (Nur CSV-Datei) Der Digital Object Identifier (DOI) der \textbf{konkreten Version} des Datensatzes. Dieser ist langzeit-stabil (persistent). Über diese DOI kann via www.doi.org immer diese konkrete Version des Datensatzes abgerufen werden. Prinzip F1 der FAIR-Data Prinzipien (\enquote{data are assigned globally unique and persistent identifiers}) empfiehlt die Dokumentation jeder Messung mit einem persistenten Identifikator. Selbst wenn die CSV-Dateien ohne Kontext weitergegeben werden kann ihre Herkunft so immer zweifelsfrei und maschinenlesbar bestimmt werden.\\
#' lizenz & String & Die Lizenz für den Gesamtdatensatz. In diesem Datensatz immer \enquote{Creative Commons Zero 1.0 Universal}.\\
#' 
#'\bottomrule
#' 
#'\end{longtable}
#'\end{centering}

#'\newpage
#+
#'# Variablen (Linguistische Annotationen)
#'\label{annovars}


#+
#'## Datenstruktur 

str(annotated.corpus)


#+
#'## Hinweise

#' Diese Variante des Datensatzes beruht nur auf den Variablen \enquote{doc\_id} und \enquote{text} des regulären Datensatzes, die tokenisiert und mittels der Software \enquote{spacy}\footnote{Die den Annotationen zugrundeliegende Software ist \emph{spacy}, die hier verfügbar ist \url{https://spacy.io/}. Diese wird in R mittels des \emph{spacyr} packages integriert: \url{https://spacyr.quanteda.io/}.} mit linguistischen Annotationen versehen wurden.
#'
#'
#' Die Metadaten des Gesamtdatensatzes sind nicht in der linguistische annotierten Fassung enthalten, weil die Bereitstellung von Metadaten für jedes Token die Dateigröße und damit auch den RAM-Bedarf für Analysen gewaltig steigern würde. Um anhand der Metadaten Teilmengen der linguistischen Annotationen zu bilden, gehen sie bitte wie folgt vor:
#'
#' \begin{enumerate}
#' \item CSV-Datei mit Metadaten einlesen
#' \item Anhand der Metadaten die gewünschte Teilmenge der Dokumente bilden
#' \item CSV-Datei mit Linguistischen Annotationen einlesen
#' \item Die Werte der Variable \enquote{doc\_id} der Teilmenge nutzen um aus den annotierten Daten nur diejenigen herauszufiltern, deren Variable \enquote{doc\_id} mit der Teilmenge übereinstimmt 
#' \end{enumerate}




#'\newpage

#+
#'## Erläuterung der Variablen

#'\ra{1.3}
#' 
#'\begin{centering}
#' 
#'\begin{longtable}{P{3.5cm}P{3cm}p{8cm}}
#' 
#'\toprule
#' 
#'Variable & Typ & Erläuterung\\

#'\midrule
#'
#'\endhead

#' doc\_id & String & Der Dateiname des Dokumentes, aus dem die Tokens stammen. Identische Werte wie im Hauptdatensatz. Geeignet um Metadaten mit den linguistischen Annotationen zu verbinden.\\
#' sentence\_id & Natürliche Zahl & Die Ordinalzahl des Satzes in dem Dokument, dem das Token zugeordnet ist.\\
#' token\_id & Natürliche Zahl & Die Nummer des Tokens in einem Dokument.\\
#' token & String & Einzelne Tokens in der Reihenfolge ihres Vorkommens im jeweiligen Dokument.\\
#' lemma & String & Die lemmatisierte Form des Tokens.\\
#' pos & String & Grobe Annotation des einzelnen Tokens nach dem universal dependency POS tagset, siehe auch \url{http://universaldependencies.org/u/pos/}.\\
#' tag & String & Feine Annotation des einzelnen Tokens mit dem \enquote{de\_core\_news\_sm}-Modell von spacy. Für eine detaillierte Erläuterung der Annotationen siehe: \url{https://spacy.io/models/de}\\
#' head\_token\_id & Natürliche Zahl & Das führende Token.\\
#' dep\_rel & String & Die \emph{dependency relation} zum head\_token.\\
#' entity & String & Erkennung von benannten Entitäten (Named Entity Recoginition).\\
#' nounphrase & String & Erkennung von Nominalphrasen.\\
#' whitespace & Logisch & Ob es sich bei dem Token um Whitespace handelt oder nicht.\\




#'\bottomrule

#'\end{longtable}
#'\end{centering}









#'\newpage
#+
#'# Registerzeichen
#' 
#'\label{register}
#' 
#' Die Tabelle der Registerzeichen und der ihnen zugeordneten Verfahrensarten stammt aus dem folgenden Datensatz: "Seán Fobbe (2021). Aktenzeichen der Bundesrepublik Deutschland (AZ-BRD). Version 1.0.1. Zenodo. DOI: 10.5281/zenodo.4569564."
#'
#' \vspace{0.5cm}


#'\ra{1.2}

kbl(table.registerzeichen[,c(2,5)],
    format = "latex",
    align = c("P{3cm}",
              "p{10cm}"),
    booktabs = TRUE,
    longtable = TRUE,
    col.names = c("Registerzeichen",
                  "Verfahrensart"))





#'\newpage
#+




#+
#'# Präsident:innen

#+
#'## Hinweise
#' \begin{itemize}
#' \item Die Personaldaten stammen aus folgendem Datensatz:  \enquote{Seán Fobbe and Tilko Swalve (2021). Presidents and Vice-Presidents of the Federal Courts of Germany (PVP-FCG). Version 2021-04-08. Zenodo. DOI: 10.5281/zenodo.4568682}.
#' \item Das Datum bezieht sich jeweils auf das Amt als Präsident:in, nicht auf die Amtszeit als Richter:in.
#' \end{itemize}
#'  

#+
#'## Lebensdaten

kable(table.praesi.daten,
      format = "latex",
      align = "l",
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Nachname",
                    "Vorname",
                    "Amtsantritt",
                    "Amtsende",
                    "Geboren",
                    "Gestorben"))

#+
#'## Dienstalter und Lebensalter

kable(table.praesi.alter[grep("VACANCY",
                              table.praesi.daten$name_last,
                              invert = TRUE)],
      format = "latex",
      align = c("l", "l", "c", "c", "c"),
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Nachname",
                    "Vorname",
                    "Alter (Amtsantritt)",
                    "Alter (Amtsende)",
                    "Alter (Tod)"))




#'\newpage
#+
#'# Vize-Präsident:innen

#+
#'## Hinweise
#' \begin{itemize}
#' \item Die Personaldaten stammen aus folgendem Datensatz:  \enquote{Seán Fobbe and Tilko Swalve (2021). Presidents and Vice-Presidents of the Federal Courts of Germany (PVP-FCG). Version 2021-04-08. Zenodo. DOI: 10.5281/zenodo.4568682}.
#' \item Das Datum bezieht sich jeweils auf das Amt als Vize-Präsident:in, nicht auf die Amtszeit als Richter:in.
#' \end{itemize}

#+
#'## Lebensdaten


kable(table.vpraesi.daten,
      format = "latex",
      align = "l",
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Nachname",
                    "Vorname",
                    "Amtsantritt",
                    "Amtsende",
                    "Geboren",
                    "Gestorben"))



#'\newpage
#+
#'##  Dienstalter und Lebensalter


kable(table.vpraesi.alter[grep("VACANCY",
                               table.vpraesi.daten$name_last,
                               invert = TRUE)],
      format = "latex",
      align = c("l", "l", "c", "c", "c"),
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Nachname",
                    "Vorname",
                    "Alter (Amtsantritt)",
                    "Alter (Amtsende)",
                    "Alter (Tod)"))








#'\newpage
#+
#'# Linguistische Kennzahlen

#+
#'## Erläuterung der Kennzahlen und Diagramme

#' Zur besseren Einschätzung des inhaltlichen Umfangs des Korpus dokumentiere ich an dieser Stelle die Verteilung der Werte für einige klassische linguistische Kennzahlen.
#'
#' \medskip
#'
#'\begin{centering}
#'\begin{longtable}{P{3.5cm}p{10.5cm}}

#'\toprule

#'Kennzahl & Definition\\

#'\midrule

#' Zeichen & Zeichen entsprechen grob den \emph{Graphemen}, den kleinsten funktionalen Einheiten in einem Schriftsystem. Beispiel: das Wort \enquote{Richterin} besteht aus 9 Zeichen.\\
#' Tokens & Eine beliebige Zeichenfolge, getrennt durch whitespace-Zeichen, d.h. ein Token entspricht in der Regel einem \enquote{Wort}, kann aber gelegentlich auch sinnlose Zeichenfolgen enthalten, weil es rein syntaktisch berechnet wird.\\
#' Typen & Einzigartige Tokens. Beispiel: wenn das Token \enquote{Verfassungsrecht} zehnmal in einer Entscheidung vorhanden ist, wird es als ein Typ gezählt.\\
#' Sätze & Entsprechen in etwa dem üblichen Verständnis eines Satzes. Die Regeln für die Bestimmung von Satzanfang und Satzende sind im Detail aber sehr komplex und in \enquote{Unicode Standard: Annex No 29} beschrieben.\\

#'\bottomrule

#'\end{longtable}
#'\end{centering}
#'
#' Es handelt sich bei den Diagrammen jeweils um \enquote{Density Charts}, die sich besonders dafür eignen die Schwerpunkte von Variablen mit stark schwankenden numerischen Werten zu visualisieren. Die Interpretation ist denkbar einfach: je höher die Kurve, desto dichter sind in diesem Bereich die Werte der Variable. Der Wert der y-Achse kann außer Acht gelassen werden, wichtig sind nur die relativen Flächenverhältnisse und die x-Achse.
#'
#' Vorsicht bei der Interpretation: Die x-Achse it logarithmisch skaliert, d.h. in 10er-Potenzen und damit nicht-linear. Die kleinen Achsen-Markierungen zwischen den Schritten der Exponenten sind eine visuelle Hilfestellung um diese nicht-Linearität zu verstehen.
#'
#'\bigskip

#'## Werte der Kennzahlen

setnames(stats.ling, c("Kennzahl",
                       "Summe",
                       "Min",
                       "Quart1",
                       "Median",
                       "Mittel",
                       "Quart3",
                       "Max"))

kable(stats.ling,
      digits = 2,
      format.args = list(big.mark = ","),
      format = "latex",
      booktabs = TRUE,
      longtable = TRUE)


#+
#'## Verteilung Zeichen

#' ![](analyse/CE-BVerfG_10_Density_Zeichen-1.pdf)


#+
#'## Verteilung Tokens

#' ![](analyse/CE-BVerfG_11_Density_Tokens-1.pdf)



#+
#'## Verteilung Typen

#' ![](analyse/CE-BVerfG_12_Density_Typen-1.pdf)




#+
#'## Verteilung Sätze

#' ![](analyse/CE-BVerfG_13_Density_Saetze-1.pdf)






    
#' \newpage
#' \ra{1.4}
#+
#'# Inhalt des Korpus

#+
#'## Zusammenfassung

setnames(stats.docvars, c("Variable",
                          "Anzahl",
                          "Min",
                          "Quart1",
                          "Median",
                          "Mittel",
                          "Quart3",
                          "Max"))


kable(stats.docvars,
      digits = 2,
      format = "latex",
      booktabs = TRUE,
      longtable = TRUE)




#'\vspace{1cm}

#'## Nach Typ der Entscheidung

#'\vspace{0.5cm}

#' ![](analyse/CE-BVerfG_02_Barplot_Entscheidung_Typ-1.pdf)

#'\vspace{1cm}

kable(table.entsch.typ,
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Typ",
                    "Entscheidungen",
                    "% Gesamt",
                    "% Kumulativ"))




#+
#'## Nach Typ des Spruchkörpers


#' ![](analyse/CE-BVerfG_03_Barplot_Spruchkoerper_Typ-1.pdf)


#'\vspace{1cm}

kable(table.spruch.typ,
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Typ",
                    "Entscheidungen",
                    "% Gesamt",
                    "% Kumulativ"))






#+
#'## Nach Spruchkörper (Aktenzeichen)


#'\vspace{0.5cm}

#' ![](analyse/CE-BVerfG_04_Barplot_Spruchkoerper_AZ-1.pdf)


#'\vspace{1cm}

kable(table.spruch.az,
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Senat",
                    "Entscheidungen",
                    "% Gesamt",
                    "% Kumulativ"))



#'## Nach Registerzeichen

#'\vspace{0.5cm}

#' ![](analyse/CE-BVerfG_05_Barplot_Registerzeichen-1.pdf)


#'\newpage

kable(table.regz,
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Registerzeichen",
                    "Entscheidungen",
                    "% Gesamt",
                    "% Kumulativ"))


#'\newpage
#'## Nach Präsident:in

#'\vspace{0.5cm}

#' ![](analyse/CE-BVerfG_06_Barplot_PraesidentIn-1.pdf)


#'\vspace{0.5cm}

kable(table.output.praesi,
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Präsident:in",
                    "Entscheidungen",
                    "% Gesamt",
                    "% Kumulativ"))




#'\newpage
#'## Nach Vize-Präsident:in

#'\vspace{0.5cm}

#' ![](analyse/CE-BVerfG_07_Barplot_VizePraesidentIn-1.pdf)

#'\vspace{0.5cm}

kable(table.output.vpraesi,
      format = "latex",
      align = 'P{3cm}',
      booktabs=TRUE,
      longtable=TRUE,
      col.names = c("Vize-Präsident:in",
                    "Entscheidungen",
                    "% Gesamt",
                    "% Kumulativ"))






#' \newpage
#+
#'## Nach Entscheidungsjahr

#'\vspace{0.5cm}

#' ![](analyse/CE-BVerfG_08_Barplot_Entscheidungsjahr-1.pdf)

#'\vspace{1cm}

kable(table.jahr.entscheid,
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Jahr",
                    "Entscheidungen",
                    "% Gesamt",
                    "% Kumulativ")) %>% kable_styling(latex_options = "repeat_header")





#'\newpage
#+
#'## Nach Eingangsjahr (ISO)


#'\vspace{0.5cm}

#' ![](analyse/CE-BVerfG_09_Barplot_EingangsjahrISO-1.pdf)

#'\vspace{1cm}

kable(table.jahr.eingangISO,
      format = "latex",
      align = 'P{3cm}',
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Jahr",
                    "Entscheidungen",
                    "% Gesamt",
                    "% Kumulativ")) %>% kable_styling(latex_options = "repeat_header")




#'# Dateigrößen

#+
#'## Verteilung PDF-Dateigrößen

#' ![](analyse/CE-BVerfG_14_Density_Dateigroessen_PDF-1.pdf)


#+
#'## Verteilung TXT-Dateigrößen

#' ![](analyse/CE-BVerfG_15_Density_Dateigroessen_TXT-1.pdf)

#'\newpage

#+
#'## Gesamtgröße je ZIP-Archiv
files.zip <- fread(hashfile)$filename
filesize <- round(file.size(files.zip) / 10^6, digits = 2)

table.size <- data.table(files.zip,
                         filesize)


kable(table.size,
      format = "latex",
      align = c("l", "r"),
      format.args = list(big.mark = ","),
      booktabs = TRUE,
      longtable = TRUE,
      col.names = c("Datei",
                    "Größe in MB"))







#'\newpage
#+
#'# Signaturprüfung

#+
#'## Allgemeines
#' Die Integrität und Echtheit der einzelnen Archive des Datensatzes sind durch eine Zwei-Phasen-Signatur sichergestellt.
#'
#' In **Phase I** werden während der Kompilierung für jedes ZIP-Archiv Hash-Werte in zwei verschiedenen Verfahren berechnet und in einer CSV-Datei dokumentiert.
#'
#' In **Phase II** wird diese CSV-Datei mit meinem persönlichen geheimen GPG-Schlüssel signiert. Dieses Verfahren stellt sicher, dass die Kompilierung von jedermann durchgeführt werden kann, insbesondere im Rahmen von Replikationen, die persönliche Gewähr für Ergebnisse aber dennoch vorhanden ist.
#'
#' Dieses Codebook ist vollautomatisch erstellt und prüft die kryptographisch sicheren SHA3-512 Signaturen (\enquote{hashes}) aller ZIP-Archive, sowie die GPG-Signatur der CSV-Datei, welche die SHA3-512 Signaturen enthält. SHA3-512 Signaturen werden durch einen system call zur OpenSSL library auf Linux-Systemen berechnet. Eine erfolgreiche Prüfung meldet \enquote{Signatur verifiziert!}. Eine gescheiterte Prüfung meldet \enquote{FEHLER!}

#+
#'## Persönliche GPG-Signatur
#' Die während der Kompilierung des Datensatzes erstellte CSV-Datei mit den Hash-Prüfsummen ist mit meiner persönlichen GPG-Signatur versehen. Der mit dieser Version korrespondierende Public Key ist sowohl mit dem Datensatz als auch mit dem Source Code hinterlegt. Er hat folgende Kenndaten:
#' 
#' **Name:** Sean Fobbe (fobbe-data@posteo.de)
#' 
#' **Fingerabdruck:** FE6F B888 F0E5 656C 1D25  3B9A 50C4 1384 F44A 4E42

#+
#'## Import: Public Key
#+ echo = TRUE
system2("gpg2", "--import gpg/PublicKey_Fobbe-Data.asc",
        stdout = TRUE,
        stderr = TRUE)




#'\newpage
#+
#'## Prüfung: GPG-Signatur der Hash-Datei

#+ echo = TRUE

# CSV-Datei mit Hashes
print(hashfile)

# GPG-Signatur
print(signaturefile)

# GPG-Signatur prüfen
testresult <- system2("gpg2",
                      paste("--verify", signaturefile, hashfile),
                      stdout = TRUE,
                      stderr = TRUE)

# Anführungsstriche entfernen um Anzeigefehler zu vermeiden
testresult <- gsub('"', '', testresult)

#+ echo = TRUE
kable(testresult, format = "latex", booktabs = TRUE,
      longtable = TRUE, col.names = c("Ergebnis"))


#'\newpage
#+
#'## Prüfung: SHA3-512 Hashes der ZIP-Archive
#+ echo = TRUE

# Prüf-Funktion definieren
sha3test <- function(filename, sig){
    sig.new <- system2("openssl",
                       paste("sha3-512", filename),
                       stdout = TRUE)
    sig.new <- gsub("^.*\\= ", "", sig.new)
    if (sig == sig.new){
        return("Signatur verifiziert!")
    }else{
        return("FEHLER!")
    }
}

# Ursprüngliche Signaturen importieren
table.hashes <- fread(hashfile)
filename <- file.path("output", table.hashes$filename)
sha3.512 <- table.hashes$sha3.512

# Signaturprüfung durchführen 
sha3.512.result <- mcmapply(sha3test, filename, sha3.512, USE.NAMES = FALSE)

# Ergebnis anzeigen
testresult <- data.table(filename, sha3.512.result)

#+ echo = TRUE
kable(testresult, format = "latex", booktabs = TRUE,
      longtable = TRUE, col.names = c("Datei", "Ergebnis"))





#+ results = "asis"
cat(readLines("CHANGELOG.md"),
    sep = "\n")



#'\newpage
#+
#'# Parameter für strenge Replikationen

system2("openssl",  "version", stdout = TRUE)

sessionInfo()

#'# Literaturverzeichnis
