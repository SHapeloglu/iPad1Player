# iPad1Player responsibility rules

## iPad1Player owns

- Media playback lifecycle.
- Media decode/demux backends.
- Playback controls, seeking and aspect ratio.
- Playback position / resume state.
- Audio/video synchronization.
- External subtitle parsing, rendering, enable/disable and timing offset.
- Embedded media track discovery and selection.
- Playback diagnostics such as unsupported codec/container messages.

## iPad1Player does not own

The following belong to iPad1Files or another dedicated suite app:

- Directory browsing.
- File search/sort/favorites.
- Copy/move/delete/rename.
- Folder creation.
- ZIP/RAR/archive management.
- Generic text/image/document viewing.
- Download management or general FTP file management.

## Suite rule

Before adding a feature, ask whether it is required to **play the media itself**. If not, apply the suite responsibility filter before implementation.


## Alpha15 enforcement

`IP1SuiteScopeGate` makes the responsibility rule available to code, not just documentation.

Player-owned keys include playback, demux/decode, renderer, A/V sync, subtitles, tracks,
chapters and diagnostics.

File operations, document/PDF reading and download management are explicitly outside Player scope.


## Alpha16 clarification

MKV/H.264 playback is explicitly a Player responsibility. It must not be moved to
iPad1Files or iPad1PDFReader simply because the media originates from those apps.

Those applications hand the local path to Player; Player owns demux/decode/render.


## Alpha17 suite review

AAC/MP3 decode, PCM buffering and AudioQueue playback are all intrinsic playback
responsibilities and therefore remain in iPad1Player.

No corresponding feature was added to iPad1Files, iPad1PDFReader or iPad1Downloader.


## Alpha18 suite review

The end-to-end demux -> AAC/MP3 decode -> PCM -> AudioQueue -> clock loop is a pure
playback concern. No parallel implementation is needed in Files, PDFReader or Downloader.
