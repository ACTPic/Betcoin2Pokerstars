#!/bin/zsh

#    Copyright © 2016 Andreas „APic“ Pickart
#
#    This file is part of B2P
#
#    B2P is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    B2P is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

mkdir -p in
mkdir -p err
mkdir -p out

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
        Wanted_Charset2=$Wanted_Charset
        Wanted_Charset+="with CRLF line terminators"
        Wanted_Charset2+="with CRLF, CR line terminators"

        if test "$Charset" = "$Wanted_Charset" -o "$Charset" = "$Wanted_Charset2"; then
            # Zeichensatz Rekodieren von UTF16 nach UTF8
            recode utf16..utf8 ../Betcoin.txt

            # Erkennen ob das Rekodieren zum erwünschsten Zeichensatz führte
            Charset=`file ../Betcoin.txt`
            Wanted_Charset="../Betcoin.txt: "
            Wanted_Charset+="ASCII text, "
            Wanted_Charset+="with CRLF line terminators"
            if test "$Charset" = "$Wanted_Charset"; then
                # Perl-Skript die Spieledaten konvertieren lassen
                ../B2P.pl < ../Betcoin.txt > ../out/$out 2>../err/FEHLER_$out
            else
                echo "$i: Rekodieren ergab nicht den gewünschten Zeichensatz." 1>&2
            fi
        else
            echo "$i: Zeichensatz ist '$Charset' statt '$Wanted_Charset'." 1>&2
        fi
    fi
done

find ../err -empty -type f -delete
