//
//  DCAddMedicationDetailsViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/23/15.
//
//

#import "DCAddMedicationDetailsViewController.h"
#import "DCAddMedicationViewController.h"
#import "DCAddMedicationPopOverContentViewController.h"
#import "DCAddMedicationSevereWarningViewController.h"
#import "DCSevereWarningPopOverBackgroundView.h"
#import "DCMissedMedicationAlertViewController.h"
#import "DCAdministratingTimeContainerView.h"
#import "DCDatePickerViewController.h"
#import "DCMedicationSlot.h"
#import "DCDatePickerPopOverBackgroundView.h"
#import "DCDosagePopOverBackgroundView.h"
#import "DCPlistManager.h"
#import "DCOverrideViewController.h"
#import "DCPopOverContentSizeUtility.h"
#import "DCMedicationSearchWebService.h"
#import "DCAddMedicationRightViewController.h"
#import "DCScrollView.h"
#import "DCAddMedicationWebService.h"
#import "DCAutoSearchView.h"
#import "DCContraIndicationWebService.h"
#import "DCAddMedicationOperation.h"
#import "DCMedicationDetails.h"

#define kSingleMedicationButtontag       1
#define kOrderSetButtonTag               2
#define kAdminstratingViewTitlelabelTag  200
#define kTagEndDateLabel                 300
#define kTagEndDateMandatoryLabel        301
#define DOSAGE_CELL_HEIGHT               44.0f

#define MEDICATION_DESCRIPTION_HEIGHT           180.0f
#define VALIDATION_VIEW_HEIGHT                  40.0f
#define MEDICATION_VIEW_OFFSET                  10.0f
#define MEDICATION_TYPE_VIEW_HEIGHT             80.0f
#define ADMINISTRATING_VIEW_TITLE_HEIGHT        65.0f
#define REGULAR_MEDICATION_CONTENT_HEIGHT       95.0f
#define SEARCH_ENTRY_MIN_LENGTH                 3
#define AUTOSEARCH_MIN_CELL_HEIGHT              48.0f
#define ORDERSET_VIEW_HEIGHT                    60.0f
#define WHEN_REQUIRED_VIEW_HEIGHT               100.0f
#define SEARCH_POPOVER_MAXIMUM_HEIGHT           480.0f
#define MEDICATION_TYPE_TITLE_VIEW_HEIGHT       45.0f
#define DELAY_DURATION                          0.3

typedef enum : NSInteger {
    
    eRegularStartDate,
    eRegularEndDate,
    eRegularAdministratingTime,
    eOnceDate,
    eOnceAdministratingTime
    
} SelectedDatePicker;

@interface DCAddMedicationDetailsViewController () <DCScrollViewDelegate, DCAdministratingTimeContainerDelegate, DCAutoSearchDelegate> {
    
    __weak IBOutlet UITextView *dosageInstructionTextView;
    __weak IBOutlet UILabel *dosageLabel;
    __weak IBOutlet UILabel *routeLabel;
    __weak IBOutlet UILabel *typeLabel;
    __weak IBOutlet UITextField *startDateTextField;
    __weak IBOutlet UITextField *endDateTextField;
    __weak IBOutlet UIView *administratingTimeContainerView;
    __weak IBOutlet UILabel *selectedMedicationTypeLabel;
    __weak IBOutlet UITextField *dateOnceMedicationTextField;
    __weak IBOutlet UIView *medicationTypeTopView;
    __weak IBOutlet UIView *regularMedicationView;
    __weak IBOutlet UIView *onceMedicationView;
    __weak IBOutlet NSLayoutConstraint *timeContainerViewHeightConstraint;
    __weak IBOutlet UIButton *medicationTypeButton;
    __weak IBOutlet UIButton *dosageButton;
    __weak IBOutlet NSLayoutConstraint *validationViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *medicationDetailsViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *medicationTypeContainerViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *regularMedicationViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *onceMedicationViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *validationViewTopConstraint;
    __weak IBOutlet UITextView *medicineNameTextView;
    __weak IBOutlet NSLayoutConstraint *medicineNameTextFieldHeightConstraint;
    __weak IBOutlet DCScrollView *scrollView;
    __weak IBOutlet UIButton *noDateButton;
    __weak IBOutlet UIButton *endDateButton;
    __weak IBOutlet UIButton *medicineNameClearButton;
    __weak IBOutlet UIButton *routeButton;
    __weak IBOutlet UIView *orderSetButtonView;
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet NSLayoutConstraint *orderSetButtonViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *bottomViewHeightConstraint;
    
    DCAdministratingTimeContainerView *timeContainerView;
    DCAddMedicationViewController *addMedicationViewController;
    DCAutoSearchView *autoSearchView;
    NSString *preparationId;
    UIPopoverController *popOverController;
    NSMutableArray *timeArray;
    SelectedDatePicker selectedDatePicker;
    NSMutableArray *medicationArray;
    BOOL majorChange;
    BOOL minorChange;
    NSDate *startDateValue;
    NSDate *endDateValue;
    NSMutableArray *alertsArray;
    NSMutableArray *dosageArray;
    CGFloat autoSearchViewHeight;
    NSMutableArray *warningsArray;
   
    BOOL addNewSubstitute;
}

@end

@implementation DCAddMedicationDetailsViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureViewElements];
    [self configureOrderSetView];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    
    [self configureMedicationTypeView];
    [super viewDidLayoutSubviews];
}

#pragma mark - Public Methods
// Done button makes the API call for Add Medication after field validation
- (void)doneButtonAction {
    [self resignKeyboard];
    if ([self entriesAreValid]) {
        if (_medicationList) {
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            if ([DCAPPDELEGATE isNetworkReachable]) {
                [addMedicationViewController addMedicationServiceCallWithParamaters:[self getMedicationDetailsDictionary]
                                                                  forMedicationType:typeLabel.text];
            }
        }
    } else {
        validationViewTopConstraint.constant = 15.0f;
        validationViewHeightConstraint.constant =  VALIDATION_VIEW_HEIGHT;
        [self setMedicationDetailsViewHeightConstraint];
    }
}

- (void)parentViewTapped {
    
    //hide auto search view
    if (!autoSearchView.hidden) {
        [autoSearchView setHidden:YES];
    }
}

- (void)loadOrderSetMedicationAtIndex:(int)selectedIndex {
    
    //load selected medicine
    [addMedicationViewController selectedOrderSetMedicineAtIndex:selectedIndex];
    [addMedicationViewController loadAddMedicationDetailsViewAtIndex:selectedIndex];
}

#pragma mark - Private Methods

