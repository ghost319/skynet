local skynet = require "skynet"
local snax = require "snax"

skynet.start(function()
	local ps = snax.uniqueservice ("pingserver", "hello world")
	
	print(ps.req.ping("foobar"))
	print(ps.post.hello())
	print(pcall(ps.req.error))
	
	skynet.sleep(1000)
	
	print("Hotfix (i) :", snax.hotfix(ps, [[

local i
local hello

function accept.hello()
	i = i + 1
	print ("fix", i, hello, test1[1], test1[2], test2, test4, testtbl[1], testtbl[2])
end

function hotfix(...)
	local temp = i
	i = 100						--修改全局中的local i
	
	test1 = {4,5}				--修改全局的信息
	test2 = 6					--修改全局的信息
	test4 = 1					--创建新的全局table    无法在全局创建local的
	
	--------------------------更新表格 start
	local skynet = require "skynet"					--不写无法获取路径
	
	_ModTbl = {}
	local mainfunc = nil
	local path = skynet.getenv "snax"
	skynet.cache.clear()							--必须清除，不然无法使用loadfile更新
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
	print("testtbl[1], testtbl[2]:", testtbl[1], testtbl[2])
	--------------------------更新表格 end
	
	return temp
end

	]]))
	print(ps.post.hello())

	local info = skynet.call(ps.handle, "debug", "INFO")

	for name,v in pairs(info) do
		print(string.format("%s\tcount:%d time:%f", name, v.count, v.time))
	end

	print(snax.kill(ps,"exit"))
	skynet.exit()
end)
