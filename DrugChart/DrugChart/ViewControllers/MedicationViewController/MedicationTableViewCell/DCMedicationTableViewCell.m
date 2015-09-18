//
//  DCMedicationTableViewCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/6/15.
//
//

#import "DCMedicationTableViewCell.h"
#import "DCMedicationSlot.h"

@interface DCMedicationTableViewCell ()

@end

@implementation DCMedicationTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
////    if (selected) {
////        [_selectionView setHidden:NO];
////        self.contentView.backgroundColor = [UIColor whiteColor];
////    } else {
////        [_selectionView setHidden:YES];
////        //TODO: change this method to hex string color
////        self.contentView.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:244.0/255.0 blue:246.0/255.0 alpha:1.0];
////    }
//}

#pragma mark - Action Methods

- (IBAction)selectButtonPressed:(id)sender {
    
    UIButton *selectionButton = (UIButton *)sender;
    if (selectionButton.selected) {
        [selectionButton setSelected:NO];
    } else {
        [selectionButton setSelected:YES];
    }
}

#pragma mark - Public Methods

- (void)configureMedicationCellWithMedicationDetails:(DCMedicationScheduleDetails *)medicationList
                                    forMenuSelection:(NSInteger)selection {
    
    self.medicationList = medicationList;
    [self populateMedicineLabelNameForSelection:selection];
    [self populateDosageInstructionLabel];
    [self populatePrescribedByLabel];
    [self populateMedicationTimeLabel];
}

#pragma mark - Private methods
- (void)populateMedicineLabelNameForSelection:(NSInteger)selection {
    
    NSString *medicineName = self.medicationList.name;
    NSDictionary *nameAttributes = @{
                                     NSFontAttributeName : [DCFontUtility getLatoRegularFontWithSize:20.0f],
                                     NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#0079c2"]
                                     };
    NSMutableAttributedString *medicationNameAttributedString = [[NSMutableAttributedString alloc] initWithString:medicineName];
    [medicationNameAttributedString setAttributes:nameAttributes range:NSMakeRange(0, [medicineName length])];
    if (selection == 0) {
        // selection is not currently active (i.e, scheduled or when needed)

        [_medicationCategoryLabel setHidden:NO];
        _medicationCategoryLabel.text = self.medicationList.medicineCategory;
        
    } else {
        [_medicationCategoryLabel setHidden:YES];
    }
    self.medicineNameLabel.attributedText = medicationNameAttributedString;
}

- (void)populateDosageInstructionLabel {
    
    NSDictionary *dosageAttributes = @{
                                     NSFontAttributeName : [DCFontUtility getLatoBoldFontWithSize:17.0f],
                                     NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#3b3b3b"]
                                     };
    NSMutableAttributedString *dosageAttrString = [[NSMutableAttributedString alloc] initWithString:self.medicationList.route];
    [dosageAttrString setAttributes:dosageAttributes range:NSMakeRange(0, [dosageAttrString length])];
    NSString *medicineInstruction = self.medicationList.instruction;
    
    NSString *instructionDisplayString = medicineInstruction.length?[NSString stringWithFormat:@" (%@)", medicineInstruction]: @"";
    NSMutableAttributedString *instructionAttributedString = [[NSMutableAttributedString alloc]
                                                                           initWithString:instructionDisplayString];
    NSDictionary *instructionAttributes = @{
                                                 NSFontAttributeName : [DCFontUtility getLatoRegularFontWithSize:15.0f],
                                                 NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#676767"]
                                                 };
    [instructionAttributedString setAttributes:instructionAttributes range:NSMakeRange(0, [instructionDisplayString length])];
    [dosageAttrString appendAttributedString:instructionAttributedString];
    self.dosageLabel.attributedText = dosageAttrString;
}

- (void)populatePrescribedByLabel {
    
    if (self.medicationList.prescribingUser.displayName) {
        NSDictionary *attributes = @{
                                     NSFontAttributeName : [DCFontUtility getLatoRegularFontWithSize:14.0f],
                                     NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#313131"]
                                     };
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.medicationList.prescribingUser.displayName];
        [attributedString setAttributes:attributes range:NSMakeRange(0, [attributedString length])];
        self.doctorNameLabel.attributedText = attributedString;
    }
}

- (void)populateMedicationTimeLabel {
    
    if (self.medicationList.timeChart.count != 0) {
        NSDictionary *medicationSlotDictionary = [self.medicationList.timeChart objectAtIndex:0];
        // sort array loke in patient list
        NSArray *medSlotArray = [medicationSlotDictionary objectForKey:MED_DETAILS];
        if ([medSlotArray count] > 0) {
            DCMedicationSlot *medicationSlot = [medSlotArray objectAtIndex:0];
            NSString *timeString = [DCDateUtility convertDate:medicationSlot.time FromFormat:DEFAULT_DATE_FORMAT ToFormat:TWENTYFOUR_HOUR_FORMAT];
            self.timeLabel.text = timeString;
        }
    }
}

- (void)configureSelectedStateForSelection:(BOOL)isSelected {
    
    if (isSelected) {
        [_selectionView setHidden:NO];
        self.contentView.backgroundColor = [UIColor whiteColor];
    } else {
        [_selectionView setHidden:YES];
        //TODO: change this method to hex string color
        self.contentView.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:244.0/255.0 blue:246.0/255.0 alpha:1.0];
    }
}

@end
