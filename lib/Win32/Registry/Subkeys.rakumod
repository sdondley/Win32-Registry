unit module Win32::Registry::Subkeys;
use Win32::Registry;

use NativeCall;

sub get-subkeys(Str:D $h, Str:D $k) is export {
    my $hkey-handle = get-hkey-handle($h);

    my int32 $hkey;
    my $success = RegOpenKeyExW(
            $hkey-handle,
            wstr($k),
            0,
            KEY_QUERY_VALUE,
            $hkey
                                             );

    if $success != ERROR_SUCCESS {
        die "Could not open key to $hkey-handle\\$k";
    }

    $success = RegQueryInfoKeyW($hkey, 0, 0, 0, my int32 $num-subkeys, my int32
    $max-sk-len, 0, 0, 0, 0, 0, 0);

    my @subkeys;
    for ^$num-subkeys {
        # the native call function gets placed in the loop to avoid problems:
        # see issue #1719 at https://github.com/MoarVM/MoarVM/issues/1719
        sub RegEnumKeyExW(
                int32 $hkey,
                # 1 handle to an open reg. key
                int32,
                # 2 the index of the subkey to retrieve
                CArray[uint16],
                # 3 pointer to a buffer
                int32 is rw,
                # 4 pointer to a variable
                int32,
                # 5 unused
                CArray[int16],
                # 6 pointer to a buffer, can be null
                int32,
                # 7 pointer to a variable, can be null
                int32
                # 8 pointer to a file structure, can be null
                          ) returns int32 is native('kernel32') {*};

        my $subkeyname = CArray[uint16].new;
        $subkeyname[$_] = 0 for 0 .. $max-sk-len;
        RegEnumKeyExW(
                $hkey,
                $_,
                $subkeyname,
                $max-sk-len + 1,
                0, CArray[int16],
                0,
                0);
        my $name = '';
        for ^$max-sk-len {
            $name ~= chr($subkeyname[$_]) if $subkeyname[$_].so;
        }
        my $key = join '\\', get-hkey($h), $k, $name;
        push @subkeys, $key;
    }
    return @subkeys;
}

=begin pod

=head1 NAME

Win32::Registry::Subkeys - Retrieve subkeys from the Windows registry

=head1 SYNOPSIS

=begin code :lang<raku>

use Win32::Registry::Subkeys;
my $hive = 'HKEY_LOCAL_MACHINE';
my $key  = 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths';
my @array  = get-subkeys( $hive, $key );

=end code

=head1 DESCRIPTION

Win32::Registry::Subkeys uses the NativeCall module to execute the
WinAPI functions to extract the subkeys below a key in the registry.

=head1 ROUTINES

=head2 get-subkeys(Str:D $hive, Str:D $key)

Returns an array with each element containing a string representing a subkey
within a given C<$key> in the registry C<$hive>.

=head1 AUTHOR

Steve Dondley <s@dondley.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Steve Dondley

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
