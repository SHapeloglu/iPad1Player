# Current Tasks

## Immediate Task

### Implement real A/V synchronization

Current playback renders decoded video as soon as the renderer can present it.

This produces functioning playback but does not yet provide timestamp-accurate synchronization.

Required work:

1. Capture video PTS from decoded AVFrame.
2. Convert video timestamps with stream time_base.
3. Use audio as master clock.
4. Compare:

       videoPTS - audioClock

5. If video is early:
   - delay presentation within a bounded interval.

6. If video is slightly late:
   - present immediately.

7. If video is significantly late:
   - drop decoded frame where safe.

8. Keep frame queues bounded.

9. Never block AudioQueue due to video scheduling.

## After A/V Sync

### EOF handling

At container EOF:

- drain decoder
- drain queued video packets
- flush delayed H.264 frames
- finish pending PCM
- emit playback-ended state
- leave UI in a valid stopped/completed state

### Pause / Resume

Validate:

- demux worker stop state
- video worker stop state
- packet queue state
- AudioQueue state
- clock continuity

### Long-duration test

Use a longer H.264 480p MKV and test:

- 10 minutes
- 30 minutes
- full movie

Watch for:

- memory growth
- audio underruns
- frame corruption
- thread deadlock
- queue growth
- A/V drift

## Completion Criteria for Current Playback Phase

The FFmpeg playback path should not be considered stable until:

- clean 480p image
- continuous audio
- no recurring micro-freezes
- no frame corruption
- bounded memory
- stable A/V sync
- clean EOF
- stable pause/resume
- long-duration device test
