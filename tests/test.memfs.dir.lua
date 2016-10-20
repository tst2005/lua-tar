local dir = require "memfs.dir"
local r0 = dir(true)

print("rootfs", r0)
local foo = r0:mkdir("foo")
print("foo", r0 "foo", foo)

r0:mkdir("bar")
print("bar", r0 "bar")
r0"bar":mkdir("rrr")

local function printdir(k,v, pdir)
	pdir=pdir or ""
	print(v, pdir.."/"..k, (k~="." and k~=".." and v.hardcount or ""))
end
local function rprint(k,v, pdir)
	printdir(k,v,pdir)
	if type(v)=="table" and k~="." and k~=".." then
		v:all(rprint, pdir.."/"..k)
	end
end

--r0:all(printdir, "")

r0:all(rprint, "")
print("rmdir rrr")
r0("bar"):rmdir("rrr")
r0:all(rprint, "")

assert(r0".."==r0)
assert(r0"."==r0)
assert(r0"foo"==r0"foo" ".")
assert(r0"foo" ".." == r0)
