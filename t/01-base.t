#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Test::More;

BEGIN {
    use_ok( 'LIVR::Contract', 'contract') || print "Bail out!\n";
}

package MyTestingClass;

use LIVR::Contract qw/contract/;

contract('my_method')->requires({
    name      => [ 'required' ],
    id        => [ 'required', 'positive_integer' ]
})->ensures({
    0 => ['required', 'positive_integer' ]
})->enable();


sub my_method {
    return 0;
}

package main;

subtest 'Test "requires" rules' => sub {
    eval {
        MyTestingClass->my_method(id => '0');
    };

    ok($@, 'Should throw exception');
    isa_ok($@, 'LIVR::Contract::Exception');
    
    is($@->type, 'input', 'Should be "input" type');
    is($@->subname, 'my_method', 'Should contain name of failed method');
    is($@->package, 'MyTestingClass', 'Should contain name of failed package');

    is_deeply($@->errors, {name => 'REQUIRED', id => 'NOT_POSITIVE_INTEGER'}, 'Should  contain errors in Validator::LIVR format');
};


subtest 'Test "ensures" rules' => sub {
    eval {
        MyTestingClass->my_method(name => 'Viktor', id => 100 );
    };

    ok($@, 'Should throw exception');
    isa_ok($@, 'LIVR::Contract::Exception');
    
    is($@->type, 'output', 'Should be "input" type');
    is($@->subname, 'my_method', 'Should contain name of failed method');
    is($@->package, 'MyTestingClass', 'Should contain name of failed package');

    is_deeply($@->errors, {0 => 'NOT_POSITIVE_INTEGER'}, 'Should  contain errors in Validator::LIVR format');
};

done_testing();

1;
