audio = {
    loadedClips = {}
}


function audio:playSound(name, stream, looping)
    if self.loadedClips[name] == nil then
        if stream then
            self.loadedClips[name] = love.audio.newSource(name, "stream")
        else
            self.loadedClips[name] = love.audio.newSource(name, "static")
        end
        self.loadedClips[name]:setLooping(looping)
        -- self.loadedClips[name]:setVolume(settings:getSettings(1)) -- 1 is volume
    end
    self.loadedClips[name]:play()
end

function audio:setVolume(volume)
    for _, audio in pairs(self.loadedClips) do
        print("set" .. volume)
        audio:setVolume(volume)
    end
end