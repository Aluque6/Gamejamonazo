local currentDirection = nil
mover = false
juegoTerminado = false
local estela = {}
local siguienteIndexEstela = 1
local tiempoEstela = 0
local intervaloEstela = 0.1
local yTrail = nil

function love.load()
  
  w0, h0 = love.graphics.getDimensions()
  perro = {}

  tamañoObstaculo = 50
  tamañoPerro = 30
  intervaloMovimiento = 0.1
  scrollVelocidad = tamañoPerro / intervaloMovimiento
  scrollX = 0
  tamañoMinimo = 100
  historialDirecciones = {}
  
   xInicial = w0 - tamañoPerro
   yInicial = h0 / 2
  
  for i = 0, tamañoMinimo - 1 do
    table.insert(perro, 1, {
        x = xInicial,
        y = yInicial})
  end
    
  
  
  obstaculosSprites = {}
  obstaculosSprites.arbol = love.graphics.newImage("sprites/arbol.png")
  
  obstaculosMaximos = 20
  obstaculosCargados = false
  obstaculosActivos = {}

  obstaculos = {["arbol"] = 0 , ["caja"] = 0}
  
  coordObstaculos = {}
  
  posObstaculoY = 100
  posObstaculoX =  100 
  
  
  velocidad = 100

  
  cargarObstaculos(obstaculos)
  yTrail = math.floor((h0/2)/tamañoPerro) * tamañoPerro
  local numPuntos = math.floor((w0/2)/tamañoPerro) + 1
  local y0 = math.floor((h0/2)/tamañoPerro) * tamañoPerro
  for i = 1, numPuntos do
    local x0 = (i-1) * tamañoPerro
    local pasoY = love.math.random(-1,1) * tamañoPerro
    print(pasoY)
    y0 = math.max(0, math.min(h0-tamañoPerro, y0 + pasoY))
    table.insert(estela, {x = x0, y = y0, visited = false})
  end
  

end

tiempoAcumulado = tiempoAcumulado or 0
intervaloMovimiento = 0.1
tiempoGeneracion = 0
intervaloGeneracion = 10


function love.update(dt)
  
if not juegoTerminado then
  detectarColisiones()
end
  
if juegoTerminado then return end
  
scrollX = scrollX + scrollVelocidad * dt
tiempoEstela = tiempoEstela + dt

if tiempoEstela >= intervaloEstela then
  local xWorld = -scrollX
  local pasoY = love.math.random(-1,1) * tamañoPerro
  yTrail = math.max(0, math.min(h0-tamañoPerro, yTrail + pasoY))
  table.insert(estela, {x = xWorld, y = yTrail, visited = false})
  tiempoEstela = tiempoEstela - intervaloEstela
end


tiempoAcumulado = tiempoAcumulado + dt
if currentDirection then
  tiempoAcumulado = tiempoAcumulado + dt
  if tiempoAcumulado >= intervaloMovimiento then
  moverPerroBien(currentDirection)
  tiempoAcumulado = 0
end
else
  if tiempoAcumulado >= intervaloMovimiento then
  moverPerroBien("a")
  tiempoAcumulado = 0
  end
end

