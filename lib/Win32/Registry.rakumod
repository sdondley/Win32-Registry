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

sub RegQueryInfoKeyW(int32, int32, int32, int32, int32 is rw, int32 is rw,
                     int32, int32, int32, int32, int32, int32)
        returns int32 is native('kernel32') is export {*};

sub wstr(Str $str) returns WCHARS is export {
    my $return = CArray[WCHAR].new($str.encode.list);
    $return[$return.elems] = 0;
    return $return;
}

multi sub open-key(Int:D $hkey-handle, Str:D $k) is export {
    my int32 $hkey;
    my $success = RegOpenKeyExW(
            $hkey-handle,
            wstr($k),
            0,
            KEY_QUERY_VALUE,
            $hkey
                                             );

    if $success != ERROR_SUCCESS {
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