- (void)configureViewElements {
    
    timeArray =  [NSMutableArray arrayWithArray:[DCPlistManager getAdministratingTimeList]];
    [DCUtility configureDisplayElementsForTextView:medicineNameTextView];
    [medicineNameTextView setTextContainerInset:MEDICINE_NAME_TEXTVIEW_EDGE_INSETS];
    [DCUtility configureDisplayElementsForTextView:dosageInstructionTextView];
    [dosageInstructionTextView setTextContainerInset:UIEdgeInsetsMake(5, 10, 5, 10)];
    //select Single Medication by default
    UIButton *singleMedicationButton = (UIButton *)[self.view viewWithTag:kSingleMedicationButtontag];
    [singleMedicationButton setSelected:YES];
    [self addAdministratingTimeContainerView];
    administratingTimeContainerView.layer.borderColor = [UIColor colorWithRed:177.0f/255.0f green:177.0f/255.0f blue:177.0f/255.0f alpha:0.6].CGColor;
    [self addAutoSearchView];
    medicationArray = [NSMutableArray arrayWithArray:_patient.medicationListArray];
    [medicationTypeTopView setHidden:YES];
    [regularMedicationView setHidden:YES];
    [onceMedicationView setHidden:YES];
    validationViewHeightConstraint.constant = ZERO_CONSTRAINT;
    validationViewTopConstraint.constant = ZERO_CONSTRAINT;
    [self setMedicationDetailsViewHeightConstraint];
    [self populateMedicationListDetails];
    scrollView.scrollDelegate = self;
     startDateValue = [DCDateUtility getDateInCurrentTimeZone:[NSDate date]];
    if (!_medicationList) {
        [self configureEndDateButtonForSelectionState:YES];
        startDateTextField.text = [DCDateUtility getDisplayDateForAddMedication:startDateValue dateAndTime:YES];
    }
    [medicineNameClearButton setHidden:YES];
    dosageArray = [[NSMutableArray alloc] init];
    addMedicationViewController = [self getParentViewController];
    dateOnceMedicationTextField.text = [DCDateUtility getDisplayDateForAddMedication:startDateValue dateAndTime:YES];
    medicationTypeContainerViewHeightConstraint.constant = ZERO_CONSTRAINT;
    [self.view layoutSubviews];
}

- (void)configureOrderSetView {
    
    //configure order set view
    if (_isLoadingOrderSet) {
        [self populateOrderSetMedicationDetailsAtIndex:_orderSetSelectedIndex];
        orderSetButtonViewHeightConstraint.constant = ORDERSET_VIEW_HEIGHT;
        bottomViewHeightConstraint.constant = 130.0f;
    } else {
        orderSetButtonViewHeightConstraint.constant = ZERO_CONSTRAINT;
        bottomViewHeightConstraint.constant = 20.0f;
    }
    [self configureOrderSetButtonsView];
    [self.view layoutIfNeeded];
}

- (void)configureOrderSetButtonsView {
    
    orderSetButtonView.hidden = _isLoadingOrderSet ? NO : YES;
}

- (void)addAdministratingTimeContainerView {
    
    //add administarting tiem container view
    timeContainerView = [[DCAdministratingTimeContainerView alloc] initWithFrame:CGRectMake(10, 30, 575, 120)];
    timeContainerView.delegate = self;
    [administratingTimeContainerView addSubview:timeContainerView];
    timeContainerView.timeArray = timeArray;
    [self updateAdministartingTimeContainerHeightConstraint];
    [administratingTimeContainerView layoutIfNeeded];
    regularMedicationViewHeightConstraint.constant = timeContainerViewHeightConstraint.constant + REGULAR_MEDICATION_CONTENT_HEIGHT;
    medicationTypeContainerViewHeightConstraint.constant = MEDICATION_TYPE_TITLE_VIEW_HEIGHT + regularMedicationViewHeightConstraint.constant + 30;
    [self.view layoutIfNeeded];
}

- (void)addAutoSearchView {
    
    //add auto search view
    autoSearchView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCAutoSearchView class]) owner:self options:nil] objectAtIndex:0];
    [autoSearchView setFrame:CGRectMake(medicineNameTextView.frame.origin.x, medicineNameTextView.frame.origin.y + medicineNameTextFieldHeightConstraint.constant + 15, 850, 100)];

    autoSearchView.autoSearchType = eMedication;
    [scrollView addSubview:autoSearchView];
    [autoSearchView setSearchDelegate:self];
    [autoSearchView setHidden:YES];
}

