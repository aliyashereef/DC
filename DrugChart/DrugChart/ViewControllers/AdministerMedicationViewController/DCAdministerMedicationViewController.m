//
//  DCAdministerMedicationViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 16/03/15.
//
//

#import "DCAdministerMedicationViewController.h"
#import "DCPatientMedicationHomeViewController.h"
#import "NameSelectionTableViewController.h"
#import "DCErrorPopOverViewController.h"
#import "DCErrorPopOverBackgroundView.h"
#import "DDPopoverBackgroundView.h"
#import "DCUsersListWebService.h"
#import "DCSecurityPinViewController.h"
#import "NameSelectionTableViewController.h"
#import "DCDatePickerPopOverBackgroundView.h"
#import "DCDatePickerViewController.h"
#import "DCMedicationAdministration.h"
//#import "DCAdministerMedicationWebService.h"

#define KEYBOARD_DURATION 0.3

typedef enum: NSInteger {
    kAdministeredBy,
    kCheckedBy
} PopOverType;

typedef enum : NSInteger {
    kStatusTypeAdministered,
    kStatusTypeRefused,
    kStatusTypeOmitted
} StatusType;

@interface DCAdministerMedicationViewController () <UITextViewDelegate, UITextFieldDelegate> {
    
    //general view components
    IBOutlet UILabel *medicineNameLabel;
    IBOutlet UILabel *medicationTimeLabel;
    IBOutlet UILabel *medicationRouteLabel;
    IBOutlet UILabel *medicationCategoryLabel;
    IBOutlet UIButton *administeredButton;
    IBOutlet UIButton *refusedButton;
    IBOutlet UIButton *omittedButton;
    IBOutlet UILabel *medicationInstructionLabel;
    
    IBOutlet UIView *medicationMenuOptionsView;
    
    // omitted view
    IBOutlet UIView *omittedOptionsView;
    IBOutlet UITextView *omittedReasonTextView;
    IBOutlet UITextView *omittedNotesTextView;
    
    // administered view
    IBOutlet UIView *administerOptionsView;
    IBOutlet UIButton *administeredByButton;
    IBOutlet UITextField *dateAndTimeTextField;
    IBOutlet UIButton *checkedByButton;
    IBOutlet UITextField *expiryDate;
    IBOutlet UITextView *administerNotes;
    
    // refused view
    IBOutlet UIView *refusedOptionsView;
    IBOutlet UITextField *refusedDate;
    IBOutlet UITextView *refusedNotes;
    
    IBOutlet UITextField *administeredByTextField;
    IBOutlet UITextField *checkedByTextField;
    
    IBOutlet UITextField *dosageTextField;
    IBOutlet UILabel *notesMandatoryLabel;
    
    IBOutlet UIView *optionsViewEarlyAdministration;
    IBOutlet UILabel *earlyAdminTitleLabel;
    IBOutlet NSLayoutConstraint *earlyAdminOptionsViewHeightConstraint;
    
    IBOutlet UIImageView *administerNotesBackgroundImageView;
    IBOutlet UILabel *administeredLabel;
    IBOutlet UILabel *refusedLabel;
    IBOutlet UILabel *omittedLabel;
    
    DCPatientMedicationHomeViewController *patientMedicationHomeViewController;
    PopOverType selectedPopOverType;
    StatusType selectedStatusType;
    UITextField *selectedPickerTextField;
    NSDate *selectedDate;
    NSDate *endDate;
    UIDatePicker *datePicker;
    DCErrorPopOverViewController *errorViewController;
    UIPopoverController *popOverController;
    
    BOOL omittedReasonError;
    BOOL earlyAdministerNotesError;
    NSMutableArray *userNamesArray;
    UITextView *activeTextView;
    UITextField *activeTextField;
    NSString *defaultUserName;
    DCAdministerMedication *updatedMedication ;
}

@end

@implementation DCAdministerMedicationViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        userNamesArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    patientMedicationHomeViewController = (DCPatientMedicationHomeViewController *)self.parentViewController;
    _hasChanges = NO;
    [self configureViewComponents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation implementation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:ADMINISTERED_BY_POPOVER]) {
        // ADD THE ADMINISTERED_BY BY LIST OF DATA HERE. I.E, WHO ARE ADMINISTERING
        NameSelectionTableViewController *nameSelectionViewController = [segue destinationViewController];
        nameSelectionViewController.namesArray = userNamesArray;
    }
    else if ([segue.identifier isEqualToString:CHECKED_BY_POPOVER]) {
        // CHECKED BY PEOPLE LIST
        NameSelectionTableViewController *nameSelectionViewController = [segue destinationViewController];
        nameSelectionViewController.namesArray = userNamesArray;
    }
}

