# 05_hostmatch.t
#
# Test suite for Regexp::Assemble
# Test a mini-application that you can build with Regexp::Assemble
#
# copyright (C) 2004-2007 David Landgren

use strict;
use Regexp::Assemble;

use constant file_testcount => 3; # tests requiring Test::File::Contents

eval qq{use Test::More tests => 22 + file_testcount};
if( $@ ) {
    warn "# Test::More not available, no tests performed\n";
    print "1..1\nok 1\n";
    exit 0;
}

use constant NR_GOOD  => 45;
use constant NR_BAD   => 529;
use constant NR_ERROR => 0;

my $fixed = 'The scalar remains the same';
$_ = $fixed;

my $have_Test_File_Contents = do {
    eval { require Test::File::Contents; import Test::File::Contents };
    $@ ? 0 : 1;
};

my @re = <DATA>;

# ordinarily we could have just chomp the array after having slurped
# <DATA>, but that would be no fun.

# insert them all into an R::A object, chomping the lines
my $ra = Regexp::Assemble->new->chomp(1)->add( @re );

is( ref($ra), 'Regexp::Assemble', 'have a Regexp::Assemble object' );

# now map each RE into its compiled form
@re = map { chomp; qr/$_/ } @re;

ok( open(GOOD,  '>t/good.out'),  "can open t/good.out for output" )  or print "# $!\n";
ok( open(BAD,   '>t/bad.out'),   "can open t/bad.out for output" )   or print "# $!\n";
ok( open(ERROR, '>t/error.out'), "can open t/error.out for output" ) or print "# $!\n";

my( $good, $bad, $error ) = (0, 0, 0);
END {
    if( !$error ) {
        unlink $_ for qw{ t/good.out t/bad.out t/error.out };
    }
}

ok( open(IN, 'eg/hostmatch/source.in'), "can open eg/hostmatch/source.in" ) or print "# $!\n";
while( defined( my $rec = <IN> )) {
    chomp $rec;
    if( $rec =~ /^$ra$/ ) {
        my $seen = 0;
        my $re;
        for $re (@re) {
            if( $rec =~ /^$re$/ ) {
                print BAD "$rec\n";
                ++$bad;
                ++$seen;
                last;
            }
        }
        if( not $seen ) {
            print ERROR "$rec\n";
            ++$error;
        }
    }
    else {
        my $seen = 0;
        my $re;
        for $re (@re) {
            if( $rec =~ /^$re$/ ) {
                print ERROR "$rec\n";
                ++$error;
                ++$seen;
                last;
            }
        }
        if( not $seen ) {
            print GOOD "$rec\n";
            ++$good;
        }
    }
}

close GOOD;
close BAD;
close ERROR;

is( NR_GOOD,  $good,   NR_GOOD.  ' good records not matched' );
is( NR_BAD,   $bad,    NR_BAD.   ' bad records matched' );
is( NR_ERROR, $error,  NR_ERROR. ' records in error' );
is( NR_GOOD+NR_BAD+NR_ERROR, $., "$. total records" );

SKIP: {
    skip( 'Test::File::Contents not installed on this system', file_testcount )
        unless $have_Test_File_Contents;
    my $file;
    for $file( qw/good bad error/ ) {
        file_contents_identical( "t/$file.out", "eg/hostmatch/$file.canonical", "saw expected $file output" );
    }
} # SKIP

{
    my $r = Regexp::Assemble->new;
    $r->add_file('eg/file.1')->add_file('eg/file.2');
    is( $r->as_string, '(?:b(?:l(?:ea|o)|[eo]a)t|s[aiou]ng)',
        q{add_file('file.1'), add_file('file.2')},
        'add_file() 2 calls'
    );

    is(
        Regexp::Assemble->new->chomp->add_file( qw[eg/file.1 eg/file.2] )
        ->as_string,
        '(?:b(?:l(?:ea|o)|[eo]a)t|s[aiou]ng)',
        'add_file() multiple files'
    );

    is(
        Regexp::Assemble->new->chomp->add_file({
            file => [qw[eg/file.1 eg/file.2]]
        })
        ->as_string,
        '(?:b(?:l(?:ea|o)|[eo]a)t|s[aiou]ng)',
        'add_file() alternate interface'
    );

    my $str = Regexp::Assemble->new
        ->add_file({ file => ['eg/file.4'], rs => '/', })
        ->as_string;
    is( $str, '(?:(?:do|pi)g|c(?:at|ow)|hen)',
        'add_file with explicit record separator'
    );

    is( Regexp::Assemble->new( rs => '/' )
        ->add_file({ file => ['eg/file.4'] })
        ->as_string, $str, 'add_file hashref with record separator specified in new()'
    );

    is( Regexp::Assemble->new
        ->add_file({ file => 'eg/file.4', input_record_separator => '/', })
        ->as_string, $str, 'add_file hashref with record separator specified in new()'
    );

    is( Regexp::Assemble->new( rs => '/' )
        ->add_file('eg/file.4')
        ->as_string, $str, 'add_file with record separator specified in new()'
    );

    is(
        Regexp::Assemble->new(
            file => 'eg/file.4',
            input_record_separator => '/',
        )
        ->as_string, $str,
        'new() file and custom record separator'
    );

    {
        local $/ = undef;
        my $raw_contents = 'cat/dog/cow/pig/hen';

        is( Regexp::Assemble->new
            ->add_file({file => 'eg/file.4'})
            ->as_string, $raw_contents, 'add_file with no record separator'
        );

        is(
            Regexp::Assemble->new(file => 'eg/file.4')->as_string,
                $raw_contents,
                'new() file and no record separator'
        );
    }

    eval { my $r = Regexp::Assemble->new( file => '/does/not/exist' ) };
    is( substr($@,0,38), q{cannot open /does/not/exist for input:}, 'file does not exist for new()' );

    SKIP: {
        skip( 'ignore DOS line-ending tests on Win32', 1 ) if $^O =~ /^MSWin32/;
        is(
            Regexp::Assemble->new->chomp->add_file({
                file => [qw[eg/file.3]],
                rs   => "\r\n",
            })
            ->as_string,
            '(?:e[ns]|i[ls])',
            'add_file() with DOS line endings'
        );
    }
}

