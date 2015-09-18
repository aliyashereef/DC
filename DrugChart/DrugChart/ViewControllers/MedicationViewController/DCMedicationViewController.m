    //
//  DCMedicationViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/6/15.
//
//

#import "DCMedicationViewController.h"
#import "DCPatientMedicationHomeViewController.h"
#import "DCMedicationTableViewCell.h"
#import "DCMedicationSlot.h"

typedef enum : NSUInteger {
    kSegmentScheduled,
    kSegmentWhenRequired,
    kSegmentCurrentlyActive
} MenuSegmentSelection;

@interface DCMedicationViewController () <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UISegmentedControl *medicationSegmentationControl;
    IBOutlet UILabel *noMedicationsMessageLabel;
    
    NSMutableArray *medicationListDisplayArray;
    MenuSegmentSelection menuSelection;
    BOOL segmentTapped;
    
    NSMutableArray *onceMedicationArray;
    NSMutableArray *whenrequiredMedicationArray;
    NSMutableArray *regularMedicationArray;
}


@end

@implementation DCMedicationViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        medicationListDisplayArray = [[NSMutableArray alloc] init];
        menuSelection = kSegmentScheduled;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _medicationTableView.rowHeight = UITableViewAutomaticDimension;
    _medicationTableView.estimatedRowHeight = 108.0;
    noMedicationsMessageLabel.hidden = YES;
    [self configureViewElements];
    [self reloadMedicationList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private Methods

- (void)configureViewElements {
    
    NSDictionary *attributes = @{[DCFontUtility getLatoRegularFontWithSize:13.0f]: NSFontAttributeName, [UIColor getColorForHexString:@"#0079c2"]: NSForegroundColorAttributeName};
    [medicationSegmentationControl setTitleTextAttributes:attributes
                                    forState:UIControlStateNormal];
    medicationSegmentationControl.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
}

- (void)sendMedicationListToParent:(DCMedicationScheduleDetails *)medicationList {
    if([self.parentViewController isKindOfClass:[DCPatientMedicationHomeViewController class]]) {
        DCPatientMedicationHomeViewController *patientMedicationHomeViewController = (DCPatientMedicationHomeViewController*)self.parentViewController;
        [patientMedicationHomeViewController setMedicationListForCalendarChart:medicationList];
    }
}

// checks for the regualr, once and when required medications count and return the
// section accordingly.
- (MedicationTableSection)getDisplaySectionForSection:(NSInteger)section {
    
    switch (section) {
        case 0: {
            if ([regularMedicationArray count] > 0) {
                return kSectionRegular;
            }
            else {
                if ([onceMedicationArray count] > 0) {
                    return kSectionOnce;
                }
                else if ([whenrequiredMedicationArray count]>0) {
                    return kSectionWhenInNeed;
                }
            }
        }
        case 1: {
            if ([onceMedicationArray count] > 0) {
                return kSectionOnce;
            }
            else if ([whenrequiredMedicationArray count]>0) {
                return kSectionWhenInNeed;
            }
        }
        case 2: {
            if ([whenrequiredMedicationArray count]>0) {
                return kSectionWhenInNeed;
            }
        }
    }
    return 0;
}


#pragma mark - Public method implementation 


- (void)reloadMedicationList {

    segmentTapped = YES;
    menuSelection = kSegmentScheduled;
    [medicationSegmentationControl setSelectedSegmentIndex:0];
    [self performSelectorInBackground:@selector(loadSelectedMenuSegmentDataInDisplay:) withObject:kSegmentScheduled];
}

- (void) toggleSegmentedControlState :(BOOL) administerViewShown {
    if (medicationSegmentationControl.userInteractionEnabled && administerViewShown) {
        medicationSegmentationControl.userInteractionEnabled = NO;
        //Disabled state segmented control alpha changes.
        [medicationSegmentationControl setTintColor:[UIColor colorWithRed:0.0f/255.0f green:121.0f/255.0f blue:194.0f/255.0f alpha:0.7]];
        
    } else {
        medicationSegmentationControl.userInteractionEnabled = YES;
        [medicationSegmentationControl setTintColor:[UIColor colorWithRed:0.0f/255.0f green:121.0f/255.0f blue:194.0f/255.0f alpha:1]];
    }
}

#pragma mark - Table view delegate methods

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (menuSelection == kSegmentCurrentlyActive) {
        return 40.0f;
    }
    return 0.0f;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view
       forSection:(NSInteger)section{
    
    view.tintColor = [UIColor getColorForHexString:@"#d8e3e5"];
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [DCFontUtility getLatoRegularFontWithSize:17.0];
    [header.textLabel setTextColor:[UIColor getColorForHexString:@"#393d3e"]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //TODO: Implemented for the current display purpose. Optimise the method
    NSArray *arrayOfVisibleCells = [_medicationTableView indexPathsForVisibleRows];
    for (NSIndexPath *indexPath in arrayOfVisibleCells) {
        DCMedicationTableViewCell *selectedMedicationTableViewCell = (DCMedicationTableViewCell *)[_medicationTableView cellForRowAtIndexPath:indexPath];
        [selectedMedicationTableViewCell configureSelectedStateForSelection:NO];
    }

    DCPatientMedicationHomeViewController *patientMedicationHomeViewController = (DCPatientMedicationHomeViewController*)self.parentViewController;
    
    if ( patientMedicationHomeViewController.isAdministerViewPresented && patientMedicationHomeViewController.administerMedicationViewController.hasChanges) {
        
        DCMedicationTableViewCell *medicationTableViewCell = (DCMedicationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        _previousSelectedIndexPath = _selectedIndexPath;
        DCMedicationScheduleDetails *medicationList = medicationTableViewCell.medicationList;
        [self sendMedicationListToParent:medicationList];
        _selectedIndexPath = indexPath;
        
    } else {
        _selectedIndexPath = indexPath;
        DCMedicationTableViewCell *medicationTableViewCell = (DCMedicationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        DCMedicationScheduleDetails *medicationList = medicationTableViewCell.medicationList;
        [medicationTableViewCell configureSelectedStateForSelection:YES];
        [self sendMedicationListToParent:medicationList];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0 && segmentTapped) {
        [cell setSelected:YES animated:NO];
        segmentTapped = NO;
    }
}

#pragma mark - Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (menuSelection == kSegmentCurrentlyActive) {
        NSInteger sections = 0;
        if ([regularMedicationArray count] > 0) {
            ++sections;
        }
        if ([onceMedicationArray count] > 0) {
            ++sections;
        }
        if ([whenrequiredMedicationArray count] > 0) {
            ++sections;
        }
        return sections==0? 1:sections;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    MedicationTableSection tableSection = [self getDisplaySectionForSection:section];
    switch (tableSection) {
        case kSectionRegular: {
            if ([regularMedicationArray count] > 0) {
                return SECTION_HEADER_REGULAR;
            }
            break;
        }
        case kSectionOnce: {
            if ([onceMedicationArray count] > 0) {
                return SECTION_HEADER_ONCE;
            }
            break;
        }
        case kSectionWhenInNeed: {
            if ([whenrequiredMedicationArray count]>0) {
                return SECTION_HEADER_WHEN_REQUIRED;
            }
            break;
        }
    }
    return EMPTY_STRING;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (menuSelection == kSegmentCurrentlyActive) {
        MedicationTableSection tableSection = [self getDisplaySectionForSection:section];
        switch (tableSection) {
            case kSectionRegular: {
                if ([regularMedicationArray count] > 0) {
                    return [regularMedicationArray count];
                }
                break;
            }
            case kSectionOnce: {
                if ([onceMedicationArray count] > 0) {
                    return [onceMedicationArray count];
                }
                break;
            }
            case kSectionWhenInNeed: {
                if ([whenrequiredMedicationArray count] > 0) {
                    return [whenrequiredMedicationArray count];
                }
                break;
            }
        }
    }
    else {
        return [medicationListDisplayArray count];
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    DCMedicationTableViewCell *medicationTableViewCell = [tableView dequeueReusableCellWithIdentifier:MEDICATION_CELL_IDENTIFIER];
    if (medicationTableViewCell == nil) {
        medicationTableViewCell = [[DCMedicationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MEDICATION_CELL_IDENTIFIER];
    }
    DCMedicationScheduleDetails *medicationList = [self getMedicationListForTableCellAtIndexPath:indexPath];
    [medicationTableViewCell configureMedicationCellWithMedicationDetails:medicationList forMenuSelection:menuSelection];
    if (menuSelection == kSegmentScheduled) {
        [medicationTableViewCell.timeLabel setHidden:NO];
    } else {
        [medicationTableViewCell.timeLabel setHidden:YES];
    }
    //TODO: Implemented for the current display purpose. Optimise the method
    if (indexPath.section == _selectedIndexPath.section && indexPath.row == _selectedIndexPath.row) {
        [medicationTableViewCell configureSelectedStateForSelection:YES];
    }
    else {
        [medicationTableViewCell configureSelectedStateForSelection:NO];
    }
    return medicationTableViewCell;
}

#pragma mark - Button action methods

- (IBAction)menuSelectionChanged:(UISegmentedControl *)sender {

    menuSelection = sender.selectedSegmentIndex;
    segmentTapped = YES;
    [self loadSelectedMenuSegmentDataInDisplay:sender.selectedSegmentIndex];
    [self tableView:_medicationTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
}

#pragma mark - Private method implementation

- (void)addLeftSwipeGestureToMedicationAdministerView {
    
    //add left swipe gesture
    UISwipeGestureRecognizer *leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(medicationViewSwipedToLeft:)];
    [leftGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [_medicationTableView addGestureRecognizer:leftGestureRecognizer];
}

- (void)addRightSwipeGestureToMedicationAdministerView {
    
    //add right swipe gesture
    UISwipeGestureRecognizer *rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(medicationViewSwipedToRight:)];
    [rightGestureRecognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_medicationTableView addGestureRecognizer:rightGestureRecognizer];
}

- (void)medicationViewSwipedToLeft:(UIGestureRecognizer *)gesture {
    
    DCDebugLog(@"medication table view swiped to left");
}

- (void)medicationViewSwipedToRight:(UIGestureRecognizer *)gesture {
    
    DCDebugLog(@"medication table view swiped to right");
}

- (void)loadSelectedMenuSegmentDataInDisplay:(NSInteger)selectedSegment {
    
    switch (selectedSegment) {
        case kSegmentScheduled: {
            [self displayRegularMedicationDetails];
        }
            break;
            
        case kSegmentWhenRequired: {
            [self displayWhenRequiredMedicationDetails];
        }
            break;
            
        case kSegmentCurrentlyActive: {
            [self displayCurrentlyActiveMedicationDetails];
        }
            break;
            
        default:
            break;
    }
}

// On selecting the regular medication segment, we need to populate the once+regular medicines
// in the table. And also on selection we also need to refresh the calender with the first
// medication timings.
- (void)displayRegularMedicationDetails {
    
    NSString *predicateString = [NSString stringWithFormat:@"(medicineCategory contains [cd] '%@') OR (medicineCategory contains [cd] '%@')", REGULAR_MEDICATION, ONCE_MEDICATION];
    [self reloadDisplayDataFromFilteredMedicationArrayWithPredicate:predicateString];
}

// On selecting the WhenRequired medication segment, we need to populate the when required medicines
// in the table. And also on selection we also need to refresh the calender with the first
// medication timings.
- (void)displayWhenRequiredMedicationDetails {
    
    NSString *predicateString = [NSString stringWithFormat:@"medicineCategory contains [cd] '%@'", WHEN_REQUIRED];
    [self reloadDisplayDataFromFilteredMedicationArrayWithPredicate:predicateString];
}

// Currently active is  the list actually obtained from the web service response.
// The table display here is segmented.
- (void)displayCurrentlyActiveMedicationDetails {

    medicationListDisplayArray = self.medicationListArray;
    DCPatientMedicationHomeViewController *patientMedicationHomeViewController = (DCPatientMedicationHomeViewController*)self.parentViewController;
    onceMedicationArray = [patientMedicationHomeViewController getAllOnceMedicationList: self.medicationListArray];
    regularMedicationArray = [patientMedicationHomeViewController getAllRegularMedicationList:self.medicationListArray];
    whenrequiredMedicationArray = [patientMedicationHomeViewController getAllWhenRequiredMedicationList:self.medicationListArray];
    [_medicationTableView reloadData];
}

- (void)reloadDisplayDataFromFilteredMedicationArrayWithPredicate:(NSString *)predicateString {
    
    NSPredicate *medicationCategoryPredicate = [NSPredicate predicateWithFormat:predicateString];
    medicationListDisplayArray = (NSMutableArray *)[self.medicationListArray filteredArrayUsingPredicate:medicationCategoryPredicate];

    if ([medicationListDisplayArray count] > 0) {
        //TODO: the sorting has to be modified with comparator. Use the above commented method for that.
        [self sortMedicationListArrayWithRespectToNextMedication:medicationListDisplayArray];
        [self performSelectorOnMainThread:@selector(reloadMedicationTableView) withObject:nil waitUntilDone:NO];
    } else {
        noMedicationsMessageLabel.hidden = NO;
        [_medicationTableView reloadData];
    }
}

- (void)reloadMedicationTableView {
    if ([medicationListDisplayArray count] > 0) {
        
        DCMedicationScheduleDetails *medicationList = [medicationListDisplayArray objectAtIndex:0];
        [self tableView:_medicationTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self performSelectorInBackground:@selector(sendMedicationListToParent:) withObject:medicationList];
        noMedicationsMessageLabel.hidden = YES;
        _medicationTableView.hidden = NO;
        [_medicationTableView reloadData];
    }
}

- (void)checkAndReloadMedicationTableView {
    
    if ([medicationListDisplayArray count] <= 0) {
       
    }
    else {
        [_medicationTableView reloadData];
    }
}

// TODO: duplicate method in patient list screen. Delete this method and
// change the logic.
- (void)sortMedicationListArrayWithRespectToNextMedication:(NSMutableArray *)medicationArray {
    
    //TODO : This method has to be replaced with optimized sorting method.
    @autoreleasepool {
        NSMutableArray *medicationList = [[NSMutableArray alloc] init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:TWENTYFOUR_HOUR_FORMAT];
        NSDate *formattedCurrentDate  = [DCDateUtility getDateInCurrentTimeZone:[NSDate date]];
        
        NSMutableArray *laterDateArray = [[NSMutableArray alloc] init];
        NSMutableArray *earlyDateArray = [[NSMutableArray alloc] init];
        NSComparisonResult comparisonResult;
        
        // compare the time with current time and populate the respectuve arrays.
        for(DCMedicationScheduleDetails *medicationList in medicationArray) {
            
            NSString *medicationTimeString = medicationList.nextMedicationDate;
            NSDate *medicationTime = [DCDateUtility dateFromSourceString:medicationTimeString];
            comparisonResult = [formattedCurrentDate compare:medicationTime];
            
            switch (comparisonResult) {
                case NSOrderedSame:
                case NSOrderedAscending: {
                    [laterDateArray addObject:medicationList];
                }
                    break;
                case NSOrderedDescending: {
                    [earlyDateArray addObject:medicationList];
                }
                    break;
            }
        }
        // sort the arrays in the ascending order and combine the array and return back.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NEXT_MEDICATION_DATE_KEY ascending:YES];
        [laterDateArray sortUsingDescriptors:@[sortDescriptor]];
        [earlyDateArray sortUsingDescriptors:@[sortDescriptor]];
        
        medicationList = laterDateArray;
        [medicationList addObjectsFromArray:earlyDateArray];
        
        if (menuSelection == kSegmentScheduled) {
            //get the medication list in near 6 hours for scheduled cases
            NSArray *filteredArray = [self getMedicationsInSixHoursFromMedicationList:medicationList];
            [medicationList removeAllObjects];
            [medicationList addObjectsFromArray:filteredArray];
        }
        medicationListDisplayArray = [NSMutableArray arrayWithArray:medicationList];
    }
}

- (NSArray *)getMedicationsInSixHoursFromMedicationList:(NSArray *)medicationArray {
    NSDate *currentDate = [DCDateUtility getDateInCurrentTimeZone:[NSDate date]];
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    for (DCMedicationScheduleDetails *schedule in medicationArray) {
        //get medication array in limit
        NSDate *medicationTime = [DCDateUtility dateFromSourceString:schedule.nextMedicationDate];
        NSTimeInterval timeDifference = [medicationTime timeIntervalSinceDate:currentDate];
        if (timeDifference <= MEDICATION_IN_SIX_HOURS) {
            [filteredArray addObject:schedule];
        }
    }
    return filteredArray;
}

- (DCMedicationScheduleDetails *)getMedicationListForTableCellAtIndexPath:(NSIndexPath *)indexPath {
    
    DCMedicationScheduleDetails *medicationList;
    if (menuSelection == kSegmentCurrentlyActive) {
        NSMutableArray *medicationArray = [[NSMutableArray alloc] init];
        MedicationTableSection tableSection = [self getDisplaySectionForSection:indexPath.section];
        switch (tableSection) {
            case kSectionRegular: {
                medicationArray = regularMedicationArray;
                medicationList = [medicationArray objectAtIndex:indexPath.row];
            }
                break;
            case kSectionOnce: {
                medicationArray = onceMedicationArray;
                medicationList = [medicationArray objectAtIndex:indexPath.row];
            }
                break;
            case kSectionWhenInNeed: {
                medicationArray = whenrequiredMedicationArray;
                medicationList = [medicationArray objectAtIndex:indexPath.row];
            }
                break;
        }
    }
    else {
        medicationList = [medicationListDisplayArray objectAtIndex:indexPath.row];
    }
    return medicationList;
}


@end