- (void)fetchMedicationListForString:(NSString *)searchString {
    
    //get complete list of medications
    DCDebugLog(@"Fetch Medication");
    DCMedicationSearchWebService *medicationWebService = [[DCMedicationSearchWebService alloc] init];
    medicationWebService.searchString = searchString;
    [autoSearchView setFrame:CGRectMake(autoSearchView.frame.origin.x, autoSearchView.frame.origin.y, autoSearchView.frame.size.width, AUTOSEARCH_MIN_CELL_HEIGHT + 10)];
    [autoSearchView.activityIndicator startAnimating];
    [medicationWebService getCompleteMedicationListWithCallBackHandler:^(id response, NSDictionary *errorDict) {
        
        if (!errorDict) {
            autoSearchView.searchListArray = [NSMutableArray arrayWithArray:response];
            [autoSearchView searchAutocompleteEntriesWithSubstring:searchString];
            if ([response count] == 0) {
                [autoSearchView setFrame: CGRectMake(autoSearchView.frame.origin.x, autoSearchView.frame.origin.y, autoSearchView.frame.size.width, AUTOSEARCH_MIN_CELL_HEIGHT + 10)];
            } else {
                [self configureAutoSearchViewHeight];
            }
        } else {
            NSInteger errorCode = [[errorDict valueForKey:@"code"] integerValue];
            if (errorCode != NSURLErrorCancelled) {
                autoSearchView.searchListArray = [NSMutableArray arrayWithArray:@[]];
                [autoSearchView searchAutocompleteEntriesWithSubstring:searchString];
                if (errorCode == NETWORK_NOT_REACHABLE) {
                    [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
                } else if (errorCode == NSURLErrorTimedOut) {
                    //time out error here
                    [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:@"Webservice call has timed out."];
                } else {
                    DCDebugLog(@"error response info %@", errorResponse);
                }
            }
        }
    }];
}

- (void)populateMedicationListDetails {
    
    if (self.medicationList) {
        medicineNameTextView.text = _medicationList.name;
        medicineNameTextView.alpha = 0.6;
        [self expandMedicineNameTextField];
        medicineNameTextView.userInteractionEnabled = NO;
        dosageLabel.text = _medicationList.dosage;
        routeLabel.text = _medicationList.route;
        dosageInstructionTextView.text = _medicationList.instruction;
        NSDate *startDate = [DCDateUtility dateFromSourceString:_medicationList.startDate];
        NSDate *endDate = [DCDateUtility dateFromSourceString:_medicationList.endDate];
        if (endDate) {
            [self configureEndDateButtonForSelectionState:NO];
            endDateTextField.text = [DCDateUtility getDisplayDateForAddMedication:endDate dateAndTime:YES];
        } else {
            [self configureEndDateButtonForSelectionState:YES];
        }
        if (startDate) {
            startDateTextField.text = [DCDateUtility getDisplayDateForAddMedication:startDate dateAndTime:YES];
        }
        @try {
            if([timeArray count] > 0) {
                [timeArray removeAllObjects];
                for (UIView *subview in administratingTimeContainerView.subviews) {
                    [subview removeFromSuperview];
                }
                for (NSString *time in _medicationList.scheduleTimesArray) {
                    NSString *dateString = [DCUtility convertTimeToHourMinuteFormat:time];
                    NSDictionary *dict = @{@"time" : dateString, @"selected" : @1};
                    [timeArray addObject:dict];
                }
            }
            [self addAdministratingTimeContainerView];
            [timeContainerView configureTimeViewsInContainerView];
        }
        @catch (NSException *exception) {
            DCDebugLog(@"");
        }
      
        typeLabel.text = _medicationList.medicineCategory;
        [self configureMedicationTypeView];
    }
}

- (void)populateOrderSetMedicationDetailsAtIndex:(int)index {
    
    //order set medication details
    _orderSetSelectedIndex = index;
    [addMedicationViewController selectedOrderSetMedicineAtIndex:index];
    NSString *backButtonTitle = (index == 0) ? CANCEL_BUTTON_TITLE : BACK_BUTTON_TITLE;
    [backButton setTitle:backButtonTitle forState:UIControlStateNormal];
    if ([self.medicationsInOrderSet count] > 0) {
        DCMedicationDetails *medication = [self.medicationsInOrderSet objectAtIndex:index];
        preparationId = [NSString stringWithFormat:@"%@", medication.medicationId];
        medicineNameTextView.text = medication.name;
        [self expandMedicineNameTextField];
        medicineNameTextView.userInteractionEnabled = NO;
        dosageInstructionTextView.text = medication.instruction;
        dosageLabel.text = medication.dosage;
        routeLabel.text = medication.route;
        typeLabel.text = medication.medicineCategory;
        [self configureMedicationTypeView];

        if (![medication.dosage isEqualToString:EMPTY_STRING]) {
            [dosageArray addObject:medication.dosage];
        }
        if (medication.startDate) {
            startDateTextField.text = medication.startDate;
        } else {
            startDateValue = [DCDateUtility getDateInCurrentTimeZone:[NSDate date]];
            startDateTextField.text = [DCDateUtility getDisplayDateForAddMedication:startDateValue dateAndTime:YES];
        }
        endDateTextField.text = medication.endDate;
        if (medication.endDate && ![medication.endDate isEqualToString:EMPTY_STRING]) {
            [self configureEndDateButtonForSelectionState:NO];
        }
        if (medication.onceMedicationDate) {
            dateOnceMedicationTextField.text = medication.onceMedicationDate;
        } else {
            dateOnceMedicationTextField.text = [DCDateUtility getDisplayDateForAddMedication:startDateValue dateAndTime:YES];
        }
        [timeContainerView deselectAdministratingTimeSlots];
        if ([medication.timeArray count] > 0) {
            timeContainerView.timeArray = medication.timeArray;
            timeArray = medication.timeArray;
        }
        [timeContainerView configureTimeViewsInContainerView];
        [self updateAdministartingTimeContainerHeightConstraint];
        [self configureAutoSearchViewHeight];
        [self callWarningsWebServiceForMedication:medication];
    }
}

- (void)displayPopOverContentViewControllerForContentType:(AddMedicationPopOverContentType)contentType fromSender:(id) sender contentSize:(CGSize) contentSize {
    
    [self resignKeyboard];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD
                                                             bundle: nil];
    DCAddMedicationPopOverContentViewController *contentViewController = [mainStoryboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_CONTENT_VIEW_CONTROLLER];
    contentViewController.contentType = contentType;
    NSString *dosageValue = dosageLabel.text;
    if (contentType == eDosage) {
        if (![dosageValue isEqualToString:EMPTY_STRING]) {
            [dosageArray addObject:dosageValue];
        }
        NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:dosageArray];
        dosageArray = [NSMutableArray arrayWithArray:[orderedSet array]];
        contentViewController.selectedDosage = dosageValue;
        contentViewController.dosageArray = dosageArray;
    }
    contentViewController.newDosageRecieved = ^ (NSString *newDosage) {
        DCDebugLog(@"***** newDosage is %@", newDosage);
        [dosageArray addObject:newDosage];
        dosageLabel.text = newDosage;
        [popOverController dismissPopoverAnimated:YES];
    };
    contentViewController.entrySelected = ^ (NSDictionary *selectedDictionary) {
        [self recievedAddMedicationSelectedContent:selectedDictionary];
    };
    popOverController = [[UIPopoverController alloc] initWithContentViewController:contentViewController];
    if (contentType == eDosage) {
        popOverController.popoverBackgroundViewClass = [DCDosagePopOverBackgroundView class];
    } else {
        popOverController.popoverBackgroundViewClass = [DCDatePickerPopOverBackgroundView class];
    }

    popOverController.popoverContentSize = contentSize;
    [popOverController presentPopoverFromRect:[sender bounds]
                                       inView:sender
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
}

- (void)configureMedicationTypeView {
    
    NSString *selectedMedicationType = typeLabel.text;
    validationViewHeightConstraint.constant = ZERO_CONSTRAINT;
    validationViewTopConstraint.constant = ZERO_CONSTRAINT;
    [self setMedicationDetailsViewHeightConstraint];
    if ([selectedMedicationType isEqualToString:REGULAR_MEDICATION]) {
        regularMedicationViewHeightConstraint.constant = timeContainerViewHeightConstraint.constant + REGULAR_MEDICATION_CONTENT_HEIGHT;
        medicationTypeContainerViewHeightConstraint.constant = MEDICATION_TYPE_TITLE_VIEW_HEIGHT + regularMedicationViewHeightConstraint.constant + 30;
        selectedMedicationTypeLabel.text = NSLocalizedString(@"REGULAR_MEDICATION", @"");
        [medicationTypeTopView setHidden:NO];
        [regularMedicationView setHidden:NO];
        [onceMedicationView setHidden:YES];
        [administratingTimeContainerView setHidden:NO];
    } else if ([selectedMedicationType isEqualToString:ONCE_MEDICATION]) {
        onceMedicationViewHeightConstraint.constant =  100.0f;
        medicationTypeContainerViewHeightConstraint.constant = MEDICATION_TYPE_TITLE_VIEW_HEIGHT + onceMedicationViewHeightConstraint.constant + 20;
        selectedMedicationTypeLabel.text = NSLocalizedString(@"ONCE_MEDICATION", @"");
        [medicationTypeTopView setHidden:NO];
        [regularMedicationView setHidden:YES];
        [onceMedicationView setHidden:NO];
    } else if ([selectedMedicationType isEqualToString:@"When Required"] ||
               [selectedMedicationType isEqualToString:WHEN_REQUIRED]) {
        //hide all views
        selectedMedicationTypeLabel.text = WHEN_REQ_DISPLAY_STRING;
        typeLabel.text = WHEN_REQ_DISPLAY_STRING;
        regularMedicationViewHeightConstraint.constant = REGULAR_MEDICATION_CONTENT_HEIGHT;
        medicationTypeContainerViewHeightConstraint.constant = MEDICATION_TYPE_TITLE_VIEW_HEIGHT + regularMedicationViewHeightConstraint.constant + 30;
        [medicationTypeTopView setHidden:NO];
        [regularMedicationView setHidden:NO];
        [onceMedicationView setHidden:YES];
        [administratingTimeContainerView setHidden:YES];
    } else {
        [medicationTypeTopView setHidden:YES];
        [regularMedicationView setHidden:YES];
        [onceMedicationView setHidden:YES];
    }
    [self.view layoutSubviews];
}

