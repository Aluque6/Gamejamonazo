
local bgImage, bgWidth, bgScroll, bgSpeed
local currentMap = 1
local bgImages = {}
local totalScrollPx = 0
local BG_REPEAT = 4
local lastBase = nil
local seqCounter = 0
local currIdx = 1
local nextIdx = 1 


local backstepActive = false
local backTargetX, backTargetY = nil, nil
local backRemoveIndex = nil

local sounds = {}

local offTrailGrace = 1
local offTrailGraceTimer = 0
local offTrailMax = 5
local offTrailTimer = offTrailMax

local rastroVisibleGrace = 3 
local rastroFadeOutPerSec = 0.6   
local rastroFadeInPerSec  = 2.0    
local gameTime = 0                


local distanciaCulo = 16000
local distanciaRecorrida = 0
local tailSpawned = false
local tailWorldX, tailWorldY
local tailSprite
local estelaTriggerDistancia = 500

local powerupSprites = {}
local obstaculosSprites = {}
local obstaculoEscala = {
  cochecitolere  = { w = 2.6, h = 1.6 },  
  puestoperritos = { w = 2.2, h = 2.0 }, 
  perritomalo    = { w = 1.3, h = 1.3 }, 
  arbol          = { w = 1.6, h = 2.2 }, 
  caja           = { w = 1.0, h = 1.0 },
}
local obstaculoMovimiento = {
  cochecitolere  = { kind = "x", speed = 120, amplitude = 260, prob = 0.8 }, 
  perritomalo    = { kind = "y", speed =  90, amplitude = 180, prob = 0.7 }, 
  puestoperritos = nil,  
  arbol          = nil,
  caja           = nil,
}

local headSprites = {}
local headAnimTimer = 0
local headAnimInterval = 0.1
local headAnimFrame = 1

local rastroSprites = {}
local rastroAnimTimer = 0
local rastroAnimInterval = 0.2   
local rastroFrame = 1
local rastroAlpha = 0.9   

local tailSprites = {}
local tailAnimTimer = 0
local tailAnimInterval = 0.1
local tailAnimFrame = 1
local rastroWarningActive = false

local winFrozen = false
local frozenTotalScrollPx = 0
local frozenScrollX = 0

local winPhase = nil
local winMoveTimer = 0
local winTargetY = 0
local winTargetX = nil
local winStopOffsetTiles = 2
local winHoldTimer = 0

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
local baseIntervaloMovimiento = 0.25
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

local function lerp(a,b,t) return a + (b-a)*t end

local headPrevX, headPrevY = 0, 0  

function recalcBgScale()
  w0, h0 = love.graphics.getDimensions()
  local iw, ih = bgImages[1]:getDimensions()
  bgScale = math.max(w0 / iw, h0 / ih) 
end

