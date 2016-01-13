#!/bin/zsh

# Bei Fehler Script stoppen:
set -e
# Kommandos vor dem Exekutieren anzeigen:
set -x

# Sicherstellen dass Quelltextdatei vorhanden ist:
test -e Betcoin.txt

# Erkennen ob der Zeichensatz passt
Charset=`file Betcoin.txt`
Wanted_Charset="Betcoin.txt: "
Wanted_Charset+="Little-endian UTF-16 Unicode text, "
Wanted_Charset+="with CRLF line terminators"
test "$Charset" = "$Wanted_Charset"

# Zeichensatz Rekodieren von UTF16 nach UTF8
recode utf16..utf8 Betcoin.txt

# Erkennen ob das Rekodieren zum erwünschsten Zeichensatz führte
Charset=`file Betcoin.txt`
Wanted_Charset="Betcoin.txt: "
Wanted_Charset+="ASCII text, "
Wanted_Charset+="with CRLF line terminators"
test "$Charset" = "$Wanted_Charset"

# Awk-Skript die Spieledaten zerlegen lassen
./Betcoin_zerlegen.gawk Betcoin.txt
