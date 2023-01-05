VERSION = "1.0.1"

function get_players()
    local players = {}
    for i = 0 , 31 do 
        if player.is_player_valid(i) then 
            table.insert(players, i)
        end
    end
    return players
end

function crashSession(feat)
    while feat.on do
        local players = get_players()
        if #players <= minPlayersSlider.value then 
            network.join_new_lobby(0)
        else 
            network.send_chat_message(spamMessage, false)
            menu.get_feature_by_hierarchy_key("online.all_players.crash_all"):toggle()
        end
        system.wait(100)
    end
end

function modify_spam_text(feat,bool)
    local code,message = input.get("Message to Spam", "", 256, 0)
    while input.is_open() do 
        system.wait(10)   
    end
    if not bool then
        modify_spam_text(feat,true)
    else 
        if code == 0 then 
            menu.notify(message,"Spam Message Changed to",3)
            spamMessage = message
        else 
            menu.notify("Message Cancelled", "Automatic Server Crasher")
        end
    end
end

function get_spam_text(feat)
    menu.notify(spamMessage,"Spam message",3)
end

spamMessage = "Get crashed by Proton you fat coons."

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
    if enums.html_response_codes[response_code] ~= "OK" then 
        menu.notify("Update failed.", "Automatic Crash All", 2, 0xff0000)
    else 
        local file = io.open(utils.get_appdata_path("PopstarDevs", "2Take1Menu").."\\".."scripts\\automatic crash all.lua", "w+b")
        file:write(response_body)
        file:flush()
    end
    --utils.get_appdata_path("PopstarDevs", "2Take1Menu")
end

menu.create_thread(function()
    if not menu.is_trusted_mode_enabled(8) then 
        menu.notify("Trusted mode HTTP required for auto update!", "Automatic Crash All", 2, 0xff0000)
    else 
        local response_code, response_body, response_headers = web.get("https://raw.githubusercontent.com/ProtonDev-sys/Automatic-Crash-gta-v/main/version")
        if response_body:match( "^%s*(.-)%s*$" ) ~= VERSION:match( "^%s*(.-)%s*$" ) then 
            menu.notify("Current version outdated, updating.", "Automatic Crash All", 2, 0xff0000)
            update_script()
        else
            menu.notify("You are using the latest version, welcome.", "Automatic Crash All", 2, 0xff00ff)
        end 
    end
    menu.notify("Automatic crash all loaded version "..VERSION, "Automatic Crash All", 2, 0xff00ff)
end)
