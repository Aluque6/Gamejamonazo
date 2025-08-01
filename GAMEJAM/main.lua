local sti = require "librerias/sti"
local mapDir = "sprites/fondos"

local mapNames = {"fondo1","fondo2","fondo3","fondo4","fondo5","fondo6",}

local mapFiles = {
  "sprites/fondos/fondo1.lua",
  "sprites/fondos/fondo2.lua",
  "sprites/fondos/fondo3.lua",
  "sprites/fondos/fondo4.lua",
  "sprites/fondos/fondo5.lua",
  "sprites/fondos/fondo6.lua",
}

local maps = {}
local ordenMapa = {}
local currentMap = 1
local bgScroll = 0
local bgWidth = 0

local offTrailGrace = 1
local offTrailGraceTimer = 0
local offTrailMax = 5
local offTrailTimer = offTrailMax

local distanciaCulo = 10000
local distanciaRecorrida = 0
local tailSpawned = false
local tailWorldX, tailWorldY
local tailSprite
local estelaTriggerDistancia = 500

local headSprites = {}
local headAnimTimer = 0
local headAnimInterval = 0.1
local headAnimFrame = 1

local currentDirection = nil
mover = false
juegoTerminado = false
local estela = {}
local siguienteIndexEstela = 1
local tiempoEstela = 0
local intervaloEstela = 0.1
local yTrail = nil
local powerups = {}
local tiempoPowerup = 0
local intervaloPowerup = 5
local intervaloMovimiento 
local baseIntervaloMovimiento = 0.2
local velocidad = 200

local gameState = "menu"
local anguloMinimo = math.rad(-5)
local anguloMaximo = math.rad(5)
local anguloTitulo = 0
local anguloVelocidad = math.rad(30)
local fadeAlpha = 0
local fadeSpeed = 2
local btnTry = {w = 200, h = 50}
local btnPlay = {w = 200, h = 50}
local btnExit = {w = 200, h = 50}
local tiempoAcumulado = tiempoAcumulado or 0
local intervaloMovimiento = baseIntervaloMovimiento
local tiempoGeneracion = 0
local intervaloGeneracion = 1

function love.load()
  
  headSprites[1] = love.graphics.newImage("sprites/Pancho/perrito1.png")
  headSprites[2] = love.graphics.newImage("sprites/Pancho/perrito2.png")
  headSprites[3] = love.graphics.newImage("sprites/Pancho/perrito3.png")
  
  tailSprite = love.graphics.newImage("sprites/Pancho/perrito3.png")
  
  w0, h0 = love.graphics.getDimensions()
  btnTry.x = (w0 - btnTry.w)/2
  btnTry.y = h0/2 + 20
  btnPlay.x = (w0 - btnPlay.w)/2
  btnPlay.y = h0/2
  btnExit.x = (w0 - btnExit.w)/2
  btnExit.y = h0/2 + 70
  
  fadeAlpha = 0
  
  
  for i, file in ipairs(mapFiles) do
  maps[i] = sti(file)      
  ordenMapa[i] = i
end
  
  for i = #ordenMapa, 2, -1 do
    local j = love.math.random(i)
    ordenMapa[i], ordenMapa[j] = ordenMapa[j], ordenMapa[i]
  end
  
  currentMap = 1
  bgScroll   = 0
  local m = maps[ordenMapa[currentMap]]
  bgWidth = m.width * m.tilewidth
  love.graphics.setBackgroundColor(1, 1, 1)
  
  
end

