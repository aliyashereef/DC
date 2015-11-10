//
//  DCAddMedicationViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/16/15.
//
//

#import "DCAddMedicationViewController.h"
//#import "DCPatientAlertsNotificationTableViewController.h"
#import "DCPopOverContentSizeUtility.h"
#import "DCSettingsPopOverBackgroundView.h"
#import "DCAddMedicationRightViewController.h"
#import "DCAddMedicationDetailsViewController.h"
#import "DCMissedMedicationAlertViewController.h"
#import "DCOrderSetMedicineView.h"
#import "DCAddMedicationWebService.h"
#import "DCOrderSetOperationQueue.h"
#import "DCAddMedicationOperation.h"

#define kSingleMedicationButtontag      1
#define kOrderSetButtonTag              2
#define kAdminstratingViewTitlelabelTag 200

#define MEDICATION_TYPE_VIEW_HEIGHT     80.0f
#define TYPE_VIEW_ORDERSET_HEIGHT       60.0f
#define TOP_VIEW_HEIGHT                 71.0f
#define TYPE_VIEW_HEIGHT                80.0f
#define BAR_BUTTON_WIDTH                76.0f
#define BACK_BUTTON_WIDTH               45.0f
#define BACK_BUTTON_HIDDEN_WIDTH        10.0f
#define CANCEL_DEFAULT_LEADING          15.0f
#define CANCEL_HIDDEN_LEADING           -5.0f
#define ORDERSET_MEDICATION_VIEW_WIDTH  145.0f
#define ORDERSET_MEDICATION_HEIGHT      50.0f
#define ORDERSET_MEDICATION_XVALUE      15.0f


#define SELECTED    1
#define DESELECTED  0

typedef enum : NSInteger {
    
    eRegularStartDate,
    eRegularEndDate,
    eRegularAdministratingTime,
    eOnceDate,
} SelectedDatePicker;

@interface DCAddMedicationViewController () <DCOrderSetMedicineViewDelegate> {
    
    __weak IBOutlet UILabel *dateOfBirthLabel;
    __weak IBOutlet UILabel *nhsLabel;
    __weak IBOutlet UILabel *consultantLabel;
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UIView *rightContainerView;
    __weak IBOutlet UIView *alertsButtonContainerView;
    __weak IBOutlet UILabel *alertsCountLabel;
    __weak IBOutlet UIView *leftContainerView;
    __weak IBOutlet UIButton *backButton;
    __weak IBOutlet UIButton *doneButton;
    __weak IBOutlet UIScrollView *orderSetMedicinesScrollView;
    __weak IBOutlet NSLayoutConstraint *topViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *topViewTopConstraint;
    __weak IBOutlet NSLayoutConstraint *typeViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *cancelButtonWidthConstraint;
    __weak IBOutlet NSLayoutConstraint *backButtonWidthConstraint;
    __weak IBOutlet NSLayoutConstraint *doneButtonWidthConstraint;
    __weak IBOutlet NSLayoutConstraint *cancelButtonLeadingConstraint;
    
    DCAddMedicationDetailsViewController *addMedicationDetailsViewController;
    DCAddMedicationRightViewController  *rightViewController;
    UINavigationController *detailsNavigationController;
    NSMutableArray *medicationArray;
    NSMutableArray *alertsArray;
    NSMutableArray *removedMedicinesArray;
    BOOL isAnimating;
    BOOL donotUseDrug;
}

@end

@implementation DCAddMedicationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureViewElements];
    [self addChildViewControllers];
    [self configureAlertsButton];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Public Methods

