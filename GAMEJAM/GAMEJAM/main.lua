
local bgImage, bgWidth, bgScroll, bgSpeed
local currentMap = 1


local offTrailGrace = 1
local offTrailGraceTimer = 0
local offTrailMax = 5
local offTrailTimer = offTrailMax

local distanciaCulo = 50000
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
local estelaSpeedPx = 0
local yTrail = nil
local powerups = {}
local tiempoPowerup = 0
local intervaloPowerup = 5
local intervaloMovimiento 
local baseIntervaloMovimiento = 0.15
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
local intervaloGeneracion = 2

function love.load()
  
  bgImage = love.graphics.newImage("sprites/fondos/fondoCiudad1.png")
  bgWidth = bgImage:getWidth()
  bgHeight = bgImage:getHeight()
  bgScroll = 0
  bgSpeed = 500
  w0, h0 = love.graphics.getDimensions()
  bgScale = w0 / bgWidth
  
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
  
  
  love.graphics.setBackgroundColor(1, 1, 1)
  
  
end

function iniciarJuego() 
  
  offTrailTimer = offTrailMax
  tailSpawned = false
  estelaCentered = false
  estelaSpeedPx = bgSpeed * bgScale
  tamañoObstaculo = 50
  tamañoPerro = 30
  tamañoMinimo = 100
  historialDirecciones = {}
  
  juegoTerminado = false
  scrollX = 0
  fadeAlpha = 0

  juegoTerminado = false
  
  perro = {}
  xInicial = math.floor((w0 * 0.9) / tamañoPerro) * tamañoPerro
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
  
    estela = {}  
  yTrail = math.floor((h0/2)/tamañoPerro) * tamañoPerro
  local numPuntos = math.floor((w0/2)/tamañoPerro) + 1
  local y0 = math.floor((h0/2)/tamañoPerro) * tamañoPerro
  for i = 1, numPuntos do
    local sx = -tamañoPerro - (numPuntos - i) * tamañoPerro
    local pasoY = love.math.random(-1,1) * tamañoPerro
    y0 = math.max(0, math.min(h0 - tamañoPerro, y0 + pasoY))
    table.insert(estela, {screenX = sx, y = y0, visited = false})
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
  
  scrollX = scrollX + fondoScreenSpeed() * dt
  bgScroll = bgScroll + bgSpeed * dt
  
