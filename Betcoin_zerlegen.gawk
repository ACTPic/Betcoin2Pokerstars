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