local cabeza = perro[#perro]
local headScreenX = cabeza.x + scrollX
local headScreenY = cabeza.y
local pt = estela[siguienteIndexEstela]

if pt and headScreenX >= pt.x
  and headScreenX < pt.x + tamañoPerro
  and headScreenY >= pt.y
  and headScreenY < pt.y + tamañoPerro then
  pt.visited = true
  siguienteIndexEstela = siguienteIndexEstela + 1 
end

for i = #estela, 1, -1 do
  if estela[i].x + scrollX < -tamañoPerro then
    table.remove(estela, i)
    if i < siguienteIndexEstela then
      siguienteIndexEstela = siguienteIndexEstela - 1
    end
  end
  
tiempoGeneracion = tiempoGeneracion + dt
if tiempoGeneracion >= intervaloGeneracion then
  if #obstaculosActivos < obstaculosMaximos then
    generarObstaculo()
  end
  tiempoGeneracion = tiempoGeneracion - intervaloGeneracion
end

end

end


function love.draw()

  love.graphics.setColor(0,1,0)
  for i, segmento in ipairs(perro) do
    love.graphics.rectangle("fill", segmento.x + scrollX, segmento.y, tamañoPerro, tamañoPerro)
  end
  love.graphics.setColor(1,1,1)
  
  for i, obstaculo in ipairs(obstaculosActivos) do
    if obstaculo.tipo == "arbol" then
      local escalaX = obstaculo.ancho / obstaculosSprites.arbol:getWidth()
      local escalaY = obstaculo.alto / obstaculosSprites.arbol:getHeight()
      love.graphics.setColor(1,1,1)
      love.graphics.draw(obstaculosSprites.arbol, obstaculo.x + scrollX, obstaculo.y, 0, escalaX, escalaY)
    elseif obstaculo.tipo == "caja" then
      love.graphics.setColor(0.8,0.6,0.2)
    else
      love.graphics.setColor(1,0,0)
    end
    love.graphics.rectangle("line", obstaculo.x + scrollX, obstaculo.y, obstaculo.ancho, obstaculo.alto)
  end
  love.graphics.setColor(1,1,1)
  
  --ESTO ES PARA LIMPIAR LOS OBSTACULOS QUE YA NO ESTAN EN PANTALLA, TOTALMENTE INNECESARIO PERO ME DA TOC NO HACERLO
  
  for i = #obstaculosActivos, 1, -1 do
    local obstaculo = obstaculosActivos[i]
    if obstaculo.x + scrollX > w0 then
      table.remove(obstaculosActivos, i)
    end
  end
 
 love.graphics.setColor(0,0,1,0.5)
 for i, pt in ipairs(estela) do
   if not pt.visited then
     love.graphics.rectangle("fill", pt.x + scrollX, pt.y, tamañoPerro, tamañoPerro)
   end
 end
 love.graphics.setColor(1,1,1,1)
    
  
  if juegoTerminado then
    love.graphics.setColor(1,0,0)
    love.graphics.printf("GAMEOVER", 0, h0/2 - 40, w0, "center" )
    love.graphics.setColor(1,1,1)
  end
  
  
  
  
  
  
end

function love.keypressed(key)
  if love.keyboard.isDown(key) then
    if key == "w" or key == "a" or key == "s" or key == "d" then
    currentDirection = key
    end
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
  end

end

function moverObstaculos(obstaculos, dt)
  
  
  
for tipo, cantidad in pairs(obstaculos) do
  
  
  
  
end


end


function generarObstaculo()
  
  local tipos = {"arbol", "caja"}
  local tipo = tipos[love.math.random(#tipos)]
  local ancho = tamañoObstaculo
  local alto = tamañoObstaculo
  local distanciaFueraPantalla = love.math.random(10,50)
  local x = -scrollX - distanciaFueraPantalla
  local y = love.math.random(0, h0 - alto)
  
  table.insert(obstaculosActivos, {tipo = tipo, x = x, y = y, ancho = ancho, alto = alto,})
    
  
end


function detectarColisiones() 
  
  for i, segmento in ipairs(perro) do
    local segmentoX = segmento.x + scrollX
    local segmentoY = segmento.y
    for n, obstaculo in ipairs(obstaculosActivos) do
      local obstaculoX = obstaculo.x + scrollX
      local obstaculoY = obstaculo.y
      local colisiona = 
      segmentoX < obstaculoX + obstaculo.ancho and
      segmentoX + tamañoPerro > obstaculoX and
      segmentoY < obstaculoY + obstaculo.alto and
      segmentoY + tamañoPerro > obstaculoY
      
      if colisiona then
        juegoTerminado = true
        return
      end
    end
  end
end



function moverPerroBien(direccion)
  
  local cabeza = perro[#perro]
  local nuevaX, nuevaY = cabeza.x, cabeza.y
  local ultimaDireccion = historialDirecciones[#historialDirecciones]
  
  if sonDireccionesOpuestas(direccion, ultimaDireccion) then
    if #perro > tamañoMinimo then
      table.remove(perro, #perro)
      table.remove(historialDirecciones, #historialDirecciones)
    end
    return
  end
  
  if direccion == "w" then
    nuevaY = nuevaY - tamañoPerro
  elseif direccion == "s" then
    nuevaY = nuevaY + tamañoPerro
  elseif direccion == "a" then
    nuevaX = cabeza.x - tamañoPerro
    local posicionEnPanralla = nuevaX + scrollX
    if posicionEnPanralla < w0 / 4 then
      return
    end
    
  elseif direccion == "d" then
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
if nuevaY > h0 - tamañoPerro then 
  nuevaY = h0 - tamañoPerro
end

if nuevaX ~= cabeza.x or nuevaY ~= cabeza.y then
  table.insert(perro, {x = nuevaX, y = nuevaY})
  table.insert(historialDirecciones, direccion)
end
  
end


function sonDireccionesOpuestas (dir1, dir2)
  
  return (dir1 == "w" and dir2 == "s") or (dir1 == "s" and dir2 == "w") or (dir1 == "a" and dir2 == "d") or (dir1 == "d" and dir2 == "a")
  
end