- (void)dismissView {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)animateViewUpwardsOnEditingText:(BOOL)moveUp  {
    
    //animate view upwards
    if (moveUp) {
        [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            topViewHeightConstraint.constant = 1.0f;
            typeViewHeightConstraint.constant = ZERO_CONSTRAINT;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:KEYBOARD_ANIMATION_DURATION delay:0.0 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            topViewHeightConstraint.constant = TOP_VIEW_HEIGHT;
            typeViewHeightConstraint.constant = TYPE_VIEW_HEIGHT;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)loadActiveOrderSetMedicationDetailsView:(NSArray *)activeMedicationArray
                          loadMedicationAtIndex:(NSInteger)index {
    
    //display new ordered list view
    DCAddMedicationViewController *orderSetMedicationsViewController = [self.storyboard instantiateInitialViewController];
    orderSetMedicationsViewController.patient = _patient;
    orderSetMedicationsViewController.isLoadingOrderSet = YES;
    orderSetMedicationsViewController.activeOrderSetArray = [NSMutableArray arrayWithArray:activeMedicationArray];
    orderSetMedicationsViewController.orderSetViewController = _orderSetViewController;
    self.navigationController.navigationBarHidden = YES;
    [self presentViewController:orderSetMedicationsViewController animated:YES completion:nil];
    [orderSetMedicationsViewController loadAddMedicationDetailsViewAtIndex:(int)index];
    orderSetMedicationsViewController.operationsArray = _operationsArray;
}

- (void)deSelectOrderSetMedicineViews {
    
    //deselect medicine views
    for (DCOrderSetMedicineView *orderSetMedicineView in orderSetMedicinesScrollView.subviews) {
        if ([orderSetMedicineView isKindOfClass:[DCOrderSetMedicineView class]]) {
            [orderSetMedicineView updateMedicationViewOnSelection:NO];
        }
    }
}

- (void)selectedOrderSetMedicineAtIndex:(int)selectedIndex {
    
    //selected order set medicine at selected index
    [self deSelectOrderSetMedicineViews];
    DCOrderSetMedicineView *selectedMedicineView = (DCOrderSetMedicineView *)[orderSetMedicinesScrollView viewWithTag:selectedIndex + 1];
    [selectedMedicineView updateMedicationViewOnSelection:YES];
}

- (void)updateActiveOrderSetArray:(NSMutableArray *)orderSetArray
                   withCompletion:(void(^)(BOOL completed))callBackHandler {
    
    //update active order set array
    _activeOrderSetArray = orderSetArray;
    [_orderSetViewController updateActiveMedicationList:_activeOrderSetArray withCompletionHandler:^(BOOL completed) {
         callBackHandler(YES);
    }];
}

- (void)loadAddMedicationDetailsViewAtIndex:(int)index {
    
    BOOL newViewPush = YES;
    _selectedMedicineIndex = index;
    NSMutableArray *viewControllersArray = [NSMutableArray arrayWithArray:detailsNavigationController.viewControllers];
    if (index >= [detailsNavigationController.viewControllers count]) {
        if (index !=  [detailsNavigationController.viewControllers count]) {
            [self pushMedicationDetailsViewControllersUptoIndex:index];
        }
        addMedicationDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_DETAILS_SB_ID];
        newViewPush = YES;
    } else {
        addMedicationDetailsViewController = (DCAddMedicationDetailsViewController *)[detailsNavigationController.viewControllers objectAtIndex:index];
        if (index != viewControllersArray.count - 1) {
            [self popMedicationDetailsViewControllersUptoIndex:index];
        }
        newViewPush = NO;
    }
    addMedicationDetailsViewController.isLoadingOrderSet = _isLoadingOrderSet;
    if (self.activeOrderSetArray) {
        addMedicationDetailsViewController.medicationsInOrderSet = self.activeOrderSetArray;
    }
    addMedicationDetailsViewController.orderSetSelectedIndex = index;
    if (newViewPush) {
        [detailsNavigationController pushViewController:addMedicationDetailsViewController
                                               animated:YES];
    } else {
        [detailsNavigationController popToViewController:addMedicationDetailsViewController
                                                animated:YES];
    }
}

- (void)addMedicationServiceCallWithParamaters:(NSDictionary *)medicationDictionary
                             forMedicationType:(NSString *)medicationType {
    
    DCAddMedicationWebService *webService = [[DCAddMedicationWebService alloc] init];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [webService  addMedicationForMedicationType:medicationType
                                   forPatientId:self.patient.patientId
                                 withParameters:medicationDictionary
                            withCallbackHandler:^(id response, NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!error) {
            [addMedicationDetailsViewController dismissViewControllerAnimated:YES completion:nil];
        } else {
            if (error.code == NETWORK_NOT_REACHABLE) {
                [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"")
                                    message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
            } else if (error.code == WEBSERVICE_UNAVAILABLE) {
                
                [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"")
                                    message:NSLocalizedString(@"WEBSERVICE_UNAVAILABLE", @"")];
            }
            else {
                [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"")
                                    message:NSLocalizedString(@"ADD_MEDICATION_FAILED", @"")];
            }
        }
    }];
}

