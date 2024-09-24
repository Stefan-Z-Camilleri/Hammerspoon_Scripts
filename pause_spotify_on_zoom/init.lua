-- Hammerspoon Init Script

-- Name of the applications and window to monitor
local zoomAppName = "zoom.us"
local meetingWindowName = "Zoom Meeting"
local spotifyAppName = "Spotify"
local defaultInputDeviceName = "MacBook Pro Microphone"

-- Create a window filter to monitor windows
local windowFilter = hs.window.filter.new()

-- Variable to track Spotify playback state
local wasSpotifyPlaying = false

-- Function to check if Spotify is playing
local function checkSpotifyPlayback()
    if hs.application.find(spotifyAppName) then
        if hs.spotify.isPlaying() then
            wasSpotifyPlaying = true
            hs.spotify.pause()
            return " | Paused Spotify"
        else
            wasSpotifyPlaying = false
        end
    end
    return ""
end

-- Function to show alerts at the bottom of the screen
local function showAlert(message)
    hs.alert.show(message, {
        interval = 3      -- Duration of the alert
    })
end

-- Function to handle window events
local function windowEventHandler(window, appName, eventType)
    if eventType == hs.window.filter.windowCreated and window then
        local windowTitle = window:title()

        -- Check for meeting window events
        if windowTitle == meetingWindowName then
            local alertMessage = "Meeting started" .. checkSpotifyPlayback()
            showAlert(alertMessage)
        end
    elseif eventType == hs.window.filter.windowDestroyed and appName == zoomAppName then
        -- Check if the "Zoom Meeting" window still exists
        local zoomApp = hs.application.find(zoomAppName)
        local meetingWindow = zoomApp and zoomApp:findWindow(meetingWindowName)

        if not meetingWindow then
            -- If the meeting window does not exist, the meeting has ended
            local alertMessage = "Meeting ended"
            
            -- Resume Spotify if it was playing before the meeting started
            if wasSpotifyPlaying and hs.application.find(spotifyAppName) then
                hs.spotify.play()
                alertMessage = alertMessage .. " | Resuming Spotify playback"
            end

            showAlert(alertMessage)
        end
    end
end

-- Function to check if a meeting is already running
local function checkForExistingMeeting()
    local zoomApp = hs.application.find(zoomAppName)
    if zoomApp then
        local meetingWindow = zoomApp:findWindow(meetingWindowName)
        if meetingWindow then
            local alertMessage = "Meeting detected (already running)" .. checkSpotifyPlayback()
            showAlert(alertMessage)
        end
    end
end

-- Function to handle audio device changes
local function audioDeviceChanged(event)
    local currentInputDevice = hs.audiodevice.defaultInputDevice()

    -- Check if the current input device is not the default
    if currentInputDevice:name() ~= defaultInputDeviceName then
        showAlert("Input device changed to " .. currentInputDevice:name() .. ". Reverting to default: " .. defaultInputDeviceName)

        -- Set the input device back to the default
        local defaultInputDevice = hs.audiodevice.findDeviceByName(defaultInputDeviceName)
        if defaultInputDevice then
            defaultInputDevice:setDefaultInputDevice()
            showAlert("Changed input device back to " .. defaultInputDeviceName)
        else
            showAlert("Default input device not found!")
        end
    end
end

-- Set the window filter to watch for all windows and add the event handler
windowFilter:subscribe(hs.window.filter.windowCreated, windowEventHandler)
windowFilter:subscribe(hs.window.filter.windowDestroyed, windowEventHandler)

-- Check for existing meetings when the script loads
checkForExistingMeeting()

-- Optionally, show an initial message when the script loads
showAlert("Monitoring for Zoom Meeting...")

-- Start the audio device watcher
hs.audiodevice.watcher.setCallback(audioDeviceChanged)
hs.audiodevice.watcher.start()
