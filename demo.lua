if SERVER then AddCSLuaFile("SpinnerObject.lua") end
if CLIENT then SpinnerObject = include("SpinnerObject.lua") end
if SERVER then return end
local bg = vgui.Create("DFrame")
bg:SetSize(300, 100)
bg:Center()
bg:MakePopup()
bg:SetTitle("Spinner demo")
bg:DockPadding(15, 30, 15, 20)

local image = vgui.Create("DImage")
image:SetParent(bg)
image:Dock(LEFT)
image:DockMargin(0, 0, 10, 0)
image:SetImage("flags16/wales.png")

local SpinnerButton = vgui.Create("DButton")
SpinnerButton:SetParent(bg)
SpinnerButton:Dock(RIGHT)
SpinnerButton:DockMargin(10, 15, 0, 15)
SpinnerButton:SetText("Spin me!")
SpinnerButton:SizeToContents()

local valueLabel = vgui.Create("DLabel")
valueLabel:SetParent(bg)
valueLabel:Dock(LEFT)
valueLabel:SetText("Aucun :(")

local cooldownLabel = vgui.Create("DLabel")
cooldownLabel:SetParent(bg)
cooldownLabel:Dock(RIGHT)
cooldownLabel:SetText("image.scroller.time")

local cooldownIndicator = vgui.Create("DPanel")
cooldownIndicator:SetParent(bg)
cooldownIndicator:SetPos(0,bg:GetTall()-5-9)
cooldownIndicator:SetSize(bg:GetWide()-10,5)
cooldownIndicator:CenterHorizontal()
cooldownIndicator.Paint = function(self, w, h)
    local function lerp(a, b, t)
        return a + (b - a) * t
    end

    local function getGradientColor(value, max_value, colorStart, colorEnd)
        if not value or not max_value or max_value == 0 then
            return colorStart.r, colorStart.g, colorStart.b 
        end
        local t = value / max_value
        local r = lerp(colorStart.r, colorEnd.r, t)
        local g = lerp(colorStart.g, colorEnd.g, t)
        local b = lerp(colorStart.b, colorEnd.b, t)
        return r, g, b
    end
    local current_time = image.scroller:getCurtime()
    local max_time = image.scroller:getTimer()
    local colorStart = Color(153, 0, 255)
    local colorEnd = Color(0, 255, 170)
    if not current_time or not max_time then
        surface.SetDrawColor(colorStart)
        surface.DrawRect(0, 0, self:GetWide(), h)
        return
    end
    local r, g, b = getGradientColor(current_time, max_time, colorStart, colorEnd)
    surface.SetDrawColor(r, g, b)
    surface.DrawRect(0, 0, self:GetWide(), h)
end


local SpinnerMeta = {}
SpinnerMeta.data = { 
    {image = "flags16/ca.png"},
    {image = "flags16/fr.png"},
    {image = "flags16/england.png"},
    {image = "flags16/ru.png"},
    {image = "flags16/us.png"} 
}
SpinnerMeta.timer = 30
SpinnerMeta.speed = 0.01
SpinnerMeta.ratio = {
    [0] = 1.0,
    [1] = 0.8,
    [2] = 0.6,
    [3] = 0.5,
    [4] = 0.4,
    [5] = 0.3,
    [6] = 0.2,
    [7] = 0.15,
    [8] = 0.1,
    [9] = 0.08,
    [10] = 0.06,
    [11] = 0.05,
    [12] = 0.04,
    [13] = 0.03,
    [14] = 0.02,
    [15] = 0.015,
    [16] = 0.01,
    [17] = 0.01,
    [18] = 0.01,
    [19] = 0.01,
    [20] = 0.01,
    [21] = 0.05,
    [22] = 0.04,
    [23] = 0.03,
    [24] = 0.02,
    [25] = 0.015,
    [26] = 0.8,
    [27] = 0.8,
    [28] = 0.8,
    [29] = 0.01,
    [30] = 0.01
}
SpinnerMeta.void = function(self)
    chat.AddText(
        Color(255,0,0),
        self:getSpin() .. " => ",
        Color(255,255,255),
        "This is the result : ",
        Color(0,255,0),
        self:getValue().image
    ) 
end
SpinnerMeta.isSlideMode = true
SpinnerMeta.isFinishImage = "flags16/wales.png" --set nil this or delay if you d'ont want to use this
SpinnerMeta.isFinishDelay = 0.5 --set nil this or image if you d'ont want to use this
SpinnerObject(image, --DImage panel
    valueLabel, --DLabel output selected    --facultatif
    cooldownLabel, --DLabel cooldown (timer) --facultatif
    SpinnerButton, --DButton to launch spinner
    cooldownIndicator, --DPanel that contain progressive bar --facultatif
    SpinnerMeta.data, --Table data. for each index (use numeric) set a key image with the image to get
    SpinnerMeta.timer, --number timer to spin
    SpinnerMeta.speed, --default speed
    SpinnerMeta.ratio, --speed control beetwem each index statement of timer
    SpinnerMeta.void, --void function when is finish to spin
    SpinnerMeta.isSlideMode, --boolean is slidemode or not
    SpinnerMeta.isFinishImage,SpinnerMeta.isFinishDelay --string, number data when scroller is finish to reset a image after x time --facultatif
)
function bg.btnClose:DoClick() self:GetParent():Remove() image.scroller:performeClose() end
function SpinnerButton:DoClick() image.scroller:start() end
