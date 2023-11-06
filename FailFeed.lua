local addonName, ns = ...

-- imports
local ehdb = ns.ehdb
local media = LibStub("LibSharedMedia-3.0")
local aceConfig = LibStub("AceConfig-3.0")
local aceConfigDialog = LibStub("AceConfigDialog-3.0")
local aceDB = LibStub("AceDB-3.0")
local aceDBOptions = LibStub("AceDBOptions-3.0")
local aceAddon = LibStub("AceAddon-3.0")

-- classes
local FrameDecay = {}
local Feed = {}
local FeedElement = {}
local FailureTracker = {}
local OptionsManager = {}
local Mover = {}

-- constants
local MAX_LINES = 100 -- max number of lines in the Feed
local SPELL_SCHOOL_COLORS = {
	[1] = "FFFFFF00", -- physical
	[2] = "FFFFE680", -- holy
	[3] = "FFFF8000", -- fire
	[4] = "FF4DFF4D", -- nature
	[5] = "FF80FFFF", -- frost
	[6] = "FF8080FF", -- shadow
	[7] = "FFFF80FF", -- arcane
}

local TEST_SOURCE = {
	"God",
	"Bright Glowing Area",
	"Emotional Damage",
	"Your Mom",
	"Way too hard to see",
	"Alcohol",
}

local TEST_SPELLS = {
	"Stupid",
	"Bad",
	"why stand there?",
	"move!",
	"Just Fire",
	"Bad Puns",
}

local DEFAULTS = {
	profile = {
		lock = true,
		test = false,
		font = "Friz Quadrata TT",
		fontColor = {0.7, 0.7, 0.7, 1},
		fontSize = 12,
		fontOutline = "",
		verticalDirection = "DOWN",
		horizontalAlignment = "LEFT",
		percentage = 5,
		lineHeight = 1,
		windowProps = {
			width = 500,
			height = 200,
			x = 0,
			y = 0,
		},
	}
}

-- ace config table
local optionsTable = {
	name = addonName,
	icon = GetAddOnMetadata(addonName, "IconTexture"),
	type = "group",
	args = {
		config = {
			name = "Open Config",
			desc = "Opens the configuration dialog",
			type = "execute",
			func = function()
				aceConfigDialog:Open(addonName)
			end,
			hidden = true,
			cmdHidden = false,
		},
		lock = {
			name = "Lock",
			desc = "Locks the feed in place",
			type = "execute",
			func = function()
				OptionsManager:set({"lock"}, true)
			end,
			hidden = true,
			cmdHidden = false,
		},
		unlock = {
			name = "Unlock",
			desc = "Allows the feed to be moved and resized",
			type = "execute",
			func = function()
				OptionsManager:set({"lock"}, false)
			end,
			hidden = true,
			cmdHidden = false,
		},
		reset = {
			name = "Reset Feed",
			desc = "Resets the feed to its default position",
			type = "execute",
			confirm = true,
			confirmText = "This will reload the UI. Continue?",
			func = function()
				OptionsManager:set({"windowProps"}, DEFAULTS.profile.windowProps)
				ReloadUI()
			end,
		},
		general = {
			name = "General",
			desc = "General settings",
			type = "group",
			handler = OptionsManager,
			get = "get",
			set = "set",
			order = 1,
			args = {
				lock = {
					name = "Lock",
					desc = "Locks the feed in place or allows rezising and moving",
					type = "toggle",
				},
				test = {
					name = "Test Mode",
					desc = "Enables test mode",
					type = "toggle",
				},
				font = {
					name = "Font",
					desc = "The font used for feed entries",
					type = "select",
					values = media:HashTable("font"),
					dialogControl = "LSM30_Font",
				},
				fontColor = {
					name = "Font Color",
					desc = "The font color used for feed entries",
					type = "color",
					hasAlpha = true,
					get = function(info)
						return unpack(OptionsManager:get(info))
					end,
					set = function(info, r, g, b, a)
						OptionsManager:set(info, {r, g, b, a})
					end,
				},
				fontSize = {
					name = "Font Size",
					desc = "The font size used for feed entries",
					type = "range",
					min = 1,
					max = 50,
					step = 1,
				},
				fontOutline = {
					name = "Font Outline",
					desc = "The font outline used for feed entries",
					type = "select",
					values = {
						[""] = "None",
						["OUTLINE"] = "Outline",
						["THICKOUTLINE"] = "Thick Outline",
					},
				},
				verticalDirection = {
					name = "Vertical Direction",
					desc = "The direction in which the feed grows",
					type = "select",
					values = {
						["UP"] = "Up",
						["DOWN"] = "Down",
					},
				},
				horizontalAlignment = {
					name = "Horizontal Alignment",
					desc = "The horizontal alignment of the feed",
					type = "select",
					values = {
						["LEFT"] = "Left",
						["CENTER"] = "Center",
						["RIGHT"] = "Right",
					},
				},
				lineHeight = {
					name = "Line Height",
					desc = "The height of each line in the feed (in multiples of the font size)",
					type = "range",
					min = 0.2,
					max = 5,
					step = 0.1,
				},
			},
		},
		filter = {
			name = "Filter",
			desc = "Filter which events are shown in the feed",
			type = "group",
			handler = OptionsManager,
			order = 2,
			get = "get",
			set = "set",
			args = {
				percentage = {
					name = "Percentage",
					desc = "Cut off percentage for events to be shown in the feed",
					type = "range",
					min = 0,
					max = 100,
					step = 0.1,
				},
			}
		}
	}
}

