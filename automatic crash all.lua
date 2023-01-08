VERSION = "1.1.0"

function get_players()
    local players = {}
    for i = 0 , 31 do 
        if player.is_player_valid(i) then 
            table.insert(players, i)
        end
    end
    return players
end

function SessionType()
    if network.is_session_started() then
        if native.call(0xF3929C2379B60CCE):__tointeger() == 1 then 
            return "Solo"
        elseif native.call(0xCEF70AA5B3F89BA1):__tointeger() == 1 then
            return "Invite Only"
        elseif native.call(0xFBCFA2EA2E206890):__tointeger() == 1 then
            return "Friends Only"
        elseif native.call(0x74732C6CA90DA2B4):__tointeger() == 1 then 
            return "Crew Only"
        end
        return "Public"
    end
    return "Singleplayer"

end

function crashSession(feat)
    local playerAmount = nil
    local joined = false
    while feat.on do
        local players = get_players()
        if #players <= minPlayersSlider.value and not joined and script.get_global_i(1574993) == 66 or SessionType() == "Singleplayer" then 
            system.wait(1000)
            --menu.get_feature_by_hierarchy_key("online.lobby.bail_netsplit"):toggle()
            --[[for _,v in next, menu.get_feature_by_hierarchy_key("online.session_browser").children do 
                if _ == 1 then 
                    v:toggle()
                    menu.notify(v.name)
                elseif _ == 7 then 
                    v:toggle()
                    menu.notify(v.name)
                    system.wait(30000)
                    break
                end
            end]]
            menu.clear_all_notifications()
            menu.notify("Session hopping")
            system.wait(250)
            network.join_new_lobby(0)
            joined = true
        end
        if #players > 1 and player.player_id() ~= 0 then 
            network.send_chat_message(spamMessage, false)
            menu.get_feature_by_hierarchy_key("online.all_players.crash_all"):toggle()
            joined = false
        end
        system.wait(100)
    end
end

function modify_spam_text(feat)
    local code,message = input.get("Message to Spam", "", 256, 0)
    while true do 
        code,message = input.get("Message to Spam", "", 256, 0)
        if code == 0 then break end
        system.wait(10)   
    end
    if code == 0 then 
        menu.notify(message,"Spam Message Changed to",3)
        spamMessage = message
    else 
        menu.notify("Message Cancelled", "Automatic Server Crasher")
    end
end

function get_spam_text(feat)
    menu.notify(spamMessage,"Spam message",3)
end

spamMessage = "Get crashed by Proton#4469 with a lua."

local local_parent = menu.add_feature("Automatic Session Crasher", "parent", 0)

local crashToggle = menu.add_feature("Crash Session", "toggle", local_parent.id, crashSession)
crashToggle.hint = "Automatically spam the chat and crash the whole session and then join into a new session to continue crashing."

local spamString = menu.add_feature("Set Spam Message", "action", local_parent.id, modify_spam_text)
spamString.hint = "Input text that will be spammed when crashing the session"

local getSpamString = menu.add_feature("Get Spam Message", "action", local_parent.id, get_spam_text)

minPlayersSlider = menu.add_feature("Min Players", "autoaction_value_i", local_parent.id, modify_min_players_slider)
minPlayersSlider.hint = "Minimum players required to join a new session (recommended to be at least 3 to prevent getting stuck in lobbies)"
minPlayersSlider.min = 1
minPlayersSlider.max = 31
minPlayersSlider.value = 3

function update_script()
    local response_code, response_body, response_headers = web.get("https://raw.githubusercontent.com/ProtonDev-sys/Automatic-Crash-gta-v/main/automatic%20crash%20all.lua")
    if response_code ~= 200 then 
        menu.notify("Update failed.", "Automatic Crash All", 2, 0xff0000ff)
    else 
        local file = io.open(utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\".."scripts\\automatic crash all.lua", "w+b")
        file:write(response_body)
        file:flush()
    end
end

menu.create_thread(function()
    if not menu.is_trusted_mode_enabled(8) then 
        menu.notify("Trusted mode HTTP required for auto update!", "Automatic Crash All", 2, 0xff0000ff)
    else 
        if VERSION == "DEV" then return end
        local response_code, response_body, response_headers = web.get("https://raw.githubusercontent.com/ProtonDev-sys/Automatic-Crash-gta-v/main/version")
        if response_body:match( "^%s*(.-)%s*$" ) ~= VERSION:match( "^%s*(.-)%s*$" ) then 
            menu.notify("Current version outdated, updating.", "Automatic Crash All", 2, 0xff0000ff)
            update_script()
        else
            menu.notify("You are using the latest version, welcome.", "Automatic Crash All", 2, 0xff00ff00)
        end 
    end
    menu.notify("Automatic crash all loaded version "..VERSION, "Automatic Crash All", 2, 0xff00ff00)
end)