- (void)setMedicationDetailsViewHeightConstraint {
    
     medicationDetailsViewHeightConstraint.constant =  MEDICATION_DESCRIPTION_HEIGHT + validationViewHeightConstraint.constant + MEDICATION_VIEW_OFFSET + validationViewTopConstraint.constant + medicineNameTextFieldHeightConstraint.constant - 35.0f;
}

- (BOOL)hasWarningForType:(WarningType )type {
    
    BOOL hasWarning = NO;
    for (NSDictionary *dict in warningsArray) {
        if (type == eSevere && [dict valueForKey:SEVERE_WARNING]) {
            hasWarning = YES;
        }
    }
    return hasWarning;
}

- (void)displayWarningsViewOnAddSubstituteCancel {
    
    [self displayWarningViewForType:SEVERE_WARNING forOrderSetCompletionStatus:NO];
}

- (void)displayWarningViewForType:(NSString *)warningType forOrderSetCompletionStatus:(BOOL)completed {
    
    //display severe/mild warnings
    [popOverController dismissPopoverAnimated:YES];
    if ([warningType isEqualToString:SEVERE_WARNING]) {
        //display severe warning pop up
        if (!completed && [self hasWarningForType:eSevere]) {
            UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD
                                                                           bundle: nil];
            DCAddMedicationSevereWarningViewController *severeWarningViewController = [administerStoryboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_SEVERE_WARNINGS_VIEW_CONTROLLER];
            [severeWarningViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
            [severeWarningViewController populateViewWithWarningsDetails:warningsArray];
            severeWarningViewController.overrideAction = ^ (BOOL override){
                DCDebugLog(@"OVERRide value: %d", override);
                [self configureViewForSevereWarningViewDismiss:override];
            };
            [self presentViewController:severeWarningViewController animated:YES completion:nil];
        }
    } else {
        //display mild warning view
        if (!_isLoadingOrderSet) {
            typeLabel.text = REGULAR_MEDICATION;
            [self configureMedicationTypeView];
        }
    }
}

- (void)displayOverrideView {
    
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD
                                                                      bundle: nil];
    DCOverrideViewController *overrideViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:OVERRIDE_VIEW_SB_ID];
    overrideViewController.reasonSubmitted = ^ (BOOL hasReason) {
        if (!hasReason) {
            //clear all fields
            if (!_isLoadingOrderSet) {
                [self configureViewForSevereWarningViewDismiss:NO];
            } else {
                [self displayWarningViewForType:SEVERE_WARNING forOrderSetCompletionStatus:NO];
            }
        }
    };
    [overrideViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:overrideViewController animated:YES completion:nil];
}

- (void)configureViewForSevereWarningViewDismiss:(BOOL)override {
    
    //override drug usage or skip using this drug
    if (override) {
        //use this drug
        //display override view
        [self performSelector:@selector(displayOverrideView) withObject:nil afterDelay:DELAY_DURATION];
    } else  {
        //skip the drug
        if (_isLoadingOrderSet) {
            //display substitute pop up
            [self displayAlertViewControllerForType:eAddSubstitute];
        } else {
            [self clearAllFields];
        }
    }
    [self.view layoutSubviews];
}

- (void) clearValidations {
    
    // Removing the validation error elements added
    validationViewTopConstraint.constant = ZERO_CONSTRAINT;
    validationViewHeightConstraint.constant =  ZERO_CONSTRAINT;
    [self setMedicationDetailsViewHeightConstraint];
}

- (void)clearAllFields {
    
    routeLabel.text = EMPTY_STRING;
    typeLabel.text = EMPTY_STRING;
    medicineNameTextView.text = EMPTY_STRING;
    dosageLabel.text = EMPTY_STRING;
    dosageInstructionTextView.text = EMPTY_STRING;
    dateOnceMedicationTextField.text = EMPTY_STRING;
    [dosageArray removeAllObjects];
    medicineNameClearButton.hidden = YES;
    [addMedicationViewController displayWarningsAccordionSection:NO];
}

- (BOOL)validateSelectedMedicationTypeView {
    
    BOOL isValid = YES;
    NSString *selectedMedicationType = typeLabel.text;
    if ([selectedMedicationType isEqualToString:REGULAR_MEDICATION]) {
        if (![self isRegularOrWhenRequiredTimeFieldsValid]) {
            isValid = NO;
        }
        if (![self isTimeViewValidForRegularMedication]) {
            isValid = NO;
        }
    } else if ([selectedMedicationType isEqualToString:ONCE_MEDICATION]) {
        if ([dateOnceMedicationTextField.text isEqualToString:EMPTY_STRING]) {
            [DCUtility modifyViewComponentForErrorDisplay:dateOnceMedicationTextField];
            isValid = NO;
        } else {
            [dateOnceMedicationTextField layer].borderColor = [UIColor clearColor].CGColor;
        }
    } else {
        //validate when required view
        if (![self isRegularOrWhenRequiredTimeFieldsValid]) {
            isValid = NO;
        }
    }
    return isValid;
}

- (BOOL)isRegularOrWhenRequiredTimeFieldsValid {
    
    BOOL isValid = YES;
    if ([startDateTextField.text isEqualToString:EMPTY_STRING]) {
        [DCUtility modifyViewComponentForErrorDisplay:startDateTextField];
        isValid = NO;
    } else {
        [startDateTextField layer].borderColor = [UIColor clearColor].CGColor;
    }
    if (!noDateButton.selected) {
        if ([endDateTextField.text isEqualToString:EMPTY_STRING]) {
            [DCUtility modifyViewComponentForErrorDisplay:endDateTextField];
            isValid = NO;
        } else {
            [endDateTextField layer].borderColor = [UIColor clearColor].CGColor;
        }
    }
    return isValid;
}

- (BOOL)isTimeViewValidForRegularMedication {
    
    //check if any of the time views are selected
    BOOL timeViewValid = YES;
    for (NSDictionary *timeDictionary in timeArray) {
        BOOL timeSelected = [[timeDictionary valueForKey:@"selected"] boolValue];
        if (timeSelected) {
            timeViewValid = YES;
            break;
        } else {
            timeViewValid = NO;
        }
    }
    if (!timeViewValid) {
        [DCUtility modifyViewComponentForErrorDisplay:administratingTimeContainerView];
    } else {
        administratingTimeContainerView.layer.borderColor = [UIColor clearColor].CGColor;
    }
    return timeViewValid;
}

- (void)resetToValidBorderColorForField:(UIView *)selectedView {
    
    //set original border color
    if (selectedView == medicineNameTextView) {
        [medicineNameTextView layer].borderColor = [UIColor colorWithRed:177.0f/255.0f green:177.0f/255.0f blue:177.0f/255.0f alpha:0.6].CGColor;
    } else if (selectedView == medicationTypeButton) {
        [medicationTypeButton layer].borderColor = [UIColor clearColor].CGColor;
    } else if (selectedView == dosageButton) {
       [dosageButton layer].borderColor = [UIColor clearColor].CGColor;
    } else if (selectedView == routeButton) {
       [routeButton layer].borderColor = [UIColor clearColor].CGColor;
    }
}

