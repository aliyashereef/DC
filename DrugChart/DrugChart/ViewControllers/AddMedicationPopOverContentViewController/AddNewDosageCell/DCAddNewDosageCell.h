//
//  AddNewDosageCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/23/15.
//
//

#import <UIKit/UIKit.h>


typedef void (^NewDosageAdded)(NSString *dosage);

@interface DCAddNewDosageCell : UITableViewCell <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *addNewTextField;
@property (nonatomic, weak) IBOutlet UIButton *addNewButton;
@property (nonatomic, strong) NewDosageAdded newDosageAdded;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *closeButtonWidthConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tickButtonWidthConstraint;

@end