#pragma mark - Keyboard notification methods

- (void)keyboardDidShow:(NSNotification *)notification {
    
    //[self repositionPopOverControllerInView:errorViewController.presentedTextfield];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    BOOL isStatusTypeOmitted = false;
    if (selectedStatusType == kStatusTypeOmitted) {
        isStatusTypeOmitted = true;
    }
    NSDictionary *keyboardDetails = @{@"keyBoardShown" : @YES , @"keyboardSize" : [NSValue valueWithCGSize:keyboardSize] , @"isStatusTypeOmitted" :[NSNumber numberWithBool: isStatusTypeOmitted] };
    
    [patientMedicationHomeViewController keyBoardActionInAdministerMedicationView:keyboardDetails];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    if (errorViewController) {
        //[self repositionPopOverControllerInView:errorViewController.presentedTextfield];
    }
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    BOOL isStatusTypeOmitted = false;
    if (selectedStatusType == kStatusTypeOmitted) {
        isStatusTypeOmitted = true;
    }
    NSDictionary *keyboardDetails = @{@"keyBoardShown" : @NO , @"keyboardSize" : [NSValue valueWithCGSize:keyboardSize] , @"isStatusTypeOmitted" :[NSNumber numberWithBool: isStatusTypeOmitted]};
    
    [patientMedicationHomeViewController keyBoardActionInAdministerMedicationView:keyboardDetails];
}

#pragma mark - TExtField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    patientMedicationHomeViewController.hasAdministerChanges = YES;
    _hasChanges = YES;
    activeTextField = textField;
    [DCUtility resetTextFieldAfterErrorCorrection:textField withColor:[UIColor clearColor]];
    [self dismissPopOverController];

}

#pragma mark - TextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    activeTextView = textView;
    _hasChanges = YES;
    patientMedicationHomeViewController.hasAdministerChanges = YES;
    [DCUtility resetTextFieldAfterErrorCorrection:textView withColor:[UIColor clearColor]];
    [self dismissPopOverController];
//    if (textView == omittedReasonTextView && omittedReasonError) {
//        [self displayErrorPopOverView:textView withMessage:NSLocalizedString(@"INVALID_REASON", @"")];
//    } else if (earlyAdministerNotesError) {
//        [self displayErrorPopOverView:textView withMessage:NSLocalizedString(@"BLANK_NOTES", @"")];
//    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (textView == omittedReasonTextView) {
        
        if (![text isEqualToString:EMPTY_STRING]) {
            omittedReasonError = NO;
            [self dismissPopOverController];
        } else if ([text isEqualToString:EMPTY_STRING] && range.location == 0 && [DCUtility isDetectedErrorField:textView]) {
            omittedReasonError = YES;
            //[self displayErrorPopOverView:textView withMessage:NSLocalizedString(@"INVALID_REASON", @"")];
        }
    } else {
        if (earlyAdministerNotesError && ![text isEqualToString:EMPTY_STRING]) {
            earlyAdministerNotesError = NO;
            [self dismissPopOverController];
        } else if ([text isEqualToString:EMPTY_STRING] && range.location == 0 && [DCUtility isDetectedErrorField:textView]){
            earlyAdministerNotesError = YES;
            //[self displayErrorPopOverView:textView withMessage:NSLocalizedString(@"BLANK_NOTES", @"")];
        }
    }
    
    return YES;
}

#pragma mark - Private methods

- (void)configureViewComponents {
    
    [self setMarginContraintsForTextViews];
    administeredByButton.layer.borderColor = BORDER_COLOR.CGColor;
    expiryDate.layer.borderColor = BORDER_COLOR.CGColor;
    dosageTextField.layer.borderColor = BORDER_COLOR.CGColor;
    checkedByButton.layer.borderColor = BORDER_COLOR.CGColor;
    dateAndTimeTextField.layer.borderColor = BORDER_COLOR.CGColor;
    refusedDate.layer.borderColor = BORDER_COLOR.CGColor;
    
    endDate = [DCDateUtility getTodaysEndTime];
    [self getAdministersAndPrescribersList];
    [datePicker setMaximumDate:endDate];
    
    @try {
       [self administerDrugTapped:nil];
    }
    @catch (NSException *exception) {
        DCDebugLog(@"the error on calling administer button tap method: %@", exception.description);
    }
}

