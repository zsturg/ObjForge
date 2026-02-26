-- ============================================================
-- ObjForge - Block editor
-- ============================================================

local C_WHITE  = Color.new(255, 255, 255, 255)
local C_GREY   = Color.new(140, 140, 140, 255)
local C_YELLOW = Color.new(255, 220,  50, 255)
local C_RED    = Color.new(255,  70,  70, 255)
local C_GREEN  = Color.new( 50, 220,  80, 255)
local C_BG     = Color.new( 18,  18,  28, 255)
local C_GRID   = Color.new( 50,  50,  70, 255)
local C_CURSOR = Color.new( 80, 180, 255, 255)
local C_WIRE   = Color.new(220, 220, 220, 120)

local SCREEN_W = 960
local SCREEN_H = 544

-- ============================================================
-- LOAD TEXTURE + PRIMITIVES
-- ============================================================
local tex = Graphics.loadImage("app0:/tex.png")
if tex == nil then
    while true do
        Graphics.initBlend()
        Screen.clear(C_BG)
        Graphics.debugPrint(10, 10, "ERROR: tex.png missing", C_RED)
        Graphics.termBlend()
        Screen.flip()
        Screen.waitVblankStart()
    end
end

local PRIM_NAMES = {
    "cube","slab","prism","wedge","corner_wedge",
    "pyramid","roof_ridge","cylinder","cone","sphere","stairs"
}
local prims = {}
for i, name in ipairs(PRIM_NAMES) do
    prims[i] = Render.loadObject("app0:/" .. name .. ".obj", tex)
end

if prims[1] == nil then
    while true do
        Graphics.initBlend()
        Screen.clear(C_BG)
        Graphics.debugPrint(10, 10, "ERROR: cube.obj missing", C_RED)
        Graphics.termBlend()
        Screen.flip()
        Screen.waitVblankStart()
    end
end

-- ============================================================
-- COLOR TEXTURES
-- ============================================================
local COLOR_NAMES = {
    "white","red","orange","yellow","green","cyan",
    "blue","purple","pink","brown","grey","dark"
}
local colorTextures = {}
for i, name in ipairs(COLOR_NAMES) do
    colorTextures[i] = Graphics.loadImage("app0:/col_" .. name .. ".png")
end
local hasColors = (colorTextures[1] ~= nil)

local COLOR_SWATCHES = {
    Color.new(255,255,255,255), Color.new(220, 50, 50,255),
    Color.new(240,150, 30,255), Color.new(255,220, 50,255),
    Color.new( 50,200, 80,255), Color.new( 50,200,220,255),
    Color.new( 60,100,240,255), Color.new(160, 60,220,255),
    Color.new(240,100,180,255), Color.new(140, 90, 50,255),
    Color.new(140,140,140,255), Color.new( 50, 50, 60,255),
}

local COLOR_RGB = {
    {1.000,1.000,1.000}, {0.863,0.196,0.196}, {0.941,0.588,0.118},
    {1.000,0.863,0.196}, {0.196,0.784,0.314}, {0.196,0.784,0.863},
    {0.235,0.392,0.941}, {0.627,0.235,0.863}, {0.941,0.392,0.706},
    {0.549,0.353,0.196}, {0.549,0.549,0.549}, {0.196,0.196,0.235},
}

-- ============================================================
-- PRIMITIVE GEOMETRY (for OBJ export)
-- verts={{x,y,z},...} faces={{v1,v2,v3[,v4]},...} 1-indexed
-- ============================================================
local PRIM_GEO = {}

PRIM_GEO["cube"] = { verts = {
    {-0.5,-0.5,-0.5},{0.5,-0.5,-0.5},{0.5,-0.5,0.5},{-0.5,-0.5,0.5},
    {-0.5,0.5,-0.5},{0.5,0.5,-0.5},{0.5,0.5,0.5},{-0.5,0.5,0.5},
}, faces = {{1,2,3,4},{5,8,7,6},{1,5,6,2},{3,7,8,4},{1,4,8,5},{2,6,7,3}} }

