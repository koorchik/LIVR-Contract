#!/usr/bin/perl
use strict;
use warnings;

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Test::More;

use LIVRContractSimpleRoleConsumerExample;

subtest 'Test "requires" rules' => sub {
    eval {
        LIVRContractSimpleRoleConsumerExample->create_object(id => '0');
    };

    ok($@, 'Should throw exception');
    isa_ok($@, 'LIVR::Contract::Exception');

    is($@->type, 'input', 'Should be "input" type');
    is($@->subname, 'create_object', 'Should contain name of failed method');
    is($@->package, 'LIVRContractSimpleRoleConsumerExample', 'Should contain name of failed package');

    is_deeply($@->errors, { name => 'REQUIRED', id => 'NOT_POSITIVE_INTEGER' }, 'Should  contain errors in Validator::LIVR format');
};


subtest 'Test "ensures" rules' => sub {
    eval {
        LIVRContractSimpleRoleConsumerExample->create_object(name => 'Viktor', id => 100 );
    };

    ok($@, 'Should throw exception');
    isa_ok($@, 'LIVR::Contract::Exception');

    is($@->type, 'output', 'Should be "input" type');
    is($@->subname, 'create_object', 'Should contain name of failed method');
    is($@->package, 'LIVRContractSimpleRoleConsumerExample', 'Should contain name of failed package');

    is_deeply($@->errors, { 0 => 'NOT_POSITIVE_INTEGER' }, 'Should  contain errors in Validator::LIVR format');
};

done_testing();

1;