local cabeza = perro[#perro]
local headScreenX = cabeza.x + scrollX
if headScreenX > w0 - tamañoPerro then
  scrollX = (w0 - tamañoPerro) - cabeza.x
end
  
  if bgScroll >= bgWidth then
    bgScroll = bgScroll - bgWidth
  end
  
for i = #obstaculosActivos, 1, -1 do
  local o = obstaculosActivos[i]
  if o.usaVelFondo then
    local vx = (o.vx ~= nil) and o.vx or fondoScreenSpeed()
    o.screenX = (o.screenX or -o.ancho) + vx * dt
    if o.screenX > w0 + o.ancho then
      table.remove(obstaculosActivos, i)
    end
  end
end


local dir = currentDirection or "a"
if tiempoAcumulado >= intervaloMovimiento then
  moverPerroBien(dir)
  tiempoAcumulado = tiempoAcumulado - intervaloMovimiento
end

limpiarSegmentosFueraPantalla()

  
local onTrail = false
local head = perro[#perro]
for _, pt in ipairs(estela) do
  local tx = pt.screenX
  local ty = pt.y
  if tx and                       
     head.x + scrollX < tx + tamañoPerro and
     head.x + scrollX + tamañoPerro > tx and
     head.y < ty + tamañoPerro and
     head.y + tamañoPerro > ty then
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
  distanciaRecorrida = distanciaRecorrida + fondoScreenSpeed() * dt
 end
 
  
  if distanciaRecorrida >= distanciaCulo and not tailSpawned then
    tailSpawned = true
    tailWorldX = -scrollX
    tailWorldY = (h0/2) - (tamañoPerro/2)
    estelaCentered = false 
    intervaloGeneracion = 100000
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
  table.insert(estela, {screenX = -tamañoPerro, y = yTrail, visited = false})
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


for i = #estela, 1, -1 do
  local pt = estela[i]
  pt.screenX = (pt.screenX or -tamañoPerro) + estelaSpeedPx * dt
  if pt.screenX > w0 + tamañoPerro then
    table.remove(estela, i)
    if i < siguienteIndexEstela then
      siguienteIndexEstela = math.max(1, siguienteIndexEstela - 1)
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
if pt then
  if headScreenX >= (pt.screenX or math.huge) and
     headScreenX <  (pt.screenX or -math.huge) + tamañoPerro and
     headScreenY >= pt.y and
     headScreenY <  pt.y + tamañoPerro then
    pt.visited = true
    siguienteIndexEstela = siguienteIndexEstela + 1
  end
end


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

-- mover el fondo de IZQUIERDA A DERECHA ADRIAN JDOER
local x = (bgScroll % bgWidth) * bgScale
love.graphics.draw(bgImage, x - w0, 0, 0, bgScale, bgScale)
love.graphics.draw(bgImage, x,      0, 0, bgScale, bgScale)


for i = 1, #perro-1 do
  local segmento = perro[i]
  love.graphics.setColor(0.6,0.3,0,1)
  love.graphics.rectangle("fill",segmento.x + scrollX, segmento.y, tamañoPerro, tamañoPerro
  )
end

    
    love.graphics.setColor(1,1,1,1)
  local cabeza = perro[#perro]
  local sprite = headSprites[headAnimFrame]
  local scale = tamañoPerro  / sprite:getWidth()
  
  love.graphics.draw(sprite, cabeza.x + scrollX, cabeza.y, 0, scale, scale)

  
  for i, obstaculo in ipairs(obstaculosActivos) do
  local ox = obstaculo.usaVelFondo and obstaculo.screenX or (obstaculo.x + scrollX)

  if obstaculo.tipo == "arbol" then
    local escalaX = obstaculo.ancho / obstaculosSprites.arbol:getWidth()
    local escalaY = obstaculo.alto  / obstaculosSprites.arbol:getHeight()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(obstaculosSprites.arbol, ox, obstaculo.y, 0, escalaX, escalaY)
  elseif obstaculo.tipo == "caja" then
    love.graphics.setColor(0.8,0.6,0.2)
  else
    love.graphics.setColor(1,0,0)
  end

  love.graphics.rectangle("line", ox, obstaculo.y, obstaculo.ancho, obstaculo.alto)
end
love.graphics.setColor(1,1,1)

  
  --ESTO ES PARA LIMPIAR LOS OBSTACULOS QUE YA NO ESTAN EN PANTALLA, TOTALMENTE INNECESARIO PERO ME DA TOC NO HACERLO
  
  for i = #obstaculosActivos, 1, -1 do
  local o = obstaculosActivos[i]
  if not o.usaVelFondo then
    if o.x + scrollX > w0 then
      table.remove(obstaculosActivos, i)
    end
  end
end

  
 
 love.graphics.setColor(0,0,1,0.5)
 for i, pt in ipairs(estela) do
   if not pt.visited then
     love.graphics.rectangle("fill", pt.screenX, pt.y, tamañoPerro, tamañoPerro)
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
  local alto  = tamañoObstaculo
  local distanciaFueraPantalla = love.math.random(10, 50)
  local y = love.math.random(0, h0 - alto)

  table.insert(obstaculosActivos, {
    tipo = tipo,
    y = y,
    ancho = ancho,
    alto  = alto,
    usaVelFondo = true,
    screenX = -ancho - distanciaFueraPantalla,
    vx = nil
  })
end



function detectarColisiones() 
  for _, segmento in ipairs(perro) do
    local segmentoX = segmento.x + scrollX
    local segmentoY = segmento.y
    if segmentoX + tamañoPerro >= 0 and segmentoX <= w0 then
      for _, obstaculo in ipairs(obstaculosActivos) do
        local obstaculoX = obstaculo.usaVelFondo and (obstaculo.screenX or -math.huge) or (obstaculo.x + scrollX) 
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

function fondoScreenSpeed()
  local extra = (not tailSpawned) and scrollVelocidad or 0
  return (bgSpeed + extra) * bgScale
end


function limpiarSegmentosFueraPantalla()
  if not perro or #perro <= 1 then return end

  local margen = 0

  while #perro > 1 do
    local tail = perro[1]
    local tailScreenX = tail.x + scrollX
    if tailScreenX < -tamañoPerro - margen then
      table.remove(perro, 1)
      if historialDirecciones and #historialDirecciones > 0 then
        table.remove(historialDirecciones, 1)
      end
    else
      break
    end
  end
end


function sonDireccionesOpuestas (dir1, dir2)
  
  return (dir1 == "w" and dir2 == "s") or (dir1 == "s" and dir2 == "w") or (dir1 == "a" and dir2 == "d") or (dir1 == "d" and dir2 == "a")
  
end
