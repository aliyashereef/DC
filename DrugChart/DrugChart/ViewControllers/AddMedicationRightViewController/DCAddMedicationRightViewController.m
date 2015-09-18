//
//  DCAddMedicationRightViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/3/15.
//
//

#import "DCAddMedicationRightViewController.h"
#import "DCAlergyDisplayCell.h"
#import "DCMedicationDisplayCell.h"
#import "DCPatientAllergy.h"
#import "DCWarningsTableCell.h"
#import "DCWarningsHeaderView.h"
#import "DCMedicationScheduleDetails.h"

#define ANIMATION_DURATION                  0.4

#define NAVIGATION_BAR_HEIGHT               64.0f
#define ADD_MEDICATION_TOP_VIEW_HEIGHT      75.0f
#define CONTAINER_SHRINK_HEIGHT             37.0f
#define WARNINGS_CONTAINER_SHRINK_HEIGHT    50.0f
#define ALLERGY_CELL_HEIGHT                 65.0f
#define WARNING_CELL_HEIGHT_DEFAULT         85.0f
#define WARNING_CELL_HEIGHT_SMALL           65.0f
#define WARNINGS_HEADER_HEIGHT              38.0f

#define LATO_REGULAR_FIFTEEN [UIFont fontWithName:@"Lato-Regular" size:15]
#define CELL_PADDING 41

@interface DCAddMedicationRightViewController () <UITableViewDataSource, UITableViewDelegate> {
    
    __weak IBOutlet UIView *allergiesTableContainerView;
    __weak IBOutlet UIView *medicationTableContainerView;
    __weak IBOutlet UIView *warningsTableContainerView;
    __weak IBOutlet UITableView *allergiesTableView;
    __weak IBOutlet UITableView *medicationTableView;
    __weak IBOutlet UITableView *warningsTableView;
    __weak IBOutlet NSLayoutConstraint *allergiesContainerHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *medicationContainerHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *warningsContainerHeightConstraint;
    __weak IBOutlet UIButton *allergiesDropDownButton;
    __weak IBOutlet UIButton *medicationDropDownButton;
    __weak IBOutlet UIButton *warningsDropDownButton;
    
    WarningType warningType;
    CGFloat medicationViewHeight;
    NSMutableArray *warningsArray;
}

@end

@implementation DCAddMedicationRightViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureViewElements];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Public Methods

- (void)populateViewWithWarningsArray:(NSArray *)warnings {
    
    warningsArray = [NSMutableArray arrayWithArray:warnings];
    [warningsTableView reloadData];
    if (!warningsDropDownButton.selected) {
        [self warningsDropDownButtonPressed:nil];
    } else {
        [self animateWarningContainerView];
    }
    [self configureMedicationViewHeight];
}

#pragma mark - Private Methods

- (void)configureViewElements {
    
    if ([_allergiesArray count] == 0) {
        [_allergiesArray addObject:NSLocalizedString(@"NO_ALLERGIES", @"")];
    }
    if ([_medicationArray count] == 0) {
        [_medicationArray addObject:NSLocalizedString(@"PATIENT_NO_MEDICATIONS", @"")];
    }
    if ([warningsArray count] == 0) {
        warningsArray = [[NSMutableArray alloc] init];
        [warningsArray addObject:NSLocalizedString(@"NO_WARNINGS", @"")];
    }
    [warningsDropDownButton setSelected:NO];
     warningsContainerHeightConstraint.constant = 15.0f;
    [allergiesDropDownButton setSelected:YES];
    allergiesContainerHeightConstraint.constant = (ALLERGY_CELL_HEIGHT * _allergiesArray.count) + CONTAINER_SHRINK_HEIGHT;
    [medicationDropDownButton setSelected:NO];
    medicationContainerHeightConstraint.constant = CONTAINER_SHRINK_HEIGHT;
    [self calculateMedicationDropDownHeight];
    [allergiesTableView reloadData];
    [self.view layoutIfNeeded];
}