- (BOOL)entriesAreValid {
    
    BOOL isValid = YES;
    if ([medicineNameTextView.text isEqualToString:EMPTY_STRING] || medicineNameTextView.text == nil) {
        [DCUtility modifyViewComponentForErrorDisplay:medicineNameTextView];
        isValid = NO;
    } else {
        [medicineNameTextView layer].borderColor = [UIColor colorWithRed:177.0f/255.0f green:177.0f/255.0f blue:177.0f/255.0f alpha:0.6].CGColor;
    }
    if ([typeLabel.text isEqualToString:EMPTY_STRING] || typeLabel.text == nil) {
        [DCUtility modifyViewComponentForErrorDisplay:medicationTypeButton];
        isValid = NO;
    } else {
        //validate added medication type view
        [medicationTypeButton layer].borderColor = [UIColor clearColor].CGColor;
        if (![self validateSelectedMedicationTypeView]) {
            isValid = NO;
        }
    }
    if ([dosageLabel.text isEqualToString:EMPTY_STRING] || dosageLabel.text == nil) {
        [DCUtility modifyViewComponentForErrorDisplay:dosageButton];
        isValid = NO;
    } else {
        [dosageButton layer].borderColor = [UIColor clearColor].CGColor;
    }
    if ([routeLabel.text isEqualToString:EMPTY_STRING] || routeLabel.text == nil) {
        [DCUtility modifyViewComponentForErrorDisplay:routeButton];
        isValid = NO;
    } else {
        [routeButton layer].borderColor = [UIColor clearColor].CGColor;
    }
    return isValid;
}

- (void)displayAlertViewControllerForType:(AlertType ) type {
    
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD
                                                                   bundle: nil];
    DCMissedMedicationAlertViewController *alertViewController = [administerStoryboard instantiateViewControllerWithIdentifier:MISSED_ADMINISTER_VIEW_CONTROLLER];
    alertViewController.alertType = type;
    alertViewController.medicineName = medicineNameTextView.text;
    alertViewController.dismissView = ^ {
        if (type == eAddSubstitute) {
            //add substitute
            [medicineNameTextView setUserInteractionEnabled:YES];
            [self clearAllFields];
             [medicineNameTextView becomeFirstResponder];
            addNewSubstitute = YES;
        } else {
            [self updateActiveMedicationListAndDismissView];
        }
    };
    alertViewController.dismissViewWithoutSaving = ^ {
        if (type == eAddSubstitute) {
            //display override view again
            [self displayWarningViewForType:SEVERE_WARNING forOrderSetCompletionStatus:NO];
            [self performSelector:@selector(displayWarningsViewOnAddSubstituteCancel) withObject:nil afterDelay:DELAY_DURATION];
        }
    };
    alertViewController.removeMedication = ^ {
        [addMedicationViewController deleteMedicineInOrderSetViewTag:_orderSetSelectedIndex + 1];
    };
    [alertViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:alertViewController animated:YES completion:nil];
}

- (void)displayDatePickerPopOverFromView:(id)sender withType:(DatePickerType) datePickerType {
    
    
    UIButton *selectedButton = (UIButton *)sender;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD
                                                         bundle: nil];
    DCDatePickerViewController *dateViewController = [storyboard instantiateViewControllerWithIdentifier:DATE_PICKER_VIEW_SB_ID];
    UIPopoverArrowDirection arrowDirection;
    dateViewController.datePickerType = datePickerType;
    if (datePickerType == eEndDatePicker) {
        dateViewController.minimumDate = startDateValue != nil ? [DCDateUtility GetDateInGMTTimeZone:startDateValue] :[NSDate date];
        if (endDateValue) {
             dateViewController.previousDate = endDateValue;
        } else {
            if (![endDateTextField.text isEqualToString:EMPTY_STRING] && self.medicationList.endDate) {
                NSDate *endDate = [DCDateUtility dateForDateString:_medicationList.endDate withDateFormat:DATE_FORMAT_RANGE];
                dateViewController.previousDate = endDate;
            }
        }
       
    } else if (selectedDatePicker == eRegularAdministratingTime){
        dateViewController.minimumDate = nil;
    } else {
        dateViewController.minimumDate = [NSDate date];
    }
    CGPoint windowPoint = [selectedButton convertPoint:selectedButton.bounds.origin toView: [[UIApplication sharedApplication] keyWindow]];
    arrowDirection = windowPoint.y > 550 ? UIPopoverArrowDirectionDown : UIPopoverArrowDirectionUp;
    dateViewController.dateHandler = ^ (NSDate *date) {
        
        [self updateViewWithSelectedDate:date];
    };
    popOverController = [[UIPopoverController alloc] initWithContentViewController:dateViewController];
    popOverController.popoverBackgroundViewClass = [DCDatePickerPopOverBackgroundView class];
    popOverController.popoverContentSize = CGSizeMake(300, 180);
    [popOverController presentPopoverFromRect:[sender bounds]
                                       inView:sender
                     permittedArrowDirections:arrowDirection
                                     animated:YES];
}

- (void)updateViewWithSelectedDate:(NSDate *)date {
    
    switch (selectedDatePicker) {
        case eRegularAdministratingTime:
            [timeContainerView updateTimeContainerViewWithSelectedTime:date];
            break;
        case eRegularStartDate:
            startDateValue = [DCDateUtility getDateInCurrentTimeZone:date];
            startDateTextField.text = [DCDateUtility getDisplayDateForAddMedication:startDateValue dateAndTime:YES];
            endDateTextField.text = EMPTY_STRING;
            break;
        case eRegularEndDate:
            endDateValue = [DCDateUtility getDateInCurrentTimeZone:date];
            endDateTextField.text = [DCDateUtility getDisplayDateForAddMedication:endDateValue dateAndTime:YES];
            break;
        case eOnceDate:
            startDateValue = [DCDateUtility getDateInCurrentTimeZone:date];;
            dateOnceMedicationTextField.text = [DCDateUtility getDisplayDateForAddMedication:startDateValue dateAndTime:YES];
            break;
        default:
            break;
    }
    minorChange = YES;
}

- (void)expandMedicineNameTextField {
    
    CGFloat textHeight = [DCUtility getTextViewSizeWithText:medicineNameTextView.text maxWidth:400 font:[DCFontUtility getLatoRegularFontWithSize:14.0f]].height;
    if (textHeight < 30) {
        medicineNameTextFieldHeightConstraint.constant = 35.0f;
    } else {
        medicineNameTextFieldHeightConstraint.constant = textHeight + 15;
    }
    [self setMedicationDetailsViewHeightConstraint];
    [self configureAutoSearchViewHeight];
    [self.view layoutIfNeeded];
}

