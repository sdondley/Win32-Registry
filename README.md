[![Actions Status](https://github.com/sdondley/Win32-Registry-Subkeys/actions/workflows/test.yml/badge.svg)](https://github.com/sdondley/Win32-Registry-Subkeys/actions)

NAME
====

Win32::Registry - Query the Windows registry using the Windows API

SYNOPSIS
========

```raku
use Win32::Registry::Subkeys;
my $hive = 'HKEY_LOCAL_MACHINE';
my $key  = 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths';
my @array  = get-subkeys( $hive, $key );
```

DESCRIPTION
===========

Win32::Registry uses the NativeCall module to execute WinAPI functions to extract information from the registry.

Native Call Functions
=====================

The following Windows API native call functions are currently supported:

RegCloseKey(int32) is native("Kernel32.dll") returns int32 is export {*};
-------------------------------------------------------------------------

RegGetValueW(int32, CArray[WCHAR], CArray[WCHAR], int32, int32, CArray[uint16], int32 is rw) is native("Kernel32.dll") returns int32 is export {*};
---------------------------------------------------------------------------------------------------------------------------------------------------

RegOpenKeyExW(int32, WCHARS, int32, int32, int32 is rw) is native("Kernel32.dll") returns int32 is export {*};
--------------------------------------------------------------------------------------------------------------

RegQueryInfoKeyW(int32, int32, int32, int32, int32 is rw, int32 is rw, int32, int32, int32, int32, int32, int32) returns int32 is native('kernel32') is export {*};
-------------------------------------------------------------------------------------------------------------------------------------------------------------------

ROUTINES
========

get-hkey-handle(Str:D $hive)
----------------------------

Returns the handle for a hive name. Hive names can be shortened to leave off the `HKEY_` bit at the beginning. Capitlization is ignored.

```raku
my $handle = get-hkey-handler('hkey_local_machine);
my $handle = get-hkey-handler('local_machine); # same as above
```

get-hkey(Str:D $h)
------------------

Returns the name of a hive, if found. Dies otherwise.

```raku
my $handle = get-hkey('local_machine');
say $handle; # OUTPUT: hkey_local_machine
```

key-exists(Str:D $key)
----------------------

Test to see if a key exists in the registry. Accepts a string representing a path to a registry key. Returns a boolean value.

```raku
my $exists = key-exists('hkey_local_machine\SOFTWARE\Microsoft\Windows \CurrentVersion \App Paths');
```

close-key(Int:D $key-handle)
----------------------------

Closes an open key. Accepts a handle to an already open key. Returns boolean value based on success of operation. False will be returned if the key was already closed.

```raku
$key-exists = key-exists('hkey_local_machine\SOFTWARE\Microsoft\Windows \CurrentVersion \App Paths');
```

wstr(Str $str)
--------------

Converts a string into a wide characgter string, suitable for passing to a Windows API native call function. Returns the original string in a native `CArray[WCHAR]` object that is terminated with a null character.

multi sub open-key(Str:D $key)
------------------------------

multi sub open-key(Int:D $hkey-handle, Str:D $key)
--------------------------------------------------

Opens a registry key. Returns the key's handle. Dies if key does not exist.

```raku
my $handle = open-key('local_machine', 'SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths' );
my $handle = open-key('hkey_local_machine\SOFTWARE\Microsoft\Windows \CurrentVersion\App Paths' );
```

SUBMODULES
==========

  * [Win32::Registry::Subkeys](https://github.com/sdondley/Win32-Registry/blob/main/lib/Win32/Registry/Subkeys.rakumod)

See the documentation for the individual submodules for further details.

AUTHOR
======

Steve Dondley <s@dondley.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Steve Dondley

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

