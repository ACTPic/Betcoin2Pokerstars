#!/usr/bin/perl -w

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

use strict;
use warnings;
use DateTime;

my $Startzeile = undef;
my $Zeit = DateTime->new(year => 2016);
my ($ID, $Hand, $Erstekarte, $Small_Blind, $Big_Blind);
my $Einsatz;
my @Zusammenfassung = ();
my @Showdown = ();
my @Kollekte = ();
my %Platz = ();
my %Aktion = ();
my %Blaetter = ();
my %Kurz = ();
my %Gewinn = ();
my ($Small_Blind_Sitz, $Big_Blind_Sitz);
my $Knopf;
my $Zustand;

sub Blatt_konvertieren {
        my $Blatt = $1;

        $Blatt =~ s/^High card (.+)$/high card $1/;
        $Blatt =~ s/^One pair of (.+)$/a pair of $1/;
        $Blatt =~ s/^Two pairs\. (.+)$/two pair, $1/;
        $Blatt =~ s/^Three Of Kind of (.+)$/three of a kind, $1/;
        $Blatt =~ s/^Four Of Kind of (.+)$/four of a kind, $1/;

        if($Blatt =~ m/^Straight to (.+)$/) {
                my @Folge = ("2", "3", "4", "5", "6", "7", "8", "9",
                             "T", "J", "Q", "K", "A");

                my %Folge = ("A"     => "Ten",
                             "Ace"   => "Ten",
                             "K"     => "Nine",
                             "King"  => "Nine",
                             "Q"     => "Eight",
                             "Queen" => "Eight",
                             "J"     => "Seven",
                             "Jack"  => "Seven",
                             "T"     => "Six",
                             "10"    => "Six",
                             "Ten"   => "Six",
                             "9"     => "Five",
                             "Nine"  => "Five",
                             "8"     => "Four",
                             "Eight" => "Four",
                             "7"     => "Three",
                             "Seven" => "Three",
                             "6"     => "Deuce",
                             "Six"   => "Deuce",
                             "5"     => "Ace",
                             "Five"  => "Ace",
                );
                my $Zu = $1;
                my $Von = $Folge{$Zu};
                $Blatt = "a straight, $Von to card $Zu";
        }

        $Blatt =~ s/^Flush, (.+) high$/a flush, $1 high/;
        $Blatt =~ s|^Full[ ]House[ ]\((.+)/(.+)\)$
                   |a full house, $1 full of $2|x;
        $Blatt =~ s/^Straight Flush to (.+) .+$/a straight flush, $1 high/;


        $Blatt =~ s/card 2$/Deuce/;
        $Blatt =~ s/card 3$/Three/;
        $Blatt =~ s/card 4$/Four/;
        $Blatt =~ s/card 5$/Five/;
        $Blatt =~ s/card 6$/Six/;
        $Blatt =~ s/card 7$/Seven/;
        $Blatt =~ s/card 8$/Eight/;
        $Blatt =~ s/card 9$/Nine/;
        $Blatt =~ s/card 10$/Ten/;
        $Blatt =~ s/card J$/Jack/;
        $Blatt =~ s/card Q$/Queen/;
        $Blatt =~ s/card K$/King/;
        $Blatt =~ s/card A$/Ace/;


        $Blatt =~ s/2s/Deuces/;
        $Blatt =~ s/3s/Threes/;
        $Blatt =~ s/4s/Fours/;
        $Blatt =~ s/5s/Fives/;
        $Blatt =~ s/6s/Sixes/;
        $Blatt =~ s/7s/Sevens/;
        $Blatt =~ s/8s/Eights/;
        $Blatt =~ s/9s/Nines/;
        $Blatt =~ s/10s/Tens/;
        $Blatt =~ s/Js/Jacks/;
        $Blatt =~ s/Qs/Queens/;
        $Blatt =~ s/Ks/Kings/;
        $Blatt =~ s/As/Aces/;

        return $Blatt;
}

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

                $ID = $Zeit->epoch() if not defined $ID;
        } elsif(/^Game ID: \d+/) {
                $_ =~ m|^Game ID: (\d+) ([0-9.]+)/([0-9.]+)|;

                if(not $Startzeile or not $Zeit) {
                        die "Handnummer ohne Startzeile/Zeit eingelesen.";
                }

                $Hand = $1;
                $Small_Blind = $2;
                $Big_Blind = $3;
                my $Datum = $Zeit->strftime("%Y/%m/%d %H:%M:%S ET");
                $Erstekarte = undef;
                $Einsatz = $Big_Blind;
                @Zusammenfassung = @Showdown = @Kollekte = ();
                %Platz = ();
                %Aktion = ();
                $Zustand = undef;
                %Gewinn = ();

                print('PokerStars Hand #43' . $Zeit->second . $Hand .
                      ': Tournament #' . $ID .
                      ', $3.14+$0.43 USD Hold\'em No Limit - Level IV (' .
                      "$Small_Blind/$Big_Blind) - $Datum" . "\n");
        } elsif(/^Seat \d+ is the button$/) {
                $_ =~ m|^Seat (\d+) is the button$|;

                if(not $ID) {
                        die "Knopf ohne ID.";
                }

                $Knopf = $1;

                print("Table '" . $ID . " 1' 9-max Seat #" . $Knopf .
                      " is the button\n");
        } elsif(/^Seat \d+:.+ \([0-9.]+\)\.$/) {
                $_ =~ m|^Seat (\d+): (.*) \(([0-9.]+)\)\.$|;

                if(not $ID) {
                        die "Sitz ohne ID.";
                }

                my $Sitz = $1;
                my $Chips = $3;
                my $Nick = $2;

                $Platz{$Sitz} = $Nick;
                $Blaetter{$Nick} = undef;
                $Kurz{$Nick} = undef;

                print("Seat " . $Sitz . ": " . $Nick .
                      " (" . $Chips . " in chips)\n");
        } elsif(/^Player .+ ante \([0-9.]+\)$/) {
                $_ =~ m|^Player (.+) ante \(([0-9.]+)\)$|;

                if(not $ID) {
                        die "Voreinsatz ohne ID.";
                }

                my $Nick = $1;
                my $Voreinsatz = $2;

                print($Nick . ": posts the ante " . $Voreinsatz . "\n");
        } elsif(/^Player .+ has (small|big) blind \([0-9.]+\)$/) {
                $_ =~ m|^Player (.+) has (.+) \(([0-9.]+)\)$|;

                if(not $ID) {
                        die "Blind ohne ID.";
                }

                my $Nick = $1;
                my $Blindtyp = $2;
                my $Blind = $3;

                foreach my $Sitz (sort keys %Platz) {
                        if($Nick eq $Platz{$Sitz}) {
                                if($Blindtyp eq 'small blind') {
                                        $Small_Blind_Sitz = $Sitz;
                                } else {
                                        $Big_Blind_Sitz = $Sitz;
                                }
                        }
                }

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
        } elsif(/^\*\*\* (TURN|RIVER|FLOP) \*\*\*: \[.+\]$/) {
                if(not $ID) {
                        die "Turn/River/Flop ohne ID";
                }

                $Zustand = "Turn" if $_ =~ m/TURN/;
                $Zustand = "River" if $_ =~ m/RIVER/;
                $Zustand = "Flop" if $_ =~ m/FLOP/;

                print("$_\n");
        } elsif(/^Player .+ calls \([0-9.]+\)$/) {
                $_ =~ m|^Player (.+) calls \(([0-9.]+)\)$|;

                if(not $ID) {
                        die "Call ohne ID.";
                }

                my $Nick = $1;
                $Einsatz = $2;

                print($Nick . ": calls " . $Einsatz . "\n");
        } elsif(/^Player .+ allin \([0-9.]+\)$/) {
                $_ =~ m|^Player (.+) allin \(([0-9.]+)\)$|;

                if(not $ID) {
                        die "All-In ohne ID.";
                }

                my $Nick = $1;
                $Einsatz = $2;

                $Aktion{$Nick} = "All-in";

                print($Nick . ": bets " . $Einsatz . " and is all-in\n");
        } elsif(/^Player .+ bets \([0-9.]+\)$/) {
                $_ =~ m|^Player (.+) bets \(([0-9.]+)\)$|;

                if(not $ID) {
                        die "Bet ohne ID.";
                }

                my $Nick = $1;
                $Einsatz = $2;

                $Aktion{$Nick} = "Bet";

                print($Nick . ": bets " . $Einsatz . "\n");
        } elsif(/^Player .+ raises \([0-9.]+\)$/) {
                $_ =~ m|^Player (.+) raises \(([0-9.]+)\)$|;

                if(not $ID) {
                        die "Raise ohne ID.";
                }

                my $Nick = $1;
                my $Neuer_Einsatz = $2;

                foreach my $Sitz (sort keys %Platz) {
                        if($Nick eq $Platz{$Sitz}) {
                                if($Small_Blind_Sitz == $Sitz) {
                                        $Neuer_Einsatz += $Small_Blind;
                                } elsif($Big_Blind_Sitz == $Sitz) {
                                        $Neuer_Einsatz += $Big_Blind;
                                }
                        }
                }

                $Aktion{$Nick} = "Raise";

                my $Alter_Einsatz = $Neuer_Einsatz - $Einsatz;

                print($Nick . ": raises $Alter_Einsatz to $Neuer_Einsatz\n");
                $Einsatz = $Neuer_Einsatz;
        } elsif(/^Player .+ folds$/) {
                $_ =~ m|^Player (.+) folds$|;

                if(not $ID) {
                        die "Fold ohne ID.";
                }

                my $Nick = $1;
                if(not defined $Zustand) {
                        my $Bet = defined $Aktion{$Nick};
                        $Aktion{$Nick} = "folded before Flop";
                        $Aktion{$Nick} .= " (didn't bet)" unless $Bet;
                } elsif($Zustand eq "Flop") {
                        $Aktion{$Nick} = "folded on the Flop";
                } elsif($Zustand eq "Turn") {
                        $Aktion{$Nick} = "folded on the Turn";
                } elsif($Zustand eq "River") {
                        $Aktion{$Nick} = "folded on the River";
                }

                print($Nick . ": folds\n");
        } elsif(/^Player .+ checks$/) {
                $_ =~ m|^Player (.+) checks$|;

                if(not $ID) {
                        die "Check ohne ID.";
                }

                my $Nick = $1;

                $Aktion{$Nick} = "Check";

                print($Nick . ": checks\n");
        } elsif(/^Player .+ mucks cards$/) {
                $_ =~ m|^Player (.+) mucks cards$|;

                if(not $ID) {
                        die "Muck ohne ID.";
                }

                my $Nick = $1;

                print($Nick . ": mucks hand\n");
        } elsif(/^Uncalled bet \([0-9.]+\) returned to .+$/) {
                $_ =~ m|^Uncalled bet \(([0-9.]+)\) returned to (.+)$|;

                if(not $ID) {
                        die "Return ohne ID.";
                }

                my $Einlage = $1;
                my $Nick = $2;

                print("Uncalled bet ($Einlage) returned to $Nick\n");
        } elsif(/^.?Player[ ].+[ ]shows:[ ].+\.[ ]?Bets:[ ][0-9.]+\.[ ]
                Collects:[ ][0-9.]+\.[ ].+:[ ][0-9.]+\.$/x) {
                my $Win = 0;
                $Win = 1 if $_ =~ /^\*/;
                $_ =~ m|^.?Player[ ](.+)[ ]shows:[ ](.+)\.[ ]?Bets:[ ]([0-9.]+)\.
                        [ ]Collects:[ ]([0-9.]+)\.[ ](.+):[ ]([0-9.]+)\.$|x;

                if(not $ID) {
                        die "Aufdecken ohne ID.";
                }

                my $Nick = $1;
                my $Karten = $2;
                my $Einlage = $3;
                my $Einsammlung = $4;
                my $Ausgang = $5;
                my $Umsatz = $6;

                if($Win) {
                        $Gewinn{$Nick} = $Einsammlung;
                }

                $Karten =~ /^(.+) (\[.+\])$/;
                my $Blatt = Blatt_konvertieren($1);
                my $Kuerzel = $2;

                $Blaetter{$Nick} = $Blatt;
                $Kurz{$Nick} = $Kuerzel;

                push(@Showdown, "$Nick: shows $Kuerzel ($Blatt)\n");
                push(@Kollekte, "$Nick: collected $Einsammlung from pot\n")
                        if $Einsammlung;

                $Aktion{$Nick} = "collected ($Einsammlung) from pot"
                        if $Einsammlung;
        } elsif(/^.?Player .+ does not show cards/) {
                my $Win = 0;
                $Win = 1 if $_ =~ /^\*/;
                $_ =~ m|^.?Player[ ](.+)[ ]does[ ]not[ ].*Bets:[ ]([0-9.]+)\.
                        [ ]Collects:[ ]([0-9.]+)\.[ ](.+):[ ]([0-9.]+)|x;

                if(not $ID) {
                        die "Wegwerfen ohne ID.";
                }

                my $Nick = $1;
                my $Einlage = $2;
                my $Einsammlung = $3;
                my $Ausgang = $4;
                my $Umsatz = $5;
        } elsif(/^.?Player .+ mucks/) {
                my $Win = 0;
                $Win = 1 if $_ =~ /^\*/;
                $_ =~ m|^.?Player[ ](.+)[ ]mucks.*[ ]Bets:[ ]([0-9.]+)\.
                [ ]Collects:[ ]([0-9.]+)\.[ ](.+):[ ]([0-9.]+)|x;

                if(not $ID) {
                        die "Wegwerfen ohne ID.";
                }

                my $Nick = $1;
                my $Einlage = $2;
                my $Einsammlung = $3;
                my $Ausgang = $4;
                my $Umsatz = $5;

                if($Win) {
                        $Gewinn{$Nick} = $Einsammlung;
                        $Aktion{$Nick} = "collected ($Einsammlung) from pot";
                }
        } elsif(/^Player .+ is timed out\./) {
                $_ =~ m|^Player (.+) is timed out\.$|;

                my $Nick = $1;

                print($Nick . " is sitting out\n");
        } elsif(/^------ Summary ------$/) {
                if(not $ID) {
                        die "Zusammenfassung ohne ID";
                }

                push @Zusammenfassung, "*** SUMMARY ***\n";
        } elsif(/^Pot: [0-9.]+$/) {
                $_ =~ m|^Pot: ([0-9.]+)$|;

                if(not $ID) {
                        die "Pot ohne ID.";
                }

                my $Pot = $1;

                push @Zusammenfassung, "Total pot $Pot | Rake 0\n";
        } elsif(/^Board: /) {
                $_ =~ m|^Board: (.+)$|;

                if(not $ID) {
                        die "Brett ohne ID.";
                }

                my $Brett = $1;

                push @Zusammenfassung, "Board $Brett\n";
        } elsif(/^Game ended at:/) {
                print("*** SHOW DOWN ***\n") if @Showdown;
                print(@Showdown);
                print(@Kollekte);
                print(@Zusammenfassung);

                foreach my $Sitz (sort keys %Platz) {
                        my $Nick = $Platz{$Sitz};
                        print("Seat $Sitz: $Nick");
                        print(" (button)") if $Sitz == $Knopf;
                        print(" (small blind)") if $Sitz == $Small_Blind_Sitz;
                        print(" (big blind)") if $Sitz == $Big_Blind_Sitz;

                        if(defined $Blaetter{$Nick}) {
                                $Blaetter{$Nick} =~ s/a //;

                                if(defined $Gewinn{$Nick}) {
                                        print(" showed $Kurz{$Nick}" .
                                              " and won ($Gewinn{$Nick})" .
                                              " with a " .
                                              $Blaetter{$Nick});
                                } else {
                                        print(" showed $Kurz{$Nick}" .
                                              " and lost with a " .
                                              $Blaetter{$Nick});
                                }
                        } elsif(defined $Aktion{$Platz{$Sitz}}) {
                                print(" " . $Aktion{$Platz{$Sitz}});
                        }

                        print("\n");
                }

                print("\n\n");
        } elsif(/^$/) {
                print("\n");
        } else {
                print "»" . $_ . "\n";
        }
}