- (void)displayWarningsAccordionSection:(BOOL)show {
    
    //display accordion section
    [rightViewController displayWarningsSection:show];
}

- (void)deleteMedicineInOrderSetViewTag:(int)viewTag {
    
    donotUseDrug = YES;
    [self selectedDeleteMedicineButtonWithViewTag:viewTag];
}

- (void)updateOrderSetMedicineViewAtIndex:(NSInteger)index
                         withMedicineName:(NSString *)medicine {
    
    //change medicine name at top view
    DCOrderSetMedicineView *selectedMedicineView = (DCOrderSetMedicineView *)[orderSetMedicinesScrollView viewWithTag:index + 1];
    selectedMedicineView.medicineNameLabel.text = medicine;
}

- (void)updateOrderSetOperationsArray {
    
    //update order set operation array
  [_orderSetViewController updateAddMedicationsOperationsArray:_operationsArray];
}

#pragma mark - Private Methods

- (void)configureViewElements {
    
    [self configureNavigationBarItems];
    [self populatePatientDetails];
    //select Single Medication by default
    UIButton *singleMedicationButton = (UIButton *)[self.view viewWithTag:kSingleMedicationButtontag];
    [singleMedicationButton setSelected:YES];
    medicationArray = [NSMutableArray arrayWithArray:_patient.medicationListArray];
    if (_isLoadingOrderSet) {
        [orderSetMedicinesScrollView setHidden:NO];
        typeViewHeightConstraint.constant = TYPE_VIEW_ORDERSET_HEIGHT;
        if ([_activeOrderSetArray count] > 0) {
            [self addMedicationButtonsForOrderSet];
        }
        _selectedMedicineIndex = 0;
    } else {
        [orderSetMedicinesScrollView setHidden:YES];
        typeViewHeightConstraint.constant = MEDICATION_TYPE_VIEW_HEIGHT;
    }
    removedMedicinesArray = [[NSMutableArray alloc] init];
    _operationsArray = [[NSMutableArray alloc] init];
    if (_medicationList) {
        UIButton *orderSetButton = (UIButton *)[self.view viewWithTag:kOrderSetButtonTag];
        [orderSetButton setUserInteractionEnabled:NO];
        [orderSetButton setAlpha:0.4f];
    }
    [self.view layoutSubviews];
}

- (void)addChildViewControllers {
    
    [self addRightChildViewController];
    [self addSingleMedicationChildViewControllerInLeftContainer];
}

- (void)configureAlertsButton {
    
    alertsArray = self.patient.patientsAlertsArray;
    if ([alertsArray count] > 0) {
        [alertsButtonContainerView setHidden:NO];
        alertsCountLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)alertsArray.count];
    } else {
        
        [alertsButtonContainerView setHidden:YES];
    }
}

- (void)configureNavigationBarItems {
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    self.navigationItem.hidesBackButton = YES;
    if (_isLoadingOrderSet) {
        cancelButtonWidthConstraint.constant = ZERO_CONSTRAINT;
        doneButtonWidthConstraint.constant = ZERO_CONSTRAINT;
        cancelButtonLeadingConstraint.constant = CANCEL_HIDDEN_LEADING;
        [backButton setHidden:NO];
        backButtonWidthConstraint.constant = BACK_BUTTON_WIDTH;
        titleLabel.text = _patient.patientName ? [NSString stringWithFormat:@"%@ - %@", ORDER_SET, _patient.patientName] : [NSString stringWithFormat:@"%@", ORDER_SET];
    } else {
        cancelButtonWidthConstraint.constant = BAR_BUTTON_WIDTH;
        doneButtonWidthConstraint.constant = BAR_BUTTON_WIDTH;
        backButtonWidthConstraint.constant = BACK_BUTTON_HIDDEN_WIDTH;
        [backButton setHidden:YES];
        cancelButtonLeadingConstraint.constant = CANCEL_DEFAULT_LEADING;
        if (_medicationList) {
             titleLabel.text = _patient.patientName ? [NSString stringWithFormat:@"%@ - %@", EDIT_MEDICATION, _patient.patientName] : [NSString stringWithFormat:@"%@", EDIT_MEDICATION];
        } else {
             titleLabel.text = _patient.patientName ? [NSString stringWithFormat:@"%@ - %@", ADD_MEDICATION, _patient.patientName] : [NSString stringWithFormat:@"%@", ADD_MEDICATION];
        }
    }
}