- (void)getAdministersAndPrescribersList {
    //get administers and prescribers list
    DCUsersListWebService *usersListWebService = [[DCUsersListWebService alloc] init];
    [usersListWebService getUsersListWithCallback:^(NSArray *usersList, NSError *error) {
        if (!error) {
            for (NSDictionary *userDictionary in usersList) {
                [userNamesArray addObject:[userDictionary objectForKey:@"displayName"]];
            }
        }
    }];
}

- (void)selectedAdministeredByNotification:(NSNotification *)notification {
    NSDictionary *notificationInfo = notification.userInfo;
    NSString *selectedName = [notificationInfo valueForKey:@"name"];
    _hasChanges = YES;
    if (selectedPopOverType == kAdministeredBy) {
        administeredByTextField.text = selectedName;
     } else {
         if (![selectedName isEqualToString:defaultUserName]) {
             //display pin view
             [self performSelector:@selector(displaySecurityPinEntryViewForSelectedUser:) withObject:selectedName afterDelay:0.3];
         }
    }
}

- (void)setMarginContraintsForTextViews {
    [omittedReasonTextView setTextContainerInset:TEXTVIEW_EDGE_INSETS];
    [administerNotes setTextContainerInset:TEXTVIEW_EDGE_INSETS];
    [refusedNotes setTextContainerInset:TEXTVIEW_EDGE_INSETS];
}

- (void)setAdministerMedication:(DCAdministerMedication *)administerMedication {
    
    //populate administer medication values in view
    _administerMedication = administerMedication;
    medicineNameLabel.text = administerMedication.medicineName;
    medicationRouteLabel.text =  administerMedication.route;
    medicationCategoryLabel.text = administerMedication.medicationCategory;
    NSString *instructionDisplayString = administerMedication.instruction.length?[NSString stringWithFormat:@" (%@)", administerMedication.instruction]:@"";
    medicationInstructionLabel.text = instructionDisplayString;
    if ([administerMedication.medicationCategory isEqualToString:WHEN_REQUIRED]) {
        medicationCategoryLabel.text = WHEN_REQ_DISPLAY_STRING;
    } else {
        medicationCategoryLabel.text = administerMedication.medicationCategory;
    }
    NSDate *currentDate = [DCDateUtility getDateInCurrentTimeZone:[NSDate date]];
    medicationTimeLabel.text = [DCDateUtility convertDate:administerMedication.medicationTime FromFormat:DEFAULT_DATE_FORMAT ToFormat:TWENTYFOUR_HOUR_FORMAT];
    administeredByTextField.text = administerMedication.administeredBy;
    checkedByTextField.text = administerMedication.checkedBy;
    expiryDate.text = administerMedication.batchNumber;
    if (administerMedication.editable) {
        
        [self displayMedicationStatusViewForStatus:YET_TO_GIVE];
        NSString *dateDisplayString = [DCDateUtility convertDate:currentDate FromFormat:DEFAULT_DATE_FORMAT ToFormat:DATE_FORMAT_WITH_DAY];
        dateAndTimeTextField.text = dateDisplayString;
        refusedDate.text = dateDisplayString;
        selectedDate = currentDate;
        administerNotes.text = administerMedication.notes;
        refusedNotes.text = administerMedication.refusedNotes;
        [notesMandatoryLabel setHidden:!administerMedication.earlyAdministration];
        UILabel *refusedNotesLabel = (UILabel *)[self.view viewWithTag:101];
        [refusedNotesLabel setHidden:!administerMedication.earlyAdministration];
        UILabel *omittedNotesLabel = (UILabel *)[self.view viewWithTag:102];
        [omittedNotesLabel setHidden:!administerMedication.earlyAdministration];
        omittedReasonTextView.text = administerMedication.omittedReason;

    } else {
        
        NSString *dateDisplayString = [DCDateUtility convertDate:administerMedication.medicationTime FromFormat:DEFAULT_DATE_FORMAT ToFormat:DATE_FORMAT_WITH_DAY];
        dateAndTimeTextField.text = dateDisplayString;
        selectedDate = administerMedication.medicationTime;
        administerNotes.text = administerMedication.notes;
        // omitted view
        omittedReasonTextView.text = administerMedication.omittedReason;
        //refused view
        refusedDate.text = dateDisplayString;
        refusedNotes.text = administerMedication.refusedNotes;
        [notesMandatoryLabel setHidden:YES];
        [self displayMedicationStatusViewForStatus:administerMedication.medicationStatus];
    }
    dosageTextField.text = administerMedication.dosage;
    [self editViewElements:administerMedication.editable];
    [[omittedReasonTextView layer] setBorderColor:[UIColor clearColor].CGColor];
    [[administerNotes layer] setBorderColor:[UIColor clearColor].CGColor];
    [[refusedNotes layer] setBorderColor:[UIColor clearColor].CGColor];
    if (administerMedication.earlyAdministration) {
        
        if (administerMedication.isNewRequiredMedication) {
            earlyAdminTitleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:13.0f];
            earlyAdminTitleLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"ADMIN_FREQUENCY", @""), NSLocalizedString(@"EARLY_ADMIN_INLINE", @"")];
        } else {
            earlyAdminTitleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:15.0f];
            earlyAdminTitleLabel.text = NSLocalizedString(@"EARLY_ADMIN_INLINE", @"");
        }
        earlyAdminOptionsViewHeightConstraint.constant = 82.0f;
    } else {
        
        earlyAdminOptionsViewHeightConstraint.constant = 44.0f;
    }
    [self.view layoutIfNeeded];
 }

