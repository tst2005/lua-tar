local tar = require "tar"

local tarball = arg[1] or "sample/data-posix.tar"

local function untarstream(x)
	return tar.tarstream(x, tar.show_the_file)
end

tar.untar(tarball)