- (void)addRightChildViewController {
    
    rightViewController = [self.storyboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_RIGHT_SB_ID];
    
    rightViewController.medicationArray = [NSMutableArray arrayWithArray:_patient.medicationListArray];
    rightViewController.allergiesArray = _patient.patientsAlergiesArray;
    [self addChildViewController:rightViewController];
    rightViewController.view.frame = rightContainerView.bounds;
    [rightContainerView addSubview:rightViewController.view];
    [rightViewController didMoveToParentViewController:self];
   // [rightViewController displayWarningsSection:NO];
}

- (NSArray *)getActiveMedicationList {
    
    NSString *predicateString = @"isActive == YES";
    NSPredicate *medicineCategoryPredicate = [NSPredicate predicateWithFormat:predicateString];
    NSMutableArray *activeMedicationsArray = (NSMutableArray *)[_patient.medicationListArray filteredArrayUsingPredicate:medicineCategoryPredicate];
    return activeMedicationsArray;
}

- (void)addSingleMedicationChildViewControllerInLeftContainer {
    
    //left child - single medication
    if (addMedicationDetailsViewController) {
        [DCUtility removeChildViewController:addMedicationDetailsViewController];
    }
    addMedicationDetailsViewController = [self.storyboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_DETAILS_SB_ID];
    addMedicationDetailsViewController.isLoadingOrderSet = _isLoadingOrderSet;
    addMedicationDetailsViewController.medicationList = self.medicationList;
    if (self.activeOrderSetArray) {
        addMedicationDetailsViewController.medicationsInOrderSet = self.activeOrderSetArray;
    }
    if (_isLoadingOrderSet) {
        detailsNavigationController = [[UINavigationController alloc] initWithRootViewController:addMedicationDetailsViewController];
        [self addChildViewController:detailsNavigationController];
        detailsNavigationController.view.frame = leftContainerView.bounds;
        detailsNavigationController.navigationBar.hidden = YES;
        [leftContainerView addSubview:detailsNavigationController.view];
        [detailsNavigationController didMoveToParentViewController:self];
    } else {
        [self addChildViewController:addMedicationDetailsViewController];
        addMedicationDetailsViewController.view.frame = leftContainerView.bounds;
        [leftContainerView addSubview:addMedicationDetailsViewController.view];
        [addMedicationDetailsViewController didMoveToParentViewController:self];
    }
}

- (void)addOrderSetChildViewControllerInLeftContainer {
    
    //left child - order set
    if (_orderSetViewController) {
        [DCUtility removeChildViewController:_orderSetViewController];
    }
    UIStoryboard *orderSetStoryboard = [UIStoryboard storyboardWithName:ORDERSET_STORYBOARD bundle:nil];
    _orderSetViewController = [orderSetStoryboard instantiateViewControllerWithIdentifier:ORDER_SET_SB_ID];
    [self addChildViewController:_orderSetViewController];
    _orderSetViewController.view.frame = leftContainerView.bounds;
    [leftContainerView addSubview:_orderSetViewController.view];
    [_orderSetViewController didMoveToParentViewController:self];
}

- (void)populatePatientDetails {
    
    //populate patient details
    dateOfBirthLabel.attributedText = [DCUtility getDateOfBirthAndAgeAttributedString:_patient.dob];
    nhsLabel.text = _patient.nhs;
    consultantLabel.text = _patient.consultant;
}

- (void)addMedicationButtonsForOrderSet {
    
    //add medication buttons in case of order set
    CGFloat xValue = ORDERSET_MEDICATION_XVALUE;
    CGFloat yValue = 0.0f;
    for (DCMedicationDetails *medication in _activeOrderSetArray) {
        int medicationIndex = (int)[_activeOrderSetArray indexOfObject:medication] + 1;
        DCOrderSetMedicineView *orderSetMedicineView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCOrderSetMedicineView class]) owner:self options:nil] objectAtIndex:0];
        [orderSetMedicineView setTag:medicationIndex];
        [orderSetMedicineView setDelegate:self];
        [orderSetMedicineView setFrame:CGRectMake(xValue, yValue, ORDERSET_MEDICATION_VIEW_WIDTH, ORDERSET_MEDICATION_HEIGHT)];
        [orderSetMedicinesScrollView addSubview:orderSetMedicineView];
        orderSetMedicineView.medicineNameLabel.text = [NSString stringWithFormat:@"%@", medication.name];
        orderSetMedicineView.countLabel.text = [NSString stringWithFormat:@"%i", medicationIndex];
        xValue += (ORDERSET_MEDICATION_VIEW_WIDTH + 10);
        [orderSetMedicineView configureViewElementsForMedication:medication];
    }
    [self adjustOrderSetMedicinesHorizontalScroll];
}