- (void)displayMedicationStatusViewForStatus:(NSString *)status {
    
    if ([status isEqualToString:REFUSED]) {
        [self refusedDrugTapped:nil];
    } else if ([status isEqualToString:OMITTED]) {
        [self omittedDrugTapped:nil];
    } else {
        [self administerDrugTapped:nil];
    }
}

- (void)editViewElements:(BOOL)editable {
    
    if (editable) {
        [self enableViewElements];
    } else {
        
        [self disableViewElements];
    }
}

- (void)enableViewElements {
    
    //enable view elements
    [omittedOptionsView setUserInteractionEnabled:YES];
    [refusedOptionsView setUserInteractionEnabled:YES];
    [administerOptionsView setUserInteractionEnabled:YES];
    [optionsViewEarlyAdministration setUserInteractionEnabled:YES];
    [administeredButton setAlpha:ALPHA_FULL];
    [omittedButton setAlpha:ALPHA_FULL];
    [refusedButton setAlpha:ALPHA_FULL];
    [dateAndTimeTextField setAlpha:ALPHA_FULL];
    [expiryDate setAlpha:ALPHA_FULL];
    [dosageTextField setAlpha:ALPHA_FULL];
    [administerNotes setAlpha:ALPHA_FULL];
    [administerNotesBackgroundImageView setAlpha:1.0];
    administerNotes.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    [refusedDate setAlpha:ALPHA_FULL];
    [refusedNotes setAlpha:ALPHA_FULL];
    [omittedReasonTextView setAlpha:ALPHA_FULL];
    [checkedByTextField setAlpha:ALPHA_FULL];
    [administeredByTextField setAlpha:ALPHA_FULL];
    [administeredByButton setAlpha:ALPHA_FULL];
    [dateAndTimeTextField setAlpha:ALPHA_FULL];
    [checkedByButton setAlpha:ALPHA_FULL];
    [administeredLabel setAlpha:ALPHA_FULL];
    [refusedLabel setAlpha:ALPHA_FULL];
    [omittedLabel setAlpha:ALPHA_FULL];
}

- (void)disableViewElements {
    
    //disable view elements
    [omittedOptionsView setUserInteractionEnabled:NO];
    [refusedOptionsView setUserInteractionEnabled:NO];
    [administerOptionsView setUserInteractionEnabled:NO];
    [optionsViewEarlyAdministration setUserInteractionEnabled:NO];
    [administeredButton setAlpha:ALPHA_PARTIAL];
    [omittedButton setAlpha:ALPHA_PARTIAL];
    [refusedButton setAlpha:ALPHA_PARTIAL];
    [dateAndTimeTextField setAlpha:ALPHA_PARTIAL];
    [expiryDate setAlpha:ALPHA_PARTIAL];
    [dosageTextField setAlpha:ALPHA_PARTIAL];
    [administerNotes setAlpha:ALPHA_PARTIAL];
    [administerNotesBackgroundImageView setAlpha:0.6];
    administerNotes.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    [refusedDate setAlpha:ALPHA_PARTIAL];
    [refusedNotes setAlpha:ALPHA_PARTIAL];
    [omittedReasonTextView setAlpha:ALPHA_PARTIAL];
    [checkedByTextField setAlpha:ALPHA_PARTIAL];
    [administeredByTextField setAlpha:ALPHA_PARTIAL];
    [administeredByButton setAlpha:ALPHA_PARTIAL];
    [dateAndTimeTextField setAlpha:ALPHA_PARTIAL];
    [checkedByButton setAlpha:ALPHA_PARTIAL];
    [administeredLabel setAlpha:ALPHA_PARTIAL];
    [refusedLabel setAlpha:ALPHA_PARTIAL];
    [omittedLabel setAlpha:ALPHA_PARTIAL];
}

