//
//  DCOrderSetInitialViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/30/15.
//
//

#import "DCOrderSetInitialViewController.h"
#import "DCAddMedicationViewController.h"
#import "DCOrderSetTableCell.h"
#import "DCAutoSearchView.h"
#import "DCScrollView.h"
#import "DCOrderSet.h"
#import "DCMissedMedicationAlertViewController.h"
#import "DCOrderSetWebService.h"
#import "DCOrderSetAutoSearchHeaderView.h"
#import "DCAddMedicationOperation.h"
#import "DCOrderSetWarningCountWebService.h"
#import "DCOrderSetWarningCount.h"

#define ROW_HEIGHT                                          45.0f
#define ACTIVE_LABEL_CONSTRAINT                             17.0f
#define INACTIVE_LABEL_TOP_CONSTRAINT_DEFAULT               20.0f
#define INACTIVE_LABEL_TOP_CONSTRAINT_IS_ACTIVE_HIDDEN      -8.0f
#define AUTOSEARCH_MIN_CELL_HEIGHT                          48.0f
#define SEARCH_POPOVER_MAXIMUM_HEIGHT                       480.0f
#define OFFSET_VALUE                                        10.0f
#define ORDERSET_NAME_FIELD_DEFAULT                         35.0f
#define TEXTVIEW_MAX_WIDTH                                  530.0f
#define ANIMATION_DURATION                                  0.3
#define TEXTFIELD_MIN_HEIGHT                                30.0f
#define VALIDATION_VIEW_HEIGHT                              40.0f

#define AUTOSEARCH_VIEW_INITIAL_FRAME             CGRectMake(orderSetNameTextView.frame.origin.x, orderSetNameTextView.frame.origin.y + 10, 536, 550)

@interface DCOrderSetInitialViewController () <DCScrollViewDelegate, DCAutoSearchDelegate> {
    
    
    __weak IBOutlet UITextView *orderSetNameTextView;
    __weak IBOutlet UITextView *descriptionTextView;
    __weak IBOutlet UITableView *activeMedicationTableView;
    __weak IBOutlet UITableView *inactiveMedicationTableView;
    __weak IBOutlet DCScrollView *scrollView;
    __weak IBOutlet UIView *contentView;
    __weak IBOutlet UILabel *activeLabel;
    __weak IBOutlet UILabel *inactiveLabel;
    __weak IBOutlet UIView *medicationView;
    __weak IBOutlet UIView *descriptionContainerView;
    __weak IBOutlet UIButton *addMedicationButton;
    __weak IBOutlet UIButton *clearButton;
    __weak IBOutlet NSLayoutConstraint *activeMedicationTableHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *inactiveMedicationTableHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *activeLabelHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *inactiveLabelTopConstraint;
    __weak IBOutlet NSLayoutConstraint *descriptionTextViewHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *descriptionContainerHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *orderSetNameHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *validationViewHeightConstraint;
    
    DCAutoSearchView *autoSearchView;
    NSMutableArray *inactiveMedicationArray;
    CGFloat autoSearchViewHeight;
    NSArray *orderSetArray;
    DCOrderSet *selectedOrderSet;
    NSString *previousOrderSetName;
    BOOL hasChanges;

}

@end

