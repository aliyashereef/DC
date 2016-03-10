//
//  DCAddMedicationDetailViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/3/15.
//
//

#import <UIKit/UIKit.h>

@protocol AddMedicationDetailDelegate <NSObject>

@optional

- (void)overrideReasonSubmittedInDetailView:(NSString *)reason;

@end

@interface DCAddMedicationDetailViewController : UIViewController

@property (nonatomic, strong) NSString *previousFilledValue;
@property (nonatomic, weak) id <AddMedicationDetailDelegate> delegate;

@end
