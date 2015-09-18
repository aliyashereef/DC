//
//  DCWardsCollectionViewCell.m
//  DrugChart
//
//  Created by aliya on 14/08/15.
//
//

#import "DCWardsCollectionViewCell.h"

@implementation DCWardsCollectionViewCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat borderWidth = 1.0f;
    self.layer.borderColor = [UIColor getColorForHexString:@"#ccd5db"].CGColor;
    self.layer.borderWidth = borderWidth;
}

- (void)configureWardDisplayCellForWard {
    
    if ([self.currentWard.wardName isEqualToString:EMPTY_STRING]) {
        self.wardNameLabel.text = @"Ward";
    }
    else {
        self.wardNameLabel.text = self.currentWard.wardName;
    }
    self.wardNumberLabel.text = [NSString stringWithFormat:@"Ward %@",self.currentWard.wardNumber];
    self.availableBedCountLabel.text = [NSString stringWithFormat:@"%@",self.currentWard.availableBedCount];
    self.closedBedCountLabel.text = [NSString stringWithFormat:@"%@",self.currentWard.closedBedCount];
    self.occupiedBedCountLabel.text = [NSString stringWithFormat:@"%@",self.currentWard.occupiedBedCount];
    self.capasityLabel.text = [NSString stringWithFormat:@"%@",self.currentWard.capacity];
}

@end
