local Core = exports.vorp_core:GetCore()

function sendToDiscordEmbed(embedData, webhookOveride)
    print("sending embed")
    TriggerServerEvent("js_discordhook:sendEmbed", embedData, webhookOveride)
end

AddEventHandler("vorp:initNewCharacter", function()
    print("New Character Created")
    TriggerServerEvent("js_discordhook:newCharacter")
end)