PRIM_GEO["slab"] = { verts = {
    {-0.5,-0.5,-0.5},{0.5,-0.5,-0.5},{0.5,-0.5,0.5},{-0.5,-0.5,0.5},
    {-0.5,0.0,-0.5},{0.5,0.0,-0.5},{0.5,0.0,0.5},{-0.5,0.0,0.5},
}, faces = {{1,2,3,4},{5,8,7,6},{1,5,6,2},{3,7,8,4},{1,4,8,5},{2,6,7,3}} }

PRIM_GEO["prism"] = { verts = {
    {-0.5,-0.5,-0.5},{0.5,-0.5,-0.5},{0.0,0.5,-0.5},
    {-0.5,-0.5,0.5},{0.5,-0.5,0.5},{0.0,0.5,0.5},
}, faces = {{1,2,3},{4,6,5},{1,4,5,2},{2,5,6,3},{1,3,6,4}} }

PRIM_GEO["wedge"] = { verts = {
    {-0.5,-0.5,-0.5},{0.5,-0.5,-0.5},{0.5,0.5,-0.5},{-0.5,0.5,-0.5},
    {-0.5,-0.5,0.5},{0.5,-0.5,0.5},
}, faces = {{1,2,3,4},{1,5,6,2},{1,4,5},{2,6,3},{4,3,6,5}} }

PRIM_GEO["corner_wedge"] = { verts = {
    {-0.5,-0.5,-0.5},{0.5,-0.5,-0.5},{0.5,-0.5,0.5},{-0.5,-0.5,0.5},
    {-0.5,0.5,-0.5},
}, faces = {{1,2,3,4},{1,5,2},{1,4,5},{4,3,2,5}} }

PRIM_GEO["pyramid"] = { verts = {
    {-0.5,-0.5,-0.5},{0.5,-0.5,-0.5},{0.5,-0.5,0.5},{-0.5,-0.5,0.5},
    {0.0,0.5,0.0},
}, faces = {{1,2,3,4},{1,2,5},{2,3,5},{3,4,5},{4,1,5}} }

PRIM_GEO["roof_ridge"] = { verts = {
    {-0.5,-0.5,-0.5},{0.5,-0.5,-0.5},{0.5,-0.5,0.5},{-0.5,-0.5,0.5},
    {0.0,0.5,-0.5},{0.0,0.5,0.5},
}, faces = {{1,2,3,4},{1,2,5},{3,4,6},{2,3,6,5},{4,1,5,6}} }

