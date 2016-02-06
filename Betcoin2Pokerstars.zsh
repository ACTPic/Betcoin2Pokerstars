#!/bin/zsh

# Bei Fehler Script stoppen:
set -e
# Kommandos vor dem Exekutieren anzeigen:
set -x

cd in
for i in HH*.txt; do
    o=${i/-G/}
    o=${o/.txt/}
    out="$o No Limit Hold'em \$3.11 + \$0.39.txt"
    if test ! -e ../out/$out; then
        cp $i ../Betcoin.txt

        # Sicherstellen dass Quelltextdatei vorhanden ist:
        test -e ../Betcoin.txt

        # Erkennen ob der Zeichensatz passt
        Charset=`file ../Betcoin.txt`
        Wanted_Charset="../Betcoin.txt: "
        Wanted_Charset+="Little-endian UTF-16 Unicode text, "
        Wanted_Charset+="with CRLF line terminators"
        test "$Charset" = "$Wanted_Charset"

        # Zeichensatz Rekodieren von UTF16 nach UTF8
        recode utf16..utf8 ../Betcoin.txt

        # Erkennen ob das Rekodieren zum erwünschsten Zeichensatz führte
        Charset=`file ../Betcoin.txt`
        Wanted_Charset="../Betcoin.txt: "
        Wanted_Charset+="ASCII text, "
        Wanted_Charset+="with CRLF line terminators"
        test "$Charset" = "$Wanted_Charset"

        # Perl-Skript die Spieledaten konvertieren lassen
        ../B2P.pl < ../Betcoin.txt > ../out/$out
    fi
done
