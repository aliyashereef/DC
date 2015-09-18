//
//  DCTimeView.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/9/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationSlot.h"

typedef void (^DCTimeAction)(void);

@interface DCTimeView : UIView

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *statusImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *timeLabelLeadingConstraint;
@property (nonatomic, strong) DCMedicationSlot *medicationSlot;
@property (nonatomic, strong) DCTimeAction timeAction;

- (void)displayTimeViewForMedicationSlot:(DCMedicationSlot *)medicationSlot;

@end
