#Include JSON.ahk

HttpGetJSON() {
    AuthorizationToken := ""
    URL := "https://api.lzt.market/user/orders"

    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    http.Open("GET", URL, false)
    http.SetRequestHeader("Accept", "application/json")
    http.SetRequestHeader("Authorization", "Bearer " AuthorizationToken)

    try {
        http.Send()
        If (FileExist("accounts.json")) {
            FileDelete, accounts.json
        }
        jsonText := http.ResponseText
        FileAppend, %jsonText%, accounts.json
    } catch e {
        MsgBox, Error during HTTP request: %e%`n%ErrorLevel%
    }
    return
}

ExtractTelegramIdPhones() {
    phonesIdsMap := {}
    FileRead, textVar, accounts.json
    jsonObj := JSON.Load(textVar)
    for index, item in jsonObj.items {
        id := item.item_id
        phone := item.telegram_phone
        phonesIdsMap[phone] := id
    }
    return phonesIdsMap
}

LoadTelegram(num, numId) {
    Run, "C:\Program Files\Google\Chrome\Application\chrome.exe" --incognito
    Sleep, 2000
    Send, ^l
    Sleep, 200
    Send, https://web.telegram.org/a/
    Send, {Enter}
    Sleep, 5000
    MouseClick, Left, 1000, 680, 3
    Send, %num%
    MouseClick, Left, 1000, 680, 3
    Send, %num%
    MouseClick, Left, 1000, 800
    Sleep, 10000
    code := GetTelegramCode(numId)
    MouseClick, Left, 1000, 570
    Send, %code%
    Sleep, 3000
    MsgBox, "Finished"
    Return
}

GetTelegramCode(numId) {
    AuthorizationToken := "TOKEN"
    URL := "https://api.lzt.market/" . numId . "/telegram-login-code"

    http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    http.Open("GET", URL, false)
    http.SetRequestHeader("Accept", "application/json")
    http.SetRequestHeader("Authorization", "Bearer " AuthorizationToken)

    http.Send()
    responseText := http.responseText
    FileDelete, code.json
    FileAppend, %responseText%, code.json
    FileRead, jsonText, code.json
    RegExMatch(jsonText, """code"":\s*""(\d+)""", match)
    MsgBox, Match: %match%
    return match
}

Start() {
    try {
        HttpGetJSON()
        phonesIdsMap := ExtractTelegramIdPhones()
        For phone, id in phonesIdsMap {
            LoadTelegram(phone, id)
            Return ;TODO: remove
        }
    } Catch, e {
        MsgBox, Error during process: %e%`n%ErrorLevel%
    }
    Return
}

Start()
