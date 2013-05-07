    use LIVR::Contract qw/contract/;
    
    contract('my_method')->requires({
        name      => [ 'required' ],
        id        => [ 'required', 'positive_integer' ]
    })->ensures({
        result => ['required', 'positive_integer' ]
    })->enable();

