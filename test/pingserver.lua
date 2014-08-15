local skynet = require "skynet"
local queue = require "skynet.queue"

local i = 0
local hello = "hello"
test1 = {1,2}
test2 = nil
if loadfile then
	_ModTbl = {}
	local mainfunc = nil
	local path = skynet.getenv "snax"
	local errlist = {}
	for pat in string.gmatch(path,"[^;]+") do
		local filename = string.gsub(pat, "?", "testtbl")
		local f , err = loadfile(filename, "bt", _ModTbl)
		if f then
			mainfunc = f
			break
		else
			table.insert(errlist, err)
		end
	end
	if mainfunc then
		mainfunc()
	else
		error(errlist)
	end
	mainfunc()
	testtbl = _ModTbl.gettt()
--	print("_Mod, _ModTbl, testtbl, testtbl[1]:", _Mod, _ModTbl, testtbl, testtbl[1])
end

--tbl = {}
--
--function testfunc1()
--end
--
--function tbl.testfunc2()
--end
--
--local function testfunc3()
--end

function response.ping(hello)
	skynet.sleep(100)
	return hello
end

-- response.sleep and accept.hello share one lock
local lock

function accept.sleep(queue, n)
	if queue then
		lock(
		function()
			print("queue=",queue, n)
			skynet.sleep(n)
		end)
	else
		print("queue=",queue, n)
		skynet.sleep(n)
	end
end

function accept.hello()
	lock(function()
	i = i + 1
	print (i, hello, test1[1], test1[2], test2, testtbl[1], testtbl[2])
	end)
end

function response.error()
	error "throw an error"
end

function init( ... )
	print ("ping server start:", ...)
	-- init queue
	lock = queue()

-- You can return "queue" for queue service mode
--	return "queue"
end

function exit(...)
	print ("ping server exit:", ...)
end
