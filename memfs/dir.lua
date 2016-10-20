
-- dir.tree[name1].tree[name2]
-- dir(name1)(name2)

local class = require "mini.class"
local instance = assert(class.instance)

local dir;dir = class("dir", {
	init = function(self, parentdir)
		assert(parentdir)
		self.hardcount = 1
		self.tree = {}
		self:hardlink(".", self)
		self:hardlink("..", parentdir==true and self or parentdir)
		require "mini.class.autometa"(self, dir)
	end
})

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
	local d = dir(self)
	self.tree[name] = d
	return d
end

function dir:rmdir(name)
	if not self.tree[name] then
		error("not exists", 2)
	end
	self.tree[name]:destroy()
	self.tree[name] = nil
	return nil
end

function dir:destroy() -- __gc ?
	self:unhardlink("..")
	self:unhardlink(".")
end

function dir:all(f, ...)
	if self.tree["."] then
		f(".", self.tree["."], ...)
	end
	if self.tree[".."] then
		f("..", self.tree[".."], ...)
	end
	for k,v in pairs(self.tree) do
		if k~="." and k~=".." then
			f(k, v, ...)
		end
	end
end

function dir:__call(name)
	assert(type(name)=="string", "something wrong")
	assert(not name:find("/"), "path not supported yet, only direct name")
	return self.tree[name]
end

function dir:__pairs()
	return pairs(self.tree)
end

return setmetatable({}, {__call = function(_, ...) return instance(dir, ...) end})
