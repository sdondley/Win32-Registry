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

