#!/usr/bin/gawk -f

length($0) == 0 {
        print "Separator."
}


# Game started at: 2016/1/9 3:0:0

/^Game started at:/ {
        print "Spielstart, Datum=" $4 ", Zeit=" $5
        split($4, Datum, "/");
        split($5, Zeit, ":");

        Zeitstempel = mktime(Datum[1] " " Datum[2] " " Datum[3] " " \
                             Zeit[1]  " " Zeit[2]  " " Zeit[3]);
        
        print("Zeitstempel: @" Zeitstempel);
}

# Game ID: 11444444 10/40 Betcoin Daily Coin 1 BTC GTD, Table 1 (Hold'em)

/^Game ID:/ {
        Spiel_ID = $3;
        split($4, Blinds, "/");
        Tischnummer = $12;

        print("Spiel-ID " Spiel_ID ", Blinds " Blinds[1] "/" Blinds[2] \
              ", Tischnummer " Tischnummer);
}