- (void) resignFirstResponderForTextFieldAndTextView {

    [activeTextField resignFirstResponder];
    [activeTextView resignFirstResponder];
}

- (void)displayDatePickerInView:(id)sender {
    
    [self resignFirstResponderForTextFieldAndTextView];
    //display date picker in popover
    UIButton *selectedButton = (UIButton *)sender;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD
                                                         bundle: nil];
    DCDatePickerViewController *dateViewController = [storyboard instantiateViewControllerWithIdentifier:DATE_PICKER_VIEW_SB_ID];
    dateViewController.minimumDate = [NSDate date];
    dateViewController.dateHandler = ^ (NSDate *date) {
        [self updateSelectedFieldWithDate:date];
    };
    UIPopoverArrowDirection arrowDirection = [self getArrowDirectionForSelectedView:selectedButton];
    dateViewController.datePickerType = eDatePicker;
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:dateViewController];
    popoverController.popoverBackgroundViewClass = [DCDatePickerPopOverBackgroundView class];
    [popoverController setPopoverContentSize:CGSizeMake(300, 162) animated:NO];
    [popoverController presentPopoverFromRect:[sender bounds] inView:sender permittedArrowDirections:arrowDirection animated:YES];
    if (_administerMedication.editable) {
        [datePicker setDate:[NSDate date]];
    }
}

- (void)dismissPopOverController {
    
    //dismiss presented pop over from view
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (popOverController) {
            [popOverController dismissPopoverAnimated:YES];
        }
    });
}

- (BOOL)validateFieldsForOmittedStatus {
    
    //validate omitted fields
    BOOL omittedValid = YES;
    if ([omittedReasonTextView.text isEqualToString:EMPTY_STRING]) {
        omittedReasonError = YES;
        [DCUtility modifyViewComponentForErrorDisplay:omittedReasonTextView];
        [self displayErrorPopOverView:omittedReasonTextView withMessage:NSLocalizedString(@"INVALID_REASON", @"")];

        omittedValid = NO;
    } else {
        
        [DCUtility resetTextFieldAfterErrorCorrection:omittedReasonTextView withColor:[UIColor clearColor]];
    }
    if (_administerMedication.earlyAdministration && [omittedNotesTextView.text isEqualToString:EMPTY_STRING]) {
        //omittedNotesError = YES;
        omittedValid = NO;
        [DCUtility modifyViewComponentForErrorDisplay:omittedNotesTextView];
        [self displayErrorPopOverView:omittedNotesTextView withMessage:NSLocalizedString(@"BLANK_NOTES", @"")];
        earlyAdministerNotesError = YES;
    } else {
        
        [DCUtility resetTextFieldAfterErrorCorrection:omittedNotesTextView withColor:[UIColor clearColor]];
    }
    return omittedValid;
}

- (BOOL)entriesAreValid {
    
    switch (selectedStatusType) {
            
        case kStatusTypeOmitted: {
            BOOL omittedValid = [self validateFieldsForOmittedStatus];
            return omittedValid;
        }
            
        case kStatusTypeAdministered: {
            if (_administerMedication.earlyAdministration && [administerNotes.text isEqualToString:EMPTY_STRING]) {
                earlyAdministerNotesError = YES;
                [DCUtility modifyViewComponentForErrorDisplay:administerNotes];
                [self displayErrorPopOverView:administerNotes withMessage:NSLocalizedString(@"BLANK_NOTES", @"")];
                return NO;
            }
        }
            break;
    
        case kStatusTypeRefused: {
            //refused
            if (_administerMedication.earlyAdministration && [refusedNotes.text isEqualToString:EMPTY_STRING]) {
                [DCUtility modifyViewComponentForErrorDisplay:refusedNotes];
                [self displayErrorPopOverView:refusedNotes withMessage:NSLocalizedString(@"BLANK_NOTES", @"")];
                earlyAdministerNotesError = YES;
                return NO;
            }
        }
            break;
        
        default:
            break;
    }
    omittedReasonError = NO;
    earlyAdministerNotesError = NO;
    return YES;
}

