
@interface GameStats : NSObject
{
    NSUserDefaults *defaults;
}

+ (GameStats *)getInstance;

- (NSUInteger)incInt:(NSString *)key;
- (void)setInt:(NSInteger)intValue forKey:(NSString *)key;
- (NSInteger)getInt:(NSString *)key;
- (void)synchronize;

@end
