#import "IP1MediaPreflight.h"

@implementation IP1MediaPreflight

+ (BOOL)isSupportedParseExtension:(NSString *)extension {
    NSString *ext = [(extension ? extension : @"") lowercaseString];
    return ([ext isEqualToString:@"mkv"] ||
            [ext isEqualToString:@"avi"] ||
            [ext isEqualToString:@"mp4"] ||
            [ext isEqualToString:@"mov"] ||
            [ext isEqualToString:@"m4v"]);
}

+ (unsigned long long)maximumReasonableFileBytes {
    /*
     This is not a RAM allocation limit. It is only a defensive sanity limit
     for obviously invalid paths/metadata on a legacy device.
    */
    return 32ULL * 1024ULL * 1024ULL * 1024ULL; /* 32 GiB */
}

+ (BOOL)validatePath:(NSString *)path error:(NSString **)errorMessage {
    if (![path length]) {
        if (errorMessage) *errorMessage = @"Medya yolu boş.";
        return NO;
    }

    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if (errorMessage) *errorMessage = @"Medya dosyası bulunamadı.";
        return NO;
    }

    if (![self isSupportedParseExtension:[path pathExtension]]) {
        if (errorMessage) *errorMessage = @"Bu dosya uzantısı parse aşamasında desteklenmiyor.";
        return NO;
    }

    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    NSNumber *size = [attrs objectForKey:NSFileSize];
    if (size && [size unsignedLongLongValue] == 0) {
        if (errorMessage) *errorMessage = @"Medya dosyası boş.";
        return NO;
    }

    if (size && [size unsignedLongLongValue] > [self maximumReasonableFileBytes]) {
        if (errorMessage) *errorMessage = @"Dosya boyutu güvenlik sınırını aşıyor.";
        return NO;
    }

    return YES;
}

@end
