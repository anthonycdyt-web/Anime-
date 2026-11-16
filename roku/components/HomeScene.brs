sub init()
    m.heading = m.top.findNode("heading")
    m.status = m.top.findNode("status")
    m.grid = m.top.findNode("animeGrid")
    m.searchButton = m.top.findNode("searchButton")
    m.detailTitle = m.top.findNode("detailTitle")
    m.detailText = m.top.findNode("detailText")
    m.episodeHeading = m.top.findNode("episodeHeading")
    m.episodeList = m.top.findNode("episodeList")
    m.video = m.top.findNode("video")
    m.grid.observeField("itemSelected", "onAnimeSelected")
    m.episodeList.observeField("itemSelected", "onEpisodeSelected")
    m.searchButton.observeField("buttonSelected", "onSearch")
    m.video.observeField("state", "onVideoState")
    m.apiBase = m.top.apiBase
    m.mode = "home"
    loadHome()
    m.grid.setFocus(true)
end sub

sub loadHome()
    m.mode = "home"
    showHome()
    m.status.text = "Loading anime..."
    requestUrl(m.apiBase + "/home?limit=30", "home")
end sub

sub requestUrl(url as String, purpose as String)
    task = CreateObject("roSGNode", "RequestTask")
    task.observeField("result", "onRequestResult")
    task.observeField("error", "onRequestError")
    task.url = url
    task.addFields({purpose: purpose})
    task.control = "RUN"
    if m.tasks = invalid then m.tasks = []
    m.tasks.push(task)
end sub

sub onRequestResult(event as Object)
    task = event.getRoSGNode()
    data = task.result
    purpose = task.purpose
    if data = invalid then return
    if purpose = "home" or purpose = "search" then
        populateAnime(data)
    else if purpose = "details" then
        showDetails(data)
    else if purpose = "servers" then
        beginStream(data)
    else if purpose = "stream" then
        playStream(data)
    end if
end sub

sub populateAnime(data as Object)
    rows = CreateObject("roSGNode", "ContentNode")
    if type(data) = "roArray" then
        addAnimeList(rows, data)
    else if type(data) = "roAssociativeArray" then
        if data.DoesExist("latest_aired") then addAnimeList(rows, data.latest_aired)
        if data.DoesExist("top_weekly") then addAnimeList(rows, data.top_weekly)
        if data.DoesExist("results") then addAnimeList(rows, data.results)
        if data.DoesExist("data") then addAnimeList(rows, data.data)
    end if
    if rows.getChildCount() = 0 then
        m.status.text = "No anime found. Try another search."
    else
        m.grid.content = rows
        m.status.text = rows.getChildCount().ToStr() + " anime — select one"
    end if
end sub

sub addAnimeList(parent as Object, items as Dynamic)
    if type(items) = "roArray" then
        for each anime in items
            addAnime(parent, anime)
        end for
    else if type(items) = "roAssociativeArray" then
        if items.DoesExist("results") then addAnimeList(parent, items.results)
        if items.DoesExist("data") then addAnimeList(parent, items.data)
        if items.DoesExist("anime") then addAnimeList(parent, items.anime)
    end if
end sub

sub addAnime(parent as Object, anime as Dynamic)
    if type(anime) <> "roAssociativeArray" then return
    title = firstValue(anime, ["title", "name", "english_title", "romaji"], "Untitled")
    slug = firstValue(anime, ["slug", "id"], "")
    if slug = "" then return
    item = parent.createChild("ContentNode")
    item.title = title
    item.shortDescriptionLine1 = title
    item.description = firstValue(anime, ["description", "synopsis"], "")
    poster = anime.cover_image
    if type(poster) = "roAssociativeArray" then
        poster = firstValue(poster, ["large", "extra_large", "medium"], "")
    else if poster = invalid then
        poster = firstValue(anime, ["poster", "image", "cover"], "")
    end if
    item.hdPosterUrl = poster
    item.addFields({slug: slug})
end sub

sub onAnimeSelected()
    if m.mode <> "home" then return
    index = m.grid.itemSelected
    content = m.grid.content
    if content = invalid or index < 0 then return
    item = content.getChild(index)
    if item = invalid then return
    m.selectedSlug = item.slug
    m.status.text = "Loading " + item.title + "..."
    requestUrl(m.apiBase + "/info/" + m.selectedSlug, "details")
end sub

