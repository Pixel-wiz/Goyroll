RollFor = RollFor or {}
local m = RollFor

if m.RollForChosenGui then return end

local M = {}
local getn = m.getn

---@param chosen_manager table
---@param group_roster GroupRoster
function M.new( chosen_manager, group_roster )
  local frame = nil
  local row_frames = {}

  local function build_frame()
    frame = CreateFrame( "Frame", "RollForChosenFrame", UIParent )
    frame:SetWidth( 220 )
    frame:SetHeight( 340 )
    frame:SetPoint( "CENTER", UIParent, "CENTER", 0, 0 )
    frame:SetFrameStrata( "DIALOG" )
    frame:SetMovable( true )
    frame:EnableMouse( true )
    frame:RegisterForDrag( "LeftButton" )
    frame:SetScript( "OnDragStart", function() this:StartMoving() end )
    frame:SetScript( "OnDragStop", function() this:StopMovingOrSizing() end )
    frame:SetBackdrop( {
      bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile     = true,
      tileSize = 32,
      edgeSize = 16,
      insets   = { left = 4, right = 4, top = 4, bottom = 4 },
    } )
    frame:SetBackdropColor( 0.08, 0.08, 0.08, 0.95 )
    frame:Hide()

    local title = frame:CreateFontString( nil, "OVERLAY", "GameFontNormalLarge" )
    title:SetPoint( "TOP", frame, "TOP", 0, -10 )
    title:SetText( "RollFor" )

    local toggle_btn = CreateFrame( "Button", "RollForChosenToggleBtn", frame, "UIPanelButtonTemplate" )
    toggle_btn:SetWidth( 110 )
    toggle_btn:SetHeight( 22 )
    toggle_btn:SetPoint( "TOP", title, "BOTTOM", 0, -6 )
    frame.toggle_btn = toggle_btn

    local scroll = CreateFrame( "ScrollFrame", "RollForChosenScroll", frame, "UIPanelScrollFrameTemplate" )
    scroll:SetPoint( "TOPLEFT",     frame, "TOPLEFT",     10, -68 )
    scroll:SetPoint( "BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 10 )

    local content = CreateFrame( "Frame", "RollForChosenContent", scroll )
    content:SetWidth( 175 )
    content:SetHeight( 1 )
    scroll:SetScrollChild( content )
    frame.content = content

    tinsert( UISpecialFrames, "RollForChosenFrame" )
  end

  local function refresh()
    if not frame or not frame:IsVisible() then return end

    for _, r in ipairs( row_frames ) do
      r:Hide()
    end
    row_frames = {}

    local content = frame.content
    local y = 0
    local row_h = 22

    local function make_row( h )
      local row = CreateFrame( "Frame", nil, content )
      row:SetHeight( h )
      row:SetPoint( "TOPLEFT",  content, "TOPLEFT",  0, -y )
      row:SetPoint( "TOPRIGHT", content, "TOPRIGHT", 0, -y )
      row:Show()
      table.insert( row_frames, row )
      return row
    end

    local chosen = chosen_manager.get_chosen()

    if getn( chosen ) > 0 then
      local hdr_row = make_row( 18 )
      local hdr = hdr_row:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
      hdr:SetPoint( "LEFT", hdr_row, "LEFT", 2, 0 )
      hdr:SetText( "|cffFFD700Chosen|r" )
      y = y + 18

      for _, name in ipairs( chosen ) do
        local row = make_row( row_h )

        local lbl = row:CreateFontString( nil, "OVERLAY", "GameFontHighlightSmall" )
        lbl:SetPoint( "LEFT", row, "LEFT", 6, 0 )
        lbl:SetText( "|cff00FF00" .. name .. "|r" )

        local btn = CreateFrame( "Button", nil, row, "UIPanelButtonTemplate" )
        btn:SetWidth( 26 )
        btn:SetHeight( 18 )
        btn:SetPoint( "RIGHT", row, "RIGHT", -2, 0 )
        btn:SetText( "x" )
        btn.player_name = name
        btn:SetScript( "OnClick", function()
          chosen_manager.remove( this.player_name )
          refresh()
        end )

        y = y + row_h
      end

      y = y + 6
    end

    local all_players = group_roster.get_all_players_in_my_group()
    local has_raid_header = false

    for _, player in ipairs( all_players ) do
      if not chosen_manager.is_chosen( player.name ) then
        if not has_raid_header then
          local hdr_row = make_row( 18 )
          local hdr2 = hdr_row:CreateFontString( nil, "OVERLAY", "GameFontNormalSmall" )
          hdr2:SetPoint( "LEFT", hdr_row, "LEFT", 2, 0 )
          hdr2:SetText( "|cffAAAAAARaid|r" )
          y = y + 18
          has_raid_header = true
        end

        local row = make_row( row_h )

        local lbl = row:CreateFontString( nil, "OVERLAY", "GameFontHighlightSmall" )
        lbl:SetPoint( "LEFT", row, "LEFT", 6, 0 )
        lbl:SetText( player.name )

        local btn = CreateFrame( "Button", nil, row, "UIPanelButtonTemplate" )
        btn:SetWidth( 26 )
        btn:SetHeight( 18 )
        btn:SetPoint( "RIGHT", row, "RIGHT", -2, 0 )
        btn:SetText( "+" )
        btn.player_name = player.name
        btn:SetScript( "OnClick", function()
          chosen_manager.add( this.player_name )
          refresh()
        end )

        y = y + row_h
      end
    end

    content:SetHeight( math.max( y + 10, 1 ) )

    local toggle_btn = frame.toggle_btn
    if chosen_manager.is_enabled() then
      toggle_btn:SetText( "|cff00FF00Chosen: ON|r" )
    else
      toggle_btn:SetText( "|cffFF4444Chosen: OFF|r" )
    end
    toggle_btn:SetScript( "OnClick", function()
      chosen_manager.toggle()
      refresh()
    end )
  end

  local function toggle_window()
    if not frame then build_frame() end

    if frame:IsVisible() then
      frame:Hide()
    else
      frame:Show()
      refresh()
    end
  end

  return {
    toggle_window = toggle_window,
    refresh       = refresh,
  }
end

m.RollForChosenGui = M
return M
