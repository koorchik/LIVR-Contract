package LIVRContractSimpleInterfaceExample;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use LIVR::Contract qw/contract/;

use Role::Tiny;
requires 'create_object';

contract('create_object')->requires({
    name      => [ 'required' ],
    id        => [ 'required', 'positive_integer' ]
})->ensures({
    0 => ['required', 'positive_integer' ]
})->enable();

1;