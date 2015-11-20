#import "NSString+Additions.h"

@implementation NSString (Additions)

+ (NSString*)ordinalNumberFormat:(NSNumber *)numObj {
    NSString *ending;
    NSInteger num = [numObj integerValue];
    
    int ones = num % 10;
    int tens = floor(num / 10);
    tens = tens % 10;
    
    if(tens == 1){
        ending = @"th";
    } else {
        switch (ones) {
            case 1:
                ending = @"st";
                break;
            case 2:
                ending = @"nd";
                break;
            case 3:
                ending = @"rd";
                break;
            default:
                ending = @"th";
                break;
        }
    }
    
    return [NSString stringWithFormat:@"%d%@", num, ending];
}

@end