# $Id: format.t 4064 2008-09-13 16:54:37Z cfaerber $
#
use strict;
use warnings;

use Test::More tests => 10 * 2;
use DateTime 0.10;
use DateTime::Format::SQLite;

my %tests_date = (
  '2003-07-01' => {
    year      => 2003,
    month     => 7,
    day	      => 1, },

  '19999-01-01' => {
    year      => 19999,
    month     => 1,
    day	      => 1, },
    
  '-0002-12-24' => {
    year      => -2,
    month     => 12,
    day	      => 24, },
);

foreach my $result (keys %tests_date) {
  my $dt = DateTime->new( %{$tests_date{$result}} );
  is( DateTime::Format::SQLite->format_date($dt), $result );
  is( DateTime::Format::SQLite->parse_datetime($result)->iso8601, $dt->iso8601 );
}

my %tests_time = (
  '12:34:45' => {
    year      => 2000,
    hour      => 12,
    minute    => 34,
    second    => 45
    
    },
    
  '00:00:00' => {
    year      => 2000,
  },
);

foreach my $result (keys %tests_time) {
  my $dt = DateTime->new( %{$tests_time{$result}} );
  is( DateTime::Format::SQLite->format_time($dt), $result );
  is( DateTime::Format::SQLite->parse_datetime($result)->iso8601, $dt->iso8601 );
}

my %tests_datetime = (
  '2003-07-01 12:00:00' => {
    year      => 2003,
    month     => 7,
    day	      => 1,
    hour      => 12,
  },

  '19999-01-01 12:34:45' => {
    year      => 19999,
    month     => 1,
    day	      => 1,
    hour      => 12,
    minute    => 34,
    second    => 45
    
    },
    
  '-0002-12-24 00:00:00' => {
    year      => -2,
    month     => 12,
    day	      => 24, },
);

foreach my $result (keys %tests_datetime) {
  my $dt = DateTime->new( %{$tests_datetime{$result}} );
  is( DateTime::Format::SQLite->format_datetime($dt), $result );
  is( DateTime::Format::SQLite->parse_datetime($result)->iso8601, $dt->iso8601 );
}

my %tests_julianday = (
  '0' => {
    year      => -4713,
    month     => 11,
    day	      => 24,
    hour      => 12,
  },

  '2454722.5' => {
    year      => 2008,
    month     => 9,
    day	      => 13,
  },
);

foreach my $result (keys %tests_julianday) {
  my $dt = DateTime->new( %{$tests_julianday{$result}} );
  is( DateTime::Format::SQLite->format_julianday($dt)+0.0, $result+0.0 );
  is( DateTime::Format::SQLite->parse_datetime($result)->iso8601, $dt->iso8601 );
}