- (void)hideAutoSearchTableViewOnTouch:(UITouch *)touch {
    
    //hide auto search view
    if(touch.view != autoSearchView){
        if (!autoSearchView.hidden) {
            [autoSearchView setHidden:YES];
        }
    }
    [addMedicationViewController configureOrderSetScrollViewOnSuperviewTap];
}

- (void)configureEndDateButtonForSelectionState:(BOOL)selected {
    
    UILabel *endDateLabel = (UILabel *)[self.view viewWithTag:kTagEndDateLabel];
    UILabel *mandatoryLabel = (UILabel *)[self.view viewWithTag:kTagEndDateMandatoryLabel];
    if (selected) {
        [noDateButton setSelected:YES];
        [endDateLabel setAlpha:0.4];
        [mandatoryLabel setHidden:YES];
        [endDateButton setHidden:YES];
        [endDateTextField.layer setBorderColor:[UIColor colorWithRed:177.0f/255.0f green:177.0f/255.0f blue:177.0f/255.0f alpha:0.6].CGColor];
        [endDateTextField setUserInteractionEnabled:NO];
        [endDateTextField setAlpha:0.4];
    } else {
        [noDateButton setSelected:NO];
        [endDateButton setHidden:NO];
        [endDateLabel setAlpha:1.0];
        [mandatoryLabel setHidden:NO];
        [endDateTextField.layer setBorderColor:[UIColor clearColor].CGColor];
        [endDateTextField setUserInteractionEnabled:YES];
        [endDateTextField setAlpha:1.0];
    }
}

- (void)moveParentViewToTopOnEditingText:(BOOL)moveUp {
    
    //animate parent view to top
    [addMedicationViewController animateViewUpwardsOnEditingText:moveUp];
}

- (void)resignKeyboard {
    
    if ([dosageInstructionTextView isFirstResponder]) {
        [dosageInstructionTextView resignFirstResponder];
    }
    if ([medicineNameTextView isFirstResponder]) {
        [medicineNameTextView resignFirstResponder];
    }
}

- (DCAddMedicationViewController *)getParentViewController {
    
    //get parent view controller
    if (_isLoadingOrderSet) {
        addMedicationViewController = (DCAddMedicationViewController *)self.navigationController.parentViewController;
    } else {
        addMedicationViewController = (DCAddMedicationViewController *)self.parentViewController;
    }
    return addMedicationViewController;
}

- (void)cancelPreviousSearchRequest {
    
    DCMedicationSearchWebService *medicationWebService = [[DCMedicationSearchWebService alloc] init];
    [medicationWebService cancelPreviousRequest];
}

- (void)saveMedicationDetailsInOrderSetAtIndex:(int)index {
    
    //save and update medicine details in order set
    DCMedicationDetails *medication = [_medicationsInOrderSet objectAtIndex:index];
    medication.name = medicineNameTextView.text;
    medication.dosage = dosageLabel.text;
    medication.medicineCategory = typeLabel.text;
    medication.instruction = dosageInstructionTextView.text;
    medication.route = routeLabel.text;
    medication.startDate = startDateTextField.text;
    medication.endDate = endDateTextField.text;
    medication.noEndDate = noDateButton.selected ? YES : NO;
    medication.onceMedicationDate = dateOnceMedicationTextField.text;
    medication.addMedicationCompletionStatus = YES;
    medication.timeArray = timeArray;
    [self addMedicationDetailsToOperationsArray];
    [addMedicationViewController updateActiveOrderSetArray:_medicationsInOrderSet withCompletion:^(BOOL completed) {
        
    }];
}

- (void)recievedAddMedicationSelectedContent:(NSDictionary *)contentDictionary {
    
    //recieved notification value
    NSInteger contentType = [[contentDictionary valueForKey:@"contentType"] integerValue];
    NSString *selectedValue = [contentDictionary valueForKey:@"value"];
    switch (contentType) {
        case eRoute:
            [self resetToValidBorderColorForField:routeButton];
            routeLabel.text = selectedValue;
            break;
        case eMedicationType:
            typeLabel.text = selectedValue;
            [self resetToValidBorderColorForField:medicationTypeButton];
            [self configureMedicationTypeView];
            break;
        case eDosage:
            dosageLabel.text = selectedValue;
            [self resetToValidBorderColorForField:dosageButton];
            break;
        default:
            break;
    }
    minorChange = YES;
}

- (void)configureAutoSearchViewHeight {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
        autoSearchViewHeight =   mainWindow.frame.size.height - (NAVIGATION_BAR_HEIGHT + self.keyboardSize.height + medicineNameTextView.frame.origin.y + medicineNameTextFieldHeightConstraint.constant + 20);
        CGFloat searchContentHeight;
        searchContentHeight = [autoSearchView.searchedContentsArray count]* autoSearchView.searchTableViewCellHeight;
        if (searchContentHeight > autoSearchViewHeight) {
            CGFloat searchHeight = autoSearchViewHeight> SEARCH_POPOVER_MAXIMUM_HEIGHT ? SEARCH_POPOVER_MAXIMUM_HEIGHT: autoSearchViewHeight;
            [autoSearchView setFrame:CGRectMake(autoSearchView.frame.origin.x, medicineNameTextView.frame.origin.y + medicineNameTextFieldHeightConstraint.constant+ validationViewHeightConstraint.constant + validationViewTopConstraint.constant + 10, autoSearchView.frame.size.width, searchHeight)];
        } else {
            CGFloat searchHeight = searchContentHeight > SEARCH_POPOVER_MAXIMUM_HEIGHT ? SEARCH_POPOVER_MAXIMUM_HEIGHT: searchContentHeight;
            if (searchHeight < 50.0f) {
                searchHeight = 50.0f;
            }
            [autoSearchView setFrame:CGRectMake(autoSearchView.frame.origin.x, medicineNameTextView.frame.origin.y + medicineNameTextFieldHeightConstraint.constant + validationViewHeightConstraint.constant + validationViewTopConstraint.constant + 10, autoSearchView.frame.size.width, searchHeight + 10)];
        }
        
    });
}

- (void)updateActiveMedicationListAndDismissView {
    
    [addMedicationViewController updateActiveOrderSetArray:_medicationsInOrderSet withCompletion:^(BOOL completed) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)callWarningsWebServiceForMedication:(DCMedication *)medication {
    
    DCContraIndicationWebService *webService = [[DCContraIndicationWebService alloc] init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [webService getContraIndicationsForPatientWithId:addMedicationViewController.patient.patientId forDrugPreparationId:preparationId withCallBackHandler:^(NSArray *alergiesArray, NSError *error) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!error) {
            warningsArray = [[NSMutableArray alloc] init];
            warningsArray = [NSMutableArray arrayWithArray:[DCUtility categorizeContentArrayBasedOnSeverity:alergiesArray]];
            NSArray *severeArray = [[warningsArray objectAtIndex:0] valueForKey:SEVERE_WARNING];
            NSArray *mildArray = [[warningsArray objectAtIndex:1] valueForKey:MILD_WARNING];
            if (!medication.addMedicationCompletionStatus) {
                //currently hard coding severe warning
                if (severeArray.count > 0) {
                    [self displayWarningViewForType:SEVERE_WARNING forOrderSetCompletionStatus:medication.addMedicationCompletionStatus];
                } else if(mildArray.count > 0) {
                    [self displayWarningViewForType:MILD_WARNING forOrderSetCompletionStatus:medication.addMedicationCompletionStatus];
                }
            }
            [addMedicationViewController updateWarningsArray:warningsArray];
        }
    }];
}

