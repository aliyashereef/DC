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

@interface DCOverrideViewController : UIViewController

@property (nonatomic, weak) id <AddMedicationDetailDelegate> delegate;

@end
