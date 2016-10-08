--
-- keep neat && clean && simple.
-- User: ppp 2016 2016/7/29 10:41
-- Desc: Simple Lua Profiler
--

local os = os
local io = io
local table = table
local debug = debug
local pairs = pairs
local Profiler = {}
local M = Profiler

function M:activate( )
    self.calls = {}
    self.total = {}
    self.this = {}

    local function hook_counter(event)
        local info = debug.getinfo(2, "Sln")
        if info.what ~= "Lua" then return end
        local func = info.name or (info.source .. ":" .. info.linedefined)
        if event == "call" then
            self.this[func] = os.clock()
        else
            if nil == self.this[func] then
                return
            end
            local time = os.clock() - self.this[func]
            self.total[func] = (self.total[func] or 0) + time
            self.calls[func] = (self.calls[func] or 0) + 1
        end
    end

    self.started = os.clock()
    debug.sethook(hook_counter, "cr")
end

function M:deactivate()
    self.ended = os.clock()
    debug.sethook( nil, "cr")
end

function M:print_results()
    local file = io.open("luaprofiler.log", 'wb')
    file:write("========Profiler Result=============================================================\n")
    table.sort(self.total, function(a, b)
        return a < b
    end)
    for f, time in pairs(self.total) do
        file:write(("avg %.4f func %s took %.4f seconds after %d calls\n"):format(time/self.calls[f], f, time, self.calls[f]))
    end
    file:write("========Profiler Result=============================================================\n")
    file:close()
end

return M
