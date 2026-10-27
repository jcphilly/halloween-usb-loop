' Halloween USB Loop
' Plays every video found on attached USB drives in an endless loop.
' Falls back to a built-in test clip when no USB videos are found.
' Rescans automatically when a USB drive is inserted or removed.

' Normal channel launch (remote, or: curl -d '' http://<roku-ip>:8060/launch/dev)
sub Main(args as Dynamic)
    RunLoop()
end sub

' Screensaver entry point (Settings > Theme > Screensaver > Halloween USB Loop)
sub RunScreenSaver(params as Dynamic)
    RunLoop()
end sub

sub RunLoop()
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    scene = screen.CreateScene("LoopScene")
    screen.Show()

    fs = CreateObject("roFileSystem")
    fs.SetMessagePort(port)

    scene.content = BuildPlaylist(fs)

    while true
        msg = wait(0, port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.IsScreenClosed() then return
        else if msgType = "roFileSystemEvent"
            ' A USB drive was inserted or removed. Rebuild the playlist.
            scene.content = BuildPlaylist(fs)
        end if
    end while
end sub

function BuildPlaylist(fs as Object) as Object
    playlist = CreateObject("roSGNode", "ContentNode")
    formats = { mp4: "mp4", m4v: "mp4", mov: "mp4", mkv: "mkv" }

    for each volume in fs.GetVolumeList()
        if Left(volume, 3) = "ext"
            AddVideos(fs, volume + "/", formats, playlist, 0)
        end if
    end for

    if playlist.GetChildCount() = 0
        item = playlist.CreateChild("ContentNode")
        item.url = "pkg:/media/builtin_test.mp4"
        item.streamFormat = "mp4"
        item.title = "Built-in test clip"
    end if

    print "Halloween USB Loop: playlist has "; playlist.GetChildCount(); " item(s)"
    return playlist
end function

sub AddVideos(fs as Object, dirPath as String, formats as Object, playlist as Object, depth as Integer)
    names = []
    for each name in fs.GetDirectoryListing(dirPath)
        names.Push(name)
    end for
    names.Sort("i")

    extRegex = CreateObject("roRegex", "\.([A-Za-z0-9]+)$", "")

    for each name in names
        ' Skip hidden files (including macOS "._" files) and Windows system folders.
        skip = Left(name, 1) = "." or Left(name, 1) = "$" or Left(name, 13) = "System Volume"
        if not skip
            fullPath = dirPath + name
            info = fs.Stat(fullPath)
            if info <> invalid and info.type = "directory"
                if depth < 3 then AddVideos(fs, fullPath + "/", formats, playlist, depth + 1)
            else
                match = extRegex.Match(name)
                if match.Count() > 1
                    ext = LCase(match[1])
                    if formats.DoesExist(ext)
                        item = playlist.CreateChild("ContentNode")
                        item.url = fullPath
                        item.streamFormat = formats[ext]
                        item.title = name
                        print "  + "; fullPath
                    end if
                end if
            end if
        end if
    end for
end sub
