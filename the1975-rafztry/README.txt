═══════════════════════════════════════════════════════════════
  THE 1975 - RAFZTRY
  Premium Music Portfolio Web App
═══════════════════════════════════════════════════════════════

OVERVIEW
--------
A cinematic, premium music portfolio experience inspired by 
Spotify, Apple Music, and late-night listening dashboards.
Built as a single-page web app with vanilla HTML, CSS, and 
JavaScript — no external frameworks or dependencies required.

FEATURES
--------
- Cinematic intro screen with animated waveform & progress bar
- Spotify/Apple Music-style layout (sidebar, main, right panel)
- 5 studio albums with 68 tracks from The 1975 discography
- 4 curated playlists (Essentials, Late Night, Night Drive, Sad Songs)
- Full music player (play/pause, next/prev, seek, volume, shuffle, repeat, like)
- HTML Audio player with Web Audio API fallback for missing files
- Show-and-fade navigation (sections animate in/out smoothly)
- Staggered card animations for album grids and track lists
- Live search across songs, albums, and playlists
- Queue management (add, remove, reorder, clear)
- Lyrics panel with animated line highlighting
- Now Playing panel with album art, mood tags, and metadata
- PWA install prompt (auto-request with user choice)
- Service worker for offline caching
- Fully responsive (desktop, tablet, mobile with bottom nav)
- Keyboard shortcuts (Space, arrows, S, R, L, M, Q, /)
- Toast notifications for user feedback
- Abstract CSS-gradient album covers (no copyrighted artwork)
- Demo placeholder audio (ambient tones per album mood)
- Placeholder lyrics (original text, not copyrighted)

DIRECTORY STRUCTURE
-------------------
the1975-rafztry/
├── index.html              Main web app (single file)
├── manifest.json           PWA manifest
├── service-worker.js       Offline caching service worker
├── README.txt              This file
├── assets/
│   ├── audio/              Demo audio files (WAV)
│   │   ├── the-1975-2013/      Album 1: The 1975 (16 tracks)
│   │   ├── iliwys-2016/        Album 2: ILIWYS (12 tracks)
│   │   ├── abiior-2018/        Album 3: ABIIOR (15 tracks)
│   │   ├── noacf-2020/         Album 4: NOACF (14 tracks)
│   │   └── bfiafl-2022/        Album 5: BFIAFL (11 tracks)
│   ├── covers/             Album & playlist cover images (PNG)
│   │   ├── the-1975-2013.png
│   │   ├── iliwys-2016.png
│   │   ├── abiior-2018.png
│   │   ├── noacf-2020.png
│   │   ├── bfiafl-2022.png
│   │   ├── playlist-essentials.png
│   │   ├── playlist-late-night.png
│   │   ├── playlist-night-drive.png
│   │   └── playlist-sad-songs.png
│   ├── lyrics/             Placeholder lyrics text files
│   │   ├── the-1975-2013/      (16 .txt files)
│   │   ├── iliwys-2016/        (12 .txt files)
│   │   ├── abiior-2018/        (15 .txt files)
│   │   ├── noacf-2020/         (14 .txt files)
│   │   └── bfiafl-2022/        (11 .txt files)
│   ├── icons/              PWA icons (72-512px PNG)
│   └── video/              Placeholder for video assets

INSTALLATION
------------
1. LOCAL: Open index.html in any modern browser (Chrome, Firefox, Safari, Edge)
2. SERVER: Upload the entire folder to any web server or static hosting
3. GITHUB PAGES: Push to a GitHub repo and enable Pages in Settings
4. NETLIFY/VERCEL: Drag and drop the folder to deploy instantly

For PWA install features (offline + install prompt), the site must 
be served over HTTPS.

REPLACING PLACEHOLDER MEDIA
----------------------------
The website is structured for easy replacement of all placeholder media:

1. AUDIO FILES:
   Replace WAV files in assets/audio/[album-dir]/ with licensed MP3/WAV files.
   File naming convention: [track-number]-[track-name-slug].wav
   Example: assets/audio/bfiafl-2022/11-about-you.wav
   The player will automatically use HTML Audio for playback.
   If a file is missing, it falls back to Web Audio API tones.

2. ALBUM COVERS:
   Replace PNG files in assets/covers/ with official artwork.
   Keep the same filenames (e.g., iliwys-2016.png).
   Recommended size: 500x500px or larger.

3. LYRICS:
   Replace text files in assets/lyrics/[album-dir]/ with licensed lyrics.
   One text file per track with plain text content.

4. VIDEO:
   Place MP4/WebM files in assets/video/ for intro or background video.
   See HTML comments in index.html for integration points.

KEYBOARD SHORTCUTS
------------------
Space       Play / Pause
Arrow Left  Seek back 5s (Shift: previous track)
Arrow Right Seek forward 5s (Shift: next track)
Arrow Up    Volume up
Arrow Down  Volume down
S           Toggle shuffle
R           Toggle repeat (off / all / one)
L           Like/unlike current track
M           Toggle mute
Q           Open queue
/           Open search
Escape      Go to home

BROWSER COMPATIBILITY
---------------------
- Chrome 80+
- Firefox 78+
- Safari 14+
- Edge 80+
- Mobile Chrome & Safari

COPYRIGHT NOTICE
----------------
This web app uses ONLY placeholder/demo media:
- Audio: Generated ambient tones (not real songs)
- Covers: Abstract gradient images (not official artwork)
- Lyrics: Original placeholder text (not copyrighted lyrics)

Song titles, album names, and artist information are used for 
educational/portfolio demonstration purposes only.

Replace all placeholder media with properly licensed content 
before any public or commercial distribution.

CREDITS
-------
Built by rafztry
Inspired by The 1975 discography
UI inspired by Spotify, Apple Music, and modern music dashboards

═══════════════════════════════════════════════════════════════