function iniciarJuego() 
  
  offTrailTimer = offTrailMax
  tailSpawned = false
  estelaCentered = false
  tamañoObstaculo = 50
  tamañoPerro = 30
  tamañoMinimo = 100
  historialDirecciones = {}
  
  juegoTerminado = false
  scrollX = 0
  fadeAlpha = 0

  juegoTerminado = false
  
  perro = {}
  xInicial = w0 - tamañoPerro
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
  obstaculosActivos = {}

  obstaculos = {["arbol"] = 0 , ["caja"] = 0}
  
  coordObstaculos = {}
  
  posObstaculoY = 100
  posObstaculoX =  100 
  
  
  velocidad = 10
  scrollVelocidad = tamañoPerro / intervaloMovimiento

  
  cargarObstaculos(obstaculos)
  yTrail = math.floor((h0/2)/tamañoPerro) * tamañoPerro
  local numPuntos = math.floor((w0/2)/tamañoPerro) + 1
  local y0 = math.floor((h0/2)/tamañoPerro) * tamañoPerro
  for i = 1, numPuntos do
    local x0 = (i-1) * tamañoPerro
    local pasoY = love.math.random(-1,1) * tamañoPerro
    y0 = math.max(0, math.min(h0-tamañoPerro, y0 + pasoY))
    table.insert(estela, {x = x0, y = y0, visited = false})
  end
  
  
end





function love.update(dt)
  
  
if gameState == "fadeout" then
  fadeAlpha = math.min(1, fadeAlpha + fadeSpeed * dt)
  if fadeAlpha >= 1 then
    gameState = "gameover"
  end
  return
end

if gameState == "gameover" then
  return
end
  
  headAnimTimer = headAnimTimer + dt
  if headAnimTimer >= headAnimInterval then
    headAnimTimer = headAnimTimer - headAnimInterval
    headAnimFrame = headAnimFrame % #headSprites + 1
  end
  
  
  
if gameState == "menu" then 
  anguloTitulo = anguloTitulo + anguloVelocidad * dt
  if anguloTitulo > anguloMaximo then
    anguloTitulo = anguloMaximo
    anguloVelocidad = -anguloVelocidad
elseif anguloTitulo < anguloMinimo then
  anguloTitulo = anguloMinimo
  anguloVelocidad = -anguloVelocidad
end
return  
end
  
if gameState == "playing" then
  tiempoAcumulado = tiempoAcumulado + dt
  scrollX = scrollX + scrollVelocidad * dt
  

local dir = currentDirection or "a"
if tiempoAcumulado >= intervaloMovimiento then
  moverPerroBien(dir)
  tiempoAcumulado = tiempoAcumulado - intervaloMovimiento
end

  
  local onTrail = false
