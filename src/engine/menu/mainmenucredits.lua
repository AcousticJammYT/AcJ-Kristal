---@class MainMenuCredits : StateClass
---
---@field menu MainMenu
---
---@field pages {[1]: string, [2]: creditsline[], [3]: creditsline[]|nil}[]
---
---@field selected_page number
---@field scroll_direction string
---@field scroll_timer number
---
---@overload fun(menu:MainMenu) : MainMenuCredits
local MainMenuCredits, super = Class(StateClass)

---@alias creditsline string|{[1]: string, [2]: number[]}

function MainMenuCredits:init(menu)
    self.menu = menu

    self.pages = {
        {
            "Kristal Engine (1/2)",
            {
                { "Lead Developers", COLORS.silver },
                "NyakoFox",
                "SylviBlossom",
                "vitellary",
                "",
                { "Assets", COLORS.silver },
                "Toby Fox",
                "Temmie Chang",
                "DELTARUNE team",
                "",
                "",
            },
            {
                { "GitHub Contributors", COLORS.silver },
                "AcousticJamm",
                "Agent 7",
                "AlexGamingSW",
                "Archie-osu",
                "Bor",
                "Dobby233Liu",
                "Elioze",
                "FireRainV",
                "HUECYCLES",
                "J.A.R.U."
            }
        },
        {
            "Kristal Engine (2/2)",
            {
                { "GitHub Contributors", COLORS.silver },
                "Lionmeow",
                "Luna",
                "MCdeDaxia",
                "MrOinky",
                "Nextop",
                "prokube",
                "Simbel",
                "sjl057",
                "skarph",
                "TFLTV"
            },
            {
                { "GitHub Contributors", COLORS.silver },
                "Verozity",
                "WIL-TZY",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
                "",
            }
        }
    }
    
    self.selected_page = 1

    self.scroll_direction = "right"
    self.scroll_timer = 0
    
    self.applied_mods = false
end

function MainMenuCredits:registerEvents(master)
    self:registerEvent("enter", self.onEnter)
    self:registerEvent("keypressed", self.onKeyPressed)

    self:registerEvent("update", self.update)
    self:registerEvent("draw", self.draw)
end

-------------------------------------------------------------------------------
-- Callbacks
-------------------------------------------------------------------------------

