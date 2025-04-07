local environment = GetConvar("environment", "development")
local Webhook = Config.Webhooks[environment] or Config.Webhooks["fallback"]
local Core = exports.vorp_core:GetCore()

-- On Server Start
AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        sendToDiscordEmbed({
            username = "System",
            title = "🟢 Server Started",
            color = 65280,
            author = {
                name = "Server Status",
                icon = ""
            },
            timestamp = true
        })
    end
end)

-- Server Stop Logging
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        sendToDiscordEmbed({
            username = "System",
            title = "🔴 Server Stopping",
            color = 16711680,
            author = {
                name = "Server Status",
                icon = ""
            },
            timestamp = true
        })
    end
end)

-- On player join
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local player = source
    local identifiers = GetPlayerIdentifiers(player)
    local playerID = tonumber(source)-65535

    local idList = ""
    for _, id in ipairs(identifiers) do
        idList = idList .. id .. "\n"
    end

    sendToDiscordEmbed({
        username = "Connection Manager",
        title = "Player Connecting",
        description = string.format("**%s** is connecting to the server.", name),
        color = 65280,
        fields = {
            { name = "Player ID", value = tostring(playerID), inline = true },
            { name = "Identifiers", value = idList ~= "" and idList or "No identifiers found", inline = false }
        },
        author = {
            name = "Server Events",
        },
        timestamp = true
    })
end)

-- On player leave
AddEventHandler('playerDropped', function (reason, resourceName, clientDropReason)
    local player = source
    local identifiers = GetPlayerIdentifiers(player)
    local name = GetPlayerName(source)
    local playerID = tonumber(source)-65535

    local idList = ""
    for _, id in ipairs(identifiers) do
        idList = idList .. id .. "\n"
    end

    sendToDiscordEmbed({
        username = "Connection Manager",
        title = "Player Dropped",
        description = string.format("**%s** (%s) has left the server.", name, source),
        color = 16711680,
        fields = {
            { name = "Reason", value = reason, inline = true },
            { name = "Resource", value = resourceName, inline = false },
            { name = "Identifiers", value = idList ~= "" and idList or "No identifiers found", inline = false }
        },
        author = {
            name = "Server Events",
        },
        timestamp = true
    })
end)


-- On character select
AddEventHandler("vorp:SelectedCharacter", function(source, character)
    local player = source
    local playerName = GetPlayerName(source)
    local identifier     = character.identifier
    local charIdentifier = character.charIdentifier
    local job            = character.job
    local jobGrade       = character.jobGrade
    local money          = character.money
    local firstname      = character.firstname
    local lastname       = character.lastname
    local fullname       = firstname .. " " .. lastname
    local coords         = character.coords or {}

    if type(coords) == "string" then
        local decoded = json.decode(coords)
        if decoded then coords = decoded else coords = {} end
    end

    local isDead = character.isdead and "Yes" or "No"
    local age    = character.age

    local x = coords.x or 0.0
    local y = coords.y or 0.0
    local z = coords.z or 0.0
    local heading = coords.heading or 0.0

    sendToDiscordEmbed({
        username = "Characters",
        title = "Character Selected",
        description = string.format("**%s** has selected their character.", playerName),
        color = 16427830,
        fields = {
            { name = "Full Name", value = fullname, inline = true },
            { name = "Age", value = tostring(age), inline = true },
            { name = "Job", value = string.format("%s (Grade %s)", job, jobGrade), inline = true },
            { name = "Money", value = "$" .. tostring(money), inline = true },
            { name = "Is Dead", value = isDead, inline = true },
            { name = "Coords", value = string.format("X: %.2f\nY: %.2f\nZ: %.2f\nHeading: %.2f", x, y, z, heading), inline = false },
            { name = "Char ID", value = charIdentifier, inline = true },
            { name = "Identifier", value = identifier, inline = false }
        },
        author = {
            name = "The Trail Roleplay",
        },
        timestamp = true
    })
end)

RegisterNetEvent("js_discordhook:newCharacter")
AddEventHandler("js_discordhook:newCharacter", function()
    local src = source
    local user = Core.getUser(src) --[[@as User]]
    local player = src
    local playerName = GetPlayerName(src)

    if not user then return end

    sendToDiscordEmbed({
        username = "Characters",
        title = "New Character Created",
        description = string.format("**%s** has created a new character.", playerName),
        color = 1123583,
        author = {
            name = "The Trail Roleplay",
        },
        timestamp = true
    })

end)

