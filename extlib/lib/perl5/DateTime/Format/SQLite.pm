# $Id: SQLite.pm 4363 2009-12-10 16:47:25Z cfaerber $
#
package DateTime::Format::SQLite;

use strict;
use vars qw ($VERSION);
use warnings;

our $VERSION = '0.11';
$VERSION = eval { $VERSION };

# "days since noon in Greenwich on November 24, 4714 B.C."
my %jd0 = ( 'year' => -4713, 'month' => 11, 'day' => 24, 'hour' => 12, time_zone => 'UTC' );

use DateTime::Format::Builder
    ( parsers =>
      { parse_datetime =>
        [
	  # format 1
	  #
          { params => [ qw( year month day ) ],
            regex  => qr/^(-?\d+)-(\d+)-(\d+)$/,
            extra  => { time_zone => 'UTC' },
          },

	  # formats 2 and 5
	  #
          { params => [ qw( year month day hour minute ) ],
            regex  => qr/^(-?\d+)-(\d{1,2})-(\d{1,2})[Tt ](\d{1,2}):(\d{1,2})$/,
            extra  => { time_zone => 'UTC' },
          },

	  # formats 3, 4, 6 and 7
	  #
          { params => [ qw( year month day hour minute second nanosecond ) ],
            regex  => qr/^(-?\d+)-(\d{1,2})-(\d{1,2})[Tt ](\d{1,2}):(\d{1,2}):(\d{1,2})(\.\d*)?$/,
            extra  => { time_zone => 'UTC' },
	    postprocess => \&_fix_nanoseconds,
          },

	  # format 8
	  #
          { params => [ qw( hour minute ) ],
            regex  => qr/^(\d{1,2}):(\d{1,2})$/,
            extra  => { time_zone => 'UTC', 'year' => 2000, },
          },

	  # format 9, 10
	  #
          { params => [ qw( hour minute second nanosecond ) ],
            regex  => qr/^(\d{1,2}):(\d{1,2}):(\d{1,2})(\.\d*)?$/,
            extra  => { time_zone => 'UTC', 'year' => 2000, },
	    postprocess => \&_fix_nanoseconds,
          },

	  # format 11
	  #
	  { params => [ qw ( dummy ) ],
	    regex  => qr/^([Nn][Oo][Ww])$/,
	    constructor => sub { return DateTime->now },
	  },

	  # format 12
	  #
	  { params => [ qw( jd secs ) ],
	    regex  => qr/^(\d+(\.\d*)?)$/,
	    constructor => sub { shift; my %p=(@_); return DateTime->new(%jd0)->add(
	      'days' => int($p{'jd'}), 'seconds' => ($p{'secs'} || 0) * (3600 * 24) ); },
	  },
	]
      },
    );

*parse_date = \&parse_datetime;
*parse_time = \&parse_datetime;
*parse_julianday = \&parse_datetime;

sub format_date
{
    my ( $self, $dt ) = @_;

    $dt = $dt->clone;
    $dt->set_time_zone('UTC');

    return $dt->ymd('-');
}

sub format_time
{
    my ( $self, $dt ) = @_;

    $dt = $dt->clone;
    $dt->set_time_zone('UTC');

    return $dt->hms(':');
}

sub format_datetime
{
    my ( $self, $dt ) = @_;

    $dt = $dt->clone;
    $dt->set_time_zone('UTC');

    return join ' ', $dt->ymd('-'), $dt->hms(':');
}


sub format_julianday
{
    my ( $self, $dt ) = @_;

    return $dt->jd;
}

sub _fix_nanoseconds 
{
    my %args = @_;
    $args{'parsed'}->{'nanosecond'} ||= 0;
    $args{'parsed'}->{'nanosecond'} *= 1000 * 1000 * 1000;
    1;
}

1;

__END__

=encoding utf8

=head1 NAME

DateTime::Format::SQLite - Parse and format SQLite dates and times

=head1 SYNOPSIS

  use DateTime::Format::SQLite;

  my $dt = DateTime::Format::SQLite->parse_datetime( '2003-01-16 23:12:01' );

  # 2003-01-16 23:12:01
  DateTime::Format::SQLite->format_datetime($dt);

=head1 DESCRIPTION

This module understands the formats used by SQLite for its
C<date>, C<datetime> and C<time> functions.  It can be used to
parse these formats in order to create L<DateTime> objects, and it
can take a DateTime object and produce a timestring accepted by
SQLite.

B<NOTE:> SQLite does not have real date/time types but stores
everything as strings. This module deals with the date/time
strings as understood/returned by SQLite's C<date>, C<time>,
C<datetime>, C<julianday> and C<strftime> SQL functions.
You will usually want to store your dates in one of these formats.

=head1 METHODS

This class offers the methods listed below.  All of the parsing
methods set the returned DateTime object's time zone to the B<UTC>
zone because SQLite does always uses UTC for date calculations.
This means your dates may seem to be one day off if you convert
them to local time.

=over 4

=item * parse_datetime($string)

Given a C<$string> representing a date, this method will return a new
C<DateTime> object.

The C<$string> may be in any of the formats understood by SQLite's
C<date>, C<time>, C<datetime>, C<julianday> and C<strftime> SQL
functions or it may be in the format returned by these functions
(except C<strftime>, of course).

The time zone for this object will always be in UTC because SQLite
assumes UTC for all date calculations.

If C<$string> contains no date, the parser assumes 2000-01-01
(just like SQLite).

If given an improperly formatted string, this method may die.

=item * parse_date($string)

=item * parse_time($string)

=item * parse_julianday($string)

These are aliases for C<parse_datetime>, for symmetry with
C<format_I<*>> functions.

=item * format_date($datetime)

Given a C<DateTime> object, this methods returnes a string in the
format YYYY-MM-DD, i.e. in the same format SQLite's C<date>
function uses.

=item * format_time($datetime)

Given a C<DateTime> object, this methods returnes a string in the
format HH:MM:SS, i.e. in the same format SQLite's C<time>
function uses.

=item * format_datetime($datetime)

Given a C<DateTime> object, this methods returnes a string in the
format YYYY-MM-DD HH:MM:SS, i.e. in the same format SQLite's C<datetime>
function uses.

=item * format_julianday($datetime)

Given a C<DateTime> object, this methods returnes a string in the
format DDDDDDDDDD, i.e. in the same format SQLite's C<julianday>
function uses.

=back

=head1 AUTHOR

Claus Färber <CFAERBER@cpan.org>

based on C<DateTime::Format::MySQL> by David Rolsky.

=head1

Copyright © 2008 Claus Färber.

Copyright © 2003 David Rolsky. 

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file
included with this module.

=head1 SEE ALSO

http://datetime.perl.org/

http://www.sqlite.org/lang_datefunc.html

=cut
