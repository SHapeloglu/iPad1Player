# Alpha15 — Suite Scope Enforcement + iPad 1 Audio Foundation

## Mandatory suite filter

iPad1Player owns only media playback responsibilities.

### iPad1Player
- demux
- audio/video decode
- audio output
- renderer
- A/V sync
- seek/resume
- playback controls
- subtitles
- audio/subtitle track selection
- chapters/media info
- playback diagnostics

### iPad1Files
- directory browsing
- file search/sort
- rename/copy/move/delete
- folder creation
- archive/ZIP/RAR
- generic file information and favorites

### iPad1PDFReader
- PDF rendering
- PDF page navigation
- PDF text/read mode
- document reading
- PDF bookmarks

### iPad1Downloader
- HTTP/HTTPS/FTP download
- download queue
- resume/retry
- persistent remote-file transfer

Player must never grow these responsibilities merely because competitors bundle them.

## Alpha15 Player-only work

### Low-memory PCM foundation
- fixed 256 KB PCM ring buffer
- no unbounded decoded-audio queue
- flush on stop/memory warning
- selected-audio-track-only policy

### Safe audio defaults
- preferred stereo output
- 44.1 kHz preferred baseline
- AAC/MP3 are Tier 1
- AC3/E-AC3 remain disabled by default until device testing

### Video policy
- 480p software H.264 may be tested
- 720p software H.264 is not a primary path
- hardware/hybrid H.264 remains test-gated

## Important
Alpha15 does not claim real AAC/MP3 decoding or PCM device output yet.
It provides the Player-owned low-memory runtime boundary required for that next step.
