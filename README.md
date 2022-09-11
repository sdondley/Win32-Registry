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

