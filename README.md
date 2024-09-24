# Hammerspoon_Scripts
Repository for my Hammerspoon Lua scripts

## ./pause_spotify_on_zoom

This `init.lua` script for Hammerspoon does the following:

Detects when a zoom meeting starts and ends

1. If Spotify is running, and playing a song... it pauses it when meeting starts
1. If Spotify is running, and song was playing before... it resumes it when meeting ends
1. If you connect another input device... it detects it, and reverts back to your default (in my case, I like the MacBook microphone)