local margin = 80

function wrapCursor(w, h)
	local x, y = love.mouse.getPosition()
	local newX, newY = x, y
	if x < margin then
		newX = w - margin
	end
	if x > w - margin then
		newX = margin
	end
	if y < margin then
		newY = h - margin
	end
	if y > h - margin then
		newY = margin
	end
	if newX ~= x or newY ~= y then
		love.mouse.setPosition(newX, newY)
	end
end