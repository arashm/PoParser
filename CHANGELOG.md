## Version 0.2.0

* Some entries in PO files are started with "#~", these entries are just kept by program for later use and are not counted as active entries. `PoParser` now supports them. We won't count them in stats or show them in Tanslated or Untranslated entries. They're just there.

* Added size/length methods to `PO` class. It won't count cached entries(described above).

## Version 0.1.1

* Fix bug of "str" and "to_str" on Messages
* Small refactoring

## Version 0.1.0

* initial release

