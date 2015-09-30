//
//  DCAddMedicationDetailViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/3/15.
//
//

#import "DCAddMedicationDetailViewController.h"
#import "DCPlistManager.h"
#import "DCAddDosageCell.h"
#import "DCAddMedicationInitialViewController.h"
#import "DrugChart-Swift.h"

#define DEFAULT_SECTION_COUNT                   1
#define DOSAGE_SECTION_COUNT                    2
#define ADMINISTRATION_TIME_SECTION_COUNT       2
#define ROW_HEIGHT_OVERRIDE                     78.0f
#define ROW_HEIGHT_DEFAULT                      44.0f
#define SECTION_HEIGHT_OVERRIDE                 55.0f
#define INITIAL_SECTION_HEIGHT                  0.0f
#define SECTION_HEIGHT                          10.0f

#define NETHERLANDS_LOCALE       @"NL"
#define TIME_KEY                 @"time"
#define SELECTED_KEY             @"selected"

@interface DCAddMedicationDetailViewController () {
    
    __weak IBOutlet UIView *pickerContentView;
    __weak IBOutlet UIDatePicker *timePickerView;
    __weak IBOutlet UITableView *detailTableView;
    
    BOOL doneClicked;
}

@end

@implementation DCAddMedicationDetailViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureViewElements];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)configureViewElements {
    
    detailTableView.layoutMargins = UIEdgeInsetsZero;
    detailTableView.separatorInset = UIEdgeInsetsZero;
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    [self configureNavigationBarItems];
    [self populateContentArray];
    if (_detailType == eNewAdministrationTime) {
        [pickerContentView setHidden:NO];
        [detailTableView setHidden:YES];
        [self configureDatePickerProperties];
    } else {
        [pickerContentView setHidden:YES];
        [detailTableView setHidden:NO];
    }
}

- (void)configureNavigationBarItems {
    
    [self populateNavigationTitle];
    [self addNavigationBarButtonItems];
}

- (void)configureDatePickerProperties {
    
    //configure picker properties
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:NETHERLANDS_LOCALE];
    [timePickerView setLocale:locale];
    timePickerView.datePickerMode = UIDatePickerModeTime;
}

- (void)populateNavigationTitle {
    
    //populate navigation title
    switch (_detailType) {
        case eDetailType:
            self.title = NSLocalizedString(@"MEDICATION_TYPE", @"");
            break;
        case eDetailRoute:
            self.title = NSLocalizedString(@"ROUTES", @"");
            break;
        case eDetailDosage:
            self.title = NSLocalizedString(@"DOSAGE", @"");
            break;
        case eDetailAdministrationTime:
            self.title = NSLocalizedString(@"ADMINISTRATING_TIME", @"");
            break;
        case eNewDosage:
            self.title = NSLocalizedString(@"ADD_DOSAGE", @"");
            break;
        case eOverrideReason:
            self.title = NSLocalizedString(@"REASON", @"");
            break;
        default:
            break;
    }
}

- (void)addNavigationBarButtonItems {
    
    if (_detailType == eNewDosage || _detailType == eDetailAdministrationTime|| _detailType == eNewAdministrationTime || _detailType == eOverrideReason) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:CANCEL_BUTTON_TITLE  style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                       initWithTitle:DONE_BUTTON_TITLE style:UIBarButtonItemStylePlain  target:self action:@selector(doneButtonPressed:)];
        self.navigationItem.rightBarButtonItem = doneButton;
    }
}

- (void)populateContentArray {
    
    switch (_detailType) {
        case eDetailType:
            _contentArray = [NSMutableArray arrayWithArray:@[REGULAR_MEDICATION, ONCE_MEDICATION, WHEN_REQUIRED_VALUE]];
            break;
        case eDetailRoute:
            _contentArray = [NSMutableArray arrayWithArray:[DCPlistManager getMedicationRoutesList]];
            break;
        case eDetailAdministrationTime:
            if ([_contentArray count] == 0) {
                 _contentArray = [NSMutableArray arrayWithArray:[DCPlistManager getAdministratingTimeList]];
            }
            break;
        default:
            break;
    }
}