- (void)repositionPopOverControllerInView:(UIView *)textView {
    
    //reposition error pop over on keyboard show/hide
    if (errorViewController) {
        
        if ((errorViewController.presentedTextfield == omittedReasonTextView && omittedReasonError) || earlyAdministerNotesError) {
            [popOverController dismissPopoverAnimated:YES];
            [errorViewController removeFromParentViewController];
            popOverController = [DCUtility getDisplayPopOverControllerOnView:textView];
            errorViewController = (DCErrorPopOverViewController *)popOverController.contentViewController;
            __weak __typeof(DCErrorPopOverViewController *)weakErrorPopUp = errorViewController;
            __weak __typeof(UITextView *)weakomittedReasonTextView = omittedReasonTextView;
            __weak __typeof(self)weakSelf = self;
            errorViewController.viewLoaded = ^ {
                weakErrorPopUp.presentedTextfield = textView;
                NSString *errorMessage;
                if (textView == weakomittedReasonTextView) {
                    errorMessage = NSLocalizedString(@"INVALID_REASON", @"");
                } else {
                    errorMessage =  NSLocalizedString(@"BLANK_NOTES", @"");
                }
                [weakSelf displayErrorMessage:errorMessage];
            };
        }
    }
}

- (void)displayErrorPopOverView:(UITextView *)textView withMessage:(NSString *)message {
    
    popOverController = [DCUtility getDisplayPopOverControllerOnView:textView];
    errorViewController = (DCErrorPopOverViewController *)popOverController.contentViewController;
    __weak __typeof(DCErrorPopOverViewController *)weakErrorPopUp = errorViewController;
    errorViewController.viewLoaded = ^ {
        weakErrorPopUp.presentedTextfield = textView;
        weakErrorPopUp.errorMessage = message;
    };
}

- (void)displayErrorMessage:(NSString *)error {
    
    //set error message to viewcontroller
    errorViewController.errorMessage = error;
}

- (void)displaySecurityPinEntryViewForSelectedUser:(NSString *)userName {
    
    //security pin view
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD
                                                                   bundle: nil];
    DCSecurityPinViewController *pinViewController = [administerStoryboard instantiateViewControllerWithIdentifier:SECURITY_PIN_VIEW_CONTROLLER];
    pinViewController.securityPinEntered = ^ (NSString *pin) {
        
        checkedByTextField.text =  userName;
    };
    
    [pinViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:pinViewController animated:YES completion:nil];
}

- (void)presentUsersListPopOverInView:(UITextField *)textField {
    
    //present checked by list view
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD
                                                                      bundle: nil];
    NameSelectionTableViewController *listViewController = [administerStoryboard instantiateViewControllerWithIdentifier:NAMES_LIST_VIEW_STORYBOARD_ID];

    NSMutableArray *userArray = [[NSMutableArray alloc] initWithArray:userNamesArray];
    if (selectedPopOverType == kAdministeredBy) {
        
        [userArray insertObject:SELF_ADMINISTERED_TITLE atIndex:0];
    }
    listViewController.namesArray = userArray;
    listViewController.userSelectionHandler = ^ (DCUser *selectedUser) {
        
        patientMedicationHomeViewController.hasAdministerChanges = YES;
        if (selectedPopOverType == kAdministeredBy) {
            
            administeredByTextField.text = selectedUser.displayName;
        } else {
            if (![selectedUser.displayName isEqualToString:defaultUserName]) {
                
                //display pin view
                [self performSelector:@selector(displaySecurityPinEntryViewForSelectedUser:) withObject:selectedUser.displayName afterDelay:0.3];
            } else {
                
                checkedByTextField.text = selectedUser.displayName;
            }
        }
    };
    UIPopoverArrowDirection arrowDirection = [self getArrowDirectionForSelectedView:textField];
    UIPopoverController *checkedBypopOverController = [[UIPopoverController alloc] initWithContentViewController:listViewController];
    checkedBypopOverController.popoverBackgroundViewClass = [DCDatePickerPopOverBackgroundView class];
    checkedBypopOverController.popoverContentSize = CGSizeMake(440.0, 275.0f);
    [checkedBypopOverController presentPopoverFromRect:[textField bounds]
                                              inView:textField
                            permittedArrowDirections:arrowDirection
                                            animated:YES];
}

- (void)updateSelectedFieldWithDate:(NSDate *)date {
    
    _hasChanges = YES;
    selectedDate = [DCDateUtility getDateInCurrentTimeZone:date];
//    if ([selectedDate compare:endDate] == NSOrderedDescending) {
//        selectedDate = endDate;
//    }
    patientMedicationHomeViewController.hasAdministerChanges = YES;
    NSString *selectedDateString = [DCDateUtility convertDate:selectedDate FromFormat:DEFAULT_DATE_FORMAT ToFormat:DATE_FORMAT_WITH_DAY];
    selectedPickerTextField.text = selectedDateString;
}

