//
//  DCMedicationDetailsViewController.m
//  DrugChart
//
//  Created by Vineeth  on 22/05/15.
//
//

#import "DCMedicationDetailsViewController.h"

@interface DCMedicationDetailsViewController ()

@end

@implementation DCMedicationDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setElements];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setElements{
    _medicineNameLabel.text = _selectedMedicationList.name;
    [self populateRouteAndInstructionLabelWithRoute:_selectedMedicationList.route instruction:_selectedMedicationList.instruction];
    if (![_selectedMedicationList.medicineCategory isEqualToString:WHEN_REQUIRED]) {
        [_timeLabel setHidden:NO];
        [_startDateTitleLabel setHidden:NO];
        NSString *formattedDate = [DCDateUtility dateStringFromSourceString:_selectedMedicationList.startDate];
        _timeLabel.text = formattedDate;
    } else {
        [_timeLabel setHidden:YES];
        [_startDateTitleLabel setHidden:YES];
    }
}

- (void)populateRouteAndInstructionLabelWithRoute:(NSString *)route instruction:(NSString *)instruction {
    //get dosage and instruction text for display
    
    NSDictionary *dosageAttributes = @{
                                       NSFontAttributeName : [DCFontUtility getLatoBoldFontWithSize:15.0f],
                                       NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#3b3b3b"]
                                       };
    NSMutableAttributedString *dosageAttributedString = [[NSMutableAttributedString alloc] initWithString:route];
    [dosageAttributedString setAttributes:dosageAttributes range:NSMakeRange(0, [dosageAttributedString length])];
    NSString *medicineInstruction = instruction;
    NSString *instructionDisplayString = medicineInstruction.length?[NSString stringWithFormat:@" (%@)", medicineInstruction]:@"";
    NSMutableAttributedString *medicineInstructionAttributedString = [[NSMutableAttributedString alloc]
                                                                      initWithString:instructionDisplayString];
    NSDictionary *instructionAttributes = @{
                                            NSFontAttributeName : [DCFontUtility getLatoRegularFontWithSize:13.0f],
                                            NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#676767"]
                                            };
    [medicineInstructionAttributedString setAttributes:instructionAttributes range:NSMakeRange(0, [instructionDisplayString length])];
    [dosageAttributedString appendAttributedString:medicineInstructionAttributedString];
    _dosageLabel.attributedText = dosageAttributedString;
}


@end