- (void)adjustOrderSetMedicinesHorizontalScroll {
    
    CGSize scrollableSize = CGSizeMake(_activeOrderSetArray.count *(ORDERSET_MEDICATION_VIEW_WIDTH + 20) , 79.0f);
    [orderSetMedicinesScrollView setContentSize:scrollableSize];
    
}

- (void)pushMedicationDetailsViewControllersUptoIndex:(int)index {
    
    //push view controllers upto index
    NSMutableArray *viewControllersArray = [NSMutableArray arrayWithArray:detailsNavigationController.viewControllers];
    for (NSUInteger i = viewControllersArray.count; i < index; i ++) {
        DCAddMedicationDetailsViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_DETAILS_SB_ID];
        detailViewController.isLoadingOrderSet = _isLoadingOrderSet;
        if (self.activeOrderSetArray) {
            detailViewController.medicationsInOrderSet = self.activeOrderSetArray;
        }
        detailViewController.orderSetSelectedIndex = (int)i;
        [detailViewController.view setHidden:YES];
        [detailsNavigationController pushViewController:detailViewController animated:NO];
        [detailViewController.view setHidden:NO];
    }
}

- (void)popMedicationDetailsViewControllersUptoIndex:(int)index {
    
    //pop view controllers upto index
    NSMutableArray *viewControllersArray = [NSMutableArray arrayWithArray:detailsNavigationController.viewControllers];
    for (NSUInteger i = viewControllersArray.count - 1; i > index; i --) {
        DCAddMedicationDetailsViewController *detailViewController = (DCAddMedicationDetailsViewController *)[detailsNavigationController.viewControllers objectAtIndex:i];
        [detailsNavigationController popToViewController:detailViewController animated:NO];
    }
}

- (void)endMedicineButtonsWobbleAnimation {
    
    if (isAnimating) {
        for (DCOrderSetMedicineView *orderSetMedicineView in orderSetMedicinesScrollView.subviews) {
            if ([orderSetMedicineView isKindOfClass:[DCOrderSetMedicineView class]]) {
                [orderSetMedicineView.deleteButton setHidden:YES];
                [DCUtility stopWobbleAnimationForView:orderSetMedicineView];
                [orderSetMedicineView configureCountLabelAndCompletionStatusImageView];
            }
        }
        isAnimating = NO;
    }
}

- (void)removeAllMedicineViewsFromContainerScrollView {
    
    //remove all orderset medicine views from scrollview
    for (DCOrderSetMedicineView *orderSetMedicineView in orderSetMedicinesScrollView.subviews) {
        if ([orderSetMedicineView isKindOfClass:[DCOrderSetMedicineView class]]) {
            [orderSetMedicineView removeFromSuperview];
        }
    }
}

- (void)updateActiveMedicationArray {
    
    //update active medication array
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    for (NSUInteger index = 0; index < removedMedicinesArray.count; index++) {
        [indexes addIndex:[[removedMedicinesArray objectAtIndex:index] integerValue]];
    }
    [_activeOrderSetArray removeObjectsAtIndexes:indexes];
    addMedicationDetailsViewController.medicationsInOrderSet = _activeOrderSetArray;
    [self adjustOrderSetMedicinesHorizontalScroll];
}

- (void)updateInactiveMedicationArray {
    
    //update inactive medication array
    NSMutableArray *inactiveMedications = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < removedMedicinesArray.count; i ++) {
        NSUInteger contentIndex = [[removedMedicinesArray objectAtIndex:i] integerValue];
        DCMedicationDetails *searchMedication = (DCMedicationDetails *)[_activeOrderSetArray objectAtIndex:contentIndex];
        [inactiveMedications addObject:searchMedication];
    }
    [_orderSetViewController updateInActiveMedicationListWithContents:inactiveMedications];
}