@implementation DCOrderSetInitialViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self addAutoSearchView];
    [self configureViewElements];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [activeMedicationTableView reloadData];
    [inactiveMedicationTableView reloadData];
    validationViewHeightConstraint.constant = ZERO_CONSTRAINT;
    [self setStatusLabelsAndTableViewHeightConstraints];
    [self.view layoutIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Public Methods

- (void)updateActiveMedicationList:(NSArray *)activeMedications
             withCompletionHandler:(void(^)(BOOL completed))callBackHandler {
    
    hasChanges = YES;
    _activeMedicationArray = [NSMutableArray arrayWithArray:activeMedications];
    [self checkAddMedicationCompletionStatusInActiveList];
    [activeMedicationTableView reloadData];
    callBackHandler(YES);
}

- (void)updateInActiveMedicationListWithContents:(NSArray *)inactiveMedications {
    
    [inactiveMedicationArray addObjectsFromArray:inactiveMedications];
}

- (BOOL)isOrderSetNameFieldValid {
    
    //validate order set name field
    BOOL isValid = YES;
    if ([orderSetNameTextView.text isEqualToString:EMPTY_STRING]) {
        isValid = NO;
        [self displayValidationView:YES];
        [DCUtility modifyViewComponentForErrorDisplay:orderSetNameTextView];
    } else {
        orderSetNameTextView.layer.borderColor = LIGHT_GRAY_BORDER_COLOR;
    }
    return isValid;
}

- (void)displayValidationView:(BOOL)show {
    
    //validation view display
    validationViewHeightConstraint.constant = show ? VALIDATION_VIEW_HEIGHT : ZERO_CONSTRAINT;
    //check if any of medications in active list are not saved. If so, display red border around the corresponding table cell
    [self validateMedicationsInActiveList:show];
}

- (void)validateMedicationsInActiveList:(BOOL)isValid {
    
    //validate medications in active list
    for (DCMedicationDetails *medication in _activeMedicationArray) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_activeMedicationArray indexOfObject:medication] inSection:0];
        DCOrderSetTableCell *orderSetCell = (DCOrderSetTableCell *)[activeMedicationTableView cellForRowAtIndexPath:indexPath];
        if (isValid) {
            if (!medication.addMedicationCompletionStatus) {
                [orderSetCell.containerView.layer setBorderColor:[UIColor redColor].CGColor];
            } else {
                [orderSetCell.containerView.layer setBorderColor:[UIColor clearColor].CGColor];
            }
        } else {
            [orderSetCell.containerView.layer setBorderColor:[UIColor clearColor].CGColor];
        }
    }
}

- (void)updateAddMedicationsOperationsArray:(NSArray *)operationsArray {
    
     DCAddMedicationViewController *addMedicationViewController = (DCAddMedicationViewController *)self.parentViewController;
    addMedicationViewController.operationsArray = [NSMutableArray arrayWithArray:operationsArray];
}

#pragma mark - Private Methods

- (void)configureViewElements {
    
    //populate view elements
    orderSetNameTextView.layer.borderColor = LIGHT_GRAY_BORDER_COLOR;
    [orderSetNameTextView setTextContainerInset:MEDICINE_NAME_TEXTVIEW_EDGE_INSETS];
    [self showMedicationAndDescriptionViews:NO];
    scrollView.scrollDelegate =  self;
    [clearButton setHidden:YES];
    [self configureOrderSetTables];
}

- (void)configureOrderSetTables {
    
    [self callOrderSetWebService];
    _activeMedicationArray = [[NSMutableArray alloc] init];
    inactiveMedicationArray = [[NSMutableArray alloc] init];
    activeMedicationTableView.layer.borderColor = [UIColor getColorForHexString:@"#c4d3d5"].CGColor;
    inactiveMedicationTableView.layer.borderColor = [UIColor getColorForHexString:@"#c4d3d5"].CGColor;
    activeMedicationTableView.separatorInset = UIEdgeInsetsZero;
    activeMedicationTableView.layoutMargins = UIEdgeInsetsZero;
    inactiveMedicationTableView.separatorInset = UIEdgeInsetsZero;
    inactiveMedicationTableView.layoutMargins = UIEdgeInsetsZero;
    [self setStatusLabelsAndTableViewHeightConstraints];
    [self.view layoutIfNeeded];
}

- (void)checkAddMedicationCompletionStatusInActiveList {
    
    //check if all medications are saved
    BOOL allMedicationsSaved = YES;
    for (DCMedicationDetails *medication in _activeMedicationArray) {
        if (!medication.addMedicationCompletionStatus) {
            allMedicationsSaved = NO;
            break;
        }
    }
    addMedicationButton.hidden = allMedicationsSaved ? YES : NO;
}

- (BOOL)checkIfAnyMedicationInActiveListIsSaved {
    
    BOOL saved = NO;
    for (DCMedicationDetails *medication in _activeMedicationArray) {
        if (medication.addMedicationCompletionStatus) {
            saved = YES;
            break;
        }
    }
    return saved;
}

