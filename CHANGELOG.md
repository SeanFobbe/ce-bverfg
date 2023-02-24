# Changelog



## Version \version

- Vollständige Aktualisierung der Daten
- Gesamte Laufzeitumgebung mit Docker versionskontrolliert
- Amtliche Sammlung bis inklusive Band 160 mit Name, Band und Seite versehen
- 50 neue historische Entscheidungen aus dem Zeitraum 1951 bis 1998 (u.a. Elfes, Schleyer-Entführung, Kurzarbeitergeld, Nachtarbeiterinnen)
- Aktenzeichen aus dem Eingangszeitraum 2000 bis 2009 nun korrekt mit führender Null formatiert (z.B. 1 BvR 44/02 statt 1 BvR 44/2)
- Überarbeitung der Namen der Entscheidungen, u.a. Einfügung von Bindestrichen um Lesbarkeit zu verbessern und weitere Standardisierung
- Verbesserte Formatierung von Warnungen und Fehlermeldungen im Compilation Report



## Version 2022-08-24



- Vollständige Aktualisierung der Daten
- Neuentwurf das gesamten Source Codes im {targets} framework
- Entfernung von englischen Zusammenfassungen aus dem Korpus
- Vielzahl zusätzlicher Unit Tests
- Zusätzliche Variablen mit URLs zu originalen HTML- und PDF-Dateien
- Variante mit linguistischen Annotationen temporär nicht mehr verfügbar
- Robustness Checks sind nun in einem separaten Bericht dokumentiert
- Frequenztabellen-Test berücksichtigt nun alle Variablen
- Neues Diagramm: Visualisierung von Kompilierungs-Prozess
- Diagramme sind in neuer Reihenfolge nummeriert, um die Reihenfolge im Codebook abzubilden




## Version 2022-02-01

- Vollständige Aktualisierung der Daten
- Strenge Versionskontrolle von R packages mit {renv}
- Kompilierung jetzt detailliert konfigurierbar, insbesondere die Parallelisierung
- Parallelisierung nun vollständig mit {future} statt mit {foreach} und {doParallel}
- Codebook-Erstellung stark beschleunigt durch Verwendung vorberechneter Diagramme
- Fehlerhafte Kompilierungen werden vor der nächsten Kompilierung vollautomatisch aufgeräumt
- Alle Ergebnisse werden automatisch fertig verpackt in den Ordner 'output' sortiert
- README und CHANGELOG sind jetzt externe Markdown-Dateien, die bei der Kompilierung automatisiert eingebunden werden
- Source Code des Changelogs zu Markdown konvertiert
- REGEX-Tests im Detail kommentiert


## Version 2021-09-19
 
- Vollständige Aktualisierung der Daten
- Neue Variablen: Pressemitteilung, Zitiervorschlag, Aktenzeichen (alle), Kurzbeschreibung und Richter
- Neue Variante: Segmentiert
- Neue Variante: HTML
- Erweiterung der Codebook-Dokumentation
- Strenge Kontrolle und semantische Sortierung der Variablen-Namen
- Abgleich der selbst berechneten ECLI mit der in der HTML-Fassung dokumentierten ECLI
- Variable für Entscheidungstyp wird nun aus dem Zitiervorschlag berechnet um eine höhere Genaugikeit zu gewährleisten
 
## Version 2021-05-20

- Vollständige Aktualisierung der Daten
- Einführung eines Debugging-Modus
- Einführung von Variablen für Verfahrensart, Lizenz, Typ der Entscheidung und Zeichenzahl
- Zusätzliche Diagramme für Typ der Entscheidung, Verteilung der Zeichen und Verteilung der Dateigrößen (TXT)
- Neue Datenquellen für Präsident:in, Vize-Präsident:in und für Registerzeichen/Verfahrensarten
- Zusammenfügen von über Zeilengrenzen getrennten Wörtern in der Variable \enquote{text} (nur CSV-Formate)
- Einige Verbesserungen im Codebook

## Version 2021-01-08
 
- Vollständige Aktualisierung der Daten
- Veröffentlichung des vollständigen Source Codes
- Deutliche Erweiterung des inhaltlichen Umfangs des Codebooks
- Einführung der vollautomatischen Erstellung von Datensatz und Codebook
- Einführung von Compilation Reports um den Erstellungsprozess exakt zu dokumentieren
- Einführung von Variablen für Versionsnummer, Concept DOI, Version DOI, ECLI, Entscheidungsnamen, BVerfGE-Band, BVerfGE-Seite, Typ des Spruchkörpers, Präsident:in, Vize-Präsident:in und linguistische Kennzahlen (Tokens, Typen, Sätze)
- Automatisierung und Erweiterung der Qualitätskontrolle
- Einführung von Diagrammen zur Visualisierung von Prüfergebnissen
- Einführung kryptographischer Signaturen
- Alle Variablen sind nun in Kleinschreibung und Snake Case gehalten
- Variable \enquote{Suffix} in \enquote{kollision} umbenannt.
- Variable \enquote{Ordinalzahl} in \enquote{eingangsnummer} umbenannt.
 
## Version 2020-08-03

- Vollständige Aktualisierung der Daten
- Angleichung der Variablen-Namen an andere Datensätze der CE-Serie\footnote{Siehe: \url{https://zenodo.org/communities/sean-fobbe-data/}}
- Einführung der Variable \enquote{Suffix} um weitere Entscheidungen korrekt erfassen zu können; aufgrund der fehlenden Berücksichtigung des Suffix sind die Metadaten von 36 Entscheidungen der Version 2020-06-20 fehlerhaft. Bitte verwenden Sie daher nur die neue Version. Alternativ können Sie die fehlerhaften Dateien (erkennbar an einem dreistelligen Eingangsjahr) aus der Analyse ausschließen oder per Hand korrigieren.

 
## Version 2020-06-20

- Erstveröffentlichung