- (void)addMedicationDetailsToOperationsArray {
    
    //add medication details as operation
    DCAddMedicationOperation *medicationOperation = [[DCAddMedicationOperation alloc] init];
    NSString *patientId = addMedicationViewController.patient.patientId;
    medicationOperation.operationId = preparationId;
    NSDictionary *medicationDictionary = [self getMedicationDetailsDictionary];
    [medicationOperation addMedicationDetailsWithMedicationType:typeLabel.text forPatientId:patientId withParameters:medicationDictionary];
    NSMutableArray *tempAddMedicationOperations = [NSMutableArray arrayWithArray:addMedicationViewController.operationsArray];
    for (DCAddMedicationOperation *operation in addMedicationViewController.operationsArray) {
        if ([operation.operationId isEqualToString:preparationId]) {
            [tempAddMedicationOperations removeObject:operation];
        }
    }
    [tempAddMedicationOperations addObject:medicationOperation];
    addMedicationViewController.operationsArray = [NSMutableArray arrayWithArray:tempAddMedicationOperations];
    [addMedicationViewController updateOrderSetOperationsArray];
}

#pragma mark - TextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if (textView == medicineNameTextView) {
        [autoSearchView setHidden:NO];
        NSString *substring = [NSString stringWithString:textView.text];
        [autoSearchView searchAutocompleteEntriesWithSubstring:substring];
        [medicineNameTextView layer].borderColor = [UIColor colorWithRed:177.0f/255.0f green:177.0f/255.0f blue:177.0f/255.0f alpha:0.6].CGColor;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    @try {
        if (textView == medicineNameTextView) {
            [autoSearchView setHidden:NO];
            [autoSearchView.activityIndicator stopAnimating];
            NSString *substring = [NSString stringWithString:textView.text];
            substring = [substring stringByReplacingCharactersInRange:range withString:text];
            [self expandMedicineNameTextField];
            if (substring.length < SEARCH_ENTRY_MIN_LENGTH) {
                //minimum search character
                autoSearchView.searchListArray =  [NSMutableArray arrayWithArray:@[]];
                [autoSearchView searchAutocompleteEntriesWithSubstring:EMPTY_STRING];
                [autoSearchView setFrame :CGRectMake(autoSearchView.frame.origin.x, autoSearchView.frame.origin.y, autoSearchView.frame.size.width, AUTOSEARCH_MIN_CELL_HEIGHT + 10) ];
                [self cancelPreviousSearchRequest];
            } else {
                if (substring.length == SEARCH_ENTRY_MIN_LENGTH) {
                    [autoSearchView.activityIndicator startAnimating];
                    autoSearchView.searchListArray = [NSMutableArray arrayWithArray:@[]];
                    autoSearchView.minimumLimit = YES;
                    [autoSearchView searchAutocompleteEntriesWithSubstring:EMPTY_STRING];
                    autoSearchView.minimumLimit = NO;
                    [autoSearchView setFrame :CGRectMake(autoSearchView.frame.origin.x, autoSearchView.frame.origin.y, autoSearchView.frame.size.width,autoSearchView.searchTableViewCellHeight + 10)];
                }
                [self fetchMedicationListForString:substring];
            }
        }
    }
    @catch (NSException *exception) {
        DCDebugLog(@"Error in searching medicine name: %@", exception.description);
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (textView == medicineNameTextView) {
        if ([textView.text isEqualToString:EMPTY_STRING]) {
            medicineNameClearButton.hidden = YES;
        } else {
            medicineNameClearButton.hidden = NO;
        }
    }
}

#pragma mark - Touches Method

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    [self hideAutoSearchTableViewOnTouch:touch];
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - DCScrollViewDelegate Methods

- (void)touchedScrollView:(UITouch *)touch {
    
    //hide auto search view
    if (touch.view != autoSearchView) {
        [autoSearchView setHidden:YES];
        if ([medicineNameTextView isFirstResponder]) {
            [medicineNameTextView resignFirstResponder];
        }
        if (_isLoadingOrderSet) {
            [addMedicationViewController endMedicineButtonsWobbleAnimation];
        }
    }
}

#pragma mark - DCAdministratingTimeContainerDelegate Methods

- (void)updatedTimeArray:(NSArray *)contentArray {
    
    timeArray = [NSMutableArray arrayWithArray:contentArray];
    BOOL valid = [self isTimeViewValidForRegularMedication];
    NSLog(@"Time View valid: %d", valid);
    [self updateAdministartingTimeContainerHeightConstraint];
}

- (void)addNewTimeButtonAction:(id)sender {
    
    //add new time
    //select administrating time
    selectedDatePicker = eRegularAdministratingTime;
    if (![popOverController isPopoverVisible]) {
        [self displayDatePickerPopOverFromView:sender withType:eTimePicker];
    }
}

- (void)updateAdministartingTimeContainerHeightConstraint {
    
    NSInteger totalRowCount = [timeArray count]/6;
    [administratingTimeContainerView layoutIfNeeded];

    timeContainerViewHeightConstraint.constant = (35 * (totalRowCount + 1)) + (totalRowCount * 10) + ADMINISTRATING_VIEW_TITLE_HEIGHT;
    [administratingTimeContainerView layoutIfNeeded];
    regularMedicationViewHeightConstraint.constant = timeContainerViewHeightConstraint.constant + REGULAR_MEDICATION_CONTENT_HEIGHT;
    medicationTypeContainerViewHeightConstraint.constant = MEDICATION_TYPE_TITLE_VIEW_HEIGHT + regularMedicationViewHeightConstraint.constant + 30;
    [self.view layoutSubviews];
}

#pragma mark - AutoSearchView delegate Methods

- (void)selectedMedication:(DCMedication *)medication {
    
    dispatch_async(dispatch_get_main_queue(), ^{
         [autoSearchView setHidden:YES];
    });
    preparationId = medication.medicationId;
    [self callWarningsWebServiceForMedication:medication];
    medicineNameTextView.text = medication.name;
    [dosageArray removeAllObjects];
    [self resignKeyboard];
    if ([medication.dosage isEqualToString:@"NULL"] || medication.dosage == nil) {
        dosageLabel.text = EMPTY_STRING;
    } else {
        dosageLabel.text = medication.dosage;
        [dosageArray addObject:medication.dosage];
        [dosageButton layer].borderColor = [UIColor clearColor].CGColor;
    }
    [self expandMedicineNameTextField];
    if (_isLoadingOrderSet) {
        //update medicine name in button text at the top
        [addMedicationViewController updateOrderSetMedicineViewAtIndex:_orderSetSelectedIndex withMedicineName:medication.name];
    }
}

#pragma mark - Notification Methods

