//
//  DCOrderSetMedicineView.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/2/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationDetails.h"

@protocol DCOrderSetMedicineViewDelegate <NSObject>

- (void)selectedMedicineSelectionButtonWithViewTag:(int)viewTag;
- (void)selectedDeleteMedicineButtonWithViewTag:(int)viewTag;
- (void)longPressActionOnMedicineView;

@end

@interface DCOrderSetMedicineView : UIView

@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@property (nonatomic, weak) IBOutlet UIButton *highlightButton;
@property (nonatomic, weak) IBOutlet UIImageView *completionStatusImageView;
@property (nonatomic, weak) IBOutlet UILabel *medicineNameLabel;
@property (nonatomic, weak) IBOutlet UIButton *deleteButton;
@property (nonatomic, weak) IBOutlet UIButton *selectionButton;
@property (nonatomic, weak) id <DCOrderSetMedicineViewDelegate> delegate;
@property (nonatomic, strong) DCMedicationDetails *medication;

- (void)configureViewElementsForMedication:(DCMedicationDetails *)medication;
- (void)updateMedicationViewOnSelection:(BOOL)select;
- (void)configureCountLabelAndCompletionStatusImageView;
- (IBAction)deleteButtonPressed:(id)sender;

@end
