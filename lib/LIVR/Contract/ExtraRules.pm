package LIVR::Contract::ExtraRules;

use Scalar::Util;

sub livr_isa {
    my $class_name = shift;

    return sub {
        my $value = shift;
        return if !defined($value) || $value eq '';

        return 'WRONG_OBJECT_CLASS' unless UNIVERSAL::isa($value, $class_name);
        return;
    };
}

sub livr_can {
    my $method_name = shift;

    return sub {
        my $value = shift;
        return if !defined($value) || $value eq '';

        return 'NO_REQUIRED_METHOD' unless UNIVERSAL::can($value, $method_name);
        return;
    };
}

sub livr_blessed {
    return sub {
        my $value = shift;
        return if !defined($value) || $value eq '';

        return 'NOT_BLESSED' unless Scalar::Util::blessed($value);
        return;
    };
}

1;