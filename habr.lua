jit.off()
ffi = require('ffi')
require('table.new')
require('table.clear')

local function caption(h, c)
    print(h)
    print(string.rep(c or '-', #h))
    print()
end

function traverse(fn, t)
    local str = '-- '
    for k, v, n in (fn or pairs)(t) do
        if str ~= '-- ' then
            str = str .. ', '
        end
        str = string.format('%s%s=%s%s',
            str, k, v, n and ', ' or ''
        )
    end
    print(str)
end

local function codeblock(str)
    print('```lua')
    for l in string.gmatch(str, "([^\n]*)\n") do
        print(l)
        assert(loadstring(l))()
    end
    print('```\n')
end

caption('Welcome to the LuaJIT internals', '=')

--------------------------
caption('Анатомия таблиц')

codeblock([[
t = {}
tostring(t)
]])

codeblock([[
t["a"] = "A"
t["b"] = "B"
t["c"] = "C"
tostring(t)
]])

codeblock([[
t1 = {a = 1, b = 2, c = 3}
tostring(t1)

t2 = {c = 3, b = 2, a = 1}
tostring(t2)

traverse(pairs, t1)

traverse(pairs, t2)
]])

codeblock([[
t2["c"] = nil
traverse(pairs, t2)
tostring(t2)
print('-- ' .. next(t2, "c"))
]])

------------------
caption('Массивы')

codeblock([[
t = {1, 2}
tostring(t)
]])

codeblock([[
t = {[2] = 2, 1}
tostring(t)
]])

---------------------------
caption('Итератор pairs()')

codeblock([[
t = table.new(4, 4)
for i = 1, 8 do t[i] = i end

tostring(t)
traverse(pairs, t)
]])

codeblock([[
t[9] = 9
tostring(t)
]])

-------------------------------------
caption('Длина таблицы table.getn()')

codeblock([[
print(#{nil, 2})
print(#{[2] = 2})
]])

codeblock([[
tostring({nil, 2})

tostring({[2] = 2})
]])

----------------------------------
caption('Сортировка table.sort()')

----------------------------------
caption('Pack / unpack')

codeblock([[
t = table.pack(nil, 2)
tostring(t)

traverse(pairs, t)
print(unpack(t, 1, t.n))
]])

----------------------------
caption('Итератор ipairs()')

codeblock([[
t = {1, 2, nil, 4}
print(#t) -- UB
traverse(ipairs, t)
]])
------------------------------
caption('Подводные камни FFI')

codeblock([[
NULL = ffi.new('void*', nil)
print(type(NULL))
print(type(nil))
print(NULL == nil)
if NULL then print('NULL is not nil') end
]])

os.exit(1)
