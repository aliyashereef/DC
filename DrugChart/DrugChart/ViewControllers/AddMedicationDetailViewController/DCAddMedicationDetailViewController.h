//
//  DCAddMedicationDetailViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/3/15.
//
//

#import <UIKit/UIKit.h>

typedef void(^EntrySelected)(NSString *value);

@protocol AddMedicationDetailDelegate <NSObject>

@optional

- (void)overrideReasonSubmitted:(NSString *)reason;

@end

@interface DCAddMedicationDetailViewController : UIViewController

@property (nonatomic) AddMedicationDetailType detailType;
@property (nonatomic, strong) EntrySelected selectedEntry;
@property (nonatomic, strong) NSString *previousFilledValue;
@property (nonatomic, strong) NSMutableArray *contentArray;
//@property (nonatomic, strong) NSString *backButtonText;
//@property (nonatomic) BOOL isEditMedication;
@property (nonatomic, weak) id <AddMedicationDetailDelegate> delegate;

@end
