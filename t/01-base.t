#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'LIVR::Contract' ) || print "Bail out!\n";
}

diag( "Testing LIVR::Contract $LIVR::Contract::VERSION, Perl $], $^X" );
