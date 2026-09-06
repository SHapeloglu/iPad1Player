# Alpha18 — iPad 1 End-to-End Audio Loop

Alpha18 connects the Player-owned audio runtime path:

```
MKV/AVI
  -> av_read_frame
  -> selected AAC/MP3 stream only
  -> IP1FFmpegAudioDecoder
  -> packed S16 PCM
  -> bounded 256 KB PCM ring
  -> AudioQueue
  -> audio master clock
```

## iPad 1 constraints

- one demux thread only
- selected audio stream only
- all video/subtitle packets are skipped in this audio-only runtime phase
- 64 KB decode scratch buffer
- decoder yields when PCM ring exceeds 75% occupancy
- 3 x 16 KB AudioQueue output buffers
- no unbounded packet/PCM queues
- per-thread autorelease pool
- FFmpeg context closes at thread exit

## Clock

The audio runtime updates clock time from the amount of accepted S16 PCM:

`seconds = bytes / (sampleRate * channels * 2)`

This becomes the future master clock for video synchronization.

## Scope review

No Alpha18 feature belongs to:
- iPad1Files
- iPad1PDFReader
- iPad1Downloader

All changes are direct media playback responsibilities of iPad1Player.

## Limitations

- FFmpeg armv7 static libraries are still external.
- Only packed S16 decoder output is accepted.
- AAC/MP3 decoders that output FLTP/S16P still require a tested swresample phase.
- This release does not decode H.264 video.
- Seek integration into the audio session is the next runtime step.