- (void)presentAddNewDosageView {
    
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCAddMedicationDetailViewController *detailViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_DETAIL_STORYBOARD_ID];
    detailViewController.detailType = eNewDosage;
    detailViewController.newDosage = ^ (NSString *dosage){
        _previousFilledValue = dosage;
        [_contentArray addObject:dosage];
        [detailTableView reloadData];
        if (self.delegate && [self.delegate respondsToSelector:@selector(newDosageAdded:)]) {
            [self.delegate newDosageAdded:dosage];
        }
    };
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:detailViewController];
    navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self.navigationController presentViewController:navigationController animated:YES completion:nil];
}

- (void)displayAdministrationTimePickerView {
    
    //display time view
    UIStoryboard *addMedicationStoryboard = [UIStoryboard storyboardWithName:ADD_MEDICATION_STORYBOARD bundle:nil];
    DCAddMedicationDetailViewController *detailViewController = [addMedicationStoryboard instantiateViewControllerWithIdentifier:ADD_MEDICATION_DETAIL_STORYBOARD_ID];
    detailViewController.detailType = eNewAdministrationTime;
    detailViewController.newTime = ^ (NSDate *time) {
        [self refreshViewWithAddedAdministrationTime:time];
    };
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)refreshViewWithAddedAdministrationTime:(NSDate *)newTime {
    
    NSDictionary *timeDict = @{TIME_KEY : [DCDateUtility getTimeStringInTwentyFourHourFormat:newTime],
                               SELECTED_KEY : @1};
    NSMutableArray *timeArray = [NSMutableArray arrayWithArray:_contentArray];
    BOOL timeAlreadyAdded = NO;
    NSInteger alreadyAddedSlotTag = 0;
    for (NSDictionary *dict in timeArray) {
        if ([dict[TIME_KEY] isEqualToString:timeDict[TIME_KEY]]) {
            timeAlreadyAdded = YES;
            alreadyAddedSlotTag = [timeArray indexOfObject:dict];
            break;
        }
    }
    if (timeAlreadyAdded) {
        [timeArray replaceObjectAtIndex:alreadyAddedSlotTag withObject:timeDict];
    } else {
        [timeArray addObject:timeDict];
    }
    timeArray = [NSMutableArray arrayWithArray:[DCUtility sortArray:timeArray
                                                         basedOnKey:TIME_KEY ascending:YES]];
    _contentArray = [NSMutableArray arrayWithArray:timeArray];
    [detailTableView reloadData];
}

- (void)passAdministrationTimeArrayToAddMedicationinitialView {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatedAdministrationTimeArray:)]) {
        [self.delegate updatedAdministrationTimeArray:_contentArray];
    }
}