- (void)setStatusLabelsAndTableViewHeightConstraints {
    
    activeMedicationTableHeightConstraint.constant = ROW_HEIGHT * _activeMedicationArray.count;
    inactiveMedicationTableHeightConstraint.constant = ROW_HEIGHT * inactiveMedicationArray.count;
    inactiveLabel.hidden = (inactiveMedicationArray.count > 0) ? NO : YES;
    activeLabel.hidden = (_activeMedicationArray.count > 0) ? NO : YES;
    activeLabelHeightConstraint.constant = activeLabel.hidden ? ZERO_CONSTRAINT : ACTIVE_LABEL_CONSTRAINT;
    inactiveLabelTopConstraint.constant = activeLabel.hidden ? INACTIVE_LABEL_TOP_CONSTRAINT_IS_ACTIVE_HIDDEN : INACTIVE_LABEL_TOP_CONSTRAINT_DEFAULT;
}

- (void)showMedicationAndDescriptionViews:(BOOL)show {
    
    //show/hide views
    [medicationView setHidden:!show];
    [descriptionContainerView setHidden:!show];
    [addMedicationButton setHidden:!show];
}

- (void)addAutoSearchView {
    
    //add auto search view
    autoSearchView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCAutoSearchView class]) owner:self options:nil] objectAtIndex:0];
    [autoSearchView setFrame:AUTOSEARCH_VIEW_INITIAL_FRAME];
    autoSearchView.autoSearchType = eOrderSet;
    [scrollView addSubview:autoSearchView];
    [autoSearchView setSearchDelegate:self];
    [autoSearchView setHidden:YES];
}

- (void)hideAutoSearchView {
    
    [autoSearchView setHidden:YES];
    if ([orderSetNameTextView isFirstResponder]) {
        [orderSetNameTextView resignFirstResponder];
    }
}

