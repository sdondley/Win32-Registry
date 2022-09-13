unit module Win32::Registry;

use NativeCall;

constant ERROR_SUCCESS is export = 0;
constant WCHAR is export = uint16;
constant WCHARS is export = CArray[WCHAR];
constant KEY_QUERY_VALUE is export = 0x1 +| 0x0008;


my %valid-hives = <
    hkey_classes_root     0x80000000
    hkey_current_user     0x80000001
    hkey_local_machine    0x80000002
    hkey_users            0x80000003
    hkey_performance_data 0x80000004
    hkey_current_config   0x80000005
    hkey_dyn_data         0x80000006
>;

sub get-hkey-handle(Str:D $h) is export {
    my $hive = (%valid-hives ~~ rx:i/$h/).orig;
    die "Unrecognized hive: $h" if !$hive;
    return %valid-hives{$hive};
}

sub get-hkey(Str:D $h) is export {
    my $hive = (%valid-hives ~~ rx:i/$h/).orig;
    die "Unrecognized hive: $h" if !$hive;
    return $hive;
}

sub RegGetValueW(int32,
                 CArray[WCHAR],
                 CArray[WCHAR],
                 int32,
                 int32,
                 CArray[uint16],
                 int32 is rw)
        is native("Kernel32.dll") returns int32 is export {*};

sub RegOpenKeyExW(int32, WCHARS, int32, int32, int32 is rw)
        is native("Kernel32.dll") returns int32 is export {*};

sub RegCloseKey(int32) is native("Kernel32.dll") returns int32 is export {*};

sub RegQueryInfoKeyW(int32, int32, int32, int32, int32 is rw, int32 is rw,
                     int32, int32, int32, int32, int32, int32)
        returns int32 is native('kernel32') is export {*};

sub wstr(Str $str) returns WCHARS is export {
    my $return = CArray[WCHAR].new($str.encode.list);
    $return[$return.elems] = 0;
    return $return;
}

sub close-key(Int:D $key-handle) is export {
    return !RegCloseKey($key-handle).so;
}

sub key-exists(Str:D $key) is export {
    my ($h, $k) = parse-key($key);
    my $hkey-handle = get-hkey-handle($h);
    my $hkey = _RegOpenKeyW($hkey-handle, $k);
    close-key $hkey if $hkey;
    return $hkey ?? True !! False;
}

sub _RegOpenKeyW(Int:D $hkey-handle, Str:D $k) {
    my int32 $hkey;
    my $success = RegOpenKeyExW(
            $hkey-handle,
            wstr($k),
            0,
            KEY_QUERY_VALUE,
            $hkey
    );
    # $success is 0 when function succeeded
    return !$success ?? $hkey !! 0;
}

multi sub open-key(Int:D $hkey-handle, Str:D $k) is export {
    my $hkey = _RegOpenKeyW($hkey-handle, $k);
    if !$hkey {
        die "Could not open key to { get-hkey($hkey-handle) }\\$k";
    }
    return $hkey;
}

multi sub open-key(Str:D $key) is export {
    my ($h, $k) = parse-key($key);
    my $hkey-handle = get-hkey-handle($h);
    my $hkey = open-key($hkey-handle, $k);
}

sub parse-key(Str $k) {
    return ($k.split('\\', 2))[0, 1];
}


=begin pod

=head1 NAME

Win32::Registry - Query the Windows registry using the Windows API

=head1 SYNOPSIS

=begin code :lang<raku>

use Win32::Registry::Subkeys;
my $hive = 'HKEY_LOCAL_MACHINE';
my $key  = 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths';
my @array  = get-subkeys( $hive, $key );

=end code

=head1 DESCRIPTION

Win32::Registry uses the NativeCall module to execute
WinAPI functions to extract information from the registry.

=head1 Native Call Functions

The following Windows API native call functions are currently supported:

=head2 RegCloseKey(int32) is native("Kernel32.dll") returns int32 is export {*};

=head2 RegGetValueW(int32, CArray[WCHAR], CArray[WCHAR], int32, int32, CArray[uint16], int32 is rw) is native("Kernel32.dll") returns int32 is export {*};

=head2 RegOpenKeyExW(int32, WCHARS, int32, int32, int32 is rw) is native("Kernel32.dll") returns int32 is export {*};

=head2 RegQueryInfoKeyW(int32, int32, int32, int32, int32 is rw, int32 is rw, int32, int32, int32, int32, int32, int32) returns int32 is native('kernel32') is export {*};

=head1 ROUTINES

=head2 get-hkey-handle(Str:D $hive)

Returns the handle for a hive name. Hive names can be shortened to
leave off the C<HKEY_> bit at the beginning. Capitlization is ignored.

=begin code :lang<raku>

my $handle = get-hkey-handler('hkey_local_machine);
my $handle = get-hkey-handler('local_machine); # same as above

=end code

=head2 get-hkey(Str:D $h)

Returns the name of a hive, if found. Dies otherwise.

=begin code :lang<raku>

my $handle = get-hkey('local_machine');
say $handle; # OUTPUT: hkey_local_machine

=end code

=head2 key-exists(Str:D $key)

Test to see if a key exists in the registry. Accepts a string
representing a path to a registry key. Returns a boolean value.

=begin code :lang<raku>

my $exists = key-exists('hkey_local_machine\SOFTWARE\Microsoft\Windows \CurrentVersion \App Paths');

=end code

=head2 close-key(Int:D $key-handle)

Closes an open key. Accepts a handle to an already open key. Returns boolean
value based on success of operation. False will be returned if the key
was already closed.

=begin code :lang<raku>

$key-exists = key-exists('hkey_local_machine\SOFTWARE\Microsoft\Windows \CurrentVersion \App Paths');

=end code

=head2 wstr(Str $str)

Converts a string into a wide characgter string, suitable for passing to a Windows
API native call function. Returns the original string in a native
C<CArray[WCHAR]> object that is terminated with a null character.

=head2 multi sub open-key(Str:D $key)
=head2 multi sub open-key(Int:D $hkey-handle, Str:D $key)

Opens a registry key. Returns the key's handle. Dies if key does not
exist.

=begin code :lang<raku>

my $handle = open-key('local_machine', 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths' );
my $handle = open-key('hkey_local_machine\SOFTWARE\Microsoft\Windows \CurrentVersion\App Paths' );

=end code

=head1 SUBMODULES

=item L<Win32::Registry::Subkeys|https://github.com/sdondley/Win32-Registry/blob/main/lib/Win32/Registry/Subkeys.rakumod>

See the documentation for the individual submodules for further details.

=head1 AUTHOR

Steve Dondley <s@dondley.com>

=head1 COPYRIGHT AND LICENSE

Copyright 2022 Steve Dondley

This library is free software; you can redistribute it and/or modify it under
the Artistic License 2.0.

=end pod
