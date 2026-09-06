ARCHS = armv7
TARGET = iphone:clang:6.1:5.1
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = iPad1Player
iPad1Player_FILES = \
	src/main.m \
	src/AppDelegate.m \
	src/IP1SubtitleCue.m \
	src/IP1SRTParser.m \
	src/IP1MediaTrack.m \
	src/IP1Chapter.m \
	src/IP1MediaInfo.m \
	src/IP1MediaCapabilities.m \
	src/IP1CompatibilityGate.m \
	src/IP1PlaybackClock.m \
	src/IP1FramePolicy.m \
	src/IP1FFmpegParseResult.m \
	src/IP1ParsePolicy.m \
	src/IP1DeviceTestStatus.m \
	src/IP1ParseDiagnostics.m \
	src/IP1StreamMetadataMapper.m \
	src/IP1FFmpegBuildCheck.m \
	src/IP1ParseResultValidator.m \
	src/IP1ParseFallbackPolicy.m \
	src/IP1MediaPreflight.m \
	src/IP1ParseStressResult.m \
	src/IP1ParseStressTester.m \
	src/IP1MemoryBudget.m \
	src/IP1PlaybackProfile.m \
	src/IP1SuiteScopeGate.m \
	src/IP1PCMRingBuffer.m \
	src/IP1AudioRuntimeProfile.m \
	src/IP1AudioEngine.m \
	src/IP1AudioQueueOutput.m \
	src/IP1FFmpegAudioDecoder.m \
	src/IP1FFmpegVideoDecoder.m \
	src/IP1YUVRendererView.m \
	src/IP1FFmpegAudioSession.m \
	src/IP1H264DecodePolicy.m \
	src/IP1VideoDecodeCapability.m \
	src/IP1FFmpegAdapter.m \
	src/IP1PacketQueue.m \
	src/IP1MKVBackend.m \
	src/IP1PlayerViewController.m

iPad1Player_FRAMEWORKS = UIKit Foundation MediaPlayer CoreGraphics AVFoundation AudioToolbox OpenGLES QuartzCore
iPad1Player_CFLAGS = -fno-objc-arc -Wall -Wextra -Wno-deprecated-declarations
iPad1Player_LDFLAGS = -Wl,-dead_strip
iPad1Player_RESOURCE_DIRS = Resources

include $(THEOS_MAKE_PATH)/application.mk


# Optional legacy FFmpeg backend (enable only after armv7/iOS 5 compatible libs are present):
iPad1Player_CFLAGS += -DIP1_FFMPEG_BACKEND
iPad1Player_LDFLAGS += -L$(THEOS_PROJECT_DIR)/vendor/ffmpeg/lib
iPad1Player_CFLAGS += -I$(THEOS_PROJECT_DIR)/vendor/ffmpeg/include
# Parse-only alpha14:
iPad1Player_LIBRARIES += avformat avcodec avutil swresample z bz2 iconv
# Alpha17 AAC/MP3 decode source uses avcodec.
# swresample is still optional and needed for non-S16 output formats.
#
# Do NOT define IP1_LEGACY_H264_HW until on-device iPad 1 testing proves the path.


# FFmpeg build guard:
# Enable only after verifying these legacy armv7/iOS 5-compatible headers/libs exist:
# vendor/ffmpeg/include/libavformat/avformat.h
# vendor/ffmpeg/include/libavcodec/avcodec.h
# vendor/ffmpeg/include/libavutil/avutil.h
# vendor/ffmpeg/lib/libavformat.a
# vendor/ffmpeg/lib/libavcodec.a
# vendor/ffmpeg/lib/libavutil.a
#
# Do not define IP1_FFMPEG_BACKEND if these are absent.
