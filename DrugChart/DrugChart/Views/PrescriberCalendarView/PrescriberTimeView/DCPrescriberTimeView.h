//
//  DCPrescriberTimeView.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/24/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationSlot.h"

@interface DCPrescriberTimeView : UIView

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *statusImageView;
@property (nonatomic, strong) DCMedicationSlot *medicationSlot;

- (UIImage *)getMedicationStatusImageForMedicationStatus:(NSString *)status;

@end
