sub init()
    m.top.functionName = "executeRequest"
end sub

sub executeRequest()
    url = m.top.url
    if url = invalid or url = "" then
        m.top.error = "Missing API URL"
        return
    end if
    xfer = CreateObject("roUrlTransfer")
    xfer.SetUrl(url)
    xfer.SetRequest("Accept", "application/json")
    xfer.SetTimeout(20000)
    port = CreateObject("roMessagePort")
    xfer.SetMessagePort(port)
    if not xfer.AsyncGetToString() then
        m.top.error = "Could not start API request"
        return
    end if
    msg = wait(22000, port)
    if msg = invalid then
        xfer.AsyncCancel()
        m.top.error = "API request timed out"
        return
    end if
    if type(msg) <> "roUrlEvent" then
        m.top.error = "Unexpected API response"
        return
    end if
    if msg.GetResponseCode() < 200 or msg.GetResponseCode() >= 300 then
        m.top.error = "API returned HTTP " + msg.GetResponseCode().ToStr()
        return
    end if
    parsed = ParseJson(msg.GetString())
    if parsed = invalid then
        m.top.error = "API returned invalid JSON"
        return
    end if
    m.top.result = parsed
end sub