sub showDetails(data as Object)
    m.mode = "details"
    m.grid.visible = false
    m.detailTitle.visible = true
    m.detailText.visible = true
    m.episodeHeading.visible = true
    m.episodeList.visible = true
    m.video.visible = false
    title = firstValue(data, ["title", "name"], "Anime details")
    m.detailTitle.text = title
    m.detailText.text = firstValue(data, ["description", "synopsis"], "Choose an episode.")
    eps = data.episodes
    nodes = CreateObject("roSGNode", "ContentNode")
    if type(eps) = "roArray" then
        for each ep in eps
            if type(ep) = "roAssociativeArray" then
                epTitle = firstValue(ep, ["title", "name"], "Episode")
                epNum = firstValue(ep, ["number", "episode", "episode_number"], "")
                node = nodes.createChild("ContentNode")
                if epNum <> "" then epTitle = "Episode " + epNum + " — " + epTitle
                node.title = epTitle
                node.addFields({episodeNumber: Val(epNum)})
            end if
        end for
    end if
    m.episodeList.content = nodes
    if nodes.getChildCount() = 0 then m.status.text = "No episode list was returned."
    m.episodeList.setFocus(true)
end sub

sub onEpisodeSelected()
    if m.mode <> "details" then return
    idx = m.episodeList.itemSelected
    list = m.episodeList.content
    if list = invalid or idx < 0 then return
    selected = list.getChild(idx)
    ep = selected.episodeNumber
    if ep = invalid or ep < 1 then ep = idx + 1
    m.currentEpisode = ep
    m.status.text = "Finding stream for episode " + ep.ToStr() + "..."
    requestUrl(m.apiBase + "/servers/" + m.selectedSlug + "/" + ep.ToStr(), "servers")
end sub

sub beginStream(data as Object)
    links = data.sub
    if type(links) <> "roArray" or links.Count() = 0 then links = data.dub
    if type(links) <> "roArray" or links.Count() = 0 then
        m.status.text = "No streaming servers available for this episode."
        return
    end if
    link = links[0].dataLink
    if link = invalid or link = "" then
        m.status.text = "The selected server did not return a stream link."
        return
    end if
    m.status.text = "Preparing video..."
    requestUrl(m.apiBase + "/stream/from-link?link=" + encodeURIComponent(link), "stream")
end sub

sub playStream(data as Object)
    streamUrl = data.url
    if streamUrl = invalid or streamUrl = "" then
        m.status.text = "The server did not return a video URL."
        return
    end if
    content = CreateObject("roSGNode", "ContentNode")
    content.url = streamUrl
    content.title = m.detailTitle.text + " — Episode " + m.currentEpisode.ToStr()
    content.streamFormat = "hls"
    m.video.content = content
    m.video.visible = true
    m.grid.visible = false
    m.detailTitle.visible = false
    m.detailText.visible = false
    m.episodeHeading.visible = false
    m.episodeList.visible = false
    m.mode = "video"
    m.video.setFocus(true)
    m.video.control = "play"
end sub

sub onVideoState()
    if m.video.state = "error" then m.status.text = "Playback failed. This stream may not support Roku."
    if m.video.state = "finished" then m.status.text = "Episode finished."
end sub

sub onSearch()
    keyboard = CreateObject("roSGNode", "Keyboard")
    keyboard.title = "Search anime"
    keyboard.observeField("buttonSelected", "onSearchSubmitted")
    m.searchKeyboard = keyboard
    m.top.dialog = keyboard
end sub

sub onSearchSubmitted()
    query = m.searchKeyboard.text
    m.top.dialog = invalid
    if query = invalid or query = "" then return
    m.status.text = "Searching for " + query + "..."
    requestUrl(m.apiBase + "/search?q=" + encodeURIComponent(query) + "&limit=30", "search")
end sub

sub showHome()
    m.grid.visible = true
    m.detailTitle.visible = false
    m.detailText.visible = false
    m.episodeHeading.visible = false
    m.episodeList.visible = false
    m.video.visible = false
    m.searchButton.visible = true
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "back" then
        if m.mode = "video" then
            m.video.control = "stop"
            m.mode = "details"
            m.video.visible = false
            m.detailTitle.visible = true
            m.detailText.visible = true
            m.episodeHeading.visible = true
            m.episodeList.visible = true
            m.episodeList.setFocus(true)
            return true
        else if m.mode = "details" then
            loadHome()
            return true
        end if
    end if
    if key = "options" then
        onSearch()
        return true
    end if
    return false
end function

sub onRequestError(event as Object)
    task = event.getRoSGNode()
    if task.error <> invalid and task.error <> "" then m.status.text = "API error: " + task.error
end sub
