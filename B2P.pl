#!/usr/bin/perl -w

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

sub Blatt_konvertieren {
        my $Blatt = $1;

        $Blatt =~ s/^High card (.+)$/high card $1/;
        $Blatt =~ s/^One pair of (.+)$/a pair of $1/;
        $Blatt =~ s/^Two pairs\. (.+)$/two pair, $1/;
        $Blatt =~ s/^Three Of Kind of (.+)$/three of a kind, $1/;
        $Blatt =~ s/^Four Of Kind of (.+)$/four of a kind, $1/;
        $Blatt =~ s/^Straight to (.+)$/a straight, % to $1/;
        $Blatt =~ s/^Flush, (.+) high$/a flush, $1 high/;
        $Blatt =~ s|^Full[ ]House[ ]\((.+)/(.+)\)$
                   |a full house, $1 full of $2|x;
        #TODO: „Straight-Flush“

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
                $_ =~ m|^Game ID: (\d+) (\d+)/(\d+)|;

                if(not $Startzeile or not $Zeit) {
                        die "Handnummer ohne Startzeile/Zeit eingelesen.";
                }

                $Hand = $1;
                $Small_Blind = $2;
                $Big_Blind = $3;
                my $Datum = $Zeit->strftime("%Y/%m/%d %H:%M:%S ET");
                $Erstekarte = undef;
                $Einsatz = $Big_Blind if not defined $Einsatz;
                @Zusammenfassung = @Showdown = @Kollekte = ();

                print('PokerStars Hand #43' . $Zeit->second . $Hand .
                      ': Tournament #' . $ID .
                      ', $3.14+$0.43 USD Hold\'em No Limit - Level IV (' .
                      "$Small_Blind/$Big_Blind) - $Datum" . "\n");
        } elsif(/^Seat \d+ is the button$/) {
                $_ =~ m|^Seat (\d+) is the button$|;

                if(not $ID) {
                        die "Knopf ohne ID.";
                }

                my $Knopf = $1;

                print("Table '" . $ID . " 1' 9-max Seat #" . $Knopf .
                      " is the button\n");
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
                        die "Voreinsatz ohne ID.";
                }

                my $Nick = $1;
                my $Voreinsatz = $2;

                print($Nick . ": posts the ante " . $Voreinsatz . "\n");
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
        } elsif(/^\*\*\* (TURN|RIVER|FLOP) \*\*\*: \[.+\]$/) {
                if(not $ID) {
                        die "Turn/River/Flop ohne ID";
                }

                print("$_\n");
        } elsif(/^Player .+ calls \(\d+\)$/) {
                $_ =~ m|^Player (.+) calls \((\d+)\)$|;

                if(not $ID) {
                        die "Call ohne ID.";
                }

                my $Nick = $1;
                $Einsatz = $2;

                print($Nick . ": calls " . $Einsatz . "\n");
        } elsif(/^Player .+ allin \(\d+\)$/) {
                $_ =~ m|^Player (.+) allin \((\d+)\)$|;

                if(not $ID) {
                        die "All-In ohne ID.";
                }

                my $Nick = $1;
                $Einsatz = $2;

                print($Nick . ": bets " . $Einsatz . " and is all-in\n");
        } elsif(/^Player .+ bets \(\d+\)$/) {
                $_ =~ m|^Player (.+) bets \((\d+)\)$|;

                if(not $ID) {
                        die "Bet ohne ID.";
                }

                my $Nick = $1;
                my $Neuer_Einsatz = $2;

                print($Nick . ": bets " . $Neuer_Einsatz . "\n");
        } elsif(/^Player .+ raises \(\d+\)$/) {
                $_ =~ m|^Player (.+) raises \((\d+)\)$|;

                if(not $ID) {
                        die "Raise ohne ID.";
                }

                my $Nick = $1;
                my $Neuer_Einsatz = $2;

                print($Nick . ": raises $Einsatz to $Neuer_Einsatz\n");
        } elsif(/^Player .+ (folds|checks)$/) {
                $_ =~ m|^Player (.+) (folds\|checks)$|;

                if(not $ID) {
                        die "Fold/Check ohne ID.";
                }

                my $Nick = $1;
                my $Aktion = $2;

                print($Nick . ": " . $Aktion . "\n");
        } elsif(/^Player .+ mucks cards$/) {
                $_ =~ m|^Player (.+) mucks cards$|;

                if(not $ID) {
                        die "Muck ohne ID.";
                }

                my $Nick = $1;

                print($Nick . ": mucks hand\n");
        } elsif(/^Uncalled bet \(\d+\) returned to .+$/) {
                if(not $ID) {
                        die "Return ohne ID.";
                }
        } elsif(/^.?Player[ ].+[ ]shows:[ ].+\.[ ]Bets:[ ]\d+\.[ ]
                Collects:[ ]\d+\.[ ].+:[ ]\d+\.$/x) {
                my $Win = 0;
                $Win = 1 if $_ =~ /^\*/;
                $_ =~ m|^.?Player[ ](.+)[ ]shows:[ ](.+)\.[ ]Bets:[ ](\d+)\.
                        [ ]Collects:[ ](\d+)\.[ ](.+):[ ](\d+)\.$|x;

                if(not $ID) {
                        die "Aufdecken ohne ID.";
                }

                my $Nick = $1;
                my $Karten = $2;
                my $Einlage = $3;
                my $Einsammlung = $4;
                my $Ausgang = $5;
                my $Umsatz = $6;

                $Karten =~ /^(.+) (\[.+\])$/;
                my $Blatt = Blatt_konvertieren($1);
                my $Kuerzel = $2;

                push(@Showdown, "$Nick: shows $Kuerzel ($Blatt)\n");
                push(@Kollekte, "$Nick: collected $Einsammlung from pot\n");
        } elsif(/^.?Player .+ does not show cards/) {
                my $Win = 0;
                $Win = 1 if $_ =~ /^\*/;
                $_ =~ m|^.?Player[ ](.+)[ ]does[ ]not[ ].*Bets:[ ](\d+)\.
                        [ ]Collects:[ ](\d+)\.[ ](.+):[ ](\d+)|x;

                if(not $ID) {
                        die "Wegwerfen ohne ID.";
                }

                my $Nick = $1;
                my $Einlage = $2;
                my $Einsammlung = $3;
                my $Ausgang = $4;
                my $Umsatz = $5;

                print "«$1: Einlage=$2 Einsammlung=$3 $4=$5\n";

                #Keine direkte Ausgabe. Im Zielformat so nicht drin.
        } elsif(/^.?Player .+ mucks/) {
                my $Win = 0;
                $Win = 1 if $_ =~ /^\*/;
                $_ =~ m|^.?Player[ ](.+)[ ]mucks.*[ ]Bets:[ ](\d+)\.[ ]Collects:[ ](\d+)\.[ ](.+):[ ](\d+)|;

                if(not $ID) {
                        die "Wegwerfen ohne ID.";
                }

                my $Nick = $1;
                my $Einlage = $2;
                my $Einsammlung = $3;
                my $Ausgang = $4;
                my $Umsatz = $5;

                print "«$1: Einlage=$2 Einsammlung=$3 $4=$5\n";

                #Keine direkte Ausgabe. Im Zielformat so nicht drin.
        } elsif(/^------ Summary ------$/) {
                if(not $ID) {
                        die "Zusammenfassung ohne ID";
                }

                push @Zusammenfassung, "*** SUMMARY ***\n";
        } elsif(/^Pot: \d+$/) {
                $_ =~ m|^Pot: (\d+)$|;

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
                print("\n\n");
        } elsif(/^$/) {
                print("\n");
        } else {
                print "»" . $_ . "\n";
        }
}
