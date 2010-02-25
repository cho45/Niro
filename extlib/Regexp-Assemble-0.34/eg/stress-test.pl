#! /usr/local/bin/perl -w

use strict;
use lib 'blib/lib';
use Regexp::Assemble;
use Data::PowerSet;
use Algorithm::Combinatorics 'combinations';

my $end = shift || 'e'; # generate the power set of the elements 'a' .. $end

my $set = [sort {join('' => @$a) cmp join('' => @$b)}
    @{Data::PowerSet::powerset( {min=>1}, 'a'..$end )}
];

$| = 1;

print "## size of powerset = ", scalar(@$set), "\n";

my $nr = 0;
for my $sel (@ARGV) {
    my $p = combinations($set,$sel);

    while (defined(my $s = $p->next)) {
        ++$nr;
        my $short = Regexp::Assemble->new;
        $short->insert(@$_) for @$s;
        my $long  = Regexp::Assemble->new;
        $long->insert('^', @$_, '$') for @$s;
        my $sh = $short->as_string;
        my $lg = $long->as_string;

        $s = [map {join '' => @$_} @$s];
        printf "%9d %2d %s $lg\n", $nr, $sel, "@$s" unless $nr % 10000;

        my %expected = map{($_,$_)} @$s;
        if( "^$sh\$" ne $lg ) {
            $lg =~ s/^\^//;
            $lg =~ s/\$$//;

            for my $t ( @$s) {
                if( $expected{$t} ) {
                    next if $t =~ /$long/;
                    printf "%5d %-50s %s\n", $nr, $lg, "@$s";
                    print "l: $t should have been matched\n";
                    last;
                }
                else {
                    next if $t !~ /$long/;
                    printf "%5d %-50s %s\n", $nr, $lg, "@$s";
                    print "l: $t should not have been matched\n";
                    last;
                }
            }

            my $short_str = '^' . $sh . '$';
            my $short_re  = qr/$short_str/;
            for my $t ( @$s) {
                if( $expected{$t} ) {
                    next if $t =~ /$short_re/;
                    printf "%5d %-50s %s\n", $nr, $sh, "@$s";
                    print "s: $t should have been matched\n";
                    last;
                }
                else {
                    next if $t !~ /$short_re/;
                    printf "%5d %-50s %s\n", $nr, $sh, "@$s";
                    print "s: $t should not have been matched\n";
                    last;
                }
            }

        }
        else {
            for my $t ( @$s) {
                if( $expected{$t} ) {
                    next if $t =~ /$long/;
                    printf "%5d %-50s %s\n", $nr, $lg, "@$s";
                    print "$t should have been matched\n";
                    last;
                }
                else {
                    next if $t !~ /$long/;
                    printf "%5d %-50s %s\n", $nr, $sh, "@$s";
                    print "$t should not have been matched\n";
                    last;
                }
            }
        }
    }
    print "# $sel $nr\n";
}

print "$nr combinations examined\n";
