package LIVR::Contract;

use strict;
use warnings;

use Exporter 'import';
use Carp qw/croak/;

use Validator::LIVR;
use Class::Method::Modifiers qw/install_modifier/;
use LIVR::Contract::Exception;

our @EXPORT_OK = ( 'contract' );
our @CARP_NOT = (__PACKAGE__);

sub contract {
    my $subname = shift;
    croak "Subname is required" unless $subname;

    return __PACKAGE__->new(
        'subname' => $subname,
        'package' => ( caller )[ 0 ]
    );
}

sub new {
    my ( $class, %args ) = @_;

    croak '"subname" is required' unless $args{subname};
    croak '"package" is required' unless $args{package};

    my $self = bless {
        subname           => $args{subname},
        package           => $args{package},
        ensures           => $args{requires},
        requires          => $args{ensures},
        input_preparator  => $args{input_preparator},
        output_preparator => $args{output_preparator},
        on_fail           => $args{on_fail},
        input_validator   => undef,
        output_validator  => undef,
    }, $class;

    return $self;
}

sub ensures {
    my ( $self, $livr ) = @_;
    $self->{ensures} = $livr;
    return $self;
}

sub requires {
    my ( $self, $livr ) = @_;
    $self->{requires} = $livr;
    return $self;
}

sub input_preparator {
    my ( $self, $preparator ) = @_;
    $self->{input_preparator} = $preparator;
    return $self;
}

sub output_preparator {
    my ( $self, $preparator ) = @_;
    $self->{output_preparator} = $preparator;
    return $self;
}

sub enable {
    my $self = shift;

    install_modifier(
        $self->{package},
        'around',
        $self->{subname},
        sub {
            my $orig  = shift;

            my $input = $self->_get_input_preparator->( @_ );
            $self->_validate_input( $input );

            my $is_wantarray = wantarray;
            my $output = $is_wantarray ? [ $orig->( @_ ) ] : $orig->( @_ );
            
            my $prepared_output = $self->_get_output_preparator->( $is_wantarray ? @$output : $output );
            $self->_validate_output( $prepared_output );

            return $is_wantarray ? @$output : $output;
        }
    );
}

sub _validate_input {
    my ( $self, $input ) = @_;
    return unless $self->{requires};

    my $validator = $self->{input_validator} ||= Validator::LIVR->new( $self->{requires} )->prepare();

    if ( !$validator->validate( $input ) ) {
        $self->_get_on_fail->( 'input', $self->{package}, $self->{subname}, $validator->get_errors() );
    }
}

sub _validate_output {
    my ( $self, $output ) = @_;
    return unless $self->{ensures};

    my $validator = $self->{output_validator} ||= Validator::LIVR->new( $self->{ensures} )->prepare();

    if ( !$validator->validate( $output ) ) {
        $self->_get_on_fail->( 'output', $self->{package}, $self->{subname}, $validator->get_errors() );
    }
}

sub _get_input_preparator {
    my $self = shift;

    return $self->{input_preparator} ||= sub {
        my ($self, %args) = @_;
        return \%args;
    };
}

sub _get_output_preparator {
    my $self = shift;

    return $self->{output_preparator} ||=  sub {
        my %res;

        for (my $i=0; $i< @_; $i++) {
            $res{$i} = $_[$i];
        }

        return \%res;
    };
}

sub _get_on_fail {
    my $self = shift;
    
    return $self->{on_fail} ||=   sub {
        my ( $type, $package, $subname, $errors ) = @_;

        local $Carp::Internal{ (__PACKAGE__) } = 1;

        die LIVR::Contract::Exception->new(
            type    => $type,
            package => $package,
            subname => $subname,
            errors  => $errors
        );
    }
}

1;
