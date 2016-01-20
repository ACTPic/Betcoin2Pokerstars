#!/usr/bin/perl -w

use strict;
use warnings;
use DateTime;

my $Startzeile = undef;
my $Zeit = DateTime->new(year => 2016);
my $ID;

while ($_ = <STDIN>) {
        s/\r?\n//;
        if(/^Game started at:/) {
                $Startzeile = $_;
                $_ =~ m|^Game.+at: (\d+)/(\d+)/(\d+) (\d+):(\d+):(\d+)|;

                $Zeit->set(
                        year    => $1,
                        month   => $2,
                        day     => $3,
                        hour    => $4,
                        minute  => $5,
                        second  => $6,
                );
        } elsif(/^Game ID: \d+/) {
                $_ =~ m|^Game ID: (\d+)|;

                if(not $Startzeile or not $Zeit) {
                        die "ID ohne Startzeile/Zeit eingelesen.";
                }

                $ID = $1;

                my $Small_Blind = "10";  #TODO
                my $Big_Blind = "30";    #TODO
                my $Datum = $Zeit->strftime("%Y/%m/%d %H:%M:%S ET");

                print('PokerStars Hand #43' . $Zeit->second . $ID .
                      ': Tournament #43' . $ID .
                      ', $3.14+$0.43 USD Hold\'em No Limit - Level IV (' .
                      "$Small_Blind/$Big_Blind) - $Datum" . "\n");
        } elsif(/^Seat \d+:.+ \(\d+\)\.$/) {
                $_ =~ m|^Seat (\d+): (.*) \((\d+)\)\.$|;

                if(not $ID) {
                        die "Sitz ohne ID.";
                }

                my $Sitz = $1;
                my $Chips = $3;
                my $Nick = $2;
                $Nick =~ s/ /_/;

                print("Seat " . $Sitz . ": " . $Nick .
                      " (" . $Chips . " in chips)\n");
        } elsif(/^Player .+ ante \(\d+\)$/) {
                $_ =~ m|^Player (.+) ante \((\d+)\)$|;

                if(not $ID) {
                        die "Einsatz ohne ID.";
                }

                my $Nick = $1;
                my $Einsatz = $2;
                $Nick =~ s/ /_/;

                print($Nick . ": posts the ante " . $Einsatz . "\n");
        } else {
                print "»" . $_ . "\n";
        }
}
