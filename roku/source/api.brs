function firstValue(obj as Object, keys as Object, fallback as String) as String
    for each key in keys
        if obj.DoesExist(key) and obj[key] <> invalid then
            value = obj[key]
            if type(value) = "roString" and value <> "" then return value
            if type(value) = "roInt" or type(value) = "roInteger" then return value.ToStr()
        end if
    end for
    return fallback
end function
