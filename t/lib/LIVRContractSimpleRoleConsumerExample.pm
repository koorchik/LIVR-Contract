package LIVRContractSimpleRoleConsumerExample;

use FindBin qw/$Bin/;
use lib "$Bin/../lib";


use Role::Tiny::With;
with 'LIVRContractSimpleInterfaceExample';

sub create_object {
    my ($class, %args) = @_;

    return {
        name => $args{name},
        id   => $args{id}
    };
}

1;