local function makeCircular(sides, makeTop)
    local v, f = {}, {}
    local step = 2 * math.pi / sides
    for i = 0, sides-1 do
        local a = i * step
        v[#v+1] = {0.5*math.cos(a), -0.5, 0.5*math.sin(a)}
    end
    if makeTop then
        for i = 0, sides-1 do
            local a = i * step
            v[#v+1] = {0.5*math.cos(a), 0.5, 0.5*math.sin(a)}
        end
        for i = 1, sides do
            local j = (i%sides)+1
            f[#f+1] = {i, j, j+sides, i+sides}
        end
    else
        v[#v+1] = {0, 0.5, 0}
        local apex = #v
        for i = 1, sides do f[#f+1] = {i, (i%sides)+1, apex} end
    end
    for i = 2, sides-1 do f[#f+1] = {1, i+1, i} end
    if makeTop then
        for i = 2, sides-1 do f[#f+1] = {sides+1, sides+i, sides+i+1} end
    end
    return {verts=v, faces=f}
end
PRIM_GEO["cylinder"] = makeCircular(12, true)
PRIM_GEO["cone"]     = makeCircular(12, false)

local function makeSphere(lon, lat)
    local v, f = {}, {}
    v[#v+1] = {0,-0.5,0}
    for j = 1, lat-1 do
        local phi = math.pi * j / lat
        local y, r = -0.5*math.cos(phi), 0.5*math.sin(phi)
        for i = 0, lon-1 do
            local t = 2*math.pi*i/lon
            v[#v+1] = {r*math.cos(t), y, r*math.sin(t)}
        end
    end
    v[#v+1] = {0,0.5,0}
    local np = #v
    for i = 1, lon do f[#f+1] = {1, 1+i, 1+(i%lon)+1} end
    for j = 0, lat-3 do
        for i = 1, lon do
            local i2 = (i%lon)+1
            f[#f+1] = {1+j*lon+i, 1+j*lon+i2, 1+(j+1)*lon+i2, 1+(j+1)*lon+i}
        end
    end
    local last = 1+(lat-2)*lon
    for i = 1, lon do f[#f+1] = {last+i, np, last+(i%lon)+1} end
    return {verts=v, faces=f}
end
PRIM_GEO["sphere"] = makeSphere(8, 6)

local function makeStairs(steps)
    local v, f = {}, {}
    local sH, sD = 1.0/steps, 1.0/steps
    for s = 0, steps-1 do
        local y1 = -0.5+(s+1)*sH
        local z0, z1 = -0.5+s*sD, -0.5+(s+1)*sD
        local b = #v
        v[#v+1]={-0.5,-0.5,z0}; v[#v+1]={0.5,-0.5,z0}
        v[#v+1]={0.5,-0.5,z1};  v[#v+1]={-0.5,-0.5,z1}
        v[#v+1]={-0.5,y1,z0};   v[#v+1]={0.5,y1,z0}
        v[#v+1]={0.5,y1,z1};    v[#v+1]={-0.5,y1,z1}
        f[#f+1]={b+5,b+8,b+7,b+6}; f[#f+1]={b+1,b+5,b+6,b+2}
        f[#f+1]={b+1,b+4,b+8,b+5}; f[#f+1]={b+2,b+6,b+7,b+3}
        if s==0 then f[#f+1]={b+1,b+2,b+3,b+4} end
        if s==steps-1 then f[#f+1]={b+3,b+7,b+8,b+4} end
    end
    return {verts=v, faces=f}
end
PRIM_GEO["stairs"] = makeStairs(4)

-- ============================================================
-- STATE
-- ============================================================
local cursor    = { x=0, y=0, z=0 }
local primIdx   = 1
local blockRotY = 0
local blockRotX = 0
local colorIdx  = 1
local scene     = {}

local coolMove, coolPrim, coolRotY, coolRotX = 0, 0, 0, 0
local coolColor, coolPlace, coolDel, coolSave = 0, 0, 0, 0
local MOVE_CD, PRIM_CD, ROT_CD, COLOR_CD = 8, 12, 15, 10
local PLACE_CD, DEL_CD, SAVE_CD = 10, 10, 60

local GRID_MIN, GRID_MAX, GRID_H = -5, 5, 5
local saveMsg, saveMsgTTL = nil, 0

-- Menu state: nil=editor, "top"=save/load choice, "save"=pick slot, "load"=pick slot
local menuState = nil
local menuSel   = 1
local coolMenu  = 0
local MENU_CD   = 12

-- ============================================================
-- CAMERA
-- ============================================================
local camYaw, touchPrevX = 0.0, nil
local CAM_DIST, CAM_Y, CAM_PITCH, TOUCH_SENS = 8.0, 4.0, -0.45, 0.005

local function updateCamera()
    local cx = cursor.x + CAM_DIST * math.sin(camYaw)
    local cy = cursor.y + CAM_Y
    local cz = cursor.z + CAM_DIST * math.cos(camYaw)
    Render.setCamera(cx, cy, cz, CAM_PITCH, camYaw, 0.0)
end

-- ============================================================
-- 2D PROJECTION (45deg matches C-side)
-- ============================================================
local FOV, ASPECT, NEAR = math.pi/4.0, SCREEN_W/SCREEN_H, 0.1

local function projectPoint(wx, wy, wz)
    local camX = cursor.x + CAM_DIST * math.sin(camYaw)
    local camY = cursor.y + CAM_Y
    local camZ = cursor.z + CAM_DIST * math.cos(camYaw)
    local dx, dy, dz = wx-camX, wy-camY, wz-camZ
    local cosY, sinY = math.cos(-camYaw), math.sin(-camYaw)
    local rx, rz = cosY*dx + sinY*dz, -sinY*dx + cosY*dz
    local cosP, sinP = math.cos(-CAM_PITCH), math.sin(-CAM_PITCH)
    local fy = cosP*dy - sinP*rz
    local fz = sinP*dy + cosP*rz
    if fz >= -NEAR then return nil end
    local invZ = -1.0 / fz
    local thf = math.tan(FOV * 0.5)
    return (rx * invZ / (thf*ASPECT)) * (SCREEN_W*0.5) + SCREEN_W*0.5,
           (-fy * invZ / thf) * (SCREEN_H*0.5) + SCREEN_H*0.5
end

-- ============================================================
-- GRID
-- ============================================================
local function drawGrid()
    for gz = GRID_MIN, GRID_MAX do
        local ax,ay = projectPoint(GRID_MIN-0.5, 0, gz-0.5)
        local bx,by = projectPoint(GRID_MAX+0.5, 0, gz-0.5)
        if ax and bx then Graphics.drawLine(ax,bx,ay,by, C_GRID) end
    end
    for gx = GRID_MIN, GRID_MAX do
        local ax,ay = projectPoint(gx-0.5, 0, GRID_MIN-0.5)
        local bx,by = projectPoint(gx-0.5, 0, GRID_MAX+0.5)
        if ax and bx then Graphics.drawLine(ax,bx,ay,by, C_GRID) end
    end
    for _, c in ipairs({
        {GRID_MIN-0.5,GRID_MIN-0.5},{GRID_MAX+0.5,GRID_MIN-0.5},
        {GRID_MAX+0.5,GRID_MAX+0.5},{GRID_MIN-0.5,GRID_MAX+0.5},
    }) do
        local ax,ay = projectPoint(c[1], 0, c[2])
        local bx,by = projectPoint(c[1], GRID_H, c[2])
        if ax and bx then Graphics.drawLine(ax,bx,ay,by, C_GRID) end
    end
    -- Cursor cell highlight
    local y2 = cursor.y - 0.5
    local p = {}
    p[1] = {projectPoint(cursor.x-0.5, y2, cursor.z-0.5)}
    p[2] = {projectPoint(cursor.x+0.5, y2, cursor.z-0.5)}
    p[3] = {projectPoint(cursor.x+0.5, y2, cursor.z+0.5)}
    p[4] = {projectPoint(cursor.x-0.5, y2, cursor.z+0.5)}
    if p[1][1] and p[2][1] and p[3][1] and p[4][1] then
        for i = 1, 4 do
            local j = (i % 4) + 1
            Graphics.drawLine(p[i][1],p[j][1],p[i][2],p[j][2], C_CURSOR)
        end
    end
end

-- ============================================================
-- WIREFRAME
-- ============================================================
local CUBE_V = {
    {-0.5,-0.5,-0.5},{0.5,-0.5,-0.5},{0.5,-0.5,0.5},{-0.5,-0.5,0.5},
    {-0.5,0.5,-0.5},{0.5,0.5,-0.5},{0.5,0.5,0.5},{-0.5,0.5,0.5},
}
local CUBE_E = {
    {1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8},
}

local function rotVert(vx, vy, vz, rX, rY)
    local ry = math.rad(rY)
    local cy, sy = math.cos(ry), math.sin(ry)
    local nx, nz = cy*vx + sy*vz, -sy*vx + cy*vz
    local rx = math.rad(rX)
    local cx, sx = math.cos(rx), math.sin(rx)
    return nx, cx*vy - sx*nz, sx*vy + cx*nz
end

local function drawBlockWire(blk)
    local proj = {}
    for i, v in ipairs(CUBE_V) do
        local rx,ry,rz = rotVert(v[1],v[2],v[3], blk.rotX, blk.rotY)
        proj[i] = {projectPoint(blk.x+rx, blk.y+ry, blk.z+rz)}
    end
    for _, e in ipairs(CUBE_E) do
        local a, b = proj[e[1]], proj[e[2]]
        if a[1] and b[1] then Graphics.drawLine(a[1],b[1],a[2],b[2], C_WIRE) end
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
local function blockKey(x,y,z) return x..","..y..","..z end
local function analogAxis(v)
    local d = v - 127
    if math.abs(d) < 30 then return 0 end
    return d > 0 and 1 or -1
end

-- ============================================================
-- DEPTH-SORTED DRAWING
-- ============================================================
local function drawScene()
    local sorted = {}
    for _, blk in pairs(scene) do sorted[#sorted+1] = blk end
    local cx = cursor.x + CAM_DIST*math.sin(camYaw)
    local cy = cursor.y + CAM_Y
    local cz = cursor.z + CAM_DIST*math.cos(camYaw)
    table.sort(sorted, function(a, b)
        return (a.x-cx)^2+(a.y-cy)^2+(a.z-cz)^2 > (b.x-cx)^2+(b.y-cy)^2+(b.z-cz)^2
    end)
    for _, blk in ipairs(sorted) do
        local mdl = prims[blk.prim]
        if mdl then
            if hasColors and colorTextures[blk.col] then
                Render.useTexture(mdl, colorTextures[blk.col])
            end
            Render.drawModel(mdl, blk.x, blk.y, blk.z, blk.rotX, blk.rotY, 0.0)
        end
    end
    for _, blk in ipairs(sorted) do drawBlockWire(blk) end
end

-- ============================================================
-- PROJECT SAVE / LOAD
-- ============================================================
local SAVE_DIR = "ux0:data/ObjForge"

local function ensureSaveDir()
    System.createDirectory(SAVE_DIR)
end

local function slotPath(n)
    return SAVE_DIR .. "/slot" .. n .. ".lua"
end

local function slotExists(n)
    return System.doesFileExist(slotPath(n))
end

local function slotInfo(n)
    if not slotExists(n) then return "Empty" end
    local f = io.open(slotPath(n), "r")
    if not f then return "Empty" end
    local count = 0
    for line in f:lines() do
        if string.sub(line, 1, 1) == "{" then count = count + 1 end
    end
    f:close()
    return count .. " blocks"
end

local function saveSlot(n)
    ensureSaveDir()
    local count = 0
    for _ in pairs(scene) do count = count + 1 end
    if count == 0 then return false, "Scene is empty" end
    local f = io.open(slotPath(n), "w")
    if not f then return false, "Cannot write" end
    f:write("return {\n")
    for _, blk in pairs(scene) do
        f:write(string.format("{%d,%d,%d,%d,%d,%d,%d},\n",
            blk.prim, blk.x, blk.y, blk.z, blk.rotY, blk.rotX, blk.col))
    end
    f:write("}\n")
    f:close()
    return true, count .. " blocks saved"
end

local function loadSlot(n)
    if not slotExists(n) then return false, "Slot empty" end
    local data = dofile(slotPath(n))
    if type(data) ~= "table" then return false, "Bad file" end
    scene = {}
    for _, row in ipairs(data) do
        local blk = {
            prim=row[1], x=row[2], y=row[3], z=row[4],
            rotY=row[5], rotX=row[6], col=row[7]
        }
        scene[blockKey(blk.x, blk.y, blk.z)] = blk
    end
    return true, #data .. " blocks loaded"
end

local function deleteSlot(n)
    if slotExists(n) then
        System.deleteFile(slotPath(n))
        return true, "Slot deleted"
    end
    return false, "Slot empty"
end

-- ============================================================
-- OBJ / MTL EXPORT
-- ============================================================

local function exportScene()
    ensureSaveDir()
    local count = 0
    for _ in pairs(scene) do count = count + 1 end
    if count == 0 then return false, "Scene is empty" end

    local mf = io.open(SAVE_DIR.."/scene.mtl", "w")
    if not mf then return false, "Cannot write MTL" end
    mf:write("# ObjForge materials\n")
    for i, name in ipairs(COLOR_NAMES) do
        local r,g,b = COLOR_RGB[i][1], COLOR_RGB[i][2], COLOR_RGB[i][3]
        mf:write("\nnewmtl "..name.."\n")
        mf:write(string.format("Ka %.3f %.3f %.3f\n", r*0.2, g*0.2, b*0.2))
        mf:write(string.format("Kd %.3f %.3f %.3f\n", r, g, b))
        mf:write("Ks 0.1 0.1 0.1\nNs 32.0\nd 1.0\n")
    end
    mf:close()

    local of = io.open(SAVE_DIR.."/scene.obj", "w")
    if not of then return false, "Cannot write OBJ" end
    of:write("# ObjForge export\nmtllib scene.mtl\n\n")
    local vOff = 0
    local byColor = {}
    for _, blk in pairs(scene) do
        local c = blk.col or 1
        if not byColor[c] then byColor[c] = {} end
        byColor[c][#byColor[c]+1] = blk
    end
    for ci, name in ipairs(COLOR_NAMES) do
        if byColor[ci] then
            of:write("usemtl "..name.."\n")
            for _, blk in ipairs(byColor[ci]) do
                local geo = PRIM_GEO[PRIM_NAMES[blk.prim]]
                if geo then
                    for _, v in ipairs(geo.verts) do
                        local rx,ry,rz = rotVert(v[1],v[2],v[3], blk.rotX, blk.rotY)
                        of:write(string.format("v %.4f %.4f %.4f\n", blk.x+rx, blk.y+ry, blk.z+rz))
                    end
                    for _, face in ipairs(geo.faces) do
                        of:write("f")
                        for _, fi in ipairs(face) do of:write(" "..(fi+vOff)) end
                        of:write("\n")
                    end
                    vOff = vOff + #geo.verts
                end
            end
        end
    end
    of:close()
    return true, count.." blocks saved"
end

-- ============================================================
-- HUD
-- ============================================================
local function drawHUD()
    -- Modified top row: Prim Name + Coords + Rotation (Simple concatenation)
    local pName = PRIM_NAMES[primIdx]
    local topRow = pName .. "  X:"..cursor.x.." Y:"..cursor.y.." Z:"..cursor.z.."  RY:"..blockRotY.." RX:"..blockRotX
    
    Graphics.debugPrint(5, 5, topRow, C_WHITE)

    -- Color info moved up
    Graphics.debugPrint(5, 25, "Color: "..COLOR_NAMES[colorIdx], COLOR_SWATCHES[colorIdx])
    
    local swW, swH, swY = 14, 10, 40
    for i = 1, #COLOR_NAMES do
        local sx = 5 + (i-1) * (swW+2)
        Graphics.fillRect(sx, sx+swW, swY, swY+swH, COLOR_SWATCHES[i])
        if i == colorIdx then
            Graphics.drawLine(sx, sx+swW, swY-1, swY-1, C_CURSOR)
            Graphics.drawLine(sx, sx+swW, swY+swH, swY+swH, C_CURSOR)
        end
    end

    if saveMsg and saveMsgTTL > 0 then
        local c = string.sub(saveMsg,1,3)=="ERR" and C_RED or C_GREEN
        Graphics.debugPrint(5, 55, saveMsg, c)
    end

    Graphics.debugPrint(5, 520,
        "LS:move DU/DD:Y LR:prim Tri:rotY O:rotX X:place Sq:del DL/DR:col Start:obj Sel:menu", C_GREY)
end

-- ============================================================
-- MENU OVERLAY
-- ============================================================
local function drawMenu()
    -- Dim background
    Graphics.fillRect(0, SCREEN_W, 0, SCREEN_H, Color.new(0,0,0,180))

    local mx, my = 330, 160
    local mw, mh = 300, 220

    Graphics.fillRect(mx, mx+mw, my, my+mh, Color.new(30,30,45,255))
    Graphics.debugPrint(mx+10, my+10, "ObjForge", C_YELLOW)

    if menuState == "top" then
        Graphics.debugPrint(mx+10, my+40, "Select:", C_WHITE)
        local items = {"Save Project", "Load Project"}
        for i, label in ipairs(items) do
            local col = (i == menuSel) and C_CURSOR or C_GREY
            local pre = (i == menuSel) and "> " or "  "
            Graphics.debugPrint(mx+20, my+60+(i-1)*20, pre..label, col)
        end
        Graphics.debugPrint(mx+10, my+mh-25, "DU/DD:pick  X:select  Select:back", C_GREY)

    elseif menuState == "save" or menuState == "load" then
        local title = menuState == "save" and "Save to Slot" or "Load from Slot"
        Graphics.debugPrint(mx+10, my+40, title, C_WHITE)
        for i = 1, 3 do
            local info = slotInfo(i)
            local col = (i == menuSel) and C_CURSOR or C_GREY
            local pre = (i == menuSel) and "> " or "  "
            Graphics.debugPrint(mx+20, my+60+(i-1)*20, pre.."Slot "..i..": "..info, col)
        end
        local act = menuState == "save" and "X:save" or "X:load"
        Graphics.debugPrint(mx+10, my+mh-25, "DU/DD:pick  "..act.."  O:delete  Select:back", C_GREY)
    end
end

-- ============================================================
-- MAIN LOOP
-- ============================================================
while true do
    local pad = Controls.read()
    local lx, ly = Controls.readLeftAnalog()
    local lxA, lyA = analogAxis(lx), analogAxis(ly)

    if coolMove  > 0 then coolMove  = coolMove  - 1 end
    if coolPrim  > 0 then coolPrim  = coolPrim  - 1 end
    if coolRotY  > 0 then coolRotY  = coolRotY  - 1 end
    if coolRotX  > 0 then coolRotX  = coolRotX  - 1 end
    if coolColor > 0 then coolColor = coolColor - 1 end
    if coolPlace > 0 then coolPlace = coolPlace - 1 end
    if coolDel   > 0 then coolDel   = coolDel   - 1 end
    if coolSave  > 0 then coolSave  = coolSave  - 1 end
    if coolMenu  > 0 then coolMenu  = coolMenu  - 1 end
    if saveMsgTTL > 0 then saveMsgTTL = saveMsgTTL - 1 end

    if menuState then
        -- ============ MENU INPUT ============
        if coolMenu == 0 then
            if Controls.check(pad, SCE_CTRL_SELECT) then
                -- Back: from save/load go to top, from top close menu
                if menuState == "save" or menuState == "load" then
                    menuState = "top"; menuSel = 1
                else
                    menuState = nil
                end
                coolMenu = MENU_CD

            elseif Controls.check(pad, SCE_CTRL_UP) then
                menuSel = menuSel - 1
                if menuSel < 1 then
                    menuSel = (menuState == "top") and 2 or 3
                end
                coolMenu = MENU_CD

            elseif Controls.check(pad, SCE_CTRL_DOWN) then
                menuSel = menuSel + 1
                local max = (menuState == "top") and 2 or 3
                if menuSel > max then menuSel = 1 end
                coolMenu = MENU_CD

            elseif Controls.check(pad, SCE_CTRL_CROSS) then
                if menuState == "top" then
                    menuState = (menuSel == 1) and "save" or "load"
                    menuSel = 1
                elseif menuState == "save" then
                    local ok, msg = saveSlot(menuSel)
                    saveMsg = ok and ("Saved: "..msg) or ("ERR: "..msg)
                    saveMsgTTL = 120
                    menuState = nil
                elseif menuState == "load" then
                    local ok, msg = loadSlot(menuSel)
                    saveMsg = ok and ("Loaded: "..msg) or ("ERR: "..msg)
                    saveMsgTTL = 120
                    menuState = nil
                end
                coolMenu = MENU_CD

            elseif Controls.check(pad, SCE_CTRL_CIRCLE) then
                if menuState == "save" or menuState == "load" then
                    local ok, msg = deleteSlot(menuSel)
                    saveMsg = ok and msg or ("ERR: "..msg)
                    saveMsgTTL = 120
                end
                coolMenu = MENU_CD
            end
        end
    else
        -- ============ EDITOR INPUT ============
        -- Touch orbit
        local tx, ty = Controls.readTouch()
        if tx then
            if touchPrevX then camYaw = camYaw + (tx - touchPrevX) * TOUCH_SENS end
            touchPrevX = tx
        else
            touchPrevX = nil
        end

        -- Cursor XZ (camera-relative)
        if coolMove == 0 and (lxA ~= 0 or lyA ~= 0) then
            local fwdX, fwdZ = -math.sin(camYaw), -math.cos(camYaw)
            local rightX, rightZ = math.cos(camYaw), -math.sin(camYaw)
            local mx = lxA*rightX - lyA*fwdX
            local mz = lxA*rightZ - lyA*fwdZ
            if mx > 0.3 then mx=1 elseif mx < -0.3 then mx=-1 else mx=0 end
            if mz > 0.3 then mz=1 elseif mz < -0.3 then mz=-1 else mz=0 end
            local moved = false
            if mx ~= 0 and cursor.x+mx >= GRID_MIN and cursor.x+mx <= GRID_MAX then
                cursor.x = cursor.x + mx; moved = true
            end
            if mz ~= 0 and cursor.z+mz >= GRID_MIN and cursor.z+mz <= GRID_MAX then
                cursor.z = cursor.z + mz; moved = true
            end
            if moved then coolMove = MOVE_CD end
        end

        -- Cursor Y
        if coolMove == 0 then
            if Controls.check(pad, SCE_CTRL_UP) and cursor.y < GRID_H then
                cursor.y = cursor.y + 1; coolMove = MOVE_CD
            elseif Controls.check(pad, SCE_CTRL_DOWN) and cursor.y > 0 then
                cursor.y = cursor.y - 1; coolMove = MOVE_CD
            end
        end

        -- Primitive select
        if coolPrim == 0 then
            if Controls.check(pad, SCE_CTRL_LTRIGGER) then
                primIdx = ((primIdx-2) % #PRIM_NAMES) + 1; coolPrim = PRIM_CD
            elseif Controls.check(pad, SCE_CTRL_RTRIGGER) then
                primIdx = (primIdx % #PRIM_NAMES) + 1; coolPrim = PRIM_CD
            end
        end

        -- Rotation
        if coolRotY == 0 and Controls.check(pad, SCE_CTRL_TRIANGLE) then
            blockRotY = (blockRotY + 90) % 360; coolRotY = ROT_CD
        end
        if coolRotX == 0 and Controls.check(pad, SCE_CTRL_CIRCLE) then
            blockRotX = (blockRotX + 90) % 360; coolRotX = ROT_CD
        end

        -- Color select
        if coolColor == 0 then
            if Controls.check(pad, SCE_CTRL_LEFT) then
                colorIdx = ((colorIdx-2) % #COLOR_NAMES) + 1; coolColor = COLOR_CD
            elseif Controls.check(pad, SCE_CTRL_RIGHT) then
                colorIdx = (colorIdx % #COLOR_NAMES) + 1; coolColor = COLOR_CD
            end
        end

        -- Place
        if coolPlace == 0 and Controls.check(pad, SCE_CTRL_CROSS) then
            scene[blockKey(cursor.x, cursor.y, cursor.z)] = {
                prim=primIdx, x=cursor.x, y=cursor.y, z=cursor.z,
                rotY=blockRotY, rotX=blockRotX, col=colorIdx
            }
            coolPlace = PLACE_CD
        end

        -- Delete
        if coolDel == 0 and Controls.check(pad, SCE_CTRL_SQUARE) then
            scene[blockKey(cursor.x, cursor.y, cursor.z)] = nil
            coolDel = DEL_CD
        end

        -- OBJ Export (Start)
        if coolSave == 0 and Controls.check(pad, SCE_CTRL_START) then
            local ok, msg = exportScene()
            saveMsg = ok and ("Saved: "..msg) or ("ERR: "..msg)
            saveMsgTTL = 120
            coolSave = SAVE_CD
        end

        -- Open menu (Select)
        if coolMenu == 0 and Controls.check(pad, SCE_CTRL_SELECT) then
            menuState = "top"
            menuSel = 1
            coolMenu = MENU_CD
        end
    end

    -- ==================== RENDER ====================
    Graphics.initBlend()
    Screen.clear(C_BG)
    updateCamera()
    drawScene()

    if prims[primIdx] then
        if hasColors and colorTextures[colorIdx] then
            Render.useTexture(prims[primIdx], colorTextures[colorIdx])
        end
        Render.drawModel(prims[primIdx], cursor.x, cursor.y, cursor.z,
                         blockRotX, blockRotY, 0.0)
        drawBlockWire({x=cursor.x, y=cursor.y, z=cursor.z, rotX=blockRotX, rotY=blockRotY})
    end

    drawGrid()
    drawHUD()
    if menuState then drawMenu() end
    Graphics.termBlend()
    Screen.flip()
    Screen.waitVblankStart()
end