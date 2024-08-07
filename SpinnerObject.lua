if SERVER then return end
SpinnerMetaAtrribut = {
    __data = {},
        setData = function(self,data) self.__data = data end,
        getData = function(self) return self.__data end,
    __default = { image = nil, delay = nil},
        setDefault = function(self,image,delay) self.__default["image"] = image ; self.__default["delay"] = delay end,
        getDefaultImage = function(self) return self.__default["image"] end,
        getDefaultCoolDown = function(self) return self.__default["delay"] end,
        isDefaultSet = function(self) return self.__default["image"] != nil end,
        unsetDefault = function(self) self.__default["image"] = nil ; self.__default["delay"] = nil end,
    __spin = 0,
        setSpin = function(self,spin) self.__spin = spin end,
        getSpin = function(self) return self.__spin end, 
    __timer = 5,
        setTimer = function(self,timer) self.__timer = timer end,
        getTimer = function(self) return self.__timer end,
    __speed = 0.5,
        overrideSpeed = function(self,speed) self.__speed = speed end,
        setSpeed = function(self,speed) self.__speed = (speed >= 0.01 and speed <= 1) and speed or 0.5 end,
        getSpeed = function(self) return self.__speed end,
    __ratio = {},
        setRatio = function(self,ratio) self.__ratio = ratio end,
        getRatio = function(self) return self.__ratio end,
    __speedMemory = 0.5,
        setSpeedMemory = function(self,speed) self.__speedMemory = speed end,
        getSpeedMemory = function(self) return self.__speedMemory end,
    __DImage = nil,
        setImage = function(self,DImage) self.__DImage = DImage end,
        getImage = function(self) return self.__DImage end,
    __DSelected = nil,
        setSelected = function(self,DLabel) self.__DSelected = DLabel end,
        getSelected = function(self) return self.__DSelected end,
    __DCoolDown = nil,
        setCoolDown = function(self,DLabel) self.__DCoolDown = DLabel end,
        getCoolDown = function(self) return self.__DCoolDown end,
    __DIndicator = nil,
        setIndicator = function(self,DPanel) self.__DIndicator = DPanel end,
        getIndicator = function(self) return self.__DIndicator end,
    __DIndicatorMemory = nil,
        setIndicatorMemory = function(self,value) self.__DIndicatorMemory = value end,
        getIndicatorMemory = function(self) return self.__DIndicatorMemory end,
    __DButton = nil,
        setButton = function(self,DButton) self.__DButton = DButton end,
        getButton = function(self) return self.__DButton end,
    __pointer = 1,
        randomPointer = function(self) self.__pointer = math.random(1,#self:getData()) end,
        getPointer = function(self) return self.__pointer end,
    __curtime = 0,
        incrementCurtime = function(self, amount)self.__curtime = self.__curtime + amount end,
        setCurtime = function(self,curtime) self.__curtime = curtime end,
        getCurtime = function(self) return self.__curtime end,
    __slideMode = false,
        toggleMode = function(self) self.__slideMode = not self.__slideMode end,
        isSlideMode = function(self) return self.__slideMode == true end,
        setNoSlideMode = function(self) self.__slideMode = false end,
        setSlideMode = function(self) self.__slideMode = true end,
    performeClose = function(self)
        if (timer.Exists("SpinnerObject::Timer => spin")) then
            timer.Remove("SpinnerObject::Timer => spin")
        end
    end,
    start = function(self)
        if (#self:getData() == 0) then return ErrorNoHalt("SpinnerObject::start => Can't spin an empty list") end
        self:getButton():SetDisabled(true)
        self:setCurtime(self:getTimer())
        timer.Create("SpinnerObject::Timer => spin",
        self:getSpeed(),self:getTimer() / self:getSpeed(),function()
            self:update()
                local CURRENT = tonumber(string.format("%.0f", math.max(self:getCurtime() or self:getTimer(), 0)))
            if (self:getCurtime() == nil or self:getTimer() == nil) then
                self:setSpeed(self:getSpeedMemory())
            else
                local index = math.floor(CURRENT / 1 )
                local MAX = self:getRatio()[index] or self:getRatio()[0]
                local MIN = 0.01
                local timerVal = self:getTimer()
                local elapsed = self:getCurtime() - timerVal * 0.1
                local duration = timerVal - timerVal * 0.1
                local ratio = 1 - (math.max(elapsed, 0) / duration)
                self:setSpeed(MIN + (MAX - MIN) * ratio)
            end
            timer.Adjust("SpinnerObject::Timer => spin", self:getSpeed(), nil, nil)
        end)
    end,
    stop = function(self)
        if (CURRENT) then CURRENT = nil end
        self:setSpin(self:getSpin() + 1)
        self:getImage():SetImage(self:getValue().image)
        if (IsValid(self:getSelected())) then
            timer.Simple(0.01, function()
                self:getSelected():SetText(self:getValue().image)
                self:getSelected():SizeToContents()
            end)
        end
        self:WhenIsFinish()
        self:getButton():SetDisabled(false)
        self:setCurtime(nil)
        timer.Remove("SpinnerObject::Timer => spin")
        if (self:isDefaultSet()) then
            timer.Simple(self:getDefaultCoolDown(),function()
                self:getImage():SetImage(self:getDefaultImage())
                if (IsValid(self:getSelected())) then self:getSelected():SetText("") end
                if (IsValid(self:getCoolDown())) then self:getCoolDown():SetText("") end
                if (IsValid(self:getIndicator())) then self:getIndicator():SetWide(self:getIndicatorMemory()) end
            end)
        else
            if (IsValid(self:getIndicator())) then self:getIndicator():SetWide(self:getIndicatorMemory()) end
        end
    end,
    update = function(self)
        if (self:isSlideMode()) then
            if not IsValid(currentImage) then
                currentImage = vgui.Create("DImage", self:getImage())
                currentImage:SetImage(self:getValue().image)
                currentImage:SetSize(self:getImage():GetWide(), self:getImage():GetTall())
                currentImage:SetPos(0, 0)
            end
            if not IsValid(nextImage) then
                self:randomPointer()
                nextImage = vgui.Create("DImage", self:getImage())
                nextImage:SetImage(self:getValue().image)
                nextImage:SetSize(self:getImage():GetWide(), self:getImage():GetTall())
                nextImage:SetPos(-self:getImage():GetWide(), 0)
            end
            local moveSpeed = 25
            local curX, curY = currentImage:GetPos()
            local nextX, nextY = nextImage:GetPos()
            currentImage:SetPos(curX + moveSpeed, curY)
            nextImage:SetPos(nextX + moveSpeed, nextY)
            self:incrementCurtime(-self:getSpeed())
            if (IsValid(self:getCoolDown())) then
                self:getCoolDown():SetText(string.format("%.0f", math.max(self:getCurtime(), 0)))
                self:getCoolDown():SizeToContents()
            end
            if (IsValid(self:getIndicator())) then
                self:getIndicator():SetWide((self:getIndicatorMemory() * (math.max(self:getCurtime(), 0) / self:getTimer())))
            end
            if curX >= self:getImage():GetWide() then
                currentImage:Remove()
                currentImage = nextImage
                currentImage:SetPos(0, 0)
                self:getImage():SetImage(self:getValue().image)
                if (IsValid(self:getSelected())) then
                    self:getSelected():SetText(self:getValue().image)
                    self:getSelected():SizeToContents()
                end
                self:randomPointer()
                nextImage = vgui.Create("DImage", self:getImage())
                nextImage:SetImage(self:getValue().image)
                nextImage:SetSize(self:getImage():GetWide(), self:getImage():GetTall())
                nextImage:SetPos(-self:getImage():GetWide(), 0)
            end
            if math.max(self:getCurtime(), 0) <= 0.1 then
                currentImage:Remove()
                nextImage:Remove()
                self:stop()
            end
        else
            self:randomPointer()
            self:getImage():SetImage(self:getValue().image)
            self:incrementCurtime(-self:getSpeed())
            if (IsValid(self:getCoolDown())) then
                self:getCoolDown():SetText(string.format("%.0f",math.max(self:getCurtime(),0)))
                self:getCoolDown():SizeToContents()
            end
            if (IsValid(self:getSelected())) then
                self:getSelected():SetText(self:getValue().image)
                self:getSelected():SizeToContents()
            end
            if (IsValid(self:getIndicator())) then
                self:getIndicator():SetWide((self:getIndicatorMemory() * (math.max(self:getCurtime(), 0) / self:getTimer())))
            end
            if (math.max(self:getCurtime(),0) <= 0.1) then
                self:stop()
            end
        end
    end,
    getValue = function(self)
        return self:getData()[self:getPointer()] or "SpinnerObject:getValue() => ?"
    end,
    WhenIsFinish = function(self)
        chat.AddText(Color(255,255,255),"This is the result : ",Color(0,255,0),self:getValue().image)
    end
}
SpinnerMetaMethode = {}
SpinnerMetaMethode["__call"] = function(self,
    DImage,DLabelSelected,DLabelTimer,DButtonSpinner,cooldownIndicator,
    arrayOfImage,timer,speed,ratio,void,isSlideMode,ImageAfterIsDone,coolDownBeforeSetAfterImage
    )
    self:setImage(DImage)
    if (DLabelSelected) then
        self:setSelected(DLabelSelected)
    end
    if (DLabelTimer) then
        self:setCoolDown(DLabelTimer)
    end
    self:setButton(DButtonSpinner)
    if (cooldownIndicator) then
        self:setIndicator(cooldownIndicator)
        self:setIndicatorMemory(cooldownIndicator:GetWide())
    end
    self:setData(arrayOfImage)
    self:setTimer(timer)
    self:setSpeed(speed)
    self:setSpeedMemory(speed)
    self:setRatio(ratio)
    if (void) then
        self.WhenIsFinish = void
    end
    if (isSlideMode) then
        self:setSlideMode()
    else
        self:setNoSlideMode()
    end
    if (ImageAfterIsDone and coolDownBeforeSetAfterImage) then
        self:setDefault(ImageAfterIsDone,coolDownBeforeSetAfterImage)
    end
    DImage.scroller = self
end
SpinnerObject = setmetatable(
    SpinnerMetaAtrribut,
    SpinnerMetaMethode
)
return SpinnerObject
