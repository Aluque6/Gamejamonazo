function love.load()
  
  w0, h0 = love.graphics.getDimensions()
  
  print(w0, h0)
  
  perro = {}
  perro.ancho = 100
  perro.alto = 50
  perro.x = w0 - perro.ancho
  perro.y = h0 / 2
  
  velocidad = 500
  
end


function love.update(dt)

moverPerro(dt)
print(perro.x)

end



function love.draw()
  
  love.graphics.setColor(1,0,0,1)
  love.graphics.rectangle("fill", perro.x, perro.y, perro.ancho, perro.alto)
  love.graphics.setColor(1,1,1,1)
  
end

function moverPerro(dt)
  
  
if love.keyboard.isDown("w") then
  perro.y = perro.y - 1 * velocidad * dt
  if perro.y < 0  then
    perro.y = 0
  end
end
if love.keyboard.isDown("s") then
  perro.y = perro.y + 1 * velocidad * dt
  if perro.y > h0 - perro.alto  then
    perro.y = h0 - perro.alto
  end
end
if love.keyboard.isDown("a") then
  perro.ancho = perro.ancho + 1 * velocidad * dt
  perro.x = perro.x - 1 * velocidad * dt
  if perro.x < h0/4 then
  perro.x = h0/4
end
end

if love.keyboard.isDown("d") then
  if perro.ancho > 100 then
  perro.ancho = perro.ancho - 1 * velocidad * dt
end
 perro.x = perro.x + 1 * velocidad * dt
if perro.x > w0 + perro.ancho then
  perro.x = w0 + perro.ancho
end
 
if perro.x > h0 + perro.ancho then
  perro.x = h0 + perro.ancho
end

end


  
end

