#!/usr/bin/perl -w

use strict;
use warnings;
use DateTime;

my $Startzeile = undef;
my $Zeit = DateTime->new(year => 2016);
my ($ID, $Erstekarte, $Small_Blind, $Big_Blind);

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
                $_ =~ m|^Game ID: (\d+) (\d+)/(\d+)|;

                if(not $Startzeile or not $Zeit) {
                        die "ID ohne Startzeile/Zeit eingelesen.";
                }

                $ID = $1;
                $Small_Blind = $2;
                $Big_Blind = $3;
                my $Datum = $Zeit->strftime("%Y/%m/%d %H:%M:%S ET");
                $Erstekarte = undef;

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

                print("Seat " . $Sitz . ": " . $Nick .
                      " (" . $Chips . " in chips)\n");
        } elsif(/^Player .+ ante \(\d+\)$/) {
                $_ =~ m|^Player (.+) ante \((\d+)\)$|;

                if(not $ID) {
                        die "Einsatz ohne ID.";
                }

                my $Nick = $1;
                my $Einsatz = $2;

                print($Nick . ": posts the ante " . $Einsatz . "\n");
        } elsif(/^Player .+ has (small|big) blind \(\d+\)$/) {
                $_ =~ m|^Player (.+) has (.+) \((\d+)\)$|;

                if(not $ID) {
                        die "Blind ohne ID.";
                }

                my $Nick = $1;
                my $Blindtyp = $2;
                my $Blind = $3;

                print($Nick . ": posts " . $Blindtyp . " " . $Blind . "\n");
        } elsif(/^Player .+ received a card.$/) {
                #Ignorieren. Im Zielformat nicht drin.
        } elsif(/^Player .+ received card: \[.+\]$/) {
                $_ =~ m|^Player (.+) received card: \[(.+)\]$|;

                if(not $ID) {
                        die "Karte ohne ID.";
                }

                my $Nick = $1;
                my $Karte = $2;

                if(not defined $Erstekarte) {
                        $Erstekarte = $Karte;
                } else {
                        print("*** HOLE CARDS ***\n");
                        print("Dealt to " . $Nick . " [" . $Erstekarte .
                              " " . $Karte ."]\n");
                }
        } elsif(/^Player .+ calls \(\d+\)$/) {
                $_ =~ m|^Player (.+) calls \((\d+)\)$|;

                if(not $ID) {
                        die "Call ohne ID.";
                }

                my $Nick = $1;
                my $Call = $2;

                print($Nick . ": calls " . $Call . "\n");
        } elsif(/^Player .+ (folds|checks)$/) {
                $_ =~ m|^Player (.+) (folds\|checks)$|;

                if(not $ID) {
                        die "Fold/Check ohne ID.";
                }

                my $Nick = $1;
                my $Aktion = $2;

                print($Nick . ": " . $Aktion . "\n");
        } else {
                print "»" . $_ . "\n";
        }
}
