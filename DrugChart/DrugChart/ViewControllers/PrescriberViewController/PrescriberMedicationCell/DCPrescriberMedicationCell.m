//
//  DCPrescriberMedicationCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/24/15.
//
//

#import "DCPrescriberMedicationCell.h"
#import "DCPrescriberTimeView.h"
#import "DCPrescriberMedicationSlotDisplayView.h"
#import "DDPopoverBackgroundView.h"
#import "DCPrescriberTimeView.h"
#import "DCMedicationScheduleDetails.h"

#import "DCMedicationSlot.h"

#define TIME_VIEW_WIDTH                         70.0f
#define TIME_VIEW_HEIGHT                        21.0f
#define MEDICATION_VIEW_LEFT_OFFSET             120.0f
#define MEDICATION_VIEW_INITIAL_LEFT_OFFSET     0.0f
#define ANIMATION_DURATION                      0.3f

@implementation DCPrescriberMedicationCell

- (void)awakeFromNib {
    // Initialization code
    [self addPanGestureToMedicationView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)addPanGestureToMedicationView {
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeMedicationView:)];
    
    [self.medicationView addGestureRecognizer:panGesture];
}

- (void)swipeMedicationView:(UIPanGestureRecognizer *)gesture {
    
    if (_discontinuedLabel.hidden) {
        
        //No swipe feature for discontinued medications
        CGPoint translate = [gesture translationInView:self.contentView];
        CGPoint gestureVelocity = [gesture velocityInView:self];
        
        if (gestureVelocity.x > 200.0 || gestureVelocity.x < - 200.0) {
            
            if ((translate.x < 0) && (_medicationViewLeadingConstraint.constant == 0)) {
                
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    _medicationViewLeadingConstraint.constant = - MEDICATION_VIEW_LEFT_OFFSET;
                    _EditButtonWidth.constant = _stopButtonWidth.constant = - (_medicationViewLeadingConstraint.constant / 2);
                    
                    [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
                    [_stopButton setTitle:@"Stop" forState:UIControlStateNormal];
                    [self layoutIfNeeded];
                }];
            }else if ((translate.x > 0) && (_medicationViewLeadingConstraint.constant == - MEDICATION_VIEW_LEFT_OFFSET)){
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    _medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET;
                    _EditButtonWidth.constant = _stopButtonWidth.constant = - (_medicationViewLeadingConstraint.constant / 2);
                    [self layoutIfNeeded];
                }];
            }
        }else{
            if (((translate.x < 0) && (_medicationViewLeadingConstraint.constant > - MEDICATION_VIEW_LEFT_OFFSET)) || ((translate.x > 0) && (_medicationViewLeadingConstraint.constant < MEDICATION_VIEW_INITIAL_LEFT_OFFSET))) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _medicationViewLeadingConstraint.constant += (float) (gestureVelocity.x / 25.0);
                    _EditButtonWidth.constant = _stopButtonWidth.constant = - (_medicationViewLeadingConstraint.constant / 2);
                    
                    [self setEditViewButtonNames];
                    [self setMedicationViewFrame];
                });
            }
        }
        if(gesture.state == UIGestureRecognizerStateEnded)
        {
            //All fingers are lifted.
            if ((translate.x < 0) && _medicationViewLeadingConstraint.constant < (- MEDICATION_VIEW_LEFT_OFFSET / 2)) {
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    _medicationViewLeadingConstraint.constant = - MEDICATION_VIEW_LEFT_OFFSET;
                    [self layoutIfNeeded];
                }completion:^(BOOL finished) {
                    [self setMedicationViewFrame];
                }];
            }else if ((translate.x < 0) && _medicationViewLeadingConstraint.constant > (- MEDICATION_VIEW_LEFT_OFFSET / 2)) {
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    _medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET + 10;
                    _EditButtonWidth.constant = _stopButtonWidth.constant = - (_medicationViewLeadingConstraint.constant / 2);
                    [self layoutIfNeeded];
                }completion:^(BOOL finished) {
                    [self setMedicationViewFrame];
                }];
            } else if ((translate.x > 0) && _medicationViewLeadingConstraint.constant > (- MEDICATION_VIEW_LEFT_OFFSET / 2)){
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    _medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET;
                    _EditButtonWidth.constant = _stopButtonWidth.constant = - (_medicationViewLeadingConstraint.constant / 2);
                    [self layoutIfNeeded];
                }completion:^(BOOL finished) {
                    [self setMedicationViewFrame];
                }];
            }else if ((translate.x > 0) && _medicationViewLeadingConstraint.constant < (- MEDICATION_VIEW_LEFT_OFFSET / 2)){
                [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                    _medicationViewLeadingConstraint.constant = - MEDICATION_VIEW_LEFT_OFFSET;
                    [self layoutIfNeeded];
                }completion:^(BOOL finished) {
                    [self setMedicationViewFrame];
                }];
            }
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                _EditButtonWidth.constant = _stopButtonWidth.constant = - (_medicationViewLeadingConstraint.constant / 2);
            } completion:^(BOOL finished) {
                [self setMedicationViewFrame];
            }];
        }
    }
}

