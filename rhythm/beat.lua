require("audio")

beat = {
    bpm = 120,
    currentTime = 0,
    timesPlayed = 0,
}

function beat:playMetronome()
    audio:playSound("audio/met2.wav", false, false)
    self.currentTime = 0
    self.timesPlayed = 0
end

function beat:update(dt)
    self.currentTime = self.currentTime + dt
    local beatInterval = 60 / self.bpm
    if (self.currentTime - (self.timesPlayed * beatInterval)) >= beatInterval then
        audio:playSound("audio/met2.wav", false, false)
        self.timesPlayed = self.timesPlayed + 1
    end
end

function beat:isClickOnBeat()
    local beatInterval = 60 / self.bpm
    local timeSinceLastBeat = self.currentTime - (self.timesPlayed * beatInterval)
    if timeSinceLastBeat >= -0.2 and timeSinceLastBeat <= 0.2 then
        -- print("onbeat")
        return true
    else
        return false
    end
end