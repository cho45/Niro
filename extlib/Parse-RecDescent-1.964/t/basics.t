# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..19\n"; }
END {print "not ok 1\n" unless $loaded;}
use Parse::RecDescent;
$loaded = 1;
print "ok 1\n";

sub debug { $D || $D || 0 }

my $count = 2;
sub ok($;$)
{
	my $ok = ((@_==2) ? ($_[0] eq $_[1]) : $_[0]);
	print "\texp=[$_[1]]\n\tres=[$_[0]]\n" if debug && @_==2;
	print "not " unless $ok;
	print "ok $count\n";
	$count++;
	return $ok;
}

######################### End of black magic.

do { $RD_TRACE = 1; $RD_HINT = 1; } if debug > 1;

$data1    = '(the 1st   teeeeeest are easy easy easyeasy';
$expect1  = '[1st|teeeeeest|are|easy:easy:easy:easy]';

$data2    = '(the 2nd   test is';
$expect2  = '[2nd|test|is|]';

$data3    = 'the cat';
$expect3a = 'fluffy';
$expect3b = 'not fluffy';

$data4    = 'a dog';
$expect4  = 'rover';

$data5    = 'type a is int; type b is a; var x holds b; type c is d;';
$expect5  = 'typedef=>a, typedef=>b, defn=>x, baddef, baddef';

##################################################################

$parser_A = new Parse::RecDescent q
{
	test1:	"(" 'the' "$::first" /te+st/ is ('easy')(s?)
			{ "[$item[3]|$item[4]|$item[5]|" .
				join(':', @{$item[6]})   .
				']' }

	is:	'is' | 'are'

#================================================================#

	test2:	<matchrule:$arg{article}>
		<matchrule:$arg[3]>[$arg{sound}]

	the:	'the'
	a:	'a'

	cat:	<reject: $arg[0] ne 'meows'> 'cat'
			{ "fluffy" }
	   |    { "not fluffy" }

	dog:	'dog'
			{ "rover" }

#================================================================#

	test3:	 (defn | typedef | fail)(5..10)
			{ join ', ', @{$item[1]}; }

	typedef: 'type' id 'is' typename ';'
			{ $return = "$item[0]=>$item[2]";
			  $thisparser->Extend("typename: '$item[2]'"); }

	fail:	 { 'baddef' }

	defn:	 'var' id 'holds' typename ';'
			{ "$item[0]=>$item[2]" }

	id:	 /[a-z]		# LEADING ALPHABETIC
		  \w*		# FOLLOWED BY ALPHAS, DIGITS, OR UNDERSCORES
		 /ix		# CASE INSENSITIVE

	typename: 'int'

#================================================================#

	test4:	'a' b /c/
			{ "$itempos[1]{offset}{from}:$itempos[2]{offset}{from}:$itempos[3]{offset}{from}" }

	b:	"b"

#================================================================#

	test5: ...!name notname | name

	notname: /[a-z]\w*/i { 'notname' }

	name: 'fred' { 'name' }

#================================================================#

	test6: <rulevar: $test6 = 1>
	test6: 'a' <commit> 'b' <uncommit> 'c' <reject: $test6 && $text>
			{ 'prod 1' }
	     | 'a'
			{ 'prod 2' }
	     | <uncommit>
			{ 'prod 3' }

#================================================================#

	test7: 'x' <resync> /y+/
			{ $return = $item[3] }
};

ok ($parser_A) or exit;



##################################################################
$first = "1st";
$res = $parser_A->test1($data1);
ok($res,$expect1);

##################################################################
$first = "2nd";
$res = $parser_A->test1($data2);
ok($res,$expect2);

##################################################################
$res = $parser_A->test2($data3,undef,
			article=>'the', animal=>'cat', sound=>'meows');
ok($res,$expect3a);

##################################################################
$res = $parser_A->test2($data3,undef,
			article=>'the', animal=>'cat', sound=>'purrs');
ok ($res,$expect3b);

##################################################################
$res = $parser_A->test2($data4,undef,
			article=>'a', animal=>'dog', sound=>'barks');
ok($res,$expect4);

##################################################################
$res = $parser_A->test3($data5);
ok($res,$expect5);

##################################################################
$res = $parser_A->test4("a  b   c");
ok($res, "0:1:7");

##################################################################
$res = $parser_A->test5("fred");
ok($res, "name");

$res = $parser_A->test5("fled");
ok($res, "notname");

##################################################################
$res = $parser_A->test6("a b d");
ok($res, "prod 2");

$res = $parser_A->test6("a c d");
ok($res, "prod 3");

$res = $parser_A->test6("a b c");
ok($res, "prod 1");

$res = $parser_A->test6("a b c d");
ok($res, "prod 2");

##################################################################
$res = $parser_A->test7("x yyy \n y");
ok($res, "y");


##################################################################

package Derived;

@ISA = qw { Parse::RecDescent };
sub method($$) { reverse $_[1] }

package main;

$parser_B = new Derived q
{
	test1:	/[a-z]+/i
		{ reverse $item[1] }
		{ $thisparser->method($item[2]) }
};

ok ($parser_B) or exit;
##################################################################
$res = $parser_B->test1("literal string");
ok($res, "literal");

#################################################################
$res = $parser_A->Extend("extended : 'some extension'");
ok(@{"$parser_A->{namespace}::ISA"} == 1);
