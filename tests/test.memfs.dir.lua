local dir = require "memfs.dir"
local r0 = dir(dir.ROOTFS)

print("rootfs", r0)
local foo = r0:mkdir("foo")
print("foo", r0.tree["foo"], foo)
r0:mkdir("bar")
print("bar", r0.tree["bar"])
r0.tree["bar"]:mkdir("rrr")
r0:all(print, "")

local function rprint(k,v, pdir)
	print(v, pdir.."/"..k)
	if type(v)=="table" and k~="." and k~=".." then
		v:all(rprint, pdir.."/"..k)
	end
end
r0:all(rprint, "")
print("rmdir rrr")
r0.tree["bar"]:rmdir("rrr")
r0:all(rprint, "")

