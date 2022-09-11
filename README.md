[![Actions Status](https://github.com/sdondley/Win32-Registry-Subkeys/actions/workflows/test.yml/badge.svg)](https://github.com/sdondley/Win32-Registry-Subkeys/actions)

NAME
====

Win32::Registry::Subkeys - Retrieve subkeys from the Windows registry

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

Win32::Registry::Subkeys uses the NativeCall module to execute the WinAPI functions to extract the subkeys below a key in the registry.

ROUTINES
========

get-subkeys(Str:D $hive, Str:D $key)
------------------------------------

Returns an array with each element containing a string representing a subkey within a given `$key` in the registry `$hive`.

AUTHOR
======

Steve Dondley <s@dondley.com>

COPYRIGHT AND LICENSE
=====================

Copyright 2022 Steve Dondley

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

