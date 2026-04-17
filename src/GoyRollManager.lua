RollFor = RollFor or {}
local m = RollFor

if m.RollForChosen then return end

local M = {}
local getn = m.getn

---@param db table
function M.new( db )
  db.enabled = db.enabled or false
  db.chosen  = db.chosen  or {}

  local function is_enabled()
    return db.enabled == true
  end

  local function toggle()
    db.enabled = not db.enabled
  end

  local function is_chosen( player_name )
    for _, name in ipairs( db.chosen ) do
      if name == player_name then return true end
    end
    return false
  end

  local function add( player_name )
    if not is_chosen( player_name ) then
      table.insert( db.chosen, player_name )
    end
  end

  local function remove( player_name )
    for i, name in ipairs( db.chosen ) do
      if name == player_name then
        table.remove( db.chosen, i )
        return
      end
    end
  end

  local function get_chosen()
    return db.chosen
  end

  -- Pick a random Chosen player from the given candidate list.
  -- already_won: list of names to exclude first (dedup for multi-item rolls).
  -- Falls back to including already_won if no others are eligible.
  -- Returns nil if no Chosen players are in candidates at all.
  local function pick_winner( candidates, already_won )
    already_won = already_won or {}

    local eligible = {}
    for _, candidate in ipairs( candidates ) do
      if is_chosen( candidate.name ) then
        local excluded = false
        for _, won_name in ipairs( already_won ) do
          if won_name == candidate.name then
            excluded = true
            break
          end
        end
        if not excluded then
          table.insert( eligible, candidate )
        end
      end
    end

    if getn( eligible ) == 0 then
      for _, candidate in ipairs( candidates ) do
        if is_chosen( candidate.name ) then
          table.insert( eligible, candidate )
        end
      end
    end

    if getn( eligible ) == 0 then return nil end
    return eligible[ math.random( 1, getn( eligible ) ) ]
  end

  -- Build a publicly-visible ordered candidate list.
  -- Places winner at winning_position; fills remaining slots with all other
  -- candidates in their original relative order.
  local function build_ordered_list( candidates, winner, winning_position )
    local others = {}
    for _, c in ipairs( candidates ) do
      if c.name ~= winner.name then
        table.insert( others, c )
      end
    end

    local result = {}
    local other_idx = 1
    for i = 1, getn( candidates ) do
      if i == winning_position then
        result[ i ] = winner
      else
        result[ i ] = others[ other_idx ]
        other_idx = other_idx + 1
      end
    end

    return result
  end

  return {
    is_enabled         = is_enabled,
    toggle             = toggle,
    is_chosen          = is_chosen,
    add                = add,
    remove             = remove,
    get_chosen         = get_chosen,
    pick_winner        = pick_winner,
    build_ordered_list = build_ordered_list,
  }
end

m.RollForChosen = M
return M
