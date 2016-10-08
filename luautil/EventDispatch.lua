local cocreate, coresume, coyield, costatus = 
    coroutine.create, coroutine.resume, coroutine.yield, coroutine.status
   
local LOG = function(...)
    io.stderr:write(os.date"!%F %T")
    local n = select("#", ...)
    if n > 0 then
        io.stderr:write(...)
    end
    io.stderr:write("\n")
end

function supervisor(...)
    local events = {}
    local name   = {}
    local done   = false

    print("start supervisor ...")
    local function remove(coro)
        for _, coros in pairs(events) do
            coros[coro] = nil
        end
        name[coro] = nil
    end

    local function log_traceback(coro, msg, err)
        LOG("Coroutine ", name[coro], " ", msg, err)
        local tb = debug.traceback(coro, err)
        for line in tb.gmatch("[^\n]+") do
            LOG(" ", line)
        end
    end

    local function handle_resume(coro, ok, todo, ...)
        print("handle_resume")
        if costatus(coro) == "dead" then
            print("handle resume dead")
            if not ok then
                log_traceback(coro, "failed with error", todo)
            end
            remove(coro)
        elseif todo ~= "waitfor" then
            print("handle resume not waitfor")
            log_traceback(coro, "unknown request " .. tostring(todo), "bad return value")
            remove(coro)
        else
            local q = events[...]
            if nil == q then 
                q = {} 
                events[...] = q 
            end
            q[coro] = true
        end
    end

    local handler = {}

    function handler.done()
        done = true
    end

    function handler.status()
        local n, e = {}, {}
        for evts, coros in pairs(events) do
            for coro in pairs(coros) do
                local who = name[coro]
                n[#n + 1] = who
                e[who] = evt
            end
        end

        table.sort(n)
        for _, who in ipairs(n) do
            LOG(who, " is waiting for ", tostring(e[who]))
        end
    end

    function handler.introduce(who, func, ...)
        print("current handing introduce")
        local coro = cocreate(func)
        print("current handleing introduce", coroutine.status(coro))
        name[coro] = who
        local param = {...}
        for k,v in pairs(param) do
            print(k)
            print(v)
        end
        return handle_resume(coro, coresume(coro, ...))
    end

    function handler.signal(what, ...)
        local q = events[what]
        if q and next(q) then
            for coro in pairs(q) do
                q[coro] = nil
                handle_resume(coro, coresume(coro, what, ...))
            end
        else
            LOG("Events ", tostring(what), " dropped into the bit bucket")
        end

        return next(q) ~= nil
    end

    local function logargs(...)
        local t = {n = select("#", ...), ...}
        if t.n > 0 then
            for i = 1, t.n do
                local ti = t[i]
                t[i] = (type(t[i] == "string" and "%q" or "%s")):format(tostring(ti))
            end
            LOG("...with arguments: ", table.concat(t, ", "))
        end
    end

    function handler:__index(what)
        LOG("supervisor received unknown message: ", what)
        return logargs
    end
    setmetatable(handler, handler)

    local function handle(simonsays, ...)
        print("handling ", simonsays)
        local param = {...}
        for k,v in pairs(param) do
            print("in handle", k, v)
        end
        return handler[simonsays](...)
    end

    LOG("starting up")
    LOG("dump")
    local rv = handle(...)
    repeat
        rv = handle(coyield(rv))
    until done

    LOG("shutting down")
end

local function block(event) 
    return coyield("waitfor", event)
end

local function process(n)
    print("process", n)
    for i = 1, n do
        local e, howmany = block("TICK")
        assert(e == "TICK" and howmany == i)
    end
end

-- test driver
local supper = cocreate(supervisor)
local function check(ok, rv)
    if not ok then
        LOG("supervisor crashed")
        local tb = debug.traceback(supper, rv)
        for line in tb:gmatch("[^\n]+") do
            LOG(" ", line)
        end
        os.exit(1)
    end
    return rv
end

local function send(msg, ...) 
    local param = {...}
    return check(coresume(supper, msg, ...)) 
end

local nprocess, nres = tonumber(arg[1]) or 10, tonumber(arg[2]) or 12
for i = 1, tonumber(nprocess) do
    print("send introduce", i)
    send("introduce", ("p%04i"):format(i), process, nres)
end

local j = 1
while send("signal", "TICK", j) do
    j = j + 1
end

print("send status")
send ("status")
print("send done")
send("done")
LOG("endcount", j)
