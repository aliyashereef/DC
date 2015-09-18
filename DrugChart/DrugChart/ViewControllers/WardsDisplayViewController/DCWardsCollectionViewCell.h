//
//  DCWardsCollectionViewCell.h
//  DrugChart
//
//  Created by aliya on 14/08/15.
//
//

#import <UIKit/UIKit.h>
#import "DCWard.h"

@interface DCWardsCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) DCWard *currentWard;
@property (weak, nonatomic) IBOutlet UILabel *wardNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *wardNumberLabel;
@property (strong, nonatomic) IBOutlet UILabel *capasityLabel;
@property (strong, nonatomic) IBOutlet UILabel *occupiedBedCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *closedBedCountLabel;
@property (strong, nonatomic) IBOutlet UILabel *availableBedCountLabel;

- (void)configureWardDisplayCellForWard;
@end