- (void)keyboardDidShow:(NSNotification *)notification {
    
    self.keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self configureAutoSearchViewHeight];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    self.keyboardSize = CGSizeZero;
    if ([medicineNameTextView.text isEqualToString:EMPTY_STRING]) {
        [autoSearchView setHidden:YES];
    }
    if (![medicineNameTextView isFirstResponder] && ![dosageInstructionTextView isFirstResponder]) {
        [popOverController dismissPopoverAnimated:YES];
    }
    [self resetAutoSearchViewHeight];
    [self configureAutoSearchViewHeight];
}

- (void)resetAutoSearchViewHeight {

    dispatch_async(dispatch_get_main_queue(), ^{
        if (autoSearchView.frame.size.height < 50.0f) {
            CGRect bounds = CGRectMake(autoSearchView.frame.origin.x, autoSearchView.frame.origin.y + 15, autoSearchView.frame.size.width, 60.0f);
            [autoSearchView setFrame:bounds];
        }
        autoSearchView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    });
}

#pragma mark - Action Methods

- (IBAction)doneButtonPressed:(id)sender {
    
    [self doneButtonAction];
}

- (IBAction)dosageButtonPressed:(id)sender {
    
    //select dosage for medication
    [self clearValidations];
    CGSize size = CGSizeMake(230.0, DOSAGE_CELL_HEIGHT * (dosageArray.count+1));
    [self displayPopOverContentViewControllerForContentType:eDosage fromSender:sender contentSize:size];
}

- (IBAction)routeButtonPressed:(id)sender {
    
    //select route
    [self displayPopOverContentViewControllerForContentType:eRoute fromSender:sender contentSize:CGSizeMake(250.0f, 220.0f)];
}

- (IBAction)startDateButtonPressed:(id)sender {
    
    //select start date
    selectedDatePicker = eRegularStartDate;
    [self displayDatePickerPopOverFromView:sender withType:eStartDatePicker];
}

- (IBAction)endDateButtonPressed:(id)sender {
    
    //select end date
    selectedDatePicker = eRegularEndDate;
    [self displayDatePickerPopOverFromView:sender withType:eEndDatePicker];
}

- (IBAction)typeButtonPressed:(id)sender {
    
    //medication type
    [self displayPopOverContentViewControllerForContentType:eMedicationType fromSender:sender contentSize:CGSizeMake(250.0f, 130.0f)];
}

- (IBAction)administratingTimeAddButtonPressed:(id)sender {
    
    //select administrating time
    selectedDatePicker = eRegularAdministratingTime;
    if (![popOverController isPopoverVisible]) {
        [self displayDatePickerPopOverFromView:sender withType:eTimePicker];
    }
}

- (IBAction)onceMedicationDateButtonPressed:(id)sender {
    
    selectedDatePicker = eOnceDate;
    [self displayDatePickerPopOverFromView:sender withType:eStartDatePicker];
}

- (IBAction)onceMedicationAdministratingTimeButtonPressed:(id)sender {
    
    selectedDatePicker = eOnceAdministratingTime;
    [self displayDatePickerPopOverFromView:sender withType:eTimePicker];
}

- (IBAction)medicineNameClearButtonPressed:(id)sender {
    
    //medicine name clear button action
    [medicineNameClearButton setHidden:YES];
    [self clearAllFields];
    [autoSearchView searchAutocompleteEntriesWithSubstring:EMPTY_STRING];
    [self expandMedicineNameTextField];
}

- (IBAction)noDateButtonPressed:(id)sender {
    
    //no date selection action
    if (noDateButton.selected) {
        [self configureEndDateButtonForSelectionState:NO];
    } else {
        [self configureEndDateButtonForSelectionState:YES];
    }
}

- (IBAction)orderSetCancelButtonPressed:(id)sender {
    
    //order set cancel action
    addMedicationViewController.activeOrderSetArray = _medicationsInOrderSet;
    if (_orderSetSelectedIndex == 0) {
        [self updateActiveMedicationListAndDismissView];
    } else {
        [self populateOrderSetMedicationDetailsAtIndex:_orderSetSelectedIndex - 1];
        [addMedicationViewController loadAddMedicationDetailsViewAtIndex:_orderSetSelectedIndex];
    }
}

- (IBAction)orderSetSaveAndProceedButtonPressed:(id)sender {
    
    //save and proceed
    if ([self entriesAreValid]) {
        [self clearValidations];
        [self saveMedicationDetailsInOrderSetAtIndex:_orderSetSelectedIndex];
        addNewSubstitute = NO;
        if (_orderSetSelectedIndex == [_medicationsInOrderSet count] - 1) {
            [self updateActiveMedicationListAndDismissView];
        } else {
            [addMedicationViewController loadAddMedicationDetailsViewAtIndex:_orderSetSelectedIndex + 1];
        }
    } else {
        validationViewTopConstraint.constant = 15.0f;
        validationViewHeightConstraint.constant =  VALIDATION_VIEW_HEIGHT;
        [self setMedicationDetailsViewHeightConstraint];
    }
}

- (NSDictionary *) getMedicationDetailsDictionary {
    
    NSString *startDateString = [DCDateUtility convertDate:startDateValue FromFormat:DATE_FORMAT_RANGE ToFormat:EMIS_DATE_FORMAT];
    NSString *endDateString = [DCDateUtility convertDate:endDateValue FromFormat:DATE_FORMAT_RANGE ToFormat:EMIS_DATE_FORMAT];
    NSMutableDictionary *medicationDictionary = [[NSMutableDictionary alloc] init];
    
    [medicationDictionary setValue:preparationId forKey:PREPARATION_ID];
    [medicationDictionary setValue:dosageLabel.text forKey:DOSAGE_VALUE];
    [medicationDictionary setValue:dosageInstructionTextView.text forKey:INSTRUCTIONS];
    [medicationDictionary setValue:@"916601000006112" forKey:ROUTE_CODE_ID];
    NSString *selectedMedicationType = typeLabel.text;
    NSMutableArray *scheduleArray = [[NSMutableArray alloc] init];
    for (NSDictionary *timeSchedule in timeArray) {
        if ([[timeSchedule valueForKey:@"selected"]  isEqual: @1]) {
            [scheduleArray addObject:[NSString stringWithFormat:@"%@:00.000",[timeSchedule valueForKey:@"time"]]];
        }
    }
    if ([selectedMedicationType isEqualToString:REGULAR_MEDICATION]) {
        
        [medicationDictionary setValue:startDateString forKey:START_DATE_TIME];
        [medicationDictionary setValue:scheduleArray forKey:SCHEDULE_TIMES];
        if (!noDateButton.selected) {
            [medicationDictionary setValue:endDateString forKey:END_DATE_TIME];
        }
        
    } else if ([selectedMedicationType isEqualToString:ONCE_MEDICATION]) {
        
        [medicationDictionary setValue:startDateString forKey:SCHEDULED_DATE_TIME];
        
    } else {
        
        [medicationDictionary setValue:startDateString forKey:START_DATE_TIME];
        if (!noDateButton.selected) {
            [medicationDictionary setValue:endDateString forKey:END_DATE_TIME];
        }
    }
    return medicationDictionary;
}

@end