function bgIndexForTile(k)
  if k < 0 then k = 0 end
  local group = math.floor(k / BG_REPEAT) 
  return (group % #bgImages) + 1
end

function seqIndex(n)
  local i = n % 10
  if i < 4 then
    return 1               
  elseif i < 6 then
    return (i == 4) and 1 or 2  
  else
    return 2               
  end
end




function love.load()
  
  sounds.colision = love.audio.newSource("audio/colision.mp3", "static")
  sounds.perderrastro = love.audio.newSource("audio/perderrastro.mp3", "static")
  sounds.perderrastro:setLooping(true)
  

  bgImages = {
  love.graphics.newImage("sprites/fondos/fondocity.png"),
  love.graphics.newImage("sprites/fondos/fondobosque.png"),}
  bgScroll = 0
  bgSpeed  = 500
  recalcBgScale()
  for i=1,#bgImages do
    bgImages[i]:setFilter("linear","linear")
  end


  totalScrollPx = 0

  w0, h0 = love.graphics.getDimensions()
  
  headSprites[1] = love.graphics.newImage("sprites/pancho/perrito1.png")
  headSprites[2] = love.graphics.newImage("sprites/pancho/perrito2.png")
  headSprites[3] = love.graphics.newImage("sprites/pancho/perrito3.png")
  
  tailSprites[1] = love.graphics.newImage("sprites/pancho/culete1.png")
  tailSprites[2] = love.graphics.newImage("sprites/pancho/culete2.png")
  tailSprites[3] = love.graphics.newImage("sprites/pancho/culete3.png")
  
  
  bodySprites = {
    horiz = love.graphics.newImage("sprites/pancho/cuerpoHorizontal.png"),
    vert = love.graphics.newImage("sprites/pancho/cuerpoVertical.png"),
    leaveDown = love.graphics.newImage("sprites/pancho/esquinaBajar.png"),
    leaveUp = love.graphics.newImage("sprites/pancho/esquinaSubir.png"),
    startUp = love.graphics.newImage("sprites/pancho/torsosube.png"),
    startDown = love.graphics.newImage("sprites/pancho/torsobaja.png"),
  }
  
rastroSprites[1] = love.graphics.newImage("sprites/pancho/rastro1.png")
rastroSprites[2] = love.graphics.newImage("sprites/pancho/rastro2.png")

powerupSprites.uranio = love.graphics.newImage("sprites/perritodeuranio.png")
powerupSprites.tungsteno = love.graphics.newImage("sprites/atungsteno.png")

obstaculosSprites.arbol = love.graphics.newImage("sprites/arbol.png")
obstaculosSprites.puestoperritos = love.graphics.newImage("sprites/puestoperritos.png")
obstaculosSprites.perritomalo = love.graphics.newImage("sprites/perritomalo.png")
obstaculosSprites.cochecitolere = love.graphics.newImage("sprites/cochecitolere.png")



  
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

iw, ih = bgImages[1]:getDimensions()
tileW  = iw * bgScale

lastBase   = math.floor((totalScrollPx or 0) / tileW)
seqCounter = 0
currIdx    = seqIndex(seqCounter)
nextIdx    = seqIndex(seqCounter + 1)


  totalScrollPx = 0
  gameTime = 0
  rastroAlpha = 1.0

  juegoTerminado       = false
  tailSpawned          = false
  estelaCentered       = false
  fadeAlpha            = 0
  scrollX              = 0


  offTrailGraceTimer   = 0
  offTrailTimer        = offTrailMax
  tiempoAcumulado      = 0
  tiempoGeneracion     = 0
  tiempoPowerup        = 0
  tiempoEstela         = 0
  siguienteIndexEstela = 1
  distanciaRecorrida   = 0

  tailAnimTimer = 0
  tailAnimFrame = 1
  baseIntervaloMovimiento = 0.2
  intervaloMovimiento = baseIntervaloMovimiento

  tamañoObstaculo      = 50
  tamañoPerro          = 50
  tamañoMinimo         = 100
  obstaculosMaximos   = 10
  obstaculosCargados  = false
  obstaculosActivos   = {}
  obstaculos          = { ["arbol"] = 0, ["caja"] = 0, ["puestoperritos"] = 0, ["perritomalo"] = 0, ["cochecitolere"] = 0 }
  powerups            = {}
  historialDirecciones = {}
  
  intervaloGeneracion = 2
  intervaloPowerup = 5


  scrollVelocidad = tamañoPerro / intervaloMovimiento
  estelaSpeedPx   = bgSpeed * bgScale  


  perro = {}
  local xInicial = math.floor((w0 * 0.9) / tamañoPerro) * tamañoPerro
  local yInicial = h0 / 2
  for i = 0, tamañoMinimo - 1 do
    table.insert(perro, 1, { x = xInicial, y = yInicial })
  end

 
  local cabeza0 = perro[#perro]
  headPrevX, headPrevY = cabeza0.x, cabeza0.y

  obstaculosMaximos   = 10
  obstaculosCargados  = false
  obstaculosActivos   = {}
  obstaculos          = { ["arbol"] = 0, ["caja"] = 0, ["puestoperritos"] = 0, ["perromalo"] = 0, ["cochecitolere"] = 0, }
  powerups            = {}

  cargarObstaculos(obstaculos)

  estela = {}
  yTrail = math.floor((h0/2)/tamañoPerro) * tamañoPerro
  local numPuntos = math.floor((w0/2)/tamañoPerro) + 1
  local y0 = math.floor((h0/2)/tamañoPerro) * tamañoPerro
  for i = 1, numPuntos do
    local sx = -tamañoPerro - (numPuntos - i) * tamañoPerro
    local pasoY = love.math.random(-1, 1) * tamañoPerro
    y0 = math.max(0, math.min(h0 - tamañoPerro, y0 + pasoY))
    table.insert(estela, { screenX = sx, y = y0, visited = false })
  end
end

function love.update(dt)
  
if gameState ~= "playing" then
  sounds.perderrastro:stop()
end
  
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

if gameState == "win" then
  headAnimTimer = headAnimTimer + dt
  if headAnimTimer >= headAnimInterval then
    headAnimTimer = headAnimTimer - headAnimInterval
    headAnimFrame = headAnimFrame % #headSprites + 1
  end


if #tailSprites > 0 then
  tailAnimTimer = tailAnimTimer + dt
  if tailAnimTimer >= tailAnimInterval then
    tailAnimTimer = tailAnimTimer - tailAnimInterval
    tailAnimFrame = (tailAnimFrame % #tailSprites) + 1
  end
end


  
  winMoveTimer = winMoveTimer + dt
  while winMoveTimer >= intervaloMovimiento and winPhase do
    winMoveTimer = winMoveTimer - intervaloMovimiento

    local cabeza = perro[#perro]

    if winPhase == "toCenterY" then
      if cabeza.y > winTargetY then
        moverPerroBien("w")
      elseif cabeza.y < winTargetY then
        moverPerroBien("s")
      else
        winPhase = "toTailX"
      end

    elseif winPhase == "toTailX" then
      if cabeza.x > tailWorldX + 2 * tamañoPerro then
        moverPerroBien("a")
      else
        winPhase = "done"
        winHoldTimer = 0
      end
    end
  end
if winPhase == "done" then
  winHoldTimer = winHoldTimer + dt
  if winHoldTimer >= 1.5 then
    gameState = "win_end"
  end
end
  return
end
  
if gameState == "playing" then
  
  tiempoAcumulado = tiempoAcumulado + dt
  totalScrollPx = totalScrollPx + fondoScreenSpeed() * dt
  rastroAnimTimer = rastroAnimTimer + dt

  
  scrollX = scrollX + fondoScreenSpeed() * dt
  bgScroll = bgScroll + bgSpeed * dt
  
  if rastroAnimTimer >= rastroAnimInterval then
  rastroAnimTimer = rastroAnimTimer - rastroAnimInterval
  rastroFrame = (rastroFrame % 2) + 1
end
  
local cabeza = perro[#perro]
local headScreenX = cabeza.x + scrollX
if headScreenX > w0 - tamañoPerro then
  scrollX = math.min(scrollX, (w0 - tamañoPerro) - cabeza.x)
end


for i = #obstaculosActivos, 1, -1 do
  local o = obstaculosActivos[i]
  if o.usaVelFondo then
    local vx = fondoScreenSpeed()
    o.screenX = (o.screenX or -o.ancho) + vx * dt
    if o.screenX > w0 + o.ancho then
      table.remove(obstaculosActivos, i)
    end
  end
end

  

for i = #obstaculosActivos, 1, -1 do
  local o = obstaculosActivos[i]
  if o.movil then
    if o.kind == "y" and o.vy then
      o.y = o.y + o.vy * dt
      if o.y < o.minY then o.y = o.minY; o.vy =  math.abs(o.vy) end
      if o.y > o.maxY then o.y = o.maxY; o.vy = -math.abs(o.vy) end
    elseif o.kind == "x" and o.vx then
      o.xOffset = (o.xOffset or 0) + o.vx * dt
      if o.xOffset < -o.maxOffset then o.xOffset = -o.maxOffset; o.vx =  math.abs(o.vx) end
      if o.xOffset >  o.maxOffset then o.xOffset =  o.maxOffset; o.vx = -math.abs(o.vx) end
    end
  end
end




local dir = currentDirection or "a"
if dir == "d" and estaEnBordeDerecho() then
  dir = nil 
end

if tiempoAcumulado >= intervaloMovimiento then
  moverPerroBien(dir or "a")
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

gameTime = gameTime + dt

if gameTime <= rastroVisibleGrace then
  rastroAlpha = 1.0
else
  if onTrail then
    rastroAlpha = math.min(1.0, rastroAlpha + rastroFadeInPerSec * dt)
  else
    rastroAlpha = math.max(0.0, rastroAlpha - rastroFadeOutPerSec * dt)
  end
end



if onTrail then

  if rastroWarningActive then
    rastroWarningActive = false
    sounds.perderrastro:stop()
  end
  offTrailGraceTimer = 0
  offTrailTimer      = offTrailMax
else

  offTrailGraceTimer = offTrailGraceTimer + dt

  if offTrailGraceTimer >= offTrailGrace then
    if not rastroWarningActive then
      rastroWarningActive = true
      if sounds.perderrastro then
        sounds.perderrastro:stop() 
        sounds.perderrastro:play()
      end
    end

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
    tailWorldY = (h0/2) 
    estelaCentered = false 
    intervaloGeneracion = 100000
end


tiempoPowerup = tiempoPowerup + dt
if tiempoPowerup >= intervaloPowerup then
  local tipos = {"uranio", "tungsteno"}
  local tipo = tipos[love.math.random(#tipos)]

  local y0 = love.math.random(0, h0 - tamañoPerro)
  y0 = math.floor(y0 / tamañoPerro) * tamañoPerro

  local distanciaFueraPantalla = love.math.random(10, 50)

  table.insert(powerups, {
    tipo = tipo,
    y = y0,
    ancho = tamañoPerro,
    alto  = tamañoPerro,
    usaVelFondo = true,
    screenX = -tamañoPerro - distanciaFueraPantalla
  })

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
  winFrozen = true
  frozenTotalScrollPx = totalScrollPx
  frozenScrollX       = scrollX
  local cabeza = perro[#perro]
  headPrevX, headPrevY = cabeza.x, cabeza.y
  winTargetY = math.floor((h0/2) / tamañoPerro) * tamañoPerro
  winPhase = "toCenterY"
  winMoveTimer = 0
  winHoldTimer = 0
  currentDirection = nil
end
end

tiempoAcumulado = tiempoAcumulado + dt

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
  if p.usaVelFondo then
    p.screenX = (p.screenX or -p.ancho) + fondoScreenSpeed() * dt
    if p.screenX > w0 + (p.ancho or tamañoPerro) then
      table.remove(powerups, i)
    end
  end
end



for i = #powerups, 1, -1 do
  local p = powerups[i]
  local pX = p.usaVelFondo and (p.screenX or -math.huge) or (p.x + scrollX)
  local pY = p.y
  local pW = p.ancho or tamañoPerro
  local pH = p.alto  or tamañoPerro

  if headScreenX < pX + pW
  and headScreenX + tamañoPerro > pX
  and headScreenY < pY + pH
  and headScreenY + tamañoPerro > pY then
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


local camX = (gameState == "win" and frozenScrollX) or scrollX

 if gameState == "menu" then
   love.graphics.clear(1,1,1,1)
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

local iw, ih = bgImages[1]:getDimensions()
local tileW  = iw * bgScale
local tileH  = ih * bgScale

local drawTot = (gameState == "win" and frozenTotalScrollPx) or totalScrollPx
local base    = math.floor(drawTot / tileW)
local offset  = drawTot - base * tileW

if lastBase == nil then
  lastBase = base
end
while base > lastBase do
  currIdx    = nextIdx
  seqCounter = seqCounter + 1
  nextIdx    = seqIndex(seqCounter + 1)
  lastBase   = lastBase + 1
end

local rightX = offset
local leftX  = offset - tileW
local y      = math.floor((h0 - tileH) * 0.5)

-- DIBUJA SIEMPRE PRIMERO EL ACTUAL (derecha) y LUEGO EL ENTRANTE (izquierda)
love.graphics.setColor(1,1,1,1)
love.graphics.draw(bgImages[currIdx], rightX, y, 0, bgScale, bgScale)
love.graphics.draw(bgImages[nextIdx], leftX,  y, 0, bgScale, bgScale)


if tailSpawned and #tailSprites > 0 then
  local camX = (gameState == "win" and frozenScrollX) or scrollX
  local tailScreenX = tailWorldX + camX
  local sprite = tailSprites[tailAnimFrame]
  if sprite then
    local scale = tamañoPerro / sprite:getWidth()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(sprite, tailScreenX, tailWorldY, 0, scale, scale)
  end
end


drawCuerpoPerro()

    
  love.graphics.setColor(1,1,1,1)

local cabeza = perro[#perro]
local sprite = headSprites[headAnimFrame]
local scale  = tamañoPerro / sprite:getWidth()

local alpha = math.min(1, tiempoAcumulado / intervaloMovimiento)

local camX = (gameState == "win" and frozenScrollX) or scrollX
local headDrawX = lerp(headPrevX, cabeza.x, alpha) + camX
local headDrawY = lerp(headPrevY, cabeza.y, alpha)

love.graphics.setColor(1,1,1,1)
love.graphics.draw(sprite, headDrawX, headDrawY, 0, scale, scale)


  
for i, obstaculo in ipairs(obstaculosActivos) do
  local camX = (gameState == "win" and frozenScrollX) or scrollX
  local ox = (obstaculo.usaVelFondo and obstaculo.screenX or (obstaculo.x + camX)) + (obstaculo.xOffset or 0)


  local img = obstaculosSprites[obstaculo.tipo]
  if img then
    local escalaX = obstaculo.ancho / img:getWidth()
    local escalaY = obstaculo.alto  / img:getHeight()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(img, ox, obstaculo.y, 0, escalaX, escalaY)
  else
    if obstaculo.tipo == "caja" then
      love.graphics.setColor(0.8,0.6,0.2,1)
    else
      love.graphics.setColor(1,0,0,1)
    end
    love.graphics.rectangle("fill", ox, obstaculo.y, obstaculo.ancho, obstaculo.alto)
    love.graphics.setColor(1,1,1,1)
  end

  -- HITBOX
  love.graphics.setColor(1,1,1,1)
  love.graphics.rectangle("line", ox, obstaculo.y, obstaculo.ancho, obstaculo.alto)
end

  --ESTO ES PARA LIMPIAR LOS OBSTACULOS QUE YA NO ESTAN EN PANTALLA
  
for i = #obstaculosActivos, 1, -1 do
  local o = obstaculosActivos[i]
  if not o.usaVelFondo and not o.movil then
    if o.x + scrollX > w0 then
      table.remove(obstaculosActivos, i)
    end
  end
end


 
local imgRastro = rastroSprites[rastroFrame]
if imgRastro then
  local sx = tamañoPerro / imgRastro:getWidth()
  local sy = sx
  love.graphics.setColor(1,1,1, rastroAlpha)
  for i, pt in ipairs(estela) do
    if not pt.visited and pt.screenX then
      love.graphics.draw(imgRastro, pt.screenX, pt.y, 0, sx, sy)
    end
  end
  love.graphics.setColor(1,1,1,1)
end

 
for i, p in ipairs(powerups) do
  local img = powerupSprites[p.tipo]
  local camX = (gameState == "win" and frozenScrollX) or scrollX
  local drawX = p.usaVelFondo and (p.screenX or -math.huge) or (p.x + camX)
  local drawY = p.y

  if img then
    local sx = (p.ancho or tamañoPerro) / img:getWidth()
    local sy = (p.alto  or tamañoPerro) / img:getHeight()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(img, drawX, drawY, 0, sx, sy)
  else
    love.graphics.setColor(0.5,0.5,0.5,1)
    love.graphics.rectangle("fill", drawX, drawY, p.ancho or tamañoPerro, p.alto or tamañoPerro)
    love.graphics.setColor(1,1,1,1)
  end
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
    love.graphics.setColor(1,1,1)
  end
  
  if gameState == "win_end" then

  love.graphics.setColor(1,1,1,1)
  love.graphics.rectangle("fill", 0, 0, w0, h0)


  love.graphics.setColor(0,0,0,1)
  love.graphics.setFont(love.graphics.newFont(48))
  love.graphics.printf("¡HAS LLEGADO AL FINAL!", 0, h0*0.3, w0, "center")

  love.graphics.setFont(love.graphics.newFont(24))

  love.graphics.setColor(0.2,0.6,1.0,1)
  love.graphics.rectangle("fill", btnTry.x, btnTry.y, btnTry.w, btnTry.h, 8, 8)
  love.graphics.setColor(1,1,1,1)
  love.graphics.printf("Reintentar", btnTry.x, btnTry.y + (btnTry.h-24)/2, btnTry.w, "center")

  love.graphics.setColor(0.9,0.3,0.3,1)
  love.graphics.rectangle("fill", btnExit.x, btnExit.y, btnExit.w, btnExit.h, 8, 8)
  love.graphics.setColor(1,1,1,1)
  love.graphics.printf("Salir", btnExit.x, btnExit.y + (btnExit.h-24)/2, btnExit.w, "center")

  return
    
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

if gameState == "win_end" and button == 1 then
  if x > btnTry.x and x < btnTry.x + btnTry.w and y > btnTry.y and y <= btnTry.y + btnTry.h then
    iniciarJuego()
    gameState = "playing"
  end
  if x > btnExit.x and x < btnExit.x + btnExit.w and y > btnExit.y and y <= btnExit.y + btnExit.h then
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

function generarObstaculo()

  local tiposDisponibles = {}
  for tipo, _ in pairs(obstaculosSprites) do
    table.insert(tiposDisponibles, tipo)
  end
  local tipo = (#tiposDisponibles > 0) and tiposDisponibles[love.math.random(#tiposDisponibles)] or "caja"

  local esc = obstaculoEscala and obstaculoEscala[tipo] or { w = 1, h = 1 }
  local ancho = math.floor(tamañoObstaculo * (esc.w or 1) + 0.5)
  local alto  = math.floor(tamañoObstaculo * (esc.h or 1) + 0.5)


  local movConf   = obstaculoMovimiento[tipo]
  local tendraMov = movConf and (love.math.random() < (movConf.prob or 1.0)) or false


  local distanciaFueraPantalla = love.math.random(10, 50)
  local yMax = math.max(0, h0 - alto)
  local yRand = love.math.random(0, yMax)
  local y = math.floor(yRand / tamañoPerro) * tamañoPerro
  if y > yMax then y = yMax end

  if tendraMov then

    local o = {
      tipo = tipo,
      y = y,
      ancho = ancho,
      alto  = alto,
      usaVelFondo = true,                              
      screenX = -ancho - distanciaFueraPantalla,       
      movil = true,
      kind  = movConf.kind,
    }

    if movConf.kind == "y" then
      local half = (movConf.amplitude or 160) / 2
      o.minY = math.max(0, y - half)
      o.maxY = math.min(h0 - alto, y + half)
      if o.minY > o.maxY then o.minY, o.maxY = o.maxY, o.minY end
      o.vy = (movConf.speed or 90) * (love.math.random() < 0.5 and -1 or 1)
    elseif movConf.kind == "x" then
      o.xOffset   = 0
      o.maxOffset = (movConf.amplitude or 200) / 2
      o.vx = (movConf.speed or 120) * (love.math.random() < 0.5 and -1 or 1)
    end

    table.insert(obstaculosActivos, o)
    return
  end

  table.insert(obstaculosActivos, {
    tipo = tipo,
    y = y,
    ancho = ancho,
    alto  = alto,
    usaVelFondo = true,
    screenX = -ancho - distanciaFueraPantalla,
    vx = nil,
  })
end




function detectarColisiones() 
  for i, segmento in ipairs(perro) do
    local segmentoX = segmento.x + scrollX
    local segmentoY = segmento.y
    if segmentoX + tamañoPerro >= 0 and segmentoX <= w0 then
      for i, obstaculo in ipairs(obstaculosActivos) do
      local obstaculoXBase = obstaculo.usaVelFondo and (obstaculo.screenX or -math.huge) or (obstaculo.x + scrollX)
local obstaculoX = obstaculoXBase + (obstaculo.xOffset or 0)
local obstaculoY = obstaculo.y

local colisiona =
  segmentoX < obstaculoX + obstaculo.ancho and
  segmentoX + tamañoPerro > obstaculoX and
  segmentoY < obstaculoY + obstaculo.alto and
  segmentoY + tamañoPerro > obstaculoY

  if colisiona then
    if sounds.colision then
    sounds.colision:stop()  
    sounds.colision:play()
    end
    juegoTerminado = true
    return
    end
  end
end
end
end


function moverPerroBien(direccion)
  if not direccion then return end

  local cabeza = perro[#perro]
  local nuevaX, nuevaY = cabeza.x, cabeza.y
  local ultimaDireccion = historialDirecciones[#historialDirecciones]
  local headScreenX = cabeza.x + scrollX

   if direccion == "d" then
    if headScreenX >= (w0 - tamañoPerro - 0.5) then
      return
    end
    if #perro > tamañoMinimo then
      local oldHead = perro[#perro]
      local newHead = perro[#perro - 1]
      headPrevX, headPrevY = oldHead.x, oldHead.y
      table.remove(perro, #perro)
      if #historialDirecciones > 0 then
        table.remove(historialDirecciones, #historialDirecciones)
      end
    end
    return
  end

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
    if gameState ~= "win" then
      local posPantalla = nuevaX + scrollX
      if posPantalla < w0 / 4 then
        return
      end
    end
  else
    return
  end

  if nuevaY < 0 then nuevaY = 0 end
  if nuevaY > h0 - tamañoPerro then nuevaY = h0 - tamañoPerro end

  if nuevaX ~= cabeza.x or nuevaY ~= cabeza.y then
    headPrevX, headPrevY = cabeza.x, cabeza.y
    table.insert(perro, { x = nuevaX, y = nuevaY })
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
    local camX = (gameState == "win" and frozenScrollX) or scrollX
    local tailScreenX = tail.x + camX
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


function sign(n) return (n > 0) and 1 or (n < 0 and -1 or 0) end

function drawPlaceholder(x, y, size)
  love.graphics.setColor(0.6, 0.3, 0, 1)
  love.graphics.rectangle("fill", x, y, size, size)
  love.graphics.setColor(1, 1, 1, 1)
end

function drawCuerpoPerro()
  if not perro or #perro < 2 then return end

  for i = 1, #perro - 1 do 
    local prev = (i > 1) and perro[i-1] or nil
    local curr = perro[i]
    local next = perro[i+1] 

    local img, rot = nil, 0
    local drawRectFallback = false

    if prev and next then

      local v_in_x  = curr.x - prev.x
      local v_in_y  = curr.y - prev.y
      local v_out_x = next.x - curr.x
      local v_out_y = next.y - curr.y

      local in_h  = (v_in_y  == 0)
      local in_v  = (v_in_x  == 0)
      local out_h = (v_out_y == 0)
      local out_v = (v_out_x == 0)

      if (in_h and out_h) then

        img, rot = bodySprites.horiz, 0

      elseif (in_v and out_v) then

        img, rot = bodySprites.vert, 0

      elseif in_h and out_v then
 
        if v_out_y < 0 then
         
          if bodySprites.startUp then
            img = bodySprites.startUp
          else
            drawRectFallback = true
          end
        else
      
          if bodySprites.startDown then
            img = bodySprites.startDown
          else
            drawRectFallback = true
          end
        end
       
        rot = (v_in_x > 0) and math.pi or 0

      elseif in_v and out_h then
        if v_in_y < 0 then
          img = bodySprites.leaveUp
        else
          img = bodySprites.leaveDown
        end
        rot = (v_out_x > 0) and math.pi or 0
        
      else
        if math.abs(v_in_x) >= math.abs(v_in_y) then
          img = bodySprites.horiz
        else
          img = bodySprites.vert
        end
      end
    else

      if next and next.y == curr.y then
        img = bodySprites.horiz
      else
        img = bodySprites.vert
      end
    end

    local camX = (gameState == "win" and frozenScrollX) or scrollX
    local drawX = curr.x + camX
    local drawY = curr.y

    if drawRectFallback or not img then
      drawPlaceholder(drawX, drawY, tamañoPerro)
    else

      local cx = drawX + tamañoPerro/2
      local cy = drawY + tamañoPerro/2
      local sx = tamañoPerro / img:getWidth()
      local sy = sx
      love.graphics.setColor(1,1,1,1)
      love.graphics.draw(img, cx, cy, rot, sx, sy, img:getWidth()/2, img:getHeight()/2)
    end
  end
end

function estaEnBordeDerecho()
  local cabeza = perro[#perro]
  print(w0- tamañoPerro - 0.5)
  print (w0)
  return (cabeza.x + scrollX) >= (w0 - 2* tamañoPerro)
end


function sonDireccionesOpuestas (dir1, dir2)
  
  return (dir1 == "w" and dir2 == "s") or (dir1 == "s" and dir2 == "w") or (dir1 == "a" and dir2 == "d") or (dir1 == "d" and dir2 == "a")
  
end
