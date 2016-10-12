-- Spin things up
-- f(s) = V0t + at^2 / 2
-- f(a) = (v1 - v0) / (t1 - t0)
--
local SpinHelper = {}
local M = SpinHelper

function M:StartSpin(startAngle, rstNotify)
    if self.spinning then return end

    self.rstNotify = rstNotify
    self.spinning = false

    self.startAngle = startAngle
    self.currentAngle = startAngle
    self.accRate = 10
    self.angleLastChanged = 0

    self:doSpeed()
end

function M:StopSpin()
end

function M:calculateAngle(delta)
    --print(("calculateAngle %.02f %.02f"):format(self.currentAngle, delta))
    self.currentAngle = self.currentAngle + delta
    while self.currentAngle > 360 do
        self.currentAngle = self.currentAngle - 360
    end

    while self.currentAngle < 0 do
        self.currentAngle = self.currentAngle + 360
    end
end

function M:doSpeed()
    self.angleLastChanged = 0
    for i = .1, 10, .1 do
        local angleChanged = self.accRate * i * i / 2
        local delta = angleChanged - self.angleLastChanged
        self:calculateAngle(delta)
        self.angleLastChanged = angleChanged
    end

    self:doConstant()
end

function M:doConstant()
    self.constSpeed = self.accRate * 10
    self.angleLastChanged = 0

    local constTime = math.random(20) + 10
    for i = 0, constTime, .1 do
        local angleChanged = self.constSpeed * i
        local delta = angleChanged - self.angleLastChanged
        self:calculateAngle(delta)
        self.angleLastChanged = angleChanged
    end

    self:doStop()
end

M.stopAngle = {360, 315, 270, 225, 180, 135, 90, 45}
M.transAngle = {0, 45, 90, 135, 180, 225, 270, 315}
function M:doStop()
    local finalIdx = math.random(8)

    --for test 360 error
    --self.currentAngle = 58
    --finalIdx = 1

    local finalAngle = self.stopAngle[finalIdx]
    local angleDiff 
    if finalAngle < self.currentAngle then
        angleDiff = finalAngle + 360 - self.currentAngle
    else
        angleDiff = finalAngle - self.currentAngle
    end

    self.finalAngle = finalAngle
    self.stopDuration = 2
    self.angleLastChanged = 0

    self.stopSpeed = 2 * angleDiff / self.stopDuration
    self.daccRate = self.stopSpeed / self.stopDuration

    local failed = true
    local startCurrAngle = self.currentAngle
    --print(("start stop %.02f %.02f %.02f %.02f"):format(self.stopSpeed, self.currentAngle, finalAngle, angleDiff))
    local angleChanged
    for i = 0, self.stopDuration * 2, .1 do
        angleChanged = self.stopSpeed * i - self.daccRate * i * i / 2
        local delta = angleChanged - self.angleLastChanged
        self:calculateAngle(delta)
        --print(("start stop %.02f %.02f %.02f %.02f"):format(self.stopSpeed, self.currentAngle, finalAngle, angleDiff))

        self.angleLastChanged = angleChanged

        local diff = math.abs(self.currentAngle - finalAngle)
        if diff < 1.5 then
            failed = false
            --print("from break")
            break
        end
    end

    if failed then
        print(("start stop %.02f %.02f %.02f %.02f %.02f %.02f"):format(self.stopSpeed
                            , startCurrAngle, angleChanged, self.currentAngle, finalAngle, angleDiff))
    end
end

--------------------------------------------------------------------------------
--test code
--------------------------------------------------------------------------------

math.randomseed(tostring(os.time()):reverse():sub(1,6))
local startAngle = math.random(360)
function MasTest()
    for i = 1, 100000 do
        startAngle = math.random(360)
        M:StartSpin(startAngle)

        local diff = math.abs(M.currentAngle - M.finalAngle)
        if diff > 1.5 then
            print(("failed %.02f %.02f %.02f %.02f"):format(i,diff,M.currentAngle, M.finalAngle))
        end
    end
end

M:StartSpin(startAngle)
MasTest()
return M
