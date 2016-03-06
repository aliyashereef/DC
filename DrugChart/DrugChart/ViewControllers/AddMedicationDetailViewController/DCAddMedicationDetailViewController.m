//
//  DCAddMedicationDetailViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/3/15.
//
//

#import "DCAddMedicationDetailViewController.h"
#import "DCAddMedicationInitialViewController.h"
#import "DrugChart-Swift.h"

#define DEFAULT_SECTION_COUNT                   1
#define ROW_HEIGHT_OVERRIDE                     78.0f
#define ROW_HEIGHT_DEFAULT                      44.0f

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
}

#pragma mark - Private Methods

- (void)configureViewElements {
    
    //configure view properties
    [self configureNavigationBarItems];
    [self populateContentArray];
    [pickerContentView setHidden:YES];
    [detailTableView setHidden:NO];
}

- (void)configureNavigationBarItems {
    
    [self configureNavigationTitleView];
    [self addNavigationBarButtonItems];
}

- (void)configureNavigationTitleView {
    
    //populate navigation title
    switch (_detailType) {
        case eDetailType:
            self.title = NSLocalizedString(@"TYPE", @"");
            break;
        case eOverrideReason:
            self.title = NSLocalizedString(@"REASON", @"");
            break;
        default:
            break;
    }
}

- (void)addNavigationBarButtonItems {
    
    //navigation bar button items
    if (_detailType == eOverrideReason) {
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
            //for medication type
            _contentArray = [NSMutableArray arrayWithArray:@[REGULAR_MEDICATION, ONCE_MEDICATION, WHEN_REQUIRED_VALUE]];
            break;
        default:
            break;
    }
}

#pragma mark - UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return DEFAULT_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        if (_detailType == eOverrideReason) {
            return 1;
        } else {
            return [_contentArray count];
        }
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_detailType == eOverrideReason) {
        static NSString *cellIdentifier = OVERRIDE_REASON_CELL_ID;
        DCReasonCell *reasonCell = [detailTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (reasonCell == nil) {
            reasonCell = [[DCReasonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        reasonCell.reasonTextView.textColor = doneClicked ? [UIColor redColor] : [UIColor colorForHexString:@"#8f8f95"];
        return reasonCell;
    } else {
        static NSString *cellIdentifier = ADD_MEDICATION_DETAIL_CELL_IDENTIFIER;
        UITableViewCell *cell = [detailTableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        NSString *content = [_contentArray objectAtIndex:indexPath.row];
        cell.textLabel.text = content;
        cell.accessoryType = [content isEqualToString:_previousFilledValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_detailType != eOverrideReason) {
        NSString *valueSelected = [_contentArray objectAtIndex:indexPath.row];
        if (valueSelected != nil) {
            self.selectedEntry (valueSelected);
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([DCAPPDELEGATE windowState] == oneThirdWindow || [DCAPPDELEGATE windowState] == halfWindow) {
        return _detailType == eOverrideReason ? (self.view.frame.size.height-133) : ROW_HEIGHT_DEFAULT;
    } else {
        return _detailType == eOverrideReason ? (self.view.frame.size.height-114) : ROW_HEIGHT_DEFAULT;
    }
}

#pragma mark - Action Methods

- (IBAction)doneButtonPressed:(id)sender {
    
    doneClicked = YES;
    if (_detailType == eOverrideReason) {
        DCReasonCell *reasonCell = (DCReasonCell *)[detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        if (![reasonCell.reasonTextView.text isEqualToString:EMPTY_STRING] && ![reasonCell.reasonTextView.text isEqualToString:REASON]) {
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(overrideReasonSubmitted:)]) {
                    [self.delegate overrideReasonSubmitted:reasonCell.reasonTextView.text];
                }
            }];
        } else {
            [detailTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