#pragma mark - UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (_detailType == eDetailDosage) {
        return DOSAGE_SECTION_COUNT;
    } else if (_detailType == eDetailAdministrationTime) {
        return ADMINISTRATION_TIME_SECTION_COUNT;
    } else {
        return DEFAULT_SECTION_COUNT;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        if (_detailType == eNewDosage || _detailType == eOverrideReason) {
            return 1;
        } else {
            return [_contentArray count];
        }
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_detailType == eNewDosage) {
        static NSString *cellIdentifier =  ADD_DOSAGE_CELL_IDENTIFIER;
        DCAddDosageCell *cell = [detailTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.layoutMargins = UIEdgeInsetsZero;
        if (cell == nil) {
            cell = [[DCAddDosageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.dosageTextField.attributedPlaceholder = [DCUtility getDosagePlaceHolderForValidState:doneClicked];
        return cell;
    } else if (_detailType == eOverrideReason) {
        static NSString *cellIdentifier = OVERRIDE_REASON_CELL_ID;
        DCReasonCell *reasonCell = [detailTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        reasonCell.layoutMargins = UIEdgeInsetsZero;
        if (reasonCell == nil) {
            reasonCell = [[DCReasonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        reasonCell.reasonTextView.textColor = doneClicked ? [UIColor redColor] : [UIColor getColorForHexString:@"#8f8f95"];
        return reasonCell;
    } else {
        static NSString *cellIdentifier = ADD_MEDICATION_DETAIL_CELL_IDENTIFIER;
        UITableViewCell *cell = [detailTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.layoutMargins = UIEdgeInsetsZero;
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        if (indexPath.section == 0) {
            if (_detailType == eDetailAdministrationTime) {
                NSDictionary *contentDict = [_contentArray objectAtIndex:indexPath.row];
                cell.textLabel.text = contentDict[TIME_KEY];
                NSInteger selectedStatus = [contentDict[SELECTED_KEY] integerValue];
                cell.accessoryType = selectedStatus == 1 ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            } else {
                NSString *content = [_contentArray objectAtIndex:indexPath.row];
                cell.textLabel.text = content;
                cell.accessoryType = [content isEqualToString:_previousFilledValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
            }
        } else {
            if (_detailType == eDetailAdministrationTime) {
                cell.textLabel.text = NSLocalizedString(@"ADD_TIME", @"");
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.textLabel.text = NSLocalizedString(@"ADD_DOSAGE", @"");
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
         }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return (_detailType == eOverrideReason ? SECTION_HEIGHT_OVERRIDE : INITIAL_SECTION_HEIGHT);
    } else {
        return SECTION_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (_detailType == eDetailAdministrationTime) {
            NSDictionary *contentDict = [_contentArray objectAtIndex:indexPath.row];
            NSInteger selectedStatus = [contentDict[SELECTED_KEY] integerValue];
            NSString *time = contentDict[TIME_KEY];
            UITableViewCell *cell = [detailTableView cellForRowAtIndexPath:indexPath];
            if (selectedStatus == 1) {
                selectedStatus = 0;
                cell.accessoryType = UITableViewCellAccessoryNone;
            } else {
                selectedStatus = 1;
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            [_contentArray replaceObjectAtIndex:indexPath.row
                                     withObject:@{TIME_KEY : time ,
                                                  SELECTED_KEY : [NSNumber numberWithInteger:selectedStatus]}];
        } else {
            if (_detailType != eOverrideReason) {
                NSString *valueSelected = [_contentArray objectAtIndex:indexPath.row];
                self.selectedEntry (valueSelected);
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    } else {
        if (_detailType == eDetailDosage) {
            [self presentAddNewDosageView];
        } else if (_detailType == eDetailAdministrationTime) {
            [self displayAdministrationTimePickerView];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return (_detailType == eOverrideReason ? ROW_HEIGHT_OVERRIDE : ROW_HEIGHT_DEFAULT);
}

#pragma mark - Action Methods

- (IBAction)doneButtonPressed:(id)sender {
    
    doneClicked = YES;
    if (_detailType == eDetailDosage || _detailType == eNewDosage) {
        DCAddDosageCell *dosageCell = (DCAddDosageCell *)[detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if (![dosageCell.dosageTextField.text isEqualToString:EMPTY_STRING]) {
            [_contentArray addObject:dosageCell.dosageTextField.text];
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                self.newDosage(dosageCell.dosageTextField.text);
            }];
        } else {
            [detailTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    } else {
        if (_detailType == eNewAdministrationTime) {
            [self dismissViewControllerAnimated:YES completion:^{
                self.newTime([DCDateUtility getDateInCurrentTimeZone:timePickerView.date]);
            }];
        } else if (_detailType == eOverrideReason) {
            DCReasonCell *reasonCell = (DCReasonCell *)[detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
            if (![reasonCell.reasonTextView.text isEqualToString:EMPTY_STRING] && ![reasonCell.reasonTextView.text isEqualToString:@"Reason"]) {
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    if (self.delegate && [self.delegate respondsToSelector:@selector(overrideReasonSubmitted:)]) {
                        [self.delegate overrideReasonSubmitted:reasonCell.reasonTextView.text];
                    }
                }];
            } else {
                [detailTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
        } else {
            if (_detailType == eDetailAdministrationTime) {
                [self passAdministrationTimeArrayToAddMedicationinitialView];
        }
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end