local currentDirection = nil
mover = false

function love.load()
  
  
  w0, h0 = love.graphics.getDimensions()
  
  print(w0, h0)
  
  scrollX = 0
  scrollVelocidad = 150
  
  perro = {}

  tamañoSegmento = 50
  tamañoMinimo = 100
  historialDirecciones = {}
  
   xInicial = w0 - tamañoSegmento
   yInicial = h0 / 2
  
  for i = 0, tamañoMinimo - 1 do
    table.insert(perro, 1, {
        x = xInicial,
        y = yInicial})
  end
    
  
  
  obstaculosSprites = {}
  obstaculosSprites.arbol = love.graphics.newImage("sprites/arbol.png")
  
  obstaculosMaximos = 10
  obstaculosCargados = false

  obstaculos = {["arbol"] = 0 , ["caja"] = 0}
  
  coordObstaculos = {}
  
  posObstaculoY = 100
  posObstaculoX =  100 
  
  
  velocidad = 500
  
  cargarObstaculos(obstaculos)
  print(obstaculos["arbol"], obstaculos["caja"])

end

tiempoAcumulado = tiempoAcumulado or 0
intervaloMovimiento = 0.1

function love.update(dt)
  
  scrollX = scrollX + scrollVelocidad * dt

if currentDirection then
  tiempoAcumulado = tiempoAcumulado + dt
  if tiempoAcumulado >= intervaloMovimiento then
  moverPerroBien()
  tiempoAcumulado = 0
  end
end

print(scrollX)


end




function love.draw()

  
  love.graphics.setColor(0,1,0)
  for i, segmento in ipairs(perro) do
    love.graphics.rectangle("fill", segmento.x + scrollX, segmento.y, tamañoSegmento, tamañoSegmento)
  end
  love.graphics.setColor(1,1,1)
  
  
  
  
end

function love.keypressed(key)
  
if key == "w" or key == "a" or key == "s" or key == "d" then
  currentDirection = key
  mover = true
end

end

function love.keyreleased(key)
  
  if key == currentDirection then
    currentDirection = nil
  end
  
end



function cargarObstaculos(obstaculos)
  
  if obstaculosCargados == false then
    number = love.math.random() * 10
    obstaculosActuales = math.floor(number)
    obstaculosCargados = true
  end
  for tipo, cantidad in pairs(obstaculos) do
    cantidad = math.floor(love.math.random() * 10)
    obstaculos[tipo] =  cantidad
    print(tipo, cantidad)
  end

end

function moverObstaculos(obstaculos, dt)
  
for tipo, cantidad in pairs(obstaculos) do
  
  
  
  
end


end


function moverPerroBien(dt)
  
  local cabeza = perro[#perro]
  local nuevaX, nuevaY = cabeza.x, cabeza.y
  local ultimaDireccion = historialDirecciones[#historialDirecciones]
  
  if sonDireccionesOpuestas(currentDirection, ultimaDireccion) then
    if #perro > tamañoMinimo then
      table.remove(perro, #perro)
      table.remove(historialDirecciones, #historialDirecciones)
    end
    return
  end
  
  if currentDirection == "w" then
    nuevaY = nuevaY - tamañoSegmento
  elseif currentDirection == "s" then
    nuevaY = nuevaY + tamañoSegmento
  elseif currentDirection == "a" then
    nuevaX = cabeza.x - tamañoSegmento
    local posicionEnPanralla = nuevaX + scrollX
    if posicionEnPanralla < w0 / 4 then
      return
    end
    
  elseif currentDirection == "d" then
  if #perro > tamañoMinimo then
    table.remove(perro, #perro)
  end
  return
else
  return
end



if nuevaY < 0 then 
  nuevaY = 0 
end
if nuevaY > h0 - tamañoSegmento then 
  nuevaY = h0 - tamañoSegmento 
end

  if nuevaX ~= cabeza.x or nuevaY ~= cabeza.y then
    table.insert(perro, {x = nuevaX, y = nuevaY})
    table.insert(historialDirecciones, currentDirection)
  end
  
  
  
end


function sonDireccionesOpuestas (dir1, dir2)
  
  return (dir1 == "w" and dir2 == "s") or (dir1 == "s" and dir2 == "w") or (dir1 == "a" and dir2 == "d") or (dir1 == "d" and dir2 == "a")
  
end
