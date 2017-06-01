3.0.1 / 2017-06-01
==================

  * Update poparser.gemspec (#18)

3.0.0 / 2017-03-03
==================
  * replaced parslet with simple_po_parser. Speedup parsing by up to 500x.
    Courtesy of @dfherr

2.0.1 / 2016-12-29
==================

  * header handles flags, especially the fuzzy flag (#13)
  * Update README.md

2.0.0 / 2016-12-22
==================

  * `Comment#to_s` now returns string instead of array (backward incompatible)
  * Parser won't choke on cases where there are spaces before eol

1.1.0 / 2016-12-07
==================

  * fixed typo refrence, but kept it backwards compatible for entries
  * [Header] skip empty header fields from to_s output with a warning
  * [Parser] Allow multiple space after msgs and text
  * added alias methods for entry accessors

Version 1.0.3
=============

  * Add `obsolete` alias for `cached` entries. Now you can use `Po#obsolete` or `Entry#obsolete?`

Version 1.0.2
=============

  * Update dependencies
  * Handle empty lines in .po file (thanks to @roland9)
  * Fix translated strings stats

Version 1.0.1
=============

  * Update dependencies and tests

Version 1.0.0
=============

  * add support for header entry
  * `add_entry` renamed to `add` and returns `self`
  * besides percentages, inspect of `po` now returns each entry count too
  * `po.add` now raises error if you try to add an unknown label

Version 0.2.1
=============

  * Add search_in method.

Version 0.2.0
=============

  * Some entries in PO files are started with "#~", these entries are just kept by program for later use and are not counted as active entries. `PoParser` now supports them. We won't count them in stats or show them in Tanslated or Untranslated entries. They're just there.
  * Added size/length methods to `PO` class. It won't count cached entries(described above).

Version 0.1.1
=============

  * Fix bug of "str" and "to_str" on Messages
  * Small refactoring

Version 0.1.0
=============

  * initial release
