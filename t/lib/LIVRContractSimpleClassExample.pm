package LIVRContractSimpleClassExample;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";

use LIVR::Contract qw/contract/;

contract('create_object')->requires({
    name      => [ 'required' ],
    id        => [ 'required', 'positive_integer' ]
})->ensures({
    0 => ['required', 'positive_integer' ]
})->enable();


sub create_object {
    my ($class, %args) = @_;

    return {
        name => $args{name},
        id   => $args{id}
    };
}

1;