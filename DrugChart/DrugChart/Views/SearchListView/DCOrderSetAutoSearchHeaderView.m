//
//  DCOrderSetAutoSearchHeaderView.m
//  DrugChart
//
//  Created by aliya on 06/08/15.
//
//

#import "DCOrderSetAutoSearchHeaderView.h"

@implementation DCOrderSetAutoSearchHeaderView

- (id)initWithFrame:(CGRect)frame {
    
    if (self == [super initWithFrame:frame]) {
        self.frame = frame;
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
}

- (IBAction)showAllButtonTapped:(id)sender {

    if (self.headerDelegate && [self.headerDelegate respondsToSelector:@selector(showAllButtonTapped)]) {
        [self.headerDelegate showAllButtonTapped];
    }
}

@end