- (void)calculateMedicationDropDownHeight {
    
    if ([_medicationArray count] > 0) {
        if ([[_medicationArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
            medicationViewHeight  = 90.0f;
        } else {
            for (DCMedicationScheduleDetails *medication in _medicationArray) {
                
                medicationViewHeight += [DCUtility getRequiredSizeForText:medication.name
                                                                     font:[DCFontUtility getLatoRegularFontWithSize:15.0f]
                                                                 maxWidth:260.0f].height;
                medicationViewHeight += 85.0f;
            }
        }
    }
}

- (DCAlergyDisplayCell *)configureAllergyCellAtIndexPath:(NSIndexPath *)indexPath {
    
 DCAlergyDisplayCell *alergyDisplayCell = (DCAlergyDisplayCell *)[allergiesTableView dequeueReusableCellWithIdentifier:ALLERGY_CELL_IDENTIFIER];
    if (alergyDisplayCell == nil) {
        alergyDisplayCell = [[DCAlergyDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ALLERGY_CELL_IDENTIFIER];
    }
    if ([[_allergiesArray objectAtIndex:indexPath.row] isKindOfClass:[DCPatientAllergy class]]) {
        DCPatientAllergy *patientAllergy = [_allergiesArray objectAtIndex:indexPath.row];
        [alergyDisplayCell configurePatientAllergyCell:patientAllergy];
    } else {
        [alergyDisplayCell configurePatientAllergyCellForNoAllergies:[_allergiesArray objectAtIndex:0]];
    }
    return alergyDisplayCell;
}

- (DCMedicationDisplayCell *)configureMedicationCellAtIndexPath:(NSIndexPath *)indexPath {
    
    DCMedicationDisplayCell *medicationDisplayCell = [medicationTableView dequeueReusableCellWithIdentifier:ADD_MEDICATION_CELL_IDENTIFIER];
    if (medicationDisplayCell == nil) {
        medicationDisplayCell = [[DCMedicationDisplayCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ADD_MEDICATION_CELL_IDENTIFIER];
    }
    if ([[_medicationArray objectAtIndex:indexPath.row] isKindOfClass:[DCMedicationScheduleDetails class]]) {
        DCMedicationScheduleDetails *medicationList = [_medicationArray objectAtIndex:indexPath.row];
        [medicationDisplayCell configureCellWithMedicationDetails:medicationList];
    } else {
        [medicationDisplayCell configureCellForNoMedicationDetails:[_medicationArray objectAtIndex:indexPath.row]];
    }
    return medicationDisplayCell;
}

- (DCWarningsTableCell *)configureWarningsCellAtIndexPath:(NSIndexPath *)indexPath {
    
    DCWarningsTableCell *warningsTableCell = [warningsTableView dequeueReusableCellWithIdentifier:WARNINGS_CELL_IDENTIFIER];
    if (warningsTableCell == nil) {
        warningsTableCell = [[DCWarningsTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WARNINGS_CELL_IDENTIFIER];
    }
    if ([[warningsArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
        [warningsTableCell configureCellForNoWarnings:[warningsArray objectAtIndex:0]];
    } else {
        
        if (indexPath.section == 0) {
            if ([self hasWarningForType:eSevere]) {
                NSArray *severeArray = [[warningsArray objectAtIndex:indexPath.section] valueForKey:SEVERE_WARNING];
                DCWarning *warning = [severeArray objectAtIndex:indexPath.row];
                [warningsTableCell configureWarningsCellForWarningsObject:warning];
            } else {
                if ([self hasWarningForType:eMild]) {
                    NSArray *mildArray = [[warningsArray objectAtIndex:indexPath.section]
                                          valueForKey:MILD_WARNING];
                    DCWarning *warning = [mildArray objectAtIndex:indexPath.row];
                    [warningsTableCell configureWarningsCellForWarningsObject:warning];
                }
            }
        } else {
            if ([self hasWarningForType:eMild]) {
                NSArray *mildArray = [[warningsArray objectAtIndex:indexPath.section]
                                      valueForKey:MILD_WARNING];
                DCWarning *warning = [mildArray objectAtIndex:indexPath.row];
                [warningsTableCell configureWarningsCellForWarningsObject:warning];
            }
        }
    }
    return warningsTableCell;
}

- (BOOL)hasWarningForType:(WarningType )type {
    
    BOOL hasWarning = NO;
    for (NSDictionary *dict in warningsArray) {
        if (type == eSevere && [dict valueForKey:SEVERE_WARNING]) {
            hasWarning = YES;
        }
        if (type == eMild && [dict valueForKey:MILD_WARNING]) {
            hasWarning = YES;
        }
    }
    return hasWarning;
}

- (void)configureMedicationViewHeight {
    
    if (medicationDropDownButton.selected) {
        UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
        medicationContainerHeightConstraint.constant = mainWindow.frame.size.height - (allergiesContainerHeightConstraint.constant + warningsContainerHeightConstraint.constant + NAVIGATION_BAR_HEIGHT + ADD_MEDICATION_TOP_VIEW_HEIGHT) ;
    }
}

- (void)animateWarningContainerView {
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        @try {
            if ([warningsArray count] > 0) {
                if ([[warningsArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
                    warningsContainerHeightConstraint.constant = WARNINGS_CONTAINER_SHRINK_HEIGHT + WARNING_CELL_HEIGHT_SMALL;
                } else {
                    NSArray *severeArray;
                    NSArray *mildArray;
                    if ([self hasWarningForType:eSevere]) {
                        severeArray = [[warningsArray objectAtIndex:0]
                                       valueForKey:SEVERE_WARNING];
                        if ([self hasWarningForType:eMild]) {
                            mildArray = [[warningsArray objectAtIndex:1] valueForKey:MILD_WARNING];
                        }
                    } else {
                        mildArray = [[warningsArray objectAtIndex:0] valueForKey:MILD_WARNING];
                    }
                    warningsContainerHeightConstraint.constant = WARNINGS_CONTAINER_SHRINK_HEIGHT;
                    CGFloat warningContainerHeightConstant = warningsContainerHeightConstraint.constant;
                    UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
                    CGFloat accordionViewHeight = mainWindow.frame.size.height - (allergiesContainerHeightConstraint.constant + medicationContainerHeightConstraint.constant + NAVIGATION_BAR_HEIGHT + ADD_MEDICATION_TOP_VIEW_HEIGHT) ;
                    if ([severeArray count] > 0) {
                        warningContainerHeightConstant += (severeArray.count * WARNING_CELL_HEIGHT_DEFAULT + WARNINGS_HEADER_HEIGHT);
                    }
                    if ([mildArray count] > 0) {
                        warningContainerHeightConstant += (mildArray.count * WARNING_CELL_HEIGHT_DEFAULT + WARNINGS_HEADER_HEIGHT);
                    }
                    if (warningContainerHeightConstant > accordionViewHeight) {
                        warningsContainerHeightConstraint.constant = accordionViewHeight;
                    } else {
                        warningsContainerHeightConstraint.constant = warningContainerHeightConstant;
                    }
                }
            }
        }
        @catch (NSException *exception) {
            NSLog(@"Exception raised on warnings section height calculation: %@", exception.description);
        }
        [self configureMedicationViewHeight];
        [self.view layoutIfNeeded];
    }];
}


#pragma mark - Public Methods

- (void)displayWarningsSection:(BOOL)show {
    
    if (show) {
        //hide warnings section
        [warningsDropDownButton setSelected:YES];
        warningsContainerHeightConstraint.constant = warningsArray.count * WARNING_CELL_HEIGHT_DEFAULT;
    } else {
        //show warnings sections
        [warningsDropDownButton setSelected:NO];
        warningsContainerHeightConstraint.constant = 15.0f;
    }
    [self configureMedicationViewHeight];
}

#pragma mark - table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == warningsTableView) {
        NSInteger sectionCount = 0;
        if (warningsArray.count > 0) {
            if ([[warningsArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
                sectionCount ++;
            } else {
                NSArray *severeArray = [[warningsArray objectAtIndex:0] valueForKey:SEVERE_WARNING];
                NSArray *mildArray = [[warningsArray objectAtIndex:1] valueForKey:MILD_WARNING];
                if (severeArray.count > 0) {
                    sectionCount ++;
                }
                if (mildArray.count > 0) {
                    sectionCount ++;
                }
            }
         }
        return sectionCount;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == allergiesTableView) {
        return _allergiesArray.count;
    } else if (tableView == medicationTableView) {
        return [_medicationArray count];
    } else {
        @try {
            if ([warningsArray count] > 0) {
                if ([[warningsArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
                    return [warningsArray count];
                } else {
                    if (section == 0) {
                        if ([self hasWarningForType:eSevere]) {
                            NSArray *severeArray = [[warningsArray objectAtIndex:section] valueForKey:SEVERE_WARNING];
                            return [severeArray count];
                        } else {
                            if ([self hasWarningForType:eMild]) {
                                NSArray *mildArray = [[warningsArray objectAtIndex:section] valueForKey:MILD_WARNING];
                                return [mildArray count];
                            }
                        }
                    } else {
                        if ([self hasWarningForType:eMild]) {
                            NSArray *mildArray = [[warningsArray objectAtIndex:section] valueForKey:MILD_WARNING];
                                return [mildArray count];
                        }
                    }
                }
            }
        }
        @catch (NSException *exception) {
            DCDebugLog(@"exception raised is %@", exception.description);
        }
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView == warningsTableView) {
        if (![[warningsArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
            DCWarningsHeaderView *warningsHeaderView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCWarningsHeaderView class]) owner:self options:nil] objectAtIndex:0];
            [warningsHeaderView configureHeaderViewForSection:section];
            return warningsHeaderView;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (tableView == warningsTableView) {
        if (![[warningsArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
            return WARNINGS_HEADER_HEIGHT;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == allergiesTableView) {
        DCAlergyDisplayCell *alergyDisplayCell = [self configureAllergyCellAtIndexPath:indexPath];
        return alergyDisplayCell;
    } else if (tableView == medicationTableView) {
        // code to be added for medicationtable view
        DCMedicationDisplayCell *medicationDisplayCell = [self configureMedicationCellAtIndexPath:indexPath];
        return medicationDisplayCell;
    } else {
        DCWarningsTableCell *warningsTableCell = [self configureWarningsCellAtIndexPath:indexPath];
        return warningsTableCell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat heightValue;
    if (tableView == allergiesTableView) {
        DCAlergyDisplayCell *cell = (DCAlergyDisplayCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        CGSize stepSize = [DCUtility getRequiredSizeForText:cell.warningLabel.text
                                                       font:LATO_REGULAR_FIFTEEN
                                                   maxWidth:250];
        heightValue = CELL_PADDING + stepSize.height;
        heightValue = heightValue < ALLERGY_CELL_HEIGHT ? ALLERGY_CELL_HEIGHT: heightValue;

    } else if (tableView == medicationTableView) {
        DCMedicationDisplayCell *cell = (DCMedicationDisplayCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        if ([[_medicationArray objectAtIndex:indexPath.row] isKindOfClass:[DCMedicationScheduleDetails class]]) {
            heightValue = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        } else {
            heightValue = ALLERGY_CELL_HEIGHT;
        }
    } else {
        if ([[warningsArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
            heightValue = WARNING_CELL_HEIGHT_SMALL;
        } else {
           heightValue = WARNING_CELL_HEIGHT_DEFAULT;
        }
    }
    return heightValue;
}

#pragma mark - Action Methods

- (IBAction)allergiesDropDownButtonPressed:(id)sender {
    
    //allergies section expansion/contraction
    if (!allergiesDropDownButton.selected) {
        allergiesDropDownButton.selected = YES;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            allergiesContainerHeightConstraint.constant = (ALLERGY_CELL_HEIGHT * _allergiesArray.count) + CONTAINER_SHRINK_HEIGHT;
            [self configureMedicationViewHeight];
            [self.view layoutIfNeeded];
        }];
    } else {
        allergiesDropDownButton.selected = NO;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^ {
            allergiesContainerHeightConstraint.constant = CONTAINER_SHRINK_HEIGHT;
            [self configureMedicationViewHeight];
            [self.view layoutIfNeeded];
        }];
    }
}

- (IBAction)medicationsDropDownButtonPressed:(id)sender {
    
    //medications section expand/contract
    if (!medicationDropDownButton.selected) {
        medicationDropDownButton.selected = YES;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^ {
            [self configureMedicationViewHeight];
            //medicationContainerHeightConstraint.constant = medicationViewHeight + CONTAINER_SHRINK_HEIGHT;
            [self.view layoutIfNeeded];
        }];
    } else {
        medicationDropDownButton.selected = NO;
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            medicationContainerHeightConstraint.constant = CONTAINER_SHRINK_HEIGHT;
            [self.view layoutIfNeeded];
        }];
    }
}

- (IBAction)warningsDropDownButtonPressed:(id)sender {
    
    if (warningsDropDownButton.selected) {
        [warningsDropDownButton setSelected:NO];
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            warningsContainerHeightConstraint.constant = WARNINGS_CONTAINER_SHRINK_HEIGHT;
            [self configureMedicationViewHeight];
            [self.view layoutIfNeeded];
        }];
    } else {
        [warningsDropDownButton setSelected:YES];
//        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
//                @try {
//                    if ([warningsArray count] > 0) {
//                        if ([[warningsArray objectAtIndex:0] isKindOfClass:[NSString class]]) {
//                            warningsContainerHeightConstraint.constant = WARNINGS_CONTAINER_SHRINK_HEIGHT + WARNING_CELL_HEIGHT_SMALL;
//                        } else {
//                            NSArray *severeArray;
//                            NSArray *mildArray;
//                            if ([self hasWarningForType:eSevere]) {
//                                severeArray = [[warningsArray objectAtIndex:0]
//                                                        valueForKey:SEVERE_WARNING];
//                                if ([self hasWarningForType:eMild]) {
//                                     mildArray = [[warningsArray objectAtIndex:1] valueForKey:MILD_WARNING];
//                                }
//                            } else {
//                                mildArray = [[warningsArray objectAtIndex:0] valueForKey:MILD_WARNING];
//                            }
//                            warningsContainerHeightConstraint.constant = WARNINGS_CONTAINER_SHRINK_HEIGHT;
//                            CGFloat warningContainerHeightConstant = warningsContainerHeightConstraint.constant;
//                            UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
//                            CGFloat accordionViewHeight = mainWindow.frame.size.height - (allergiesContainerHeightConstraint.constant + medicationContainerHeightConstraint.constant + NAVIGATION_BAR_HEIGHT + ADD_MEDICATION_TOP_VIEW_HEIGHT) ;
//                            if ([severeArray count] > 0) {
//                                warningContainerHeightConstant += (severeArray.count * WARNING_CELL_HEIGHT_DEFAULT + WARNINGS_HEADER_HEIGHT);
//                            }
//                            if ([mildArray count] > 0) {
//                                warningContainerHeightConstant += (mildArray.count * WARNING_CELL_HEIGHT_DEFAULT + WARNINGS_HEADER_HEIGHT);
//                            }
//                            if (warningContainerHeightConstant > accordionViewHeight) {
//                                warningsContainerHeightConstraint.constant = accordionViewHeight;
//                            } else {
//                                warningsContainerHeightConstraint.constant = warningContainerHeightConstant;
//                            }
//                        }
//                    }
//                 }
//                @catch (NSException *exception) {
//                    NSLog(@"Exception raised on warnings section height calculation: %@", exception.description);
//                }
//            [self configureMedicationViewHeight];
//            [self.view layoutIfNeeded];
//        }];
        [self animateWarningContainerView];
    }
}

@end
