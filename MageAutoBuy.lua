if desiredReagents == nil then
	desiredReagents = {20, 10, 10}
end

local reagentIds = {17020, 17031, 17032}
local numReagents = {}
local merchantIdx = {}
local class = {UnitClass("player")}

local mabFrame = CreateFrame("Frame")
mabFrame:RegisterEvent("MERCHANT_SHOW")
SLASH_MAGEAUTOBUY1 = "/mab"
SlashCmdList["MAGEAUTOBUY"] = function(msg)
	mab_SlashCommandHandler(msg)
end

mabFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "MERCHANT_SHOW" then
		if class[2] == "MAGE" then
			if mab_MerchantReagents() then
				mab_GetCurrentReagents()
				mab_BuyReagents()
			end
		end
	end
end)

function mab_GetCurrentReagents()
	for i=1, #reagentIds do
		numReagents[i] = 0
		local reagentName = GetItemInfo( reagentIds[i] )

		for bag = 0, 4 do
			local size = C_Container.GetContainerNumSlots(bag);

			if size > 0 then
				for slot = 1, size do
					local itemLink = C_Container.GetContainerItemLink(bag, slot)
					if itemLink then
						local itemName = GetItemInfo( itemLink )
						local containerInfo = C_Container.GetContainerItemInfo(bag, slot)
						local itemCount = containerInfo["stackCount"]

						if (itemName == reagentName) then
							numReagents[i] = numReagents[i] + itemCount
						end
					end
				end
			end
		end
	end
end

function mab_MerchantReagents()
	local boolReagents = {false, false, false}

	for i=1, #reagentIds do
		local reagentName = GetItemInfo(reagentIds[i])
		for j = 0, GetMerchantNumItems() do
			local itemName = GetMerchantItemInfo(j)

			if (itemName == reagentName) then
				boolReagents[i] = true
				merchantIdx[i] = j
			end
		end
	end

	return (boolReagents[1] or boolReagents[2] or boolReagents[3])
end

function mab_BuyReagents()
	for i=1, #reagentIds do
		if (numReagents[i] < desiredReagents[i]) then
			local numBuy = desiredReagents[i] - numReagents[i]
			BuyMerchantItem( merchantIdx[i], numBuy );
		end
	end
end

function mab_SlashCommandHandler( msg )
	if msg == "" or msg == nil or msg == "help" then
		ChatFrame1:AddMessage("|cffffff00/mab |cff00d2d6<ItemLink>|r <Desired Amount>")
	end
	local count = msg:match("%s(%S+)$")
	if strfind(msg, "Arcane Powder") then
		desiredReagents[1] = tonumber(count)
	elseif strfind(msg, "Rune of Teleportation") then
		desiredReagents[2] = tonumber(count)
	elseif strfind(msg, "Rune of Portals") then
		desiredReagents[3] = tonumber(count)
	end
end