local head = perro[#perro]
for _, pt in ipairs(estela) do
  local tx, ty = pt.x + scrollX, pt.y
  if head.x + scrollX < tx + tamañoPerro
  and head.x + scrollX + tamañoPerro > tx
  and head.y < ty + tamañoPerro
  and head.y + tamañoPerro > ty then
    onTrail = true
    break
  end
end

if onTrail then
  offTrailGraceTimer = 0
  offTrailTimer      = offTrailMax
else
  offTrailGraceTimer = offTrailGraceTimer + dt
  if offTrailGraceTimer >= offTrailGrace then
    offTrailTimer = offTrailTimer - dt
    if offTrailTimer <= 0 then
      juegoTerminado = true
      gameState      = "fadeout"
      return
    end
  end
end
    
  detectarColisiones()
  
  if juegoTerminado and gameState == "playing" then
  gameState = "fadeout"
end
  
  
  if not tailSpawned then 
  bgScroll = bgScroll + scrollVelocidad * dt
  distanciaRecorrida = distanciaRecorrida + scrollVelocidad * dt
 end
 
  
  if bgScroll >= bgWidth then
    bgScroll = bgScroll - bgWidth
    currentMap = currentMap % #maps + 1
    local m = maps[ordenMapa[currentMap]]
    bgWidth = m.width * m.tilewidth
  end
  
  if distanciaRecorrida >= distanciaCulo and not tailSpawned then
    tailSpawned = true
    tailWorldX = -scrollX
    tailWorldY = (h0/2) - (tamañoPerro/2)
    estelaCentered = false 
    intervaloGeneracion = 100000
end

local distToEnd = distanciaCulo - distanciaRecorrida
    if distToEnd <= estelaTriggerDistancia and not estelaCentered then
      local last = estela[#estela]
      local lastScreenX = last.x + scrollX
      local targetX = w0/2
      local diff = targetX - lastScreenX
      local shift = diff * dt * 5
      for _, pt in ipairs(estela) do
        pt.x = pt.x + shift
      end
      if math.abs(diff) < 1 then
        estelaCentered = true
      end
    end


tiempoPowerup = tiempoPowerup + dt
if tiempoPowerup >= intervaloPowerup then
  local tipos = {"uranio", "tungsteno"}
  local tipo = tipos[love.math.random(#tipos)]
  local x0 = -scrollX - tamañoPerro
  local y0 = love.math.random(0, h0 - tamañoPerro)
  table.insert(powerups, {tipo = tipo, x = x0, y = y0})
  tiempoPowerup = tiempoPowerup - intervaloPowerup
end


tiempoEstela = tiempoEstela + dt
if tiempoEstela >= intervaloEstela and not tailSpawned then
  local xWorld = -scrollX
  local pasoY = love.math.random(-1,1) * tamañoPerro
  yTrail = math.max(0, math.min(h0-tamañoPerro, yTrail + pasoY))
  table.insert(estela, {x = xWorld, y = yTrail, visited = false})
  tiempoEstela = tiempoEstela - intervaloEstela
end

if not tailSpawned then
  tiempoGeneracion = tiempoGeneracion + dt
  if tiempoGeneracion >= intervaloGeneracion then
    if #obstaculosActivos < obstaculosMaximos then
      generarObstaculo()
    end
  tiempoGeneracion = tiempoGeneracion - intervaloGeneracion
  end
end

if not estelaCentered then
  for i = #estela, 1, -1 do
    if estela[i].x + scrollX < -tamañoPerro then
      table.remove(estela, i)
      if i < siguienteIndexEstela then
        siguienteIndexEstela = siguienteIndexEstela - 1
      end
    end
  end
end

if distanciaRecorrida > distanciaCulo - 500 then
  intervaloGeneracion = 100000
  intervaloPowerup = 100000
end


if tailSpawned and distanciaRecorrida >= distanciaCulo then
    gameState = "win"
end
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

for i = #powerups, 1, -1 do
  local p = powerups[i]
  if headScreenX < p.x + scrollX + tamañoPerro
  and headScreenX + tamañoPerro > p.x + scrollX 
  and headScreenY < p.y + tamañoPerro 
  and headScreenY + tamañoPerro > p.y then
    if p.tipo == "uranio" then
      intervaloMovimiento = math.max(0.01, intervaloMovimiento * 0.8)
    else
      intervaloMovimiento = intervaloMovimiento * 1.2
    end
    table.remove(powerups, i)
  end
end

    

if pt and headScreenX >= pt.x
  and headScreenX < pt.x + tamañoPerro
  and headScreenY >= pt.y
  and headScreenY < pt.y + tamañoPerro then
  pt.visited = true
  siguienteIndexEstela = siguienteIndexEstela + 1 
end


  
tiempoGeneracion = tiempoGeneracion + dt
if tiempoGeneracion >= intervaloGeneracion then
  if #obstaculosActivos < obstaculosMaximos then
    generarObstaculo()
  end
  tiempoGeneracion = tiempoGeneracion - intervaloGeneracion
end

end




function love.draw()

  
 
 if gameState == "menu" then
  local angulo = anguloTitulo
 love.graphics.setFont(love.graphics.newFont(48))
 love.graphics.push()
  love.graphics.translate(w0/2, h0/4)
  love.graphics.rotate(angulo)
  love.graphics.setColor(0,0,0)
  love.graphics.printf("TITULO DEL JUEGO", -w0/2, -24, w0, "center")
love.graphics.pop()
love.graphics.setColor(0.2,0.2,0.8)
love.graphics.rectangle("fill", btnPlay.x, btnPlay.y, btnPlay.w, btnPlay.h, 8, 8)
love.graphics.setColor(0,0,0)
love.graphics.printf("Play", btnPlay.x, btnPlay.y + 12, btnPlay.w, "center")
love.graphics.setColor(0.8,0.2,0.2)
love.graphics.rectangle("fill", btnExit.x, btnExit.y, btnExit.w, btnExit.h, 8,8)
love.graphics.setColor(0,0,0)
love.graphics.printf("Exit", btnExit.x, btnExit.y + 12, btnExit.w, "center")
return
end

love.graphics.setColor(0.6,0.3,0,1)
for i = 1, #perro-1 do
  local segmento = perro[i]
  love.graphics.rectangle("fill",segmento.x + scrollX, segmento.y, tamañoPerro, tamañoPerro
  )
end

    
    love.graphics.setColor(1,1,1,1)
  local cabeza = perro[#perro]
  local sprite = headSprites[headAnimFrame]
  local scale = tamañoPerro  / sprite:getWidth()
  
  love.graphics.draw(sprite, cabeza.x + scrollX, cabeza.y, 0, scale, scale)

  
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
 
 for i, p in ipairs(powerups) do
   if p.tipo == "uranio" then
     love.graphics.setColor(0,1,0.2)
   else
     love.graphics.setColor(0.5,0.5,0.5)
   end
   love.graphics.rectangle("fill", p.x+scrollX, p.y, tamañoPerro, tamañoPerro)
 end
 love.graphics.setColor(1,1,1)
 
 if tailSpawned then
  local tailScreenX = tailWorldX + scrollX
    love.graphics.setColor(1,1,1)
    love.graphics.draw(
      tailSprite,
      tailScreenX,
      tailWorldY,
      0,
      tamañoPerro / tailSprite:getWidth(),
      tamañoPerro / tailSprite:getWidth()
    )
  end 
  
if gameState == "playing" and offTrailTimer < offTrailMax then
    love.graphics.setColor(1,0,0)
    love.graphics.print(offTrailTimer)
  end
  love.graphics.setColor(1,1,1)
 
 if gameState == "fadeout" or gameState == "gameover" then
   love.graphics.setColor(0,0,0,fadeAlpha)
   love.graphics.rectangle("fill", 0, 0, w0, h0)
 end
 
 if gameState == "gameover" then
   love.graphics.setColor(1,1,1)
   love.graphics.setFont(love.graphics.newFont(48))
   love.graphics.printf("GAME OVER", 0, h0/2 - 80, w0, "center")
   
   love.graphics.setFont(love.graphics.newFont(24))
   love.graphics.setColor(0.2,0.2,0.2)
   love.graphics.rectangle("fill", btnTry.x, btnTry.y, btnTry.w, btnTry.h, 8, 8)
   love.graphics.setColor(1,1,1)
   love.graphics.printf("Try Again", btnTry.x, btnTry.y + (btnTry.h-24)/2, btnTry.w, "center")
 end
 
 if gameState == "win" then
    love.graphics.setColor(0,0,0)
    love.graphics.printf("¡HAS LLEGADO AL FINAL!", 0, h0/2 - 24, w0, "center")
  end
 
end

function love.mousepressed(x, y, button)
  
if gameState == "menu" and button == 1 then
  if x > btnPlay.x and x<= btnPlay.x + btnPlay.w
  and y >= btnPlay.y and y<=btnPlay.y + btnPlay.h then
    iniciarJuego()
    gameState = "playing"
    return
  end
  if x>btnExit.x and x<=btnExit.x + btnExit.w
  and y >= btnExit.y and y<=btnExit.y + btnExit.h then
    love.event.quit()
    return
  end

end


if gameState == "gameover" and button == 1 then
  if x > btnTry.x and x < btnTry.x + btnTry.w and y > btnTry.y and y<= btnTry.y+btnTry.h then
    iniciarJuego()
    gameState = "playing"
  end
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
