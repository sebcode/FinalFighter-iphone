
@interface GameAchievement : NSObject

- (BOOL)isDone;

@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *trigger;
@property (readwrite) NSUInteger triggerMin;
@property (readwrite, copy) NSString *gameCenterID;

@end