function MainMenuCredits:onEnter(old_state)
    self.selected_page = 1

    self.scroll_direction = "right"
    self.scroll_timer = 0

    self.menu.heart_target_x = 320 - 32 - 16 + 1
    self.menu.heart_target_y = 480 - 16 + 1
    
    if not applied_mods then
        applied_mods = true
        
        local function space_count(list)
            local count = 0
            local second_index = nil
            
            for i = 1, #list do
                if list[i] == "" then
                    local only_empty_after = true
                    for j = i + 1, #list do
                        if list[j] ~= "" then
                            only_empty_after = false
                            break
                        end
                    end
                    if only_empty_after then
                        count = count + 1
                        if count == 2 then
                            second_index = i
                        end
                    end
                end
            end
            
            return count, second_index
        end
        
        local function libsort(dict)
            local function get_author_count(obj)
                if obj.authors == nil then
                    return 0
                elseif type(obj.authors) ~= "table" then
                    return 1
                else
                    return #obj.authors
                end
            end

            -- Extract values into an array
            local values = {}
            for _, v in pairs(dict) do
                table.insert(values, v)
            end

            -- Sort array
            table.sort(values, function(a, b)
                return get_author_count(a) < get_author_count(b)
            end)

            return values
        end
        
        for k,v in pairs(Kristal.Mods.list) do
            local should_credits = false
            
            if v.authors then should_credits = true end
            
            for k2, v2 in pairs(v.libs) do
                if v2.authors then should_credits = true end
            end
            
            if should_credits then
                local sides = {}
                
                if v.authors and #v.authors > 0 then
                    local sides = {}
                    local authlist = v.authors
                    if type(authlist) == "string" then
                        authlist = {authlist}
                    end
                    local authors = #v.authors
                    local slides = math.ceil(authors/10)
                    
                    for i=1, slides do
                        local page = {{ v.name, COLORS.silver }, "", "", "", "", "", "", "", "", "", ""}
                        for j=1, math.min(10, authors) do
                            local author = v.authors[((i-1) * 10) + j]
                            page[j+1] = author
                        end
                        authors = authors - 10
                        table.insert(sides, page)
                    end
                
                    if #sides%2 == 1 then
                        table.insert(sides, {
                            "","","","","","","","","","","",})
                    end
                    
                    local pages = math.ceil(#sides/2)
                    
                    for i=1, math.ceil(#sides/2) do
                        local name = v.name
                        
                        if pages > 1 then
                            name = name .. " (" .. i .. "/" .. pages .. ")"
                        end
                        
                        table.insert(self.pages, {
                            name,
                            sides[(i*2)-1],
                            sides[i*2]
                        })
                    end
                end
                
                local libs_sorted = libsort(v.libs)
                
                for k2, v2 in pairs(libs_sorted) do
                    if v2.authors and #v2.authors > 0 then
                        local authlist = v2.authors
                        if type(authlist) == "string" then
                            authlist = {authlist}
                        end
                        
                        local create_new_page = false
                        local index
                        
                        if #sides == 0 then
                            create_new_page = true
                        else
                            local num, ind = space_count(sides[#sides])
                            
                            if num - 2 < #authlist then
                                create_new_page = true
                            else
                                index = ind
                            end
                        end
                        
                        local authors = #authlist
                        
                        if create_new_page then
                            local pages = math.ceil(authors/10)
                            
                            for i=1, pages do
                                local page = {{ v2.id, COLORS.silver }, "", "", "", "", "", "", "", "", "", ""}
                                if v2.name then
                                    page = {{ v2.name, COLORS.silver }, "", "", "", "", "", "", "", "", "", ""}
                                end
                                for j=1, math.min(10, authors) do
                                    local author = authlist[((i-1) * 10) + j]
                                    page[j+1] = author
                                end
                                authors = authors - 10
                                table.insert(sides, page)
                            end
                        else
                            editing_page = sides[#sides]
                            editing_page[index] = { v2.id, COLORS.silver }
                            if v2.name then
                                editing_page[index] = { v2.name, COLORS.silver }
                            end
                            
                            for i=1, authors do
                                editing_page[index + i] = authlist[i]
                            end
                        end
                    end
                end
                
                if #sides%2 == 1 then
                    table.insert(sides, {
                        "","","","","","","","","","","",})
                end
                
                local pages = math.ceil(#sides/2)
                
                for i=1, math.ceil(#sides/2) do
                    local name = v.name .. " LIBRARIES"
                    
                    if pages > 1 then
                        name = name .. " (" .. i .. "/" .. pages .. ")"
                    end
                    
                    table.insert(self.pages, {
                        name,
                        sides[(i*2)-1],
                        sides[i*2]
                    })
                end
            end
        end
    end
end

function MainMenuCredits:onKeyPressed(key, is_repeat)
    if Input.isCancel(key) or Input.isConfirm(key) then
        self.menu:setState("TITLE")

        if Input.isCancel(key) then
            Assets.stopAndPlaySound("ui_move")
        else
            Assets.stopAndPlaySound("ui_select")
        end

        self.menu.title_screen:selectOption("credits")
    end

    local page_dir = "right"
    local page_now = self.selected_page

    if Input.is("left", key) then
        page_now = page_now - 1
        page_dir = "left"
    end
    if Input.is("right", key) then
        page_now = page_now + 1
        page_dir = "right"
    end

    page_now = Utils.clamp(page_now, 1, #self.pages)

    if page_now ~= self.selected_page then
        self.selected_page = page_now

        Assets.stopAndPlaySound("ui_move")

        self.scroll_direction = page_dir
        self.scroll_timer = 0.1
    end
end

function MainMenuCredits:update()
    if self.scroll_timer > 0 then
        self.scroll_timer = Utils.approach(self.scroll_timer, 0, DT)
    end
end

function MainMenuCredits:draw()
    local menu_font = Assets.getFont("main")

    local page = self.pages[self.selected_page]

    local title = page[1]:upper()
    local title_width = menu_font:getWidth(title)

    Draw.setColor(COLORS.silver)
    Draw.printShadow("( CREDITS )", 0, 0, 2, "center", 640)

    Draw.setColor(1, 1, 1)
    Draw.printShadow(title, 0, 48, 2, "center", 640)

    if #self.pages > 1 then
        local l_offset, r_offset = 0, 0

        if self.scroll_timer > 0 then
            if self.scroll_direction == "left" then
                l_offset = -4
            elseif self.scroll_direction == "right" then
                r_offset = 4
            end
        end

        if self.selected_page >= #self.pages then
            Draw.setColor(COLORS.silver, 0.5)
        else
            Draw.setColor(COLORS.white)
        end
        Draw.draw(Assets.getTexture("kristal/menu_arrow_right"), 320 + (title_width / 2) + 8 + r_offset, 52, 0, 2, 2)

        if self.selected_page == 1 then
            Draw.setColor(COLORS.silver, 0.5)
        else
            Draw.setColor(COLORS.white)
        end
        Draw.draw(Assets.getTexture("kristal/menu_arrow_left"), 320 - (title_width / 2) - 26 + l_offset, 52, 0, 2, 2)

        Draw.setColor(COLORS.white)
    end

    local left_column = page[2]
    local right_column = page[3] or {}

    for index, value in ipairs(left_column) do
        local color = {1, 1, 1, 1}
        local offset = 0
        if type(value) == "table" then
            color = value[2]
            value = value[1]
        else
            offset = offset + 32
        end
        Draw.setColor(color)
        Draw.printShadow(value, 32 + offset, 64 + (32 * index))
    end
    for index, value in ipairs(right_column) do
        local color = {1, 1, 1, 1}
        local offset = 0
        if type(value) == "table" then
            color = value[2]
            value = value[1]
        else
            offset = offset - 32
        end
        Draw.setColor(color)
        Draw.printShadow(value, 0, 64 + (32 * index), 2, "right", 640 - 32 + offset)
    end

    Draw.setColor(1, 1, 1)
    Draw.printShadow("Back", 0, 454 - 8, 2, "center", 640)
end

return MainMenuCredits
