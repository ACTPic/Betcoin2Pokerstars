#!/bin/zsh

# Bei Fehler Script stoppen:
set -e
# Kommandos vor dem Exekutieren anzeigen:
set -x


# Sicherstellen dass Quelltextdatei vorhanden ist:
test -e Betcoin.txt
