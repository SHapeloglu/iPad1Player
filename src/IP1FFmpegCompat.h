#import <Foundation/Foundation.h>

#ifdef IP1_FFMPEG_BACKEND

#ifdef __cplusplus
extern "C" {
#endif

#include <libavformat/avformat.h>
#include <libavcodec/avcodec.h>
#include <libavutil/avutil.h>
#include <libavutil/dict.h>
#include <libavutil/rational.h>

#ifdef __cplusplus
}
#endif


static inline enum AVMediaType IP1FFStreamType(AVStream *stream)
{
    if (!stream) {
        return AVMEDIA_TYPE_UNKNOWN;
    }

#if LIBAVFORMAT_VERSION_MAJOR >= 57
    return stream->codecpar
        ? stream->codecpar->codec_type
        : AVMEDIA_TYPE_UNKNOWN;
#else
    return stream->codec
        ? stream->codec->codec_type
        : AVMEDIA_TYPE_UNKNOWN;
#endif
}


static inline enum AVCodecID IP1FFStreamCodecID(AVStream *stream)
{
    if (!stream) {
        return AV_CODEC_ID_NONE;
    }

#if LIBAVFORMAT_VERSION_MAJOR >= 57
    return stream->codecpar
        ? stream->codecpar->codec_id
        : AV_CODEC_ID_NONE;
#else
    return stream->codec
        ? stream->codec->codec_id
        : AV_CODEC_ID_NONE;
#endif
}


static inline int IP1FFStreamWidth(AVStream *stream)
{
    if (!stream) {
        return 0;
    }

#if LIBAVFORMAT_VERSION_MAJOR >= 57
    return stream->codecpar ? stream->codecpar->width : 0;
#else
    return stream->codec ? stream->codec->width : 0;
#endif
}


static inline int IP1FFStreamHeight(AVStream *stream)
{
    if (!stream) {
        return 0;
    }

#if LIBAVFORMAT_VERSION_MAJOR >= 57
    return stream->codecpar ? stream->codecpar->height : 0;
#else
    return stream->codec ? stream->codec->height : 0;
#endif
}


static inline int IP1FFStreamSampleRate(AVStream *stream)
{
    if (!stream) {
        return 0;
    }

#if LIBAVFORMAT_VERSION_MAJOR >= 57
    return stream->codecpar ? stream->codecpar->sample_rate : 0;
#else
    return stream->codec ? stream->codec->sample_rate : 0;
#endif
}


static inline int IP1FFStreamChannels(AVStream *stream)
{
    if (!stream) {
        return 0;
    }

#if LIBAVFORMAT_VERSION_MAJOR >= 59
    return stream->codecpar
        ? (int)stream->codecpar->ch_layout.nb_channels
        : 0;
#elif LIBAVFORMAT_VERSION_MAJOR >= 57
    return stream->codecpar
        ? stream->codecpar->channels
        : 0;
#else
    return stream->codec
        ? stream->codec->channels
        : 0;
#endif
}


static inline int IP1FFCodecContextChannels(AVCodecContext *ctx)
{
    if (!ctx) {
        return 0;
    }

#if LIBAVCODEC_VERSION_MAJOR >= 59
    return (int)ctx->ch_layout.nb_channels;
#else
    return ctx->channels;
#endif
}


static inline void IP1FFPacketUnref(AVPacket *packet)
{
    if (!packet) {
        return;
    }

#if LIBAVCODEC_VERSION_MAJOR >= 57
    av_packet_unref(packet);
#else
    av_free_packet(packet);
#endif
}

#endif /* IP1_FFMPEG_BACKEND */
