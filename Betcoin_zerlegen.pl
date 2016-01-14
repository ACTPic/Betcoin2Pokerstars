#!/usr/bin/perl -w

use strict;
use warnings;
use DateTime;

my ($Startzeile, $Zeitstempel) = undef;
my $Handle = undef;

while ($_ = <STDIN>) {
        s/\r?\n//;
        if(not length) {
                print "___Separator___\n";
                if($Handle) {
                        close $Handle;
                        $Handle = undef;
                }
                next;
        }

        if(/^Game started at:/) {
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
        } elsif(/^Game ID: \d+/) {
                $_ =~ m|^Game ID: (\d+)|;

                if(not $Startzeile or not $Zeitstempel) {
                        die "ID ohne Startzeile/Zeitstempel eingelesen.";
                }

                my $ID = $1;
                print("ID: " . $ID . "\n");

                my $Dir = "Pokerspiel_@" . $Zeitstempel . "_" . $ID;

                mkdir $Dir or die "Verzeichnis für ID " . $ID . " besetzt.";
                die $Dir . "/In.txt besetzt." if -e $Dir . "/In.txt";
                open ($Handle, '>>', $Dir . "/In.txt") or die;
                print $Handle $Startzeile . "\n" . $_;
        } else {
                print $Handle $_ . "\n" if $Handle;
        }
}

close $Handle if $Handle;
