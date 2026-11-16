function firstValue(obj as Object, keys as Object, fallback as String) as String
    if type(obj) <> "roAssociativeArray" then return fallback
    for each key in keys
        if obj.DoesExist(key) and obj[key] <> invalid then
            value = obj[key]
            if type(value) = "roString" and value <> "" then return value
            if type(value) = "roInt" or type(value) = "roInteger" or type(value) = "roFloat" then return value.ToStr()
        end if
    end for
    return fallback
end function

function encodeURIComponent(value as String) as String
    result = ""
    for i = 1 to Len(value)
        ch = Mid(value, i, 1)
        code = Asc(ch)
        if (code >= 48 and code <= 57) or (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or ch = "-" or ch = "_" or ch = "." or ch = "~" then
            result = result + ch
        else
            result = result + "%" + UCase(Right("0" + Hex(code), 2))
        end if
    end for
    return result
end function
