# $Id: withsqlite.t 4064 2008-09-13 16:54:37Z cfaerber $
#
use strict;
use warnings;

use Test::More;

use DateTime 0.10;
use DateTime::Format::SQLite;

eval "use DBI;";
plan skip_all => "DBI required for real database test" if $@;

eval "use DBD::SQLite;";
plan skip_all => "DBD::SQLite required for real database test" if $@;

my %tests = (
  '2003-07-01' => {
    year      => 2003,
    month     => 7,
    day	      => 1, },

  '-0002-12-24' => {
    year      => -2,
    month     => 12,
    day	      => 24, },
  
  '12:34:45' => {
    year      => 2000,
    hour      => 12,
    minute    => 34,
    second    => 45 },
    
  '00:00:00' => {
    year      => 2000,
  },

  '1999-01-01 12:34:45' => {
    year      => 1999,
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

plan tests => 8 * 2;

my $file = "sql$$.tmp";
my $dbh = DBI->connect("dbi:SQLite:dbname=$file","","");

foreach my $result (keys %tests) {
  my $dt = DateTime->new( %{$tests{$result}} );

  # check that SQLite can parse our formatted dates
  #
  cmp_ok( $dbh->selectrow_array('SELECT julianday(?)', {},
        DateTime::Format::SQLite->format_datetime($dt)) - $dt->jd,
      '<', 0.0001, "$result/format");

  # check that we can parse what SQLite's datetime returns
  #
  cmp_ok( DateTime::Format::SQLite->parse_datetime(
        $dbh->selectrow_array('SELECT julianday(?)', {},
	$result))->jd - $dt->jd,
      '<', 0.0001, "$result/format");
}

unlink $file;
