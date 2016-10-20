
-- dir.tree[name].tree[name]

local class = require "mini.class"
local instance = assert(class.instance)

local parentdir_is_myself = {} -- uniq value to bootstrap root directory

local dir = class("dir", {
	init = function(self)
		self.hardcount = 1
		self.tree = {}
		self:hardlink(".", self)
		if parentdir == parentdir_is_myself then
			self:hardlink("..", self)
		end
		--require "mini.class.autometa"(self, dirmt)
		return tree -- the instance returns self, tree
	end
})

function dir:_hardlinkcount(incr)
	assert(incr == 1 or incr == -1)
	self.hardcount = self.hardcount + incr
end

-- create a hardlink of <what> named <name> into <self>
function dir:hardlink(name, what)
	if not self.tree[name] then
		self.tree[name] = what
		what.hardcount = what.hardcount +1
	end
end

function dir:unhardlink(name)
	if self[name] then
		self[name].hardcount = self[name].hardcount -1
		self[name]=nil
	end
end

function dir:mkdir(name)
	if self.tree[name] then
		error("already exists", 2)
	end
	local d = dir()
	d:hardlink("..", self)
	self.tree[name] = d
	return d
end

function dir:rmdir(name)
	if not self.tree[name] then
		error("not exists", 2)
	end
	self.tree[name] = nil
	return nil
end

function dir:all(f, ...)
	for k,v in pairs(self.tree) do
		f(k,v, ...)
	end
end

return setmetatable({ROOTFS=parentdir_is_myself}, {__call = function(_, ...) return instance(dir, ...) end})
