sub init()
    m.heading = m.top.findNode("heading")
    m.status = m.top.findNode("status")
    m.grid = m.top.findNode("animeGrid")
    m.grid.observeField("itemSelected", "onAnimeSelected")
    m.apiBase = m.top.apiBase
    m.request = CreateObject("roSGNode", "RequestTask")
    m.request.observeField("result", "onHomeLoaded")
    m.request.observeField("error", "onRequestError")
    m.request.url = m.apiBase + "/home?limit=30"
    m.request.control = "RUN"
    m.grid.setFocus(true)
end sub

sub onHomeLoaded()
    data = m.request.result
    if data = invalid then return
    rows = CreateObject("roSGNode", "ContentNode")
    latest = data.latest_aired
    if type(latest) = "roArray" then
        for each anime in latest
            addAnime(rows, anime)
        end for
    else if type(latest) = "roAssociativeArray" then
        addAnimeList(rows, latest)
    end if
    weekly = data.top_weekly
    if type(weekly) = "roArray" then
        for each anime in weekly
            addAnime(rows, anime)
        end for
    else if type(weekly) = "roAssociativeArray" then
        addAnimeList(rows, weekly)
    end if
    if rows.getChildCount() = 0 then
        m.status.text = "No anime returned. Try again later."
    else
        m.grid.content = rows
        m.status.text = "Choose an anime"
    end if
end sub

sub addAnimeList(parent, obj)
    for each key in obj
        val = obj[key]
        if type(val) = "roArray" then
            for each anime in val
                addAnime(parent, anime)
            end for
        end if
    end for
end sub

sub addAnime(parent, anime)
    if type(anime) <> "roAssociativeArray" then return
    title = firstValue(anime, ["title", "name", "english_title", "romaji"], "Untitled")
    slug = firstValue(anime, ["slug", "id"], "")
    if slug = "" then return
    item = parent.createChild("ContentNode")
    item.title = title
    item.shortDescriptionLine1 = title
    item.description = firstValue(anime, ["description", "synopsis"], "")
    item.hdPosterUrl = firstValue(anime, ["poster", "image", "cover", "cover_image"], "")
    if type(item.hdPosterUrl) = "roAssociativeArray" then
        item.hdPosterUrl = firstValue(item.hdPosterUrl, ["large", "extra_large", "medium"], "")
    end if
    item.addFields({slug: slug})
end sub

sub onAnimeSelected()
    index = m.grid.itemSelected
    content = m.grid.content
    if content = invalid or index < 0 then return
    item = content.getChild(index)
    if item = invalid then return
    m.status.text = item.title + "  •  " + item.description
    m.status.text = Left(m.status.text, 150)
    ' Details and playback are added in the next implementation step.
end sub

sub onRequestError()
    if m.request.error <> invalid and m.request.error <> "" then
        m.status.text = "API error: " + m.request.error
    end if
end sub
