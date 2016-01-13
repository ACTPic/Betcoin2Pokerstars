#!/usr/bin/perl -w

use strict;
use warnings;
use DateTime;

while ($_ = <STDIN>) {
        s/\r?\n//;
        if(not length) {
                print "___Separator___\n";
                next;
        }

        if (/^Game started at:/) {
                $_ =~ m|^Game.+at: (\d+)/(\d+)/(\d+) (\d+):(\d+):(\d+)|;

                my $dt = DateTime->new(
                        year    => $1,
                        month   => $2,
                        day     => $3,
                        hour    => $4,
                        minute  => $5,
                        second  => $6,
                );
                print("Zeitstempel: @" . $dt->epoch . "\n");
        }
}
