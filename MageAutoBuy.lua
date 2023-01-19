if desiredReagents == nil then
	desiredReagents = {20, 10, 10}
end

local reagentIds = {17020, 17031, 17032}
local numReagents = {};
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

function mab_GetItemName(var)
	item =  {GetItemInfo( var )};
	return item[1];
end

function mab_GetCurrentReagents()
	for i=1, #reagentIds, 1 do
		numReagents[i] = 0

		for bag = 4, 0, -1 do
			local size = C_Container.GetContainerNumSlots(bag);

			if size > 0 then
				for slot = 1, size, 1 do
					if C_Container.GetContainerItemLink(bag, slot) then
						local itemName = mab_GetItemName( C_Container.GetContainerItemLink(bag, slot) )
						local reagentName = mab_GetItemName( reagentIds[i] )
						local _,itemCount = C_Container.GetContainerItemInfo(bag, slot)

						if itemName == reagentName then
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
		for j = 0, GetMerchantNumItems() do
			local itemName = GetMerchantItemInfo(j)
			local reagentName = mab_GetItemName(reagentIds[i])

			if itemName == reagentName then
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