is( $_, $fixed, '$_ has not been altered' );

__DATA__
m\d+-\d+-\d+-\d+\.andorpac\.ad
de\d+\.alshamil\.net\.ae
\d+-\d+-\d+-\d+\.fibertel\.com\.ar
ol\d+-\d+\.fibertel\.com\.ar
host\d+\.\d+\.\d+\.\d+\.ifxnw\.com\.ar
int-\d+-\d+-\d+-\d+\.movi\.com\.ar
host-\d+\.\d+\.\d+\.\d+-ta\.adsl\.netizen\.com\.ar
dsl-\d+-\d+-\d+-\d+\.users\.telpin\.com\.ar
\d+-\d+-\d+-\d+\.bbt\.net\.ar
\d+-\d+-\d+-\d+\.prima\.net\.ar
\d+-\d+-\d+-\d+\.cab\.prima\.net\.ar
\d+-\d+-\d+-\d+\.dsl\.prima\.net\.ar
\d+-\d+-\d+-\d+\.dup\.prima\.net\.ar
\d+-\d+-\d+-\d+\.dup\.prima\.net\.ar
\d+-\d+-\d+-\d+\.wll\.prima\.net\.ar
host\d+\.\d+-\d+-\d+\.telecom\.net\.ar
chello\d+\.\d+\.sc-graz\.chello\.at
\d+-\d+-\d+-\d+\.dynamic\.home\.xdsl-line\.inode\.at
\d+-\d+-\d+-\d+\.paris-lodron\.xdsl-line\.inode\.at
h\d+\.dyn\.cm\.kabsi\.at
h\d+\.med\.cm\.kabsi\.at
h\d+\.moe\.cm\.kabsi\.at
cm\d+-\d+\.liwest\.at
\d+-\d+-\d+-\d+\.pircher\.at
\d+-\d+-\d+-\d+\.dyn\.salzburg-online\.at
chello\d+\.\d+\.graz\.surfer\.at
chello\d+\.\d+\.klafu\.surfer\.at
chello\d+\.tirol\.surfer\.at
chello\d+\.\d+\.\d+\.vie\.surfer\.at
d\d+-\d+-\d+-\d+\.cust\.tele\d+\.at
m\d+p\d+\.adsl\.highway\.telekom\.at
n\d+p\d+\.adsl\.highway\.telekom\.at
l\d+p\d+\.dipool\.highway\.telekom\.at
chello\d+\.\d+\.\d+\.univie\.teleweb\.at
chello\d+\.\d+\.\d+\.wu-wien\.teleweb\.at
dsl-linz\d+-\d+-\d+\.utaonline\.at
dialup-\d+\.syd\.ar\.com\.au
dialup-\d+\.\d+\.\d+\.\d+\.acc\d+-ball-lis\.comindico\.com\.au
dialup-\d+\.\d+\.\d+\.\d+\.acc\d+-mcmi-dwn\.comindico\.com\.au
dsl-\d+\.\d+\.\d+\.\d+\.dsl\.comindico\.com\.au
\d+-\d+-\d+-\d+\.netspeed\.com\.au
blaax\d+-a\d+\.dialup\.optusnet\.com\.au
chtax\d+-\d+\.dialup\.optusnet\.com\.au
lonax\d+-b\d+\.dialup\.optusnet\.com\.au
rohax\d+-\d+\.dialup\.optusnet\.com\.au
wayax\d+-\d+\.dialup\.optusnet\.com\.au
winax\d+-\d+\.dialup\.optusnet\.com\.au
wooax\d+-b\d+\.dialup\.optusnet\.com\.au
d\d+-\d+-\d+-\d+\.dsl\.nsw\.optusnet\.com\.au
c\d+-\d+-\d+-\d+\.eburwd\d+\.vic\.optusnet\.com\.au
c\d+-\d+-\d+-\d+\.lowrp\d+\.vic\.optusnet\.com\.au
\d+\.fip-\d+\.permisdn\.ozemail\.com\.au
\d+-\d+-\d+-\d+-bri-ts\d+-\d+\.tpgi\.com\.au
\d+-\d+-\d+-\d+-vic-pppoe\.tpgi\.com\.au
\d+-\d+-\d+-\d+\.tpgi\.com\.au
dar-\d+k-\d+\.tpgi\.com\.au
sou-ts\d+-\d+-\d+\.tpgi\.com\.au
ains-\d+-\d+-\d+-\d+\.ains\.net\.au
cpe-\d+-\d+-\d+-\d+\.nsw\.bigpond\.net\.au
cpe-\d+-\d+-\d+-\d+\.qld\.bigpond\.net\.au
cpe-\d+-\d+-\d+-\d+\.sa\.bigpond\.net\.au
cpe-\d+-\d+-\d+-\d+\.vic\.bigpond\.net\.au
cpe-\d+-\d+-\d+-\d+\.wa\.bigpond\.net\.au
ppp-\d+\.cust\d+-\d+-\d+\.ghr\.chariot\.net\.au
adsl-\d+\.cust\d+-\d+-\d+\.qld\.chariot\.net\.au
\d+-\d+-\d+-\d+\.dyn\.iinet\.net\.au
\d+\.a\.\d+\.mel\.iprimus\.net\.au
\d+\.b\.\d+\.pth\.iprimus\.net\.au
\d+\.a\.\d+\.sop\.iprimus\.net\.au
r\d+-\d+-\d+-\d+\.cpe\.unwired\.net\.au
dial-\d+\.\d+\.\d+\.\d+\.cotas\.com\.bo
\d+-dial-user-ecp\.acessonet\.com\.br
\d+-\d+-\d+-\d+\.corp\.ajato\.com\.br
\d+\.\d+\.\d+\.\d+\.user\.ajato\.com\.br
\d+-\d+-\d+-\d+\.user\.ajato\.com\.br
\d+\.\d+\.\d+\.\d+\.user\.ajato\.com\.br
cm-net-cwb-c[\da-f]+\.brdterra\.com\.br
cm-net-poa-c[\da-f]+\.brdterra\.com\.br
cm-tvcidade-rec-c[\da-f]+\.brdterra\.com\.br
cm-tvcidade-ssa-c[\da-f]+\.brdterra\.com\.br
cm-virtua-fln-c[\da-f]+\.brdterra\.com\.br
cm-virtua-poa-c[\da-f]+\.brdterra\.com\.br
net-\d+-\d+\.cable\.cpunet\.com\.br
\d+-\d+-\d+\.xdsl-dinamico\.ctbcnetsuper\.com\.br
\d+-\d+-\d+\.xdsl-fixo\.ctbcnetsuper\.com\.br
dl-nas\d+-poa-c[\da-f]+\.dialterra\.com\.br
\d+-\d+-\d+-\d+\.brt\.dialuol\.com\.br
\d+-\d+-\d+-\d+\.tlf\.dialuol\.com\.br
\d+-\d+-\d+-\d+\.tlm\.dialuol\.com\.br
\d+-\d+-\d+-\d+\.rev\.easyband\.com\.br
max-\d+-\d+-\d+\.nwnet\.com\.br
\d+-\d+-\d+-\d+\.papalegua\.com\.br
adsl\d+c\d+\.sercomtel\.com\.br
\d+\.user\.veloxzone\.com\.br
\d+\.virtua\.com\.br
\d+\.bhz\.virtua\.com\.br
[\da-f]+\.bhz\.virtua\.com\.br
[\da-f]+\.rjo\.virtua\.com\.br
[\da-f]+\.soc\.virtua\.com\.br
[\da-f]+\.virtua\.com\.br
\d+\.rjo\.virtua\.com\.br
bhe\d+\.res-com\.wayinternet\.com\.br
\d+-\d+-\d+-\d+\.mganm\d+\.dial\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.pmjce\d+\.dial\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.pnisir\d+\.dial\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.pvoce\d+\.dial\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.sance\d+\.dial\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.bnut\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.bsace\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.cbabm\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.cpece\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.cslce\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.ctame\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.gnace\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.jvece\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.nhoce\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.paemt\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.pltce\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.pvoce\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.smace\d+\.dsl\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.smace\d+\.e\.brasiltelecom\.net\.br
\d+-\d+-\d+-\d+\.dialdata\.net\.br
\d+\.\d+\.\d+\.\d+\.dialup\.gvt\.net\.br
\d+\.\d+\.\d+\.\d+\.tbprof\.gvt\.net\.br
\d+-\d+-\d+-\d+\.customer\.telesp\.net\.br
\d+-\d+-\d+-\d+\.dial-up\.telesp\.net\.br
\d+-\d+-\d+-\d+\.dsl\.telesp\.net\.br