- (void)configureTableViewAtIndexPath:(NSIndexPath *)indexPath forRemoveAction:(BOOL)remove {
    
    //configure table view cell for remove action
    if (remove) {
        DCMedicationDetails *medication = [_activeMedicationArray objectAtIndex:indexPath.row];
        [inactiveMedicationArray addObject:medication];
        [_activeMedicationArray removeObjectAtIndex:indexPath.row];
        [activeMedicationTableView beginUpdates];
        [UIView animateWithDuration:ANIMATION_DURATION animations:^ {
            [activeMedicationTableView cellForRowAtIndexPath:indexPath].alpha = ALPHA_PARTIAL;
            [activeMedicationTableView deleteRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationFade];
        } completion:^(BOOL finished) {
            [activeMedicationTableView endUpdates];
            [inactiveMedicationTableView beginUpdates];
            [inactiveMedicationTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:inactiveMedicationArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
            [inactiveMedicationTableView endUpdates];
            [self checkAddMedicationCompletionStatusInActiveList];
        }];
    } else {
        DCMedicationDetails *medication = [inactiveMedicationArray objectAtIndex:indexPath.row];
        [_activeMedicationArray addObject:medication];
        [inactiveMedicationArray removeObjectAtIndex:indexPath.row];
        [inactiveMedicationTableView beginUpdates];
        [UIView animateWithDuration:ANIMATION_DURATION animations:^ {
            [inactiveMedicationTableView cellForRowAtIndexPath:indexPath].alpha = ALPHA_PARTIAL;
            [inactiveMedicationTableView deleteRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationFade];
        } completion:^(BOOL finished) {
            [inactiveMedicationTableView endUpdates];
            [activeMedicationTableView beginUpdates];
            [activeMedicationTableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_activeMedicationArray.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
            [activeMedicationTableView endUpdates];
            [self checkAddMedicationCompletionStatusInActiveList];
        }];
    }
    [self setStatusLabelsAndTableViewHeightConstraints];
}

- (void)expandOrderSetDescriptionView {
    
    //order set description
    CGFloat descriptionTextHeight = [DCUtility getHeightValueForText:descriptionTextView.text
                                                            withFont:[DCFontUtility getLatoRegularFontWithSize:14.0f] maxWidth:TEXTVIEW_MAX_WIDTH];
    if (descriptionTextHeight < TEXTFIELD_MIN_HEIGHT) {
        descriptionTextViewHeightConstraint.constant = ORDERSET_NAME_FIELD_DEFAULT;
    } else {
        descriptionTextViewHeightConstraint.constant = descriptionTextHeight;
    }
    descriptionContainerHeightConstraint.constant = descriptionTextViewHeightConstraint.constant + OFFSET_VALUE;
    [self.view layoutIfNeeded];
}

- (void)expandOrderSetNameTextViewForText:(NSString *)text {
    
    //order set description
    CGFloat orderSetNameHeight = [DCUtility getHeightValueForText:text
                                                         withFont:[DCFontUtility getLatoRegularFontWithSize:14.0f]
                                                         maxWidth:TEXTVIEW_MAX_WIDTH];
    if (orderSetNameHeight < TEXTFIELD_MIN_HEIGHT) {
        orderSetNameHeightConstraint.constant = ORDERSET_NAME_FIELD_DEFAULT;
    } else {
        orderSetNameHeightConstraint.constant = orderSetNameHeight + 15;
    }
    [self configureAutoSearchViewHeight];
    [self.view layoutIfNeeded];
}

- (void)configureAutoSearchViewHeight {
    
    UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
    autoSearchViewHeight =   mainWindow.frame.size.height - (NAVIGATION_BAR_HEIGHT + self.keyboardSize.height + orderSetNameTextView.frame.origin.y + orderSetNameHeightConstraint.constant + 10);
    CGFloat searchContentHeight;
    NSUInteger totalCellCount = [autoSearchView.searchedContentsArray count] + [autoSearchView.favouriteContentsArray count];
    searchContentHeight = totalCellCount * autoSearchView.searchTableViewCellHeight;
    searchContentHeight += [self getHeaderHeight];
    if (searchContentHeight > autoSearchViewHeight) {
        CGFloat searchHeight = autoSearchViewHeight> SEARCH_POPOVER_MAXIMUM_HEIGHT ? SEARCH_POPOVER_MAXIMUM_HEIGHT: autoSearchViewHeight;
        [autoSearchView setFrame:CGRectMake(autoSearchView.frame.origin.x, orderSetNameTextView.frame.origin.y + orderSetNameHeightConstraint.constant + OFFSET_VALUE, autoSearchView.frame.size.width, searchHeight + OFFSET_VALUE)];
    } else {
        CGFloat searchHeight = searchContentHeight> SEARCH_POPOVER_MAXIMUM_HEIGHT ? SEARCH_POPOVER_MAXIMUM_HEIGHT: searchContentHeight;
        [autoSearchView setFrame:CGRectMake(autoSearchView.frame.origin.x, orderSetNameTextView.frame.origin.y + orderSetNameHeightConstraint.constant + OFFSET_VALUE, autoSearchView.frame.size.width, searchHeight + OFFSET_VALUE)];
    }
    [self.view layoutIfNeeded];
}

- (void)resizeAutoSearchViewHeightForSearchString:(NSString *)searchString {
    
    NSUInteger totalCellCount = [autoSearchView.searchedContentsArray count] + [autoSearchView.favouriteContentsArray count];
    if (totalCellCount == 0) {
        [autoSearchView setFrame: CGRectMake(autoSearchView.frame.origin.x, autoSearchView.frame.origin.y + OFFSET_VALUE, autoSearchView.frame.size.width, AUTOSEARCH_MIN_CELL_HEIGHT + OFFSET_VALUE)];
    } else {
        CGFloat searchContentHeight = totalCellCount * autoSearchView.searchTableViewCellHeight;
        searchContentHeight += [self getHeaderHeight];
        if (searchContentHeight < autoSearchViewHeight) {
            [autoSearchView setFrame: CGRectMake(autoSearchView.frame.origin.x, autoSearchView.frame.origin.y + OFFSET_VALUE, autoSearchView.frame.size.width, searchContentHeight + OFFSET_VALUE)];
        } else {
            [self configureAutoSearchViewHeight];
        }
    }
    [self.view layoutIfNeeded];
}

- (void)displayConfirmationAlertForType:(AlertType)alertType {
    
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD
                                                                   bundle: nil];
    DCMissedMedicationAlertViewController *alertViewController = [administerStoryboard instantiateViewControllerWithIdentifier:MISSED_ADMINISTER_VIEW_CONTROLLER];
    alertViewController.alertType = alertType;
    alertViewController.dismissView = ^ {
        hasChanges = NO;
        if (alertType == eOrderSetNameClearConfirmation) {
            [_activeMedicationArray removeAllObjects];
            [self orderSetNameClearButtonPressed:nil];
        } else if (alertType == eNewOrderSetSelection) {
            [_activeMedicationArray removeAllObjects];
            [self selectedOrderSet:selectedOrderSet];
        }
    };
    alertViewController.dismissViewWithoutSaving = ^ {
        if (alertType == eNewOrderSetSelection) {
            [autoSearchView setHidden:YES];
            orderSetNameTextView.text = previousOrderSetName;
            [orderSetNameTextView resignFirstResponder];
        }
    };
    [alertViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:alertViewController animated:YES completion:nil];
}

- (void)displayMedicationDetailsViewAtIndex:(NSInteger)index {
    
    DCAddMedicationViewController *addMedicationViewController = (DCAddMedicationViewController *)self.parentViewController;
    [addMedicationViewController loadActiveOrderSetMedicationDetailsView:_activeMedicationArray
                                                   loadMedicationAtIndex:index];
}

- (void)callOrderSetWebService {
    
    //get order set list from api
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    DCOrderSetWebService *webService = [[DCOrderSetWebService alloc] init];
    [webService getAllOrderSetsWithCallBackHandler:^(NSArray *orderSetsArray, NSError *error) {
        if (!error) {
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            orderSetArray = [NSMutableArray arrayWithArray:orderSetsArray];
        }
    }];
}

- (void)getOrderSetWarningsCountForPatientId:(NSString *)patientId  andOrderSetId:(NSString *)orderSetId{
    
    DCOrderSetWarningCountWebService *webService= [[DCOrderSetWarningCountWebService alloc] init];
    [webService getOrderSetWarningCountForPatientWithId:patientId forOrderSetWithId:orderSetId withCallBackHandler:^(NSArray *warningsArray, NSError *error) {
        if (error) {
            
            NSMutableArray *orderSetMedicationArray = [NSMutableArray arrayWithArray:selectedOrderSet.medicationList];
            NSMutableArray *countUpdateMedicationArray = [[NSMutableArray alloc] init];
            if (warningsArray.count > 0) {
                
                for (int count = 0; count < warningsArray.count; count++) {
                   
                    DCMedicationDetails *medication = [orderSetMedicationArray objectAtIndex:count];
                    DCOrderSetWarningCount *warning = [warningsArray objectAtIndex:count];
                    if ([medication.medicationId isEqualToString:warning.medicationId]) {
                        
                        medication.hasWarning = YES;
                        medication.severeWarningCount = [warning.severeWarningCount integerValue];
                        medication.mildWarningCount = [warning.mildWarningCount integerValue];
                        [countUpdateMedicationArray addObject:medication];
                    }
                }
            }
            selectedOrderSet.medicationList = [NSMutableArray arrayWithArray:countUpdateMedicationArray];
            [activeMedicationTableView reloadData];
            [inactiveMedicationTableView reloadData];
        }
    }];
    
}

- (NSArray *)getFavouriteOrderSetList {
    
    NSString *predicateString = @"isUserFavourite == YES";
    NSPredicate *orderSetCategoryPredicate = [NSPredicate predicateWithFormat:predicateString];
    NSMutableArray *favouriteOrderSetArray = (NSMutableArray *)[orderSetArray filteredArrayUsingPredicate:orderSetCategoryPredicate];
    return favouriteOrderSetArray;
}

- (CGFloat )getHeaderHeight {
    
    if ([autoSearchView.searchedContentsArray count] > 0 && [autoSearchView.favouriteContentsArray count] > 0) {
        return 80.0f;
    } else if ([autoSearchView.searchListArray count] > 0 || [autoSearchView.favouriteContentsArray count] > 0){
        return 40;
    } else {
        return 0.0f;
    }
}

#pragma mark - TextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView{
    
    if (textView == orderSetNameTextView) {
        [autoSearchView setHidden:NO];
        NSString *substring = [NSString stringWithString:textView.text];
        autoSearchView.searchListArray = [NSMutableArray arrayWithArray:orderSetArray];
        [autoSearchView.autoFillTableView reloadData];
        [autoSearchView searchAutocompleteEntriesWithSubstring:substring];
        [self resizeAutoSearchViewHeightForSearchString:substring];
        orderSetNameTextView.layer.borderColor = LIGHT_GRAY_BORDER_COLOR;
        validationViewHeightConstraint.constant = ZERO_CONSTRAINT;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (textView == orderSetNameTextView) {
        [autoSearchView setHidden:NO];
        NSString *substring = [NSString stringWithString:textView.text];
        substring = [substring
                     stringByReplacingCharactersInRange:range withString:text];
        [self expandOrderSetNameTextViewForText:substring];
        [autoSearchView searchAutocompleteEntriesWithSubstring:substring];
        [self resizeAutoSearchViewHeightForSearchString:substring];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    clearButton.hidden = [textView.text isEqualToString:EMPTY_STRING] ? YES : NO;
}

#pragma mark - DCScrollViewDelegate Methods

- (void)touchedScrollView:(UITouch *)touch {
//    NSArray *subviews = [touch.view subviews];
    [self hideAutoSearchView];
}

#pragma mark - Touches Method

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event  {
    
    [self hideAutoSearchView];
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - TableView Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == activeMedicationTableView) {
        return [_activeMedicationArray count];
    } else {
       return [inactiveMedicationArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCOrderSetTableCell *orderSetCell = [tableView dequeueReusableCellWithIdentifier:ORDER_CELL_IDENTIFIER];
    if (orderSetCell == nil) {
        orderSetCell = [[DCOrderSetTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ORDER_CELL_IDENTIFIER];
    }
    orderSetCell.layoutMargins = UIEdgeInsetsZero;
    orderSetCell.selectionStyle = UITableViewCellSelectionStyleNone;
    DCMedicationDetails *medication;
    if (tableView == activeMedicationTableView) {
        medication = [_activeMedicationArray objectAtIndex:indexPath.row];
    } else {
        medication = [inactiveMedicationArray objectAtIndex:indexPath.row];
    }
    [orderSetCell configureOrderSetCellForMedication:medication];
    return orderSetCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *buttonTitle = (tableView == activeMedicationTableView) ? REMOVE_BUTTON_TITLE : ORDER_BUTTON_TITLE;
    UITableViewRowAction *removeButton = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:buttonTitle handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                              {
                                                  DCDebugLog(@"Action to perform with Remove Or Order");
                                                  hasChanges = YES;
                                                  [tableView deselectRowAtIndexPath:indexPath animated:NO];
                                                  if (tableView == activeMedicationTableView) {
                                                      [self configureTableViewAtIndexPath:indexPath forRemoveAction:YES];
                                                  } else {
                                                      [self configureTableViewAtIndexPath:indexPath forRemoveAction:NO];
                                                  }
                                              }];
    removeButton.backgroundColor = (tableView == activeMedicationTableView) ? [UIColor getColorForHexString:@"#f00707"] : [UIColor getColorForHexString:@"#4dc8e9"];
    UIFont *font = [DCFontUtility getLatoRegularFontWithSize:14.0f];
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString: buttonTitle
                                                                          attributes: attributes];
    [[UIButton appearanceWhenContainedIn:[UIView class], [DCOrderSetTableCell class], nil] setAttributedTitle: attributedTitle
                                                                                          forState: UIControlStateNormal];
    return @[removeButton];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == activeMedicationTableView) {
        DCMedicationDetails *selectedMedication = [_activeMedicationArray objectAtIndex:indexPath.row];
        if (selectedMedication.addMedicationCompletionStatus) {
            [self displayMedicationDetailsViewAtIndex:indexPath.row];
        }
    }
}

#pragma mark - Action Methods

- (IBAction)addMedicationDetailsButtonPressed:(id)sender {
    
    //display whole list of medications
    [self displayValidationView:NO];
    [self displayMedicationDetailsViewAtIndex:0];
}

- (IBAction)orderSetNameClearButtonPressed:(id)sender {
    
    if (hasChanges) {
        //display confirmation alert here
        [self displayConfirmationAlertForType:eOrderSetNameClearConfirmation];
    } else {
        //order set name clear button action
        orderSetNameTextView.text = EMPTY_STRING;
        [clearButton setHidden:YES];
        [self displayValidationView:NO];
        orderSetNameHeightConstraint.constant = ORDERSET_NAME_FIELD_DEFAULT;
        [self expandOrderSetNameTextViewForText:EMPTY_STRING];
        [self resizeAutoSearchViewHeightForSearchString:EMPTY_STRING];   
        [autoSearchView searchAutocompleteEntriesWithSubstring:EMPTY_STRING];
        [self showMedicationAndDescriptionViews:NO];
        [_activeMedicationArray removeAllObjects];
        [inactiveMedicationArray removeAllObjects];
        DCAddMedicationViewController *addMedicationViewController = (DCAddMedicationViewController *)self.parentViewController;
        [addMedicationViewController.operationsArray removeAllObjects];
        NSUInteger totalCellCount = [autoSearchView.searchedContentsArray count] + [autoSearchView.favouriteContentsArray count];
        CGFloat searchContentHeight = totalCellCount * autoSearchView.searchTableViewCellHeight;
        searchContentHeight += [self getHeaderHeight];
        if (searchContentHeight < autoSearchViewHeight) {
            [autoSearchView setFrame: CGRectMake(autoSearchView.frame.origin.x, autoSearchView.frame.origin.y + OFFSET_VALUE, autoSearchView.frame.size.width, searchContentHeight + OFFSET_VALUE)];
        } else {
            [self configureAutoSearchViewHeight];
        }
    }
}

#pragma mark - SearchDelegate Methods

- (void)selectedOrderSet:(DCOrderSet *)orderSet {
    
    selectedOrderSet = orderSet;
    [self validateMedicationsInActiveList:NO];
    if (![orderSet.name isEqualToString:orderSetNameTextView.text] && hasChanges) {
        //display confirmation alert here
        [self displayConfirmationAlertForType:eNewOrderSetSelection];
    } else {
        //selected order set
        DCAddMedicationViewController *addMedicationViewController = (DCAddMedicationViewController *)self.parentViewController;
        //[self getOrderSetWarningsCountForPatientId : addMedicationViewController.patient.patientId andOrderSetId:selectedOrderSet.identifier];
        [autoSearchView setHidden:YES];
        [clearButton setHidden:NO];
        [self showMedicationAndDescriptionViews:YES];
        [orderSetNameTextView resignFirstResponder];
        orderSetNameTextView.text = orderSet.name;
        descriptionTextView.text = orderSet.ordersetDescription;
        [self expandOrderSetNameTextViewForText:orderSetNameTextView.text];
        [addMedicationViewController.operationsArray removeAllObjects];
        [self expandOrderSetDescriptionView];
        _activeMedicationArray = [NSMutableArray arrayWithArray:selectedOrderSet.medicationList];
        inactiveMedicationArray = [NSMutableArray arrayWithArray:@[]];
        [activeMedicationTableView reloadData];
        [inactiveMedicationTableView reloadData];
        [self setStatusLabelsAndTableViewHeightConstraints];
        [self checkAddMedicationCompletionStatusInActiveList];
        previousOrderSetName = orderSet.name;
    }
}

#pragma mark - Keyboard Delegate Methods

- (void)keyboardDidShow:(NSNotification *)notification {
    
    self.keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self configureAutoSearchViewHeight];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    self.keyboardSize = CGSizeZero;
    if ([orderSetNameTextView.text isEqualToString:EMPTY_STRING]) {
        [autoSearchView setHidden:YES];
    }
    [self configureAutoSearchViewHeight];
}


@end