- (void)setEditViewButtonNames{
    
    if (_EditButtonWidth.constant > 40.0) {
        
        [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
        [_stopButton setTitle:@"Stop" forState:UIControlStateNormal];
    }else{
        
        [_editButton setTitle:@"" forState:UIControlStateNormal];
        [_stopButton setTitle:@"" forState:UIControlStateNormal];
    }
}

- (void)setMedicationViewFrame{
    
    if (_medicationViewLeadingConstraint.constant < - MEDICATION_VIEW_LEFT_OFFSET) {
        _medicationViewLeadingConstraint.constant = - MEDICATION_VIEW_LEFT_OFFSET;
    }else if (_medicationViewLeadingConstraint.constant > MEDICATION_VIEW_INITIAL_LEFT_OFFSET){
        _medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET;
    }
}

- (void)swipeMedicationViewToRight:(UIGestureRecognizer *)gesture {
    
    //swipe gesture - right
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        _medicationViewLeadingConstraint.constant = MEDICATION_VIEW_INITIAL_LEFT_OFFSET;
        [self layoutIfNeeded];
    }];
}

- (void)setIndexPath:(NSIndexPath *)indexPath {
    
    _indexPath = indexPath;
}


- (void)addOverLayButtonForMedicationSlots:(NSArray *)medicationSlotsArray {
    
    _medicationSlotsArray = medicationSlotsArray;
    for (NSDictionary *medicationsSlotsDictionary in medicationSlotsArray) {
        NSInteger viewTag = [[medicationsSlotsDictionary objectForKey:PRESCRIBER_SLOT_VIEW_TAG] integerValue];
        DCPrescriberMedicationSlotDisplayView *prescriberMedicationSlotDisplayView = (DCPrescriberMedicationSlotDisplayView *)[self viewWithTag:viewTag];
        [self addOverlayActionButtonForPrescriberDescriptionView:prescriberMedicationSlotDisplayView];
    }
}

- (void)hideLoadingIndicator {
    
}

// here the time slots and the button to display the details are added.
- (void)addMedicationTimeAndStatusIconsFromMedicationSlotsArray:(NSArray *)medicationSlotsArray {
    
    for (NSDictionary *medicationsSlotsDictionary in medicationSlotsArray) {
        NSInteger viewTag = [[medicationsSlotsDictionary objectForKey:PRESCRIBER_SLOT_VIEW_TAG] integerValue];
        NSArray *timeSlotsArray = [medicationsSlotsDictionary objectForKey:PRESCRIBER_TIME_SLOTS];
        UIView *prescriberMedicationSlotDisplayView = [self viewWithTag:viewTag];
        CGFloat yValue = 5.0f;
        if (timeSlotsArray) {
            for (NSInteger index = 0; index < [timeSlotsArray count]; index++) {
                if (index == 3) {
                    DCDebugLog(@"NEED TO ADD THE ... FOR MORE THAN 3 SLOTS");
                    //remove dot image from xib once data is ready
                    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
                    [moreButton setTag:(viewTag*10 + viewTag)];
                    [moreButton setFrame:CGRectMake(77.0f, prescriberMedicationSlotDisplayView.frame.origin.y +
                                                    prescriberMedicationSlotDisplayView.frame.size.height - 22, 23, 22)];
                    [moreButton setImage:[UIImage imageNamed:@"Dots"] forState:UIControlStateNormal];
                    [moreButton addTarget:self action:@selector(moreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [prescriberMedicationSlotDisplayView addSubview:moreButton];
                    break;
                }
                DCPrescriberTimeView *timeView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCPrescriberTimeView class]) owner:self options:nil] objectAtIndex:0];
                DCMedicationSlot *medicationSlot = [timeSlotsArray  objectAtIndex:index];
                timeView.medicationSlot = medicationSlot;
                [timeView setFrame:CGRectMake(10.0f, yValue, TIME_VIEW_WIDTH, TIME_VIEW_HEIGHT)];
                [prescriberMedicationSlotDisplayView addSubview:timeView];
                yValue += TIME_VIEW_HEIGHT + 6;
            }
        }
    }
}

