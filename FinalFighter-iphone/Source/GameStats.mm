
#import "GameStats.h"
#import "GameConstants.h"
#import <CommonCrypto/CommonDigest.h>

@implementation GameStats

static GameStats *sharedGameStats;

+ (GameStats *)getInstance
{
    [GameStats createInstance];

    return sharedGameStats;
}

+ (void)createInstance
{
    static BOOL initialized = NO;
    if (!initialized) {
        initialized = YES;
        sharedGameStats = [[GameStats alloc] init];
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (void)setInt:(NSInteger)intValue forKey:(NSString *)key
{
#ifdef LOG_STATS
    NSLog(@"STATS setInt %@", key);
#endif
    
    NSString *encKey = [GameStats md5HexDigest:key];
    NSString *realKey = [NSString stringWithFormat:@"gs.%@", encKey];
    NSNumber *value = [NSNumber numberWithLong:intValue];
    
    [defaults setValue:value forKey:realKey];
}

- (NSUInteger)incInt:(NSString *)key
{
#ifdef LOG_STATS
    NSLog(@"STATS incInt %@", key);
#endif
    
    NSString *encKey = [GameStats md5HexDigest:key];
    NSString *realKey = [NSString stringWithFormat:@"gs.%@", encKey];
    NSNumber *value = [defaults valueForKey:realKey];
    NSInteger intValue = [value intValue];
    intValue++;
    value = [NSNumber numberWithLong:intValue];
    
    [defaults setValue:value forKey:realKey];
    
    return intValue;
}

- (void)synchronize
{
    [defaults synchronize];
}

- (NSInteger)getInt:(NSString *)key
{
    NSString *encKey = [GameStats md5HexDigest:key];
    NSString *realKey = [NSString stringWithFormat:@"gs.%@", encKey];
    NSNumber *value = [defaults valueForKey:realKey];
    return [value intValue];
}

+ (NSString*)md5HexDigest:(NSString*)input
{
    const char* str = [input UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (unsigned int) strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

@end
