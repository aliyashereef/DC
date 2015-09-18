//
//  DCWarningsHeaderView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/21/15.
//
//

#import "DCWarningsHeaderView.h"

@interface DCWarningsHeaderView ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation DCWarningsHeaderView

- (void)configureHeaderViewForSection:(NSInteger)sectionCount {
    
    if (sectionCount == 0) {
        _titleLabel.text = NSLocalizedString(@"SEVERE", @"Severe Warnings title");
    } else {
        _titleLabel.text = NSLocalizedString(@"MILD", @"Mild Warnings title");
    }
}

@end