RegisterNetEvent("vorp_core:Server:OnPlayerDeath", function(killerServerId, causeOfDeath)
    local victimId = source
    local victimName = GetPlayerName(victimId) or "Unknown"
    local cause = causeOfDeath or "Unknown"
    local isSuicide
    local killerName
    
    if killerServerId ~= 0 then
        killerName = GetPlayerName(killerServerId)
        isSuicide = false
    else
        isSuicide = true
        killerName = "Unknown"
    end
    
    -- Prepare embed fields
    local fields = {
        { name = "🧍 Victim", value = victimName .. " (ID: " .. victimId .. ")", inline = true },
        { name = "💀 Cause of Death", value = cause, inline = true }
    }

    if not isSuicide then
        table.insert(fields, {
            name = "🔫 Killer",
            value = killerName .. " (ID: " .. killerServerId .. ")",
            inline = true
        })
    else
        table.insert(fields, {
            name = "🔁 Note",
            value = "This was a suicide.",
            inline = false
        })
    end

    -- Call internal embed function directly
    sendToDiscordEmbed({
        title = "☠️ Player Death",
        description = isSuicide
            and string.format("**%s** died by suicide (Cause: `%s`).", victimName, cause)
            or string.format("**%s** was killed by **%s** (Cause: `%s`).", victimName, killerName, cause),
        color = 16427830,
        fields = fields,
        timestamp = true
    })
end)


AddEventHandler("vorp_core:Server:OnPlayerRevive", function(source)
    local playerId = source
    local playerName = GetPlayerName(playerId) or "Unknown"

    -- Send the embed
    sendToDiscordEmbed({
        title = "💚 Player Revived",
        description = string.format("**%s** (ID: %s) has been revived.", playerName, playerId),
        color = 16427830,
        fields = {
            { name = "Player Name", value = playerName, inline = true },
            { name = "Player ID", value = tostring(playerId), inline = true }
        },
        timestamp = true
    })
end)

AddEventHandler("vorp_core:Server:OnPlayerRespawn", function(source)
    local playerId = source
    local playerName = GetPlayerName(playerId) or "Unknown"

    -- Send the embed
    sendToDiscordEmbed({
        title = "🔄 Player Respawned",
        description = string.format("**%s** (ID: %s) has respawned.", playerName, playerId),
        color = 16427830,
        fields = {
            { name = "Player Name", value = playerName, inline = true },
            { name = "Player ID", value = tostring(playerId), inline = true }
        },
        timestamp = true
    })
end)


-- General-purpose Discord embed sender with debug logging (toggleable via Config.Debug)
function sendToDiscordEmbed(options, webhookOveride)
    if Config.Debug then print("[DEBUG] sendToDiscordEmbed called") end

    -- Debug options
    if Config.Debug then
        print("[DEBUG] Options received:")
        print(json.encode(options, { indent = true }))
    end

    local embed = {
        title = options.title or nil,
        description = options.description or nil,
        color = options.color or Config.EmbedColor,
        fields = options.fields or nil,
        footer = options.footer or { text = "The Trail Roleplay", icon_url = "https://i.ibb.co/9k27jpCP/ttrplogo.png" },
        image = options.image and { url = options.image } or nil,
        thumbnail = options.thumbnail and { url = options.thumbnail } or nil,
        author = options.author and { name = options.author.name or "", icon_url = options.author.icon or "https://i.ibb.co/9k27jpCP/ttrplogo.png" } or nil,
        timestamp = options.timestamp ~= false and os.date("!%Y-%m-%dT%H:%M:%SZ") or nil
    }

    -- Debug embed structure
    if Config.Debug then
        print("[DEBUG] Embed constructed:")
        print(json.encode(embed, { indent = true }))
    end

    local webhookToUse = webhookOveride or Webhook
    if Config.Debug then
        if webhookOveride then
            print("[DEBUG] Using webhook override: " .. webhookOveride)
        else
            print("[DEBUG] Using default webhook: " .. tostring(Webhook))
        end
    end

    local payload = {
        username = options.username or "The Trail Roleplay",
        avatar_url = options.avatar_url or Config.AvatarURL,
        embeds = { embed }
    }

    -- Debug payload
    if Config.Debug then
        print("[DEBUG] Payload to be sent:")
        print(json.encode(payload, { indent = true }))
    end

    PerformHttpRequest(webhookToUse, function(err, text, headers)
        if Config.Debug then
            print("[DEBUG] Discord webhook response:")
            print("Status Code: " .. tostring(err))
            print("Response Text: " .. tostring(text))
            print("Headers: " .. json.encode(headers, { indent = true }))
        end
    end, "POST", json.encode(payload), {
        ["Content-Type"] = "application/json"
    })
end


RegisterNetEvent("js_discordhook:sendEmbed")
AddEventHandler("js_discordhook:sendEmbed", function(embedData, webhookOveride)
    if Config.Debug then
        print("[DEBUG] Event 'js_discordhook:sendEmbed' triggered")
        print("[DEBUG] embedData:")
        print(json.encode(embedData, { indent = true }))

        if webhookOveride then
            print("[DEBUG] webhookOveride provided: " .. tostring(webhookOveride))
        else
            print("[DEBUG] No webhook override provided, using default webhook")
        end
    end

    -- Validate that embedData is a table before calling
    if type(embedData) ~= "table" then
        if Config.Debug then
            print("[ERROR] Invalid embedData: Expected table, got " .. type(embedData))
        end
        return
    end

    sendToDiscordEmbed(embedData, webhookOveride)
end)



exports("sendToDiscordEmbed", sendToDiscordEmbed)
