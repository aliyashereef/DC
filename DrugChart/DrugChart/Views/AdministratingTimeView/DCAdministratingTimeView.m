//
//  DCAdministratingTimeView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/17/15.
//
//

#import "DCAdministratingTimeView.h"

@implementation DCAdministratingTimeView

- (void)setStatusImageForSelectionState:(NSInteger)state {
    
    if (state == 1) {
        
        [_statusImageView setImage:[UIImage imageNamed:ADMINISTRATING_TIME_SELECTED]];
        [_timeLabel setTextColor:[UIColor getColorForHexString:@"#181818"]];
    } else {
        
        [_statusImageView setImage:[UIImage imageNamed:ADMINISTRATING_TIME_UNSELECTED]];
        [_timeLabel setTextColor:[UIColor getColorForHexString:@"#b7b7b7"]];
    }
}

- (void)updateTimeViewWithDetails:(NSDictionary *)timeDictionary {
    
    NSString *time = [timeDictionary valueForKey:@"time"];
    NSInteger selected = [[timeDictionary valueForKey:@"selected"] integerValue];
    [self setStatusImageForSelectionState:selected];
    _timeLabel.text = time;
}

@end