- (void)removeViewControllersFromNavigationStackOnDelete {
    
    //delete view controllers from navigation stack
    @try {
        NSPredicate *lesserPredicate = [NSPredicate predicateWithFormat:@"SELF <= %i", _selectedMedicineIndex];
        NSArray *lesserResults = [removedMedicinesArray filteredArrayUsingPredicate:lesserPredicate];
        if (_activeOrderSetArray.count == 0) {
            [self updateActiveOrderSetArray:_activeOrderSetArray withCompletion:^(BOOL completed) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }];
        } else {
            if ([lesserResults count] > 0) {
                NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:detailsNavigationController.viewControllers];
                NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
                for (NSUInteger index = 0; index < lesserResults.count; index++) {
                    [indexes addIndex:index];
                }
                [viewControllers removeObjectsAtIndexes:indexes];
                if ([removedMedicinesArray containsObject:[NSNumber numberWithInt:_selectedMedicineIndex]] && _selectedMedicineIndex == 0) {
                    if (_activeOrderSetArray.count > 0) {
                        [self popMedicationDetailsViewControllersUptoIndex:0];
                        [self loadAddMedicationDetailsViewAtIndex:_selectedMedicineIndex];
                        [addMedicationDetailsViewController populateOrderSetMedicationDetailsAtIndex:_selectedMedicineIndex];
                    } else {
                        [self updateActiveOrderSetArray:_activeOrderSetArray withCompletion:^(BOOL completed) {
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }];
                    }
                }  else {
                    [detailsNavigationController setViewControllers:viewControllers animated:YES];
                    _selectedMedicineIndex -= lesserResults.count;
                    addMedicationDetailsViewController.orderSetSelectedIndex = _selectedMedicineIndex;
                    [self selectedOrderSetMedicineAtIndex:_selectedMedicineIndex];
                    [addMedicationDetailsViewController populateOrderSetMedicationDetailsAtIndex:_selectedMedicineIndex];
                }
            } else {
                [addMedicationDetailsViewController populateOrderSetMedicationDetailsAtIndex:_selectedMedicineIndex];
            }
        }
        [removedMedicinesArray removeAllObjects];
    }
    @catch (NSException *exception) {
        DCDebugLog(@"Remove ViewControllers from stack exception: %@", exception.description);
    }
 }

- (void)configureOrderSetScrollViewOnSuperviewTap {
    
    if (isAnimating || donotUseDrug) {
        [addMedicationDetailsViewController parentViewTapped];
        [self removeAllMedicineViewsFromContainerScrollView];
        [self updateInactiveMedicationArray];
        [self updateActiveMedicationArray];
        [self addMedicationButtonsForOrderSet];
        [self removeViewControllersFromNavigationStackOnDelete];
        if (!donotUseDrug) {
            [self longPressActionOnMedicineView];
        }
        donotUseDrug = NO;
    }
}

- (void)displayMedicationConfirmationAlertWithType:(AlertType) alertType{
    //display missed administartion pop up
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD
                                                                   bundle: nil];
    DCMissedMedicationAlertViewController *missedMedicationAlertViewController = [administerStoryboard instantiateViewControllerWithIdentifier:MISSED_ADMINISTER_VIEW_CONTROLLER];
    missedMedicationAlertViewController.alertType = alertType;
    missedMedicationAlertViewController.dismissView = ^ {
        //delete the medication from order set
        if (alertType == eOrderSetDeleteConfirmation) {
            [self configureOrderSetScrollViewOnSuperviewTap];
        }
    };
    missedMedicationAlertViewController.dismissViewWithoutSaving = ^ {
        if (alertType == eOrderSetDeleteConfirmation) {
            [removedMedicinesArray removeAllObjects];
            [addMedicationDetailsViewController displayWarningsViewOnAddSubstituteCancel];
        }
    };
    [missedMedicationAlertViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:missedMedicationAlertViewController animated:YES completion:nil];
}

- (BOOL)allMedicationsInActiveListAreSaved {
    
   // check if all medications are saved
    BOOL allMedicationsSaved = YES;
    @try {
        if ([self.orderSetViewController.activeMedicationArray count] > 0) {
            for (DCMedicationDetails *medication in self.orderSetViewController.activeMedicationArray) {
                if (!medication.addMedicationCompletionStatus) {
                    allMedicationsSaved = NO;
                    break;
                }
            }
        }
    }
    @catch (NSException *exception) {
        DCDebugLog(@"Exception raised : %@", exception.description);
    }
    return allMedicationsSaved;
}

