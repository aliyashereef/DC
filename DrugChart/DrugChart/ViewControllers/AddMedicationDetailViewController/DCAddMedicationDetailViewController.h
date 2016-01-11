//
//  DCAddMedicationDetailViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/3/15.
//
//

#import <UIKit/UIKit.h>

typedef void(^EntrySelected)(NSString *value);
typedef void(^NewAdministrationTime)(NSDate *date);

@protocol AddMedicationDetailDelegate <NSObject>

@optional

- (void)updatedAdministrationTimeArray:(NSArray *)timeArray;
- (void)overrideReasonSubmitted:(NSString *)reason;

@end

@interface DCAddMedicationDetailViewController : UIViewController

@property (nonatomic) AddMedicationDetailType detailType;
@property (nonatomic, strong) EntrySelected selectedEntry;
@property (nonatomic, strong) NewAdministrationTime newTime;
@property (nonatomic, strong) NSString *previousFilledValue;
@property (nonatomic, strong) NSMutableArray *contentArray;
@property (nonatomic, weak) id <AddMedicationDetailDelegate> delegate;

@end
