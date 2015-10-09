lua tar
=======

Original tar.lua comes from luarocks project, see [here](https://github.com/keplerproject/luarocks/blob/master/src/luarocks/tools/tar.lua).
It only support tar extraction (with standard blocksize) and direct write to the file system.

Goal
====

Support listing and extraction for .tar.gz file...
Support fast access (read/seek/...) inside the archive by using a catalog almost like the zip one.

TODO
====

* [x] a simple tar listing
* [ ] tar listing over a stream
 * [ ] tar listing over a stream of io/file handler (to support uncompressing on the fly)
* [ ] tar extraction on filesystem using abstraction module (support more than the luarocks fs module)
* [ ] simple tar creation
* [ ] ...