- (void)updateWarningsArray:(NSArray *)warningsArray {
    
    //update warnings array
   // rightViewController.warningsArray = [NSMutableArray arrayWithArray:warningsArray];
    [rightViewController populateViewWithWarningsArray:warningsArray];
}

- (void)addMedicationOperationsToOrderSetQueue {
    
    //add medication operations to order set queue
    DCOrderSetOperationQueue *operationQueue;
    if ([_operationsArray count] > 0) {
         operationQueue = [[DCOrderSetOperationQueue alloc] init];
         [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [operationQueue executeAddMedicationOperationsInOrdersetQueue:_operationsArray withCompletionHandler:^(id response, id error) {
            //completion of add order set call
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [self dismissView];
        }];
    }
}

#pragma mark - Touches Method

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self endMedicineButtonsWobbleAnimation];
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - Action Methods

- (IBAction)cancelButtonPressed:(id)sender {
    
    //discard all changes and dismiss view
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (IBAction)doneButtonPressed:(id)sender {
    
    if (_orderSetViewController.isViewLoaded && _orderSetViewController.view.window && _isLoadingOrderSet) {
        // viewController is visible
        if ([_orderSetViewController isOrderSetNameFieldValid] && [self allMedicationsInActiveListAreSaved]) {
            
            [self addMedicationOperationsToOrderSetQueue];
        } else {
            if (![self allMedicationsInActiveListAreSaved]) {
                //all medications not saved
                //add validation for order set initial screen
                [_orderSetViewController displayValidationView:YES];
            }
        }
    } else {
        [addMedicationDetailsViewController doneButtonAction];
    }
}

- (IBAction)typeOfMedicationSelected:(id)sender {
    
    //type of medication selected
    UIButton *selectedButton = (UIButton *)sender;
    if (selectedButton.tag == kSingleMedicationButtontag) {
        //single medication
        _isLoadingOrderSet = NO;
        [selectedButton setSelected:YES];
        UIButton *orderSetButton = (UIButton *)[self.view viewWithTag:kOrderSetButtonTag];
        [orderSetButton setSelected:NO];
        [self addSingleMedicationChildViewControllerInLeftContainer];
    } else {
        //order set button selected
        [selectedButton setSelected:YES];
        _isLoadingOrderSet = YES;
        UIButton *orderSetButton = (UIButton *)[self.view viewWithTag:kSingleMedicationButtontag];
        [orderSetButton setSelected:NO];
        [self addOrderSetChildViewControllerInLeftContainer];
    }
    //[rightViewController displayWarningsSection:NO];
}


- (IBAction)backButtonPressed:(id)sender {
    
    [self updateActiveOrderSetArray:_activeOrderSetArray withCompletion:^(BOOL completed) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - Notification Methods

- (void)keyboardDidShow:(NSNotification *)notification {
    
    self.keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self animateViewUpwardsOnEditingText:YES];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    [self animateViewUpwardsOnEditingText:NO];
}

#pragma mark - DCOrderSetMedicineViewDelegate Methods

- (void)selectedMedicineSelectionButtonWithViewTag:(int)viewTag {
    
    //load corresponding medication details in view
    _selectedMedicineIndex = viewTag - 1;
    [self deSelectOrderSetMedicineViews];
    [addMedicationDetailsViewController loadOrderSetMedicationAtIndex:viewTag - 1];
}

- (void)selectedDeleteMedicineButtonWithViewTag:(int)viewTag {
    
    //delete medicine buttons
    [removedMedicinesArray addObject:[NSNumber numberWithInt:viewTag - 1]];
    //display confirmation alert here
    [self displayMedicationConfirmationAlertWithType:eOrderSetDeleteConfirmation];
}

- (void)longPressActionOnMedicineView {
    
    //wobble animation for orderset medicine view
    for (DCOrderSetMedicineView *orderSetMedicineView in orderSetMedicinesScrollView.subviews) {
        if ([orderSetMedicineView isKindOfClass:[DCOrderSetMedicineView class]]) {
            [orderSetMedicineView.deleteButton setHidden:NO];
            [DCUtility startWobbleAnimationForView:orderSetMedicineView];
            isAnimating = YES;
        }
    }
}

@end