- (UIPopoverArrowDirection )getArrowDirectionForSelectedView:(UIView *)selectedView {
    
    UIPopoverArrowDirection arrowDirection;
    CGPoint windowPoint = [selectedView convertPoint:selectedView.bounds.origin toView: [[UIApplication sharedApplication] keyWindow]];
    if (windowPoint.y > 550) {
        arrowDirection = UIPopoverArrowDirectionDown;
    } else {
        arrowDirection = UIPopoverArrowDirectionUp;
    }
    return arrowDirection;
}

- (NSDictionary *)getMedicationAdministrationDictionary {
    
    //get administer medication dictionary
    NSMutableDictionary *administerDictionary = [[NSMutableDictionary alloc] init];
    NSLog(@"_administerMedication.scheduledTime is %@", _administerMedication.scheduledTime);
    NSString *scheduledDateString = [DCDateUtility convertDate:_administerMedication.scheduledTime FromFormat:@"yyyy-MM-dd hh:mm:ss 'Z'" ToFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSLog(@"scheduledDateString is %@", scheduledDateString);
    [administerDictionary setObject:scheduledDateString forKey:SCHEDULED_ADMINISTRATION_TIME];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:EMIS_DATE_FORMAT];
    NSString *administeredDateString = [dateFormatter stringFromDate:[NSDate date]];
    [administerDictionary setObject:administeredDateString forKey:ACTUAL_ADMINISTRATION_TIME];
    [administerDictionary setObject:updatedMedication.medicationStatus forKey:ADMINISTRATION_STATUS];
    [administerDictionary setObject:@1 forKey:IS_SELF_ADMINISTERED];
    [administerDictionary setObject:dosageTextField.text forKey:ADMINISTRATING_DOSAGE];
    [administerDictionary setObject:expiryDate.text forKey:ADMINISTRATING_BATCH];
    //TODO: currently hardcoded as ther is no expiry field in UI
    [administerDictionary setObject:@"2015-09-23T00:00:00.000Z" forKey:EXPIRY_DATE];
    [administerDictionary setObject:_administerMedication.notes forKey:ADMINISTRATING_NOTES];
    return administerDictionary;
}

- (void)callAdministerMedicationWebService {
    
    
//    DCAdministerMedicationWebService *administerMedicationWebService = [[DCAdministerMedicationWebService alloc] init];
//    [administerMedicationWebService administerMedicationForScheduleId:_scheduleId
//                                                         forPatientId:_patientId withParameters:[self getMedicationAdministrationDictionary] withCallbackHandler:^(id response, NSError *error) {
//                                                             
//                                                             if (!error) {
//                                                                 NSLog(@"response : %@", response);
//                                                                 self.administerMedicationHandler(updatedMedication);
//                                                             } else {
//                                                                 NSLog(@"errorinfo : %@", error.userInfo);
//                                                             }
//                                                             
//                                                         }];
}


#pragma mark - Button click methods
// top bar button actions
- (IBAction)cancelButtonTapped:(UIButton *)sender {
    
    [self resignFirstResponderForTextFieldAndTextView];
    _hasChanges = NO;
    if ([self.parentViewController isKindOfClass:[DCPatientMedicationHomeViewController class]]) {
        [patientMedicationHomeViewController cancelMedicationAdministration];
    }
}

- (IBAction)doneButtonTapped:(UIButton *)sender {
   
    [self resignFirstResponderForTextFieldAndTextView];
    if ([self entriesAreValid]) {
        
        _hasChanges = NO;
        if ([self.parentViewController isKindOfClass:[DCPatientMedicationHomeViewController class]]) {
            [patientMedicationHomeViewController doneTappedForMedicationAdministration];
        }
        if (_administerMedication.editable) {
            
            updatedMedication = [[DCAdministerMedication alloc] init];
            updatedMedication.administeredBy = administeredByTextField.text;
            updatedMedication.scheduledTime = _administerMedication.scheduledTime;
            updatedMedication.checkedBy = checkedByTextField.text;
            updatedMedication.batchNumber = expiryDate.text;
            updatedMedication.isNewRequiredMedication = _administerMedication.isNewRequiredMedication;
            updatedMedication.dosage = dosageTextField.text;
            switch (selectedStatusType) {
                    
                case kStatusTypeRefused:
                    updatedMedication.medicationTime = selectedDate;
                    updatedMedication.medicationStatus = REFUSED;
                    updatedMedication.refusedNotes = refusedNotes.text;
                    break;
                    
                case kStatusTypeOmitted:
                    updatedMedication.medicationTime = [DCDateUtility getDateInCurrentTimeZone:[NSDate date]];
                    updatedMedication.medicationStatus = OMITTED;
                    updatedMedication.omittedReason = omittedReasonTextView.text;
                    break;
                    
                default:
                    if ([administeredByTextField.text isEqualToString:SELF_ADMINISTERED_TITLE]) {
                        updatedMedication.medicationStatus = SELF_ADMINISTERED;
                    } else {
                        updatedMedication.medicationStatus = IS_GIVEN;
                    }
                    updatedMedication.medicationTime = selectedDate;
                    updatedMedication.notes = administerNotes.text;
                    break;
            }
//            self.administerMedicationHandler(updatedMedication);
            [self callAdministerMedicationWebService];
        }
    }
 }

