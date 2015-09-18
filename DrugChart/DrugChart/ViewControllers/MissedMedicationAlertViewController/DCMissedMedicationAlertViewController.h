//
//  DCMissedMedicationAlertViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 09/04/15.
//
//

#import <UIKit/UIKit.h>

typedef void (^DismissView)();
typedef void (^DismissViewWithoutSaving)();
typedef void(^RemoveMedication)();

@interface DCMissedMedicationAlertViewController : DCBaseViewController <UIViewControllerTransitioningDelegate, UITextViewDelegate>

@property (nonatomic, strong) DismissView dismissView;
@property (nonatomic, strong) DismissViewWithoutSaving dismissViewWithoutSaving;
@property (nonatomic, strong) RemoveMedication removeMedication;
@property (nonatomic, strong) NSString *medicineName;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *alertTitle;
@property (nonatomic) AlertType alertType;

@end