- (void)addOverlayActionButtonForPrescriberDescriptionView:(DCPrescriberMedicationSlotDisplayView *) prescriberMedicationSlotDisplayView {
    
    UIButton *overlayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayButton setFrame:prescriberMedicationSlotDisplayView.frame];
    [_calendarView addSubview:overlayButton];
    [overlayButton setTag:(10 + prescriberMedicationSlotDisplayView.tag)];
    [overlayButton addTarget:self action:@selector(moreButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self layoutIfNeeded];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.routeAndInstructionLabel.attributedText = dosageAttributedString;
    });
}

- (void)populateMedicationLabelWithName:(NSString *)medicineName dosage:(NSString *)dosage {
    
    //populate medication name label
    NSArray *medicineNameContentsArray = [medicineName componentsSeparatedByString:@" "];
    NSString *medicineNameString = medicineName;
    if ([medicineNameContentsArray count] > 0) {
        if ([medicineNameContentsArray count] == 1) {
            medicineNameString = [NSString stringWithFormat:@"%@ %@", [medicineNameContentsArray objectAtIndex:0], dosage];
        } else {
            medicineNameString = [NSString stringWithFormat:@"%@ %@ %@", [medicineNameContentsArray objectAtIndex:0], dosage, [medicineNameContentsArray objectAtIndex:1]];
        }
    }
    self.medicationNameLabel.text = medicineNameString;
}

#pragma mark - Public methods implementation
- (void)configurePrescriberMedicationCellForMedication:(DCMedicationScheduleDetails *)medicationList {
    
    [self populateRouteAndInstructionLabelWithRoute:medicationList.route instruction:medicationList.instruction];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.medicationNameLabel.text = medicationList.name;
        if (!medicationList.isActive) {
            [_discontinuedLabel setHidden:NO];
            _discontinuedLabel.text = NSLocalizedString(@"DISCONTINUED", @"");
            _discontinuedLabel.textColor = [UIColor getColorForHexString:@"#DA6A6A"];
        } else {
            [_discontinuedLabel setHidden:YES];
        }
    });
}

#pragma mark - AlertView Delegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //alertview delegate method
    if (buttonIndex != alertView.cancelButtonIndex) {
        
        [self swipeMedicationViewToRight:nil];
        [self.delegate stopMedicationForSelectedIndexPath:_indexPath];
    }
}

#pragma mark - Action Methods

- (IBAction)moreButtonPressed:(id)sender {
    
    //more button action
    UIButton *selectedMoreButton = (UIButton *)sender;
    //get view tag from more button tag
    NSInteger selectedViewTag = (selectedMoreButton.tag%10);
    for (NSDictionary *medicationsSlotsDictionary in _medicationSlotsArray) {
        NSInteger viewTag = [[medicationsSlotsDictionary objectForKey:PRESCRIBER_SLOT_VIEW_TAG] integerValue];
        NSArray *timeSlotsArray = [medicationsSlotsDictionary objectForKey:PRESCRIBER_TIME_SLOTS];
        if (viewTag == selectedViewTag) {

            if (self.delegate && [self.delegate respondsToSelector:@selector(displayMedicationDetailsViewAtIndexPath:withButtonTag: slotsArray:)]) {
                [self.delegate displayMedicationDetailsViewAtIndexPath:_indexPath withButtonTag:selectedViewTag slotsArray:timeSlotsArray];
            }
        }
    }
}

- (IBAction)editMedicationButtonPressed:(id)sender {
    
    //edit medication button action
    [self.delegate editMedicationForSelectedIndexPath:_indexPath];
}

- (IBAction)stopMedicationButtonPressed:(id)sender {
    
    //stop medication
    [self.delegate stopMedicationForSelectedIndexPath:_indexPath];
}

@end
