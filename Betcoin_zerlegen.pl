#!/usr/bin/perl -w

use strict;
use warnings;
use DateTime;

my ($Startzeile, $Zeitstempel) = undef;

while ($_ = <STDIN>) {
        s/\r?\n//;
        if(not length) {
                print "___Separator___\n";
                next;
        }

        if (/^Game started at:/) {
                $Startzeile = $_;
                $_ =~ m|^Game.+at: (\d+)/(\d+)/(\d+) (\d+):(\d+):(\d+)|;

                my $dt = DateTime->new(
                        year    => $1,
                        month   => $2,
                        day     => $3,
                        hour    => $4,
                        minute  => $5,
                        second  => $6,
                );

                $Zeitstempel = $dt->epoch;
                print("Zeitstempel: @" . $Zeitstempel . "\n");
        }

        if (/^Game ID: \d+/) {
                $_ =~ m|^Game ID: (\d+)|;

                if(not $Startzeile or not $Zeitstempel) {
                        die "ID ohne Startzeile/Zeitstempel eingelesen.";
                }

                my $ID = $1;
                print("ID: " . $ID . "\n");
        }

}
