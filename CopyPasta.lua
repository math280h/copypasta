local lines = CopyPastaLines or {
    { title = "Default", text = "No lines loaded. Check Lines.lua." }
  }
  local selectedLine = lines[1].text
  
  -- Main frame
  local frame = CreateFrame("Frame", "CopypastaFrame", UIParent, "BasicFrameTemplateWithInset")
  frame:SetSize(700, 400)
  frame:SetPoint("CENTER")
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame:Hide()
  
  frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  frame.title:SetPoint("TOP", 0, -10)
  frame.title:SetText("Copypasta Browser")
  
  -- Left-side scroll list
  local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
  scrollFrame:SetPoint("TOPLEFT", 15, -35)
  scrollFrame:SetSize(300, 340)
  
  local listFrame = CreateFrame("Frame", nil, scrollFrame)
  scrollFrame:SetScrollChild(listFrame)
  listFrame:SetSize(280, 35 * #lines)
  
  -- Populate list with buttons
  for i, lineObj in ipairs(lines) do
    local btn = CreateFrame("Button", nil, listFrame, "UIPanelButtonTemplate")
    btn:SetSize(260, 30)
    btn:SetText(lineObj.title or ("Line " .. i))
    btn:SetPoint("TOPLEFT", 10, -((i - 1) * 35))
    btn:SetScript("OnClick", function()
      selectedLine = lineObj.text
      previewText:SetText(selectedLine)
    end)
  end
  
  -- Right-side preview panel
  local previewBox = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
  previewBox:SetSize(350, 250)
  previewBox:SetPoint("TOPRIGHT", -15, -35)
  previewBox:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
  })
  previewBox:SetBackdropColor(0, 0, 0, 1)
  
  previewText = previewBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  previewText:SetPoint("TOPLEFT", 10, -10)
  previewText:SetJustifyH("LEFT")
  previewText:SetJustifyV("TOP")
  previewText:SetWidth(320)
  previewText:SetSpacing(6)
  previewText:SetText(selectedLine)
  
  -- Bottom send buttons (evenly spaced)
  local sendTypes = {
    { label = "Say", chatType = "SAY" },
    { label = "Party", chatType = "PARTY" },
    { label = "Instance", chatType = "INSTANCE_CHAT" },
    { label = "Guild", chatType = "GUILD" },
  }
  
  local function SendChatMessageSplit(text, chatType)
    local maxLength = 255
    local startPos = 1
    while startPos <= #text do
      local part = text:sub(startPos, startPos + maxLength - 1)
      SendChatMessage(part, chatType)
      startPos = startPos + maxLength
    end
  end

  for i, info in ipairs(sendTypes) do
    local btn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    btn:SetSize(80, 24)
    btn:SetText(info.label)
  
    -- Position buttons evenly under the preview box
    btn:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20 - ((4 - i) * 90), 10)
  
    btn:SetScript("OnClick", function()
      if selectedLine then
        SendChatMessageSplit(selectedLine, info.chatType)
      end
    end)
  end
  
  -- Slash command to toggle the window
  SLASH_COPYPASTA1 = "/copypasta"
  SlashCmdList["COPYPASTA"] = function()
    frame:SetShown(not frame:IsShown())
  end
  