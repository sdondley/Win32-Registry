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

sub get-hkey-handle(Str:D $h ) is export {
    my $hive = (%valid-hives ~~ rx:i/$h/).orig;
    die "Unrecognized hive: $h" if !$hive;
    return %valid-hives{$hive};
}

sub get-hkey(Str:D $h) is export {
    my $hive = (%valid-hives ~~ rx:i/$h/).orig;
    die "Unrecognized hive: $h" if !$hive;
    return $hive;
}

sub RegOpenKeyExW(int32, WCHARS, int32, int32, int32 is rw)
        is native("Kernel32.dll") returns int32 is export {*};

sub RegQueryInfoKeyW( int32, int32, int32, int32, int32 is rw, int32 is rw,
                      int32, int32, int32, int32, int32, int32 )
        returns int32 is native('kernel32') is export { * };

sub wstr(Str $str) returns WCHARS is export {
    my $return = CArray[WCHAR].new($str.encode.list);
    $return[$return.elems] = 0;
    return $return;
}


