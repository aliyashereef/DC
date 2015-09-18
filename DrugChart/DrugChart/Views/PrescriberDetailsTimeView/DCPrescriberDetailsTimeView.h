//
//  DCPrescriberDetailsTimeView.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/12/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationSlot.h"

typedef void (^DCTimeAction)(void);

@interface DCPrescriberDetailsTimeView : UIView

@property (nonatomic, strong) DCMedicationSlot *medicationSlot;
@property (nonatomic, strong) DCTimeAction timeAction;
@property (nonatomic, weak) IBOutlet UIButton *timeButton;

- (void)setMedicationSlotValuesForSelectedState:(BOOL)selected;
- (IBAction)timeViewButtonClicked:(id)sender;

@end