// check button actions
- (IBAction)administerDrugTapped:(UIButton *)sender {
    // loads the respective images for checked status.
    // and bring the desired view to the front.
    [self resignFirstResponderForTextFieldAndTextView];
    selectedStatusType = kStatusTypeAdministered;
    if (_administerMedication.earlyAdministration) {
        
        earlyAdminOptionsViewHeightConstraint.constant = 82.0f;
    }
    
    [administeredButton setSelected:YES];
    [refusedButton setSelected:NO];
    [omittedButton setSelected:NO];
    if ([[SHARED_APPDELEGATE userRole] isEqualToString:ROLE_DOCTOR]) {
        if ([self.administerMedication.administeredBy isEqualToString:EMPTY_STRING] || self.administerMedication.administeredBy == nil) {
            administeredByTextField.text = DEFAULT_DOCTOR_NAME;
            defaultUserName = DEFAULT_DOCTOR_NAME;
        }
        if ([self.administerMedication.checkedBy isEqualToString:EMPTY_STRING] || self.administerMedication.checkedBy == nil) {
            checkedByTextField.text = DEFAULT_DOCTOR_NAME;
            defaultUserName = DEFAULT_DOCTOR_NAME;
        }
    } else {
        if ([self.administerMedication.administeredBy isEqualToString:EMPTY_STRING] || self.administerMedication.administeredBy == nil){
            administeredByTextField.text = DEFAULT_NURSE_NAME;
            defaultUserName = DEFAULT_NURSE_NAME;
        }
        if ([self.administerMedication.checkedBy isEqualToString:EMPTY_STRING] || self.administerMedication.checkedBy == nil) {
            checkedByTextField.text = DEFAULT_NURSE_NAME;
            defaultUserName = DEFAULT_NURSE_NAME;
        }
    }
    [medicationMenuOptionsView bringSubviewToFront:administerOptionsView];
    [self.view layoutIfNeeded];
}

- (IBAction)refusedDrugTapped:(UIButton *)sender {
    
    [self resignFirstResponderForTextFieldAndTextView];
    // loads the respective images for checked status.
    selectedStatusType = kStatusTypeRefused;
    if (_administerMedication.earlyAdministration) {
        
        earlyAdminOptionsViewHeightConstraint.constant = 82.0f;
    }
    [self.view layoutIfNeeded];
    [administeredButton setSelected:NO];
    [refusedButton setSelected:YES];
    [omittedButton setSelected:NO];
    [medicationMenuOptionsView bringSubviewToFront:refusedOptionsView];
}

- (IBAction)omittedDrugTapped:(UIButton *)sender {
    
    [self resignFirstResponderForTextFieldAndTextView];
    // loads the respective images for checked status.
    selectedStatusType = kStatusTypeOmitted;
    if (_administerMedication.earlyAdministration) {
        
        earlyAdminOptionsViewHeightConstraint.constant = 44.0f;
    }
    [self.view layoutIfNeeded];
    [administeredButton setSelected:NO];
    [refusedButton setSelected:NO];
    [omittedButton setSelected:YES];
    [medicationMenuOptionsView bringSubviewToFront:omittedOptionsView];
}

- (IBAction)dateAndTimeSelectionButtonClicked:(id)sender {
    selectedPickerTextField = dateAndTimeTextField;
    [self displayDatePickerInView:sender];
}

- (IBAction)refusedDateFieldSelected:(id)sender {
    selectedPickerTextField = refusedDate;
    [self displayDatePickerInView:sender];
}

// Administered button clicks
- (IBAction)administeredByButtonTapped:(UIButton *)sender {
    
    [self resignFirstResponderForTextFieldAndTextView];
    selectedPopOverType = kAdministeredBy;
    [self presentUsersListPopOverInView:administeredByTextField];
}

- (IBAction)checkedByButtonTapped:(UIButton *)sender {
    
    [self resignFirstResponderForTextFieldAndTextView];
    selectedPopOverType = kCheckedBy;
    //display names list for checked by
    [self presentUsersListPopOverInView:checkedByTextField];
}


@end