--[[
	Called when the addon is loaded
	@param addon The addon object for callbacks when settings change
]]--
function OptionsManager:init(addon)
	self.addon = addon

	self.db = aceDB:New("FailFeedDB", DEFAULTS, true)

	optionsTable.args.profile = aceDBOptions:GetOptionsTable(self.db)
	aceConfig:RegisterOptionsTable(addonName, optionsTable, {"failfeed"})
	aceConfigDialog:AddToBlizOptions(addonName, addonName)
end

function OptionsManager:triggerSettingsChanged()
	self.addon:SettingsChanged(self.db)
end

--[[
	Called by AceConfig to get config values
	@param info Table with args subtable of optionsTable
]]--
function OptionsManager:get(info)
	local key = info[#info] --for whatever reason, the last element is the key
	
	return self.db.profile[key]
end

--[[
	Called by AceConfig to set config values
	@param info Table with args subtable of optionsTable
	@param value The value to set
]]--
function OptionsManager:set(info, value)
	local key = info[#info]
	self.db.profile[key] = value

	if type(value) == "table" then
		-- table.concat doesn't work on tables with non-numeric keys, so we have to do this
		local str = ""
		for k, v in pairs(value) do
			str = str .. k .. "=" .. v .. ", "
		end
		self.addon:Print("Config: " .. key .. " set to table " .. str)
	else
		self.addon:Print("Config: " .. key .. " set to " .. tostring(value) .. ".")
	end

	self.addon:SettingsChanged(self.db)
end

local function getSpellSchoolColor(bitfield)
	-- highest bit takes precedence
	for i = 7, 1, -1 do
		if bit.band(bitfield, bit.lshift(1, i)) > 0 then
			return SPELL_SCHOOL_COLORS[i]
		end
	end
	return "FFFC0303"
end

local function formatPlayer(dstName)
	local name = dstName

	-- name may contain server name, if present, remove it
	local dashIndex = string.find(dstName, "-")
	if dashIndex then
		name = string.sub(dstName, 1, dashIndex - 1)
	end

	local classColor = C_ClassColor.GetClassColor(select(2, UnitClass(dstName))):GenerateHexColor()
	local role = UnitGroupRolesAssigned(dstName)
	
	-- build formatted string for display
	local formatted = ""

	-- start with role icon (if available)
	if role == "TANK" then
		formatted = formatted .. CreateAtlasMarkup("roleicon-tiny-tank")
	elseif role == "HEALER" then
		formatted = formatted .. CreateAtlasMarkup("roleicon-tiny-healer")
	elseif role == "DAMAGER" then
		formatted = formatted .. CreateAtlasMarkup("roleicon-tiny-dps")
	end

	
	-- add colored name
	formatted = formatted .. "|c" .. classColor .. name .. "|r"

	return formatted
end

local function formatSpell(spellId, spellName)
	local spellTexture = GetSpellTexture(spellId)

	local formatted = ""

	-- add spell icon
	formatted = formatted .. "|T" .. spellTexture .. ":0|t"

	-- add spell name
	formatted = formatted .. "|cFFFFFFFF" .. spellName .. "|r"

	return formatted
end

local function formatNumber(amount)
	-- add proper suffix and round to 2 decimal places (unless it's a whole number)
	if amount >= 1000000 then
		return string.format("%.2fm", amount / 1000000)
	elseif amount >= 1000 then
		return string.format("%.2fk", amount / 1000)
	end

	return amount
		
end

--[[
	Initializes a FrameDecay.
	@param frame the frame to decay
	@param hideAfter the time after which the frame should be hidden
	@param fadeOutTime the time it takes to fade out the frame
]]--
function FrameDecay.new(frame, hideAfter, fadeOutTime)
	local self = {}
	setmetatable(self, {__index = FrameDecay})
	self.frame = frame
	self.hideAfter = hideAfter
	self.fadeOutTime = fadeOutTime

	return self
end

--[[
	Decays the frame. If the frame is already decaying, the decay is reset.
]]--
function FrameDecay:decay()
	-- if timer is already running, cancel it
	if self.timer then
		self.timer:Cancel()
	end

	-- cancel pending fade out and force alpha to 1
	UIFrameFadeRemoveFrame(self.frame)
	self.frame:SetAlpha(1)
	

	self.timer = C_Timer.NewTimer(self.hideAfter, function()
		-- start fade out
		UIFrameFadeOut(self.frame, self.fadeOutTime, 1, 0)
	end, 1)
end

function Mover.new(frame, callback)
	-- window controls are implemented as a frame with a resize button, containing the parent frame
	local self = CreateFrame("Frame", nil, frame)

	for k, v in pairs(Mover) do
		self[k] = v
	end

	self.frame = frame
	self.callback = callback
	frame:SetResizeBounds(50, 50)

	-- overlay the parent frame
	self:SetAllPoints()

	-- act as click area for parent
	self:SetScript("OnDragStart", function(self)
		frame:StartMoving()
		frame:resetDecay()
	end)

	self:SetScript("OnDragStop", function(self)
		frame:StopMovingOrSizing()
		if callback then
			callback()
		end
	end)

	-- background to visualize the frame
	self.background = self:CreateTexture(nil, "BACKGROUND")
	self.background:SetAllPoints()
	self.background:SetColorTexture(0, 0, 0, 0.5)

	-- resize via bottom right corner
	self.resizeButton = CreateFrame("Button", nil, self)
	self.resizeButton:SetSize(16, 16)
	self.resizeButton:SetPoint("BOTTOMRIGHT", 0, 0)
	self.resizeButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	self.resizeButton:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	self.resizeButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

	self.resizeButton:SetScript("OnMouseDown", function(self)
		frame:StartSizing("BOTTOMRIGHT")
		frame:resetDecay()
	end)

	self.resizeButton:SetScript("OnMouseUp", function(self)
		frame:StopMovingOrSizing()
		if callback then
			callback()
		end
	end)

	self:Disable()

	return self
end

function Mover:Enable()
	if self.state == "enabled" then
		return
	end
	self.state = "enabled"

	self:Show()

	self:RegisterForDrag("LeftButton")
	self:EnableMouse(true)
	self.frame:SetClampedToScreen(true)
	self.frame:SetResizable(true)
	self.frame:SetMovable(true)
end

function Mover:Disable()
	if self.state == "disabled" then
		return
	end
	self.state = "disabled"

	self:RegisterForDrag()
	self:EnableMouse(false)
	self.frame:SetClampedToScreen(false)
	self.frame:SetResizable(false)
	self.frame:SetMovable(false)

	self:Hide()
end

--[[
	Initializes the fail Feed.
	@param parent the parent frame
]]--
function Feed.init(parent, windowProps)
	local self = CreateFrame("Frame", nil, parent)

	-- copy Feed methods to self
	for k, v in pairs(Feed) do
		self[k] = v
	end

	self:SetSize(windowProps.width, windowProps.height)
	self:SetClipsChildren(true)
	self:SetPoint("TOPLEFT", windowProps.x, - windowProps.y)

	-- add mover frame for dragging and resizing
	self.mover = Mover.new(self, function()

		-- notify caller about new size and position
		if self.callback then
			local width, height = self:GetSize()
			local x = self:GetLeft()
			local y = GetScreenHeight() - self:GetTop()
			self.callback({
				width = width,
				height = height,
				x = x,
				y = y
			})
		end
	end)

	self.entries = {}
	for i = 1, MAX_LINES do
		local entry = FeedElement.new(self, i)
		entry:SetSize(500, 20)
		
		-- anchor left and right to self to make sure they are always the same width
		entry:SetPoint("LEFT", self, "LEFT")
		entry:SetPoint("RIGHT", self, "RIGHT")
		
		self.entries[i] = entry
	end

	return self
end

function Feed:unlock(callback)
	self.callback = callback
	self.mover:Enable()
end

function Feed:lock()
	self.mover:Disable()
end


function Feed:resetDecay()
	for _, entry in pairs(self.entries) do
		entry.decay:decay()
	end
end

--[[
	Sets the vertical direction in which entries are displayed.
	@param direction the direction. valid values are "UP" and "DOWN"
]]--
function Feed:verticalDirection(direction)
	local prevAnchor = self
	for i = 1, #self.entries do
		local anchor = self.entries[i]
		anchor:ClearPoint("TOP")
		anchor:ClearPoint("BOTTOM")

		-- first element needs to be anchored inside parent frame
		if direction == "UP" then
			if i == 1 then
				anchor:SetPoint("BOTTOM", self, "BOTTOM")
			else
				anchor:SetPoint("BOTTOM", prevAnchor, "TOP")
			end
		elseif direction == "DOWN" then
			if i == 1 then
				anchor:SetPoint("TOP", self, "TOP")
			else
				anchor:SetPoint("TOP", prevAnchor, "BOTTOM")
			end
		end

		prevAnchor = anchor
	end
end

--[[
	Sets the horizontal alignment of entries.
	@param alignment the alignment. valid values are "LEFT", "RIGHT" and "CENTER"
]]--
function Feed:horizontalAlignment(alignment)
	for i = 1, #self.entries do
		local anchor = self.entries[i]
		anchor.text:SetJustifyH(alignment)
	end
end

function Feed:updateFontElement(fn)
	for i = 1, #self.entries do
		local anchor = self.entries[i]
		fn(anchor.text)
	end
end

function Feed:setFont(font, size, flags, lineHeight)
	self:updateFontElement(function(text)
		text:SetFont(font, size, flags)
	end)

	for i = 1, #self.entries do
		local anchor = self.entries[i]
		anchor:SetHeight(lineHeight * size)
	end
end

function Feed:setColor(color)
	local r, g, b, a = unpack(color)
	self:updateFontElement(function(text)
		text:SetTextColor(r, g, b, a)
	end)
end

--[[
	Returns entry element from end of the queue, moves it to the front and returns it.
	@return the entry element
]]--
function Feed:getNextEntry()
	local oldFirst = self.entries[1]

	local entry = self.entries[#self.entries]
	table.remove(self.entries, #self.entries)
	table.insert(self.entries, 1, entry)
	
	-- old first entry is either anchored top or bottom, depending on vertical direction, so check for both
	-- top most frame is also anchored top/top in parent or bottom/bottom in parent
	if oldFirst:GetPointByName("TOP") then
		entry:SetPoint("TOP", self, "TOP")
		oldFirst:SetPoint("TOP", entry, "BOTTOM")
	elseif oldFirst:GetPointByName("BOTTOM") then
		entry:SetPoint("BOTTOM", self, "BOTTOM")
		oldFirst:SetPoint("BOTTOM", entry, "TOP")
	end

	return entry
end

--[[
	Initializes a FeedElement.
	@param parent the parent frame
	@param i the index of the element for debugging purposes
]]--
function FeedElement.new(parent, i)
	local self = CreateFrame("Frame", nil, parent)
	
	-- start hidden
	self:SetAlpha(0)

	self._i = i
	self.decay = FrameDecay.new(self, 5, 1)

	-- create text child and anchor it to entry
	self.text = self:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	self.text:SetAllPoints()

	-- demo text for debugging
	local spacer = string.rep("_", i)
	self.text:SetText("Entry " .. spacer .. i)

	-- add FeedElement methods to self
	for k, v in pairs(FeedElement) do
		self[k] = v
	end

	return self
end

--[[
	Sets the text of the FeedElement and starts the decay process. Existing decay is reset.
	@param text the text to set
]]--
function FeedElement:setText(text)
	self.text:SetText(text)
	self.decay:decay()
end

--[[
	Initializes the FailureTracker.
	@param feed the Feed to which the FailureTracker should write
]]--
function FailureTracker.new(feed)
	local self = CreateFrame("Frame", nil)
	self.feed = feed

	for k, v in pairs(FailureTracker) do
		self[k] = v
	end

	self:SetScript("OnEvent", function(self, event, ...)
		self[event](self, ...)
	end)

	-- inject wrapper for ElitismFrame to make copied code run
	self.elitismFrame = {
		SpellDamage = function(_, ...)
			self:ehSpellDamage( ...)
		end,
		SwingDamage = function(_, ...)
			self:ehSwingDamage(...)
		end,
		AuraApply = function(_, ...)
			self:ehAuraApply(...)
		end
	}

	return self
end

function FailureTracker:start()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function FailureTracker:setPercentage(percentage)
	self.percentage = percentage
end

function FailureTracker:report(player, source, spellString, damageColor, amount)

	-- sometimes there is no source
	if not source then
		source = "Environment"
	end

	local playerString = formatPlayer(player)
	local sourceString = "|cFFFFFFFF" .. source .. "|r"

	-- some reports don't have damage, in which case we use a different format
	local text = playerString .. " hit by " .. spellString .. " from " .. sourceString
	local percentage = 0
	if amount then

		percentage = math.floor(amount / UnitHealthMax(player) * 100)
		local amountString = "|c" .. damageColor .. formatNumber(amount) .. " (" .. percentage .. "%)|r"
		text = prefix .. playerString .. " hit by " .. spellString .. " for " .. amountString .. " from " .. sourceString
	end

	if percentage >= self.percentage then
		local entry = self.feed:getNextEntry()
		entry:setText(text)
	end
end

function FailureTracker:reportDeath(player)
	local playerString = formatPlayer(player)

	local tombstone = "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:0|t "
	local text = tombstone .. playerString .. " died"
	local entry = self.feed:getNextEntry()
	entry:setText(text)
end

function FailureTracker:ehSpellDamage(_, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, amount)
	if not UnitIsPlayer(dstName) then
		return
	end

	if ehdb.Spells[spellId] or (ehdb.SpellsNoTank[spellId] and UnitGroupRolesAssigned(dstName) ~= "TANK") then

		local spellString = formatSpell(spellId, spellName)
		local damageColor = getSpellSchoolColor(spellSchool)
		
		self:report(dstName, srcName, spellString, damageColor, amount)
	end
end

function FailureTracker:ehSwingDamage(_, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, amount)
	if not UnitIsPlayer(dstName) then
		return
	end

	if not srcGUID:match("^Creature") then
		return
	end

	local sourceNpcId = select(6, strsplit("-", srcGUID))
	if ehdb.MeleeHitters[sourceNpcId] then

		local spellString = "|TInterface\\Icons\\INV_Sword_04:0|t|cFFFFFFFFmeelee|r"
		local damageColor = "FFFFFFFF"

		self:report(dstName, srcName, spellString, damageColor, amount)
	end
end

function FailureTracker:ehAuraApply(_, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, auraType, auraAmount)
	if not UnitIsPlayer(dstName) then
		return
	end

	if ehdb.Auras[spellId] or (ehdb.AurasNoTank[spellId] and UnitGroupRolesAssigned(dstName) ~= "TANK") then

		local playerString = formatPlayer(dstName)
		local spellString = formatSpell(spellId, spellName)
		local damageColor = "FFFFFFFF"
		
		self:report(dstName, srcName, spellString, damageColor, auraAmount)
	end
end

function FailureTracker:COMBAT_LOG_EVENT_UNFILTERED()
	-- ripped from ElitismHelper, injecting ElitismFrame variable to allow copying of code verbatim
	local ElitismFrame = self.elitismFrame

	-- START of ElitismHelper code
	local timestamp, eventType, hideCaster, srcGUID, srcName, srcFlags, srcFlags2, dstGUID, dstName, dstFlags, dstFlags2 = CombatLogGetCurrentEventInfo(); -- Those arguments appear for all combat event variants.
	local eventPrefix, eventSuffix = eventType:match("^(.-)_?([^_]*)$");

	if (eventPrefix:match("^SPELL") or eventPrefix:match("^RANGE")) and eventSuffix == "DAMAGE" then
		local spellId, spellName, spellSchool, sAmount, aOverkill, sSchool, sResisted, sBlocked, sAbsorbed, sCritical, sGlancing, sCrushing, sOffhand, _ = select(12, CombatLogGetCurrentEventInfo())
		ElitismFrame:SpellDamage(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, sAmount)
	elseif eventPrefix:match("^SWING") and eventSuffix == "DAMAGE" then
		local aAmount, aOverkill, aSchool, aResisted, aBlocked, aAbsorbed, aCritical, aGlancing, aCrushing, aOffhand, _ = select(12, CombatLogGetCurrentEventInfo())
		ElitismFrame:SwingDamage(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, aAmount)
	elseif eventPrefix:match("^SPELL") and eventSuffix == "MISSED" then
		local spellId, spellName, spellSchool, missType, isOffHand, mAmount = select(12, CombatLogGetCurrentEventInfo())
		if mAmount then
			ElitismFrame:SpellDamage(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, mAmount)
		end
	elseif eventType == "SPELL_AURA_APPLIED" then
		local spellId, spellName, spellSchool, auraType = select(12, CombatLogGetCurrentEventInfo())
		ElitismFrame:AuraApply(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, auraType)
	elseif eventType == "SPELL_AURA_APPLIED_DOSE" then
		local spellId, spellName, spellSchool, auraType, auraAmount = select(12, CombatLogGetCurrentEventInfo())
		ElitismFrame:AuraApply(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, auraType, auraAmount)
	end
	-- END of ElitismHelper code

	-- start of own code
	if eventType == "UNIT_DIED" and UnitIsPlayer(dstName) then
		-- hunter feign death is not a real death
		if UnitClass(dstName) == "Hunter" and UnitIsFeignDeath(dstName) then
			return
		end

		self:reportDeath(dstName)
	end
end

local FailFeed = aceAddon:NewAddon(addonName, "AceConsole-3.0")

function FailFeed:OnInitialize()
	OptionsManager:init(self)

	local windowProps = OptionsManager:get({"windowProps"})

	self.feed = Feed.init(UIParent, windowProps)
	self.tracker = FailureTracker.new(self.feed)
end

function FailFeed:OnEnable()
	OptionsManager:triggerSettingsChanged()

	self.tracker:start()

	local windowProps = OptionsManager:get({"windowProps"})

end

function FailFeed:OnDisable()
	self:Print("I have no idea how you disabled this addon. But I can tell you it doesn't like it.")
end

function FailFeed:SettingsChanged(db)
	local profile = db.profile

	-- resolve font via LibSharedMedia
	local fontPath = media:Fetch("font", profile.font)
	self.feed:setFont(fontPath, profile.fontSize, profile.fontOutline, profile.lineHeight)
	self.feed:setColor(profile.fontColor)

	-- order is important here, as reanchoring will fix stuff I'm unwilling to debug
	self.feed:horizontalAlignment(profile.horizontalAlignment)
	self.feed:verticalDirection(profile.verticalDirection)

	self.tracker:setPercentage(profile.percentage)

	if profile.test then
		-- check if timer is already running
		if not self.testTimer then
			self.testTimer = C_Timer.NewTicker(1, function()
				-- get random entry from SPELL array
				local spell = TEST_SPELLS[math.random(#TEST_SPELLS)]
				local spellColor = SPELL_SCHOOL_COLORS[math.random(#SPELL_SCHOOL_COLORS)]
				local spellString = "|TInterface\\ICONS\\INV_Misc_QuestionMark:0|t|cFFFFFFFF" .. spell .. "|r"
				local source = TEST_SOURCE[math.random(#TEST_SOURCE)]

				-- player, source, spellString, damageColor, amount)
				self.tracker:report(GetUnitName("player"), source, spellString, spellColor, math.random(UnitHealthMax("player")))
			end)
		end
	else
		if self.testTimer then
			self.testTimer:Cancel()
			self.testTimer = nil
		end
	end

	if profile.lock then
		self.feed:lock()

	else
		self.feed:unlock(function(windowProps)
			OptionsManager:set({"windowProps"}, windowProps)
		end)
	end
end
