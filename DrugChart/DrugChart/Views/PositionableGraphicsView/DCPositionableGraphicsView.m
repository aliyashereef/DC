//
//  DCPositionableGraphicsView.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 14/06/15.
//
//

#import "DCPositionableGraphicsView.h"

#define NURSE_STATION_NIB @"DCPositionableGraphicsNurseStation"

@interface DCPositionableGraphicsView () {
    
    IBOutlet UIImageView *stationIconImageView;
        
}

@end

@implementation DCPositionableGraphicsView


- (id)initWithGraphicsType:(PositionableGraphicsType)graphicsType
                  andFrame:(CGRect)viewFrame {
    
    if (graphicsType == kDivider) {
        self = [[DCPositionableGraphicsView alloc] initWithFrame:viewFrame];
        self.backgroundColor = [UIColor colorForHexString:@"#E2E2E2"];
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1] CGColor];
        //self.alpha = 0.2;
        return self;
    }
    else if (graphicsType == kNurseStation) {
        self = [[[NSBundle mainBundle] loadNibNamed:NURSE_STATION_NIB
                                              owner:self
                                            options:nil] objectAtIndex:0];
        self.frame = viewFrame;
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1] CGColor];
        return self;
    }
    return nil;
}

@end
