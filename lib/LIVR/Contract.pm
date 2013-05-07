package LIVR::Contract;

use strict;

use Validator::LIVR;
use Class::Method::Modifier qw/install_modifier/;

use Moo;

has 'subname'           => ( is => 'rw', required => 1 );
has 'package'           => ( is => 'rw', required => 1 );
has 'ensures'           => ( is => 'rw' );
has 'requires'          => ( is => 'rw' );
has 'input_preparator'  => ( is => 'rw' );
has 'output_preparator' => ( is => 'rw' );
has 'on_fail'           => ( is => 'lazy' );

has '_input_validator'   => (
    is => 'lazy',
    default => sub {
        my $self = shift;
        return Validator::LIVR->new($self->requires)->prepare();
    }
);

has '_output_validator'  => (
    is => 'lazy',
    default => sub {
        my $self = shift;
        return Validator::LIVR->new($self->requires)->prepare();
    }
);

sub contract {
    my $subname = shift;
    my $package = '';

    return __PACKAGE__->new(
        'subname' => $subname,
        'package' => $package
    );
}

sub enable {
    my $self = shift;

    install_modifier( $package, 'around', $self->subname, sub {
        my $orig = shift;
        my $input = $self->input_preparator->(@_);
        $self->_validate_input($input);

        my $output = wantarray ? [ $orig->(@_) ] : $orig->(@_);

        $self->_validate_output($output);

        return wantarray ? @$output : $output;
    });
}

sub _validate_input {
    my ($self, $input) = @_;
    my $validator = $self->_input_validator;

    if ( ! $validator->validate($input) ) {
        $self->on_fail->( $self->package, $self->subname, $validator->get_errors() );
    }
}

sub _validate_output {
    my ($self, $output) = @_;

    my $validator = $self->_output_validator;

    if ( ! $validator->validate($input) ) {
        $self->on_fail->( $self->package, $self->subname, $validator->get_errors() );
    }
}

sub _build_on_fail {
    return sub  {
        my ($package, $subname, $errors) = @_;
        die "$package: $subname";
    }
}


# sub new {
#     my ($class, %args) = @_;
#     my $self = {
#         'subname'  => $args->{subname},
#         'package'  => $args->{package},
#         'ensures'  => {},
#         'requires' => {},
#         #...
#     }
# }

# sub ensures {
#     my ($self, $livr) = @_;
#     $self->{ensures} = $livr;
#     return $self;
# }

# sub requires {
#     my ($self, $livr) = @_;
#     $self->{requires} = $livr;
#     return $self;
# }

# sub input_preparator {
#     my ($self, $preparator) = @_;
#     $self->{input_preparator} = $preparator;
#     return $self;
# }


# sub output_preparator {
#     my ($self, $preparator) = @_;
#     $self->{output_preparator} = $preparator;
#     return $self;
# }


1;