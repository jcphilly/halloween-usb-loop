sub init()
    m.player = m.top.FindNode("player")
    m.player.ObserveField("state", "onStateChanged")
    m.player.SetFocus(true)
    m.errorCount = 0
end sub

sub onContentChanged()
    content = m.top.content
    if content = invalid then return

    m.player.control = "stop"
    m.player.contentIsPlaylist = true
    m.player.loop = true
    m.player.content = content
    m.player.control = "play"
    m.errorCount = 0
end sub

sub onStateChanged()
    state = m.player.state
    if state = "playing"
        m.errorCount = 0
    else if state = "error"
        ' A file the Roku can't decode. Skip it instead of stalling.
        print "Halloween USB Loop: playback error: "; m.player.errorMsg
        m.errorCount = m.errorCount + 1
        count = m.top.content.GetChildCount()
        if count > 1 and m.errorCount < count
            m.player.nextContentIndex = (m.player.contentIndex + 1) mod count
            m.player.control = "play"
        end if
    end if
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    ' Swallow Back so a stray press doesn't exit the loop. Home still exits.
    if key = "back" then return true
    return false
end function
