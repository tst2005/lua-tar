local dir = require "memfs.dir"
local r0 = dir(dir.ROOTFS)

print("rootfs", r0)
local foo = r0:mkdir("foo")
print("foo", r0.tree["foo"], foo)
r0:mkdir("bar")
print("bar", r0.tree["bar"])
