//
//  DCCalendarChartViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/6/15.
//
//

#import "DCCalendarChartViewController.h"
#import "DCCalendarViewCell.h"
#import "DCPatientMedicationHomeViewController.h"
#import "DCAdministerMedication.h"
#import "DCMissedMedicationAlertViewController.h"
#import "DCMedicationDetailsViewController.h"
#import "DCMedicinalDetailsBackgroundView.h"
#import "DCPrescriberFilterBackgroundView.h"

static NSString *const DCMedicationDetailsViewController_STORYBOARD_ID = @"DCMedicationDetailsViewController";

@interface DCCalendarChartViewController () <UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate> {
    
    IBOutlet UILabel *weekLabel;
    IBOutlet UILabel *medicineNameLabel;
    IBOutlet UILabel *startDateTitleLabel;
    IBOutlet UILabel *startDateLabel;
    IBOutlet UITableView *medicationChartTableView;
    IBOutlet UIView *headerView;
    IBOutlet NSLayoutConstraint *leftImageViewTrailingConstraint;
    IBOutlet NSLayoutConstraint *rightImageViewLeadingConstraint;
    IBOutlet UITableView *leftTableView;
    IBOutlet UITableView *rightTableView;
    IBOutlet NSLayoutConstraint *leftTableViewWidthConstraint;
    IBOutlet NSLayoutConstraint *rightTableViewWidthConstraint;
    IBOutlet UIButton *todayButton;
    IBOutlet UIButton *previousButton;
    IBOutlet UIButton *nextButton;
    
    IBOutlet UIButton *infoButton;
    NSMutableArray *currentWeekArray;
    NSMutableArray *currentWeekDatesArray;
    NSArray *leftTableViewContentsArray;
    NSArray *rightTableViewContentsArray;
    NSDate *startDateOfWeek;
    NSDate *endDateOfWeek;
    NSIndexPath *selectedIndexPath;
    NSString *initialWeekString;
    BOOL displayWhenRequired;
    BOOL todayButtonPressed;
    BOOL currentWeekDisplayed;
}
@property (nonatomic, strong) DCMedicationScheduleDetails *selectedMedicationList;


@end

@implementation DCCalendarChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewElements];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addNotificationObservers];
     medicationChartTableView.panGestureRecognizer.delaysTouchesBegan = medicationChartTableView.delaysContentTouches;
    [leftTableView setHidden:NO];
    [rightTableView setHidden:NO];
    [infoButton setHidden:YES];
    [weekLabel setTranslatesAutoresizingMaskIntoConstraints:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [leftTableView setHidden:YES];
    [rightTableView setHidden:YES];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Public Methods

- (void)setDisplayMedicationList:(DCMedicationScheduleDetails *)medicationList {
    _selectedMedicationList = medicationList;
    if(!_selectedMedicationList) {
        
        [infoButton setHidden:YES];
    } else {
        
        [infoButton setHidden:NO];
    }
    NSArray *timeArray = [DCUtility sortArray:_selectedMedicationList.timeChart basedOnKey:@"time" ascending:YES];
    _selectedMedicationList.timeChart = [NSMutableArray arrayWithArray:timeArray];
    if (![_selectedMedicationList.medicineCategory isEqualToString:WHEN_REQUIRED]) {
        [startDateLabel setHidden:NO];
        [startDateTitleLabel setHidden:NO];
        NSString *formattedDate = [DCDateUtility dateStringFromSourceString:medicationList.startDate];
        startDateLabel.text = formattedDate;
    } else {
        [startDateLabel setHidden:YES];
        [startDateTitleLabel setHidden:YES];
    }
   
    medicineNameLabel.text = _selectedMedicationList.name;
    dispatch_async(dispatch_get_main_queue(), ^{
        [medicationChartTableView reloadData];
        [leftTableView reloadData];
        [rightTableView reloadData];
    });
}

- (void)updateViewOnAdministerScreenAppear:(BOOL)shown {
    
    //disable previous/next/today button
    [todayButton setUserInteractionEnabled:!shown];
    [nextButton setUserInteractionEnabled:!shown];
    [previousButton setUserInteractionEnabled:!shown];
    if (shown) {
        
        [todayButton setAlpha:0.4];
        [nextButton setAlpha:0.4];
        [previousButton setAlpha:0.4];
    } else {
        
        [todayButton setAlpha:1.0];
        [nextButton setAlpha:1.0];
        [previousButton setAlpha:1.0];
        if (currentWeekDisplayed) {
            [self todayButtonEnable:NO];
        }
    }
}

- (void)configureViewIfmedicationListIsEmpty {
    
    [self updateViewOnAdministerScreenAppear:YES];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    UIView *gestureView = [gestureRecognizer view];
    CGPoint translation = [gestureRecognizer translationInView:[gestureView superview]];
    if (fabs(translation.x) > fabs(translation.y)) {
        return YES;
    }
    return NO;
}


- (NSArray *)getWeeklyMedicationDetailsArrayForTableView:(UITableView *)tableView {
    
    NSArray *medicationArray;
    if (tableView == medicationChartTableView) {
        
        medicationArray = currentWeekDatesArray;
    } else if (tableView == leftTableView) {
        
        NSDate *previousDate = [DCDateUtility getPreviousWeekEndDate:startDateOfWeek];
        medicationArray = [DCDateUtility getDaysOfWeekFromDate:previousDate];
        leftTableViewContentsArray = medicationArray;
    } else {
        
        NSDate *nextDate = [DCDateUtility getNextWeekStartDate:endDateOfWeek];
        medicationArray = [DCDateUtility getDaysOfWeekFromDate:nextDate];
        rightTableViewContentsArray = medicationArray;
    }
    return medicationArray;
}

- (NSArray *)getWeekArrayForTableView:(UITableView *)tableView {
    
    NSMutableArray *datesArray;
    if (tableView == medicationChartTableView) {
        
        datesArray = currentWeekArray;
    } else if (tableView == leftTableView) {
        
        NSDate *previousDate = [DCDateUtility getPreviousWeekEndDate:startDateOfWeek];
        NSArray *dates = [DCDateUtility getDaysOfWeekFromDate:previousDate];
        datesArray = [DCDateUtility getDateDisplayStringForDateArray:dates];
    } else {
        
        NSDate *nextDate = [DCDateUtility getNextWeekStartDate:endDateOfWeek];
        NSArray *dates = [DCDateUtility getDaysOfWeekFromDate:nextDate];
        datesArray = [DCDateUtility getDateDisplayStringForDateArray:dates];
    }
    return datesArray;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [currentWeekArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCCalendarViewCell *calendarViewCell = (DCCalendarViewCell *)[tableView dequeueReusableCellWithIdentifier:CALENDAR_CELL_IDENTIFIER];
    if (calendarViewCell == nil) {
        calendarViewCell = [[DCCalendarViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CALENDAR_CELL_IDENTIFIER];
    }
    
    NSArray *weekDatesArray = [self getWeeklyMedicationDetailsArrayForTableView:tableView];
    
    calendarViewCell.date = [weekDatesArray objectAtIndex:indexPath.row];
    // call back handler for time item clicked in the calender for administration...
    calendarViewCell.calendarHandler = ^ (NSArray *slotArray, NSInteger index, BOOL administerMedicationEditable) {
        selectedIndexPath = indexPath;
        [self manageAdministerMedicationForSlotsArray:slotArray
                                              atIndex:index
                                           ifEditable:administerMedicationEditable];
    };
    // if the data returned from server is not sorted, it has to be done in client side.
    NSArray *timeArray = _selectedMedicationList.timeChart;
    NSArray *weekArray = [self getWeekArrayForTableView:tableView];
    calendarViewCell.dateLabel.text = [weekArray objectAtIndex:indexPath.row];
    NSDate *startDate = [DCDateUtility dateForDateString:_selectedMedicationList.startDate withDateFormat:DATE_FORMAT_RANGE];
    NSDate *endDate = [DCDateUtility dateForDateString:_selectedMedicationList.endDate withDateFormat:DATE_FORMAT_RANGE];
    
    BOOL dateWithInRange = [DCDateUtility isDate:[weekDatesArray objectAtIndex:indexPath.row] inRangeFirstDate:startDate lastDate:endDate];
    NSString *cellDate = [DCDateUtility convertDate:[weekDatesArray objectAtIndex:indexPath.row] FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
    NSString *currentDate = [DCDateUtility convertDate:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]] FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
    if ([cellDate isEqualToString:currentDate]) {
        if ([_selectedMedicationList.medicineCategory isEqualToString:WHEN_REQUIRED]) {
            //displayWhenRequired bool is to display when scheduled calendar cell values
            //only on administer click
            if (displayWhenRequired) {
                dateWithInRange = YES;
            }
            [calendarViewCell.administerButtonContentView setHidden:NO];
        } else {
            [calendarViewCell.administerButtonContentView setHidden:YES];
        }
        calendarViewCell.backgroundColor = [UIColor getColorForHexString:@"#edf7fd"];
    } else {
        if ([_selectedMedicationList.medicineCategory isEqualToString:WHEN_REQUIRED]) {
            dateWithInRange = NO;
        }
        calendarViewCell.backgroundColor = [UIColor whiteColor];
        [calendarViewCell.administerButtonContentView setHidden:YES];
    }
    [calendarViewCell.administerButton addTarget:self
                                          action:@selector(administerMedicationStatus:)
                                forControlEvents:UIControlEventTouchUpInside];
    
    if (dateWithInRange) {
        NSString *predicateString = [NSString stringWithFormat:@"medDate contains[cd] '%@'",cellDate];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        NSArray *slotArray = [timeArray filteredArrayUsingPredicate:predicate];
        if ([slotArray count] > 0) {
            NSDictionary *slotDictionary = [slotArray objectAtIndex:0];
            NSArray *displayMedicationSlotArray = [slotDictionary objectForKey:MED_DETAILS];
            [calendarViewCell displayMedicationTime:displayMedicationSlotArray isWhenRequired:[_selectedMedicationList.medicineCategory isEqualToString:WHEN_REQUIRED]];
        }
    }
   
    return calendarViewCell;
}

#pragma mark - Table view Delegate Implementation

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCCalendarViewCell *calendarCell = (DCCalendarViewCell *) [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return calendarCell.scrollViewHeight.constant;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) {
        //end of loading
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].windows[0] animated:YES];
    }
}

#pragma mark - Action Methods

- (IBAction)previousButtonPressed:(id)sender {
   
    if (!todayButtonPressed) {
        [self updateWeekDetailsForTableView:leftTableView];
    }
    [self animateCalendarViewToRight];
    
}

- (IBAction)nextButtonPressed:(id)sender {
    
    if (!todayButtonPressed) {
        [self updateWeekDetailsForTableView:rightTableView];
    }
    [self animateCalendarViewToLeft];
    
}

- (IBAction)todayButtonTapped:(id)sender {
    
    todayButtonPressed = YES;
   // [self displayCurrentWeekDetailsInCalendar];
    if ([startDateOfWeek compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedDescending) {
        
        NSLog(@"today date in next section");
        [self previousButtonPressed:nil];
    } else {
        
        NSLog(@"today date in previous section");
        [self nextButtonPressed:nil];
    }
}

#pragma mark - Private methods

- (void)configureViewElements {
    //configue view parameters
    headerView.layer.borderColor = [[UIColor getColorForHexString:@"#c9e7f8"] CGColor];
    headerView.layer.borderWidth = 1.0f;
    [self addPanGestures];
    [self displayCurrentWeekDetailsInCalendar];
    UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
    leftTableViewWidthConstraint.constant = mainWindow.frame.size.width - 399.0f;
    rightTableViewWidthConstraint.constant = mainWindow.frame.size.width - 399.0f;
    [self todayButtonEnable:NO];
    initialWeekString = weekLabel.text;
}

- (void)todayButtonEnable:(BOOL)enable {
    
    if (enable) {
        
        currentWeekDisplayed = NO;
        [todayButton setAlpha:1.0];
        [todayButton setUserInteractionEnabled:YES];
    } else {
        
        currentWeekDisplayed = YES;
        [todayButton setAlpha:0.4];
        [todayButton setUserInteractionEnabled:NO];
    }
}

- (void)displayCurrentWeekDetailsInCalendar {
    
    [currentWeekDatesArray removeAllObjects];
    [currentWeekArray removeAllObjects];
    NSDate *initialDisplayDate = [DCDateUtility getInitialDateOfWeekForDisplay:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]];
    currentWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:initialDisplayDate];
    [self configureCalendarView];
}

- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recievedAdministrationReason:)
                                                 name:kEarlyAdministrationNotification
                                               object:nil];
}

- (void)displayPreviousWeekDetails {
    
    NSDate *previousDate = [DCDateUtility getPreviousWeekEndDate:startDateOfWeek];
    [currentWeekDatesArray removeAllObjects];
    [currentWeekArray removeAllObjects];
    currentWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:previousDate];
    [self configureCalendarView];
}

- (void)displayNextWeekDetails {
    
    NSDate *nextDate = [DCDateUtility getNextWeekStartDate:endDateOfWeek];
    [currentWeekDatesArray removeAllObjects];
    [currentWeekArray removeAllObjects];
    currentWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:nextDate];
    currentWeekArray = [DCDateUtility getDateDisplayStringForDateArray:currentWeekDatesArray];
    [self configureCalendarView];
}

- (void)configureCalendarView {
    
    //get the week days for display in calendar view
    [self updateWeekDetailsForTableView:medicationChartTableView];
    [medicationChartTableView reloadData];
    [leftTableView reloadData];
    [rightTableView reloadData];
}

- (void)updateWeekDetailsForTableView:(UITableView *)tableView {
    
    if (tableView == medicationChartTableView) {
        
        startDateOfWeek = [currentWeekDatesArray objectAtIndex:0];
        endDateOfWeek = [currentWeekDatesArray objectAtIndex:6];
        currentWeekArray = [DCDateUtility getDateDisplayStringForDateArray:currentWeekDatesArray];
        weekLabel.text = [DCDateUtility getDisplayStringForStartDate:startDateOfWeek andEndDate:endDateOfWeek];
    } else if (tableView == leftTableView) {
        
        NSDate *startDate = [leftTableViewContentsArray objectAtIndex:0];
        NSDate *endDate = [leftTableViewContentsArray objectAtIndex:6];
        weekLabel.text = [DCDateUtility getDisplayStringForStartDate:startDate andEndDate:endDate];
        [weekLabel updateConstraintsIfNeeded];
    } else {
        
        NSDate *startDate = [rightTableViewContentsArray objectAtIndex:0];
        NSDate *endDate = [rightTableViewContentsArray objectAtIndex:6];
        weekLabel.text = [DCDateUtility getDisplayStringForStartDate:startDate andEndDate:endDate];
        [weekLabel updateConstraintsIfNeeded];
    }
    
    if ([weekLabel.text isEqualToString:initialWeekString]) {
        
        [self todayButtonEnable:NO];
    } else {
        
        [self todayButtonEnable:YES];
    }
}

- (void)addPanGestures {
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(detectPanGestureOnTableView:)];
    [medicationChartTableView addGestureRecognizer:panRecognizer];
    panRecognizer.delegate = self;
}

- (void)detectPanGestureOnTableView:(UIPanGestureRecognizer *) panGestureRecognizer {
    
    CGPoint translation = [panGestureRecognizer translationInView:self.view.superview];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    
    CGRect tableFrame = medicationChartTableView.frame;
    
    if ([panGestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        NSLog(@"touch began");
        leftTableView.frame = CGRectMake(-tableFrame.size.width, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
        rightTableView.frame = CGRectMake(tableFrame.size.width, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
    }
    medicationChartTableView.center = CGPointMake(medicationChartTableView.center.x + translation.x, medicationChartTableView.center.y);
    leftTableView.center = CGPointMake(leftTableView.center.x + translation.x, leftTableView.center.y);
    rightTableView.center = CGPointMake(rightTableView.center.x + translation.x, rightTableView.center.y);
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        NSLog(@"Pan ended");
        if (velocity.x > 0) {
            
            [self animateCalendarViewToRight];
        } else {
            
            [self animateCalendarViewToLeft];
        }
    }
    [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:panGestureRecognizer.view];
}

- (void)animateCalendarViewToLeft {
    
   // [self updateWeekDetailsForTableView:rightTableView];
    CGRect tableFrame = medicationChartTableView.frame;
    
    if (todayButtonPressed) {
        [self displayCurrentWeekDetailsInCalendar];
    } else {
        [self updateWeekDetailsForTableView:rightTableView];
    }
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        rightTableView.frame = CGRectMake(0, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
        medicationChartTableView.frame = CGRectMake(-tableFrame.size.width, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
        leftTableView.frame = CGRectMake(-2 * tableFrame.size.width, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
        if (todayButtonPressed) {
            [self.view sendSubviewToBack:rightTableView];
        }
    } completion:^(BOOL finished) {
        
        if (todayButtonPressed) {
            
            [self displayCurrentWeekDetailsInCalendar];
            todayButtonPressed = NO;
        } else {
            
            [self displayNextWeekDetails];
        }
        medicationChartTableView.frame = CGRectMake(0, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
        [self.view bringSubviewToFront:medicationChartTableView];

        leftTableView.frame = CGRectMake(-tableFrame.size.width, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
        rightTableView.frame = CGRectMake(tableFrame.size.width, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
    }];
}

- (void)animateCalendarViewToRight {
    
    //get the week days for display in calendar view
    //[self updateWeekDetailsForTableView:leftTableView];
   // UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
    CGRect tableFrame = medicationChartTableView.frame;

    if (todayButtonPressed) {
        [self displayCurrentWeekDetailsInCalendar];
    } else {
        [self updateWeekDetailsForTableView:leftTableView];
    }
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
       
        leftTableView.frame = CGRectMake(0, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
        medicationChartTableView.frame = CGRectMake(tableFrame.size.width, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
        rightTableView.frame = CGRectMake(2*tableFrame.size.width, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
        if (todayButtonPressed) {
            [self.view sendSubviewToBack:leftTableView];
        }
    } completion:^(BOOL finished) {
        
        if (todayButtonPressed) {
            
            [self displayCurrentWeekDetailsInCalendar];
            todayButtonPressed = NO;
        } else {
            
            [self displayPreviousWeekDetails];
        }
        medicationChartTableView.frame = CGRectMake(0, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
        [self.view bringSubviewToFront:medicationChartTableView];
        leftTableView.frame = CGRectMake(-tableFrame.size.width, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
        rightTableView.frame = CGRectMake(tableFrame.size.width, tableFrame.origin.y, tableFrame.size.width, tableFrame.size.height);
        

     }];
}


- (void)manageAdministerMedicationForSlotsArray:(NSArray *)slotsArray
                                        atIndex:(NSInteger)index
                                     ifEditable:(BOOL)isEditable {
    
    DCMedicationSlot *medicationSlot = [slotsArray objectAtIndex:index];
    
    if (index != 0) {
        NSInteger previousIndex = index - 1;
        DCMedicationSlot *previousSlot = [slotsArray objectAtIndex:previousIndex];
        NSLog(@"previousSlot.time is %@", previousSlot.time);
        BOOL isFutureDate = (([previousSlot.time compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedDescending) && medicationSlot.medicationAdministration.status);
        if ([previousSlot.status isEqualToString:YET_TO_GIVE] || (isFutureDate && !isEditable)) {
            // show warning that user needs to update the previous medication.
            DCDebugLog(@"the previous slot is not administered");
            [self displayMissedPreviousAdministratonAlert];
        }
        else {
            if (![previousSlot.status isEqualToString:TO_GIVE] && ([medicationSlot.time compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedDescending)) {
                isEditable = YES;
            }
            [self setAdministerMedicationForMedicationSlot:medicationSlot enableAdministerMedication:isEditable];
        }
    }
    else {
        // we need to check for the previous day item.        
        NSString *dateString = [DCDateUtility convertDate:medicationSlot.time FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
        NSString *predicateString = [NSString stringWithFormat:@"medDate contains[cd] '%@'",dateString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        NSArray *slotArray = [_selectedMedicationList.timeChart filteredArrayUsingPredicate:predicate];
        NSInteger slotIndex = [_selectedMedicationList.timeChart indexOfObject:[slotArray objectAtIndex:0]];
        if (slotIndex != 0) {
            NSDictionary *timeChartDictionary = [_selectedMedicationList.timeChart objectAtIndex:slotIndex - 1];
            NSMutableArray *slotArray = [timeChartDictionary objectForKey:MED_DETAILS];
            if ([slotArray count] > 0) {
                DCMedicationSlot *slot = [slotArray objectAtIndex:[slotArray count] - 1];
                NSLog(@"slot.time  IS %@", slot.time );
                BOOL isFutureDate = ([slot.time compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedDescending);
                if ([slot.status isEqualToString:YET_TO_GIVE] || (isFutureDate && !isEditable)) {
                    DCDebugLog(@"the previous day last slot is not administered");
                    [self displayMissedPreviousAdministratonAlert];
                }
                else {
                    if (![slot.status isEqualToString:TO_GIVE] && ([medicationSlot.time compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedDescending)) {
                        isEditable = YES;
                    }
                    [self setAdministerMedicationForMedicationSlot:medicationSlot enableAdministerMedication:isEditable];
                }
            }
        }
        else {
            [self setAdministerMedicationForMedicationSlot:medicationSlot enableAdministerMedication:isEditable];
        }
    }
}

- (NSString *)getMedicineDisplayNameForAdministerScreen {

    return _selectedMedicationList.name;
}

- (void)displayAdministerMedicationViewController:(id)medication {
    
    if([self.parentViewController isKindOfClass:[DCPatientMedicationHomeViewController class]]) {
        DCPatientMedicationHomeViewController *patientMedicationHomeViewController = (DCPatientMedicationHomeViewController*)self.parentViewController;
        [patientMedicationHomeViewController displayAdministerMedicationViewController:medication];
    }
}

- (void)setAdministerMedicationForPastMedicationSlot:(DCMedicationSlot *)medicationSlot {
    
    //past medication details, if medication slot has administerMedication value,
    //then get past medication details from it
    DCAdministerMedication *pastMedication = [[DCAdministerMedication alloc] init];
    if (medicationSlot.administerMedication) {
        pastMedication = medicationSlot.administerMedication;
    } else {
        pastMedication.medicationTime = medicationSlot.time;
        pastMedication.scheduledTime = medicationSlot.time;
        pastMedication.editable = NO;
        pastMedication.dosage = _selectedMedicationList.dosage;
        pastMedication.medicationCategory = _selectedMedicationList.medicineCategory;
        pastMedication.medicationStatus = medicationSlot.status;
        pastMedication.notes = NSLocalizedString(@"ADMINISTER_NOTES", @"administration notes");
        pastMedication.refusedNotes = NSLocalizedString(@"REFUSED_NOTES", @"refused notes");
        pastMedication.omittedNotes = NSLocalizedString(@"OMITTED_NOTES", @"omitted notes");
        pastMedication.omittedReason = NSLocalizedString(@"OMITTED_REASON", @"omitted reason");
        pastMedication.batchNumber = @"105";
        if ([pastMedication.medicationStatus isEqualToString:SELF_ADMINISTERED]) {
            pastMedication.administeredBy = SELF_ADMINISTERED_TITLE;
        }
    }
    pastMedication.instruction = _selectedMedicationList.instruction;
    pastMedication.route = _selectedMedicationList.route;
    pastMedication.medicineName = [self getMedicineDisplayNameForAdministerScreen];
    [self displayAdministerMedicationViewController:pastMedication];
}

- (void)displayMissedPreviousAdministratonAlert {
    //display missed administartion pop up
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD
                                                                   bundle: nil];
    DCMissedMedicationAlertViewController *missedMedicationAlertViewController = [administerStoryboard instantiateViewControllerWithIdentifier:MISSED_ADMINISTER_VIEW_CONTROLLER];
    missedMedicationAlertViewController.dismissView = ^{};
    [missedMedicationAlertViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:missedMedicationAlertViewController animated:YES completion:nil];
}


- (void)setAdministerMedicationForMedicationSlot:(DCMedicationSlot *) medicationSlot
                      enableAdministerMedication:(BOOL)enable {
    
    DCAdministerMedication *administerMedication = [[DCAdministerMedication alloc] init];
    administerMedication.medicationTime = medicationSlot.time;
    administerMedication.scheduledTime = medicationSlot.time;
    administerMedication.scheduleId = _selectedMedicationList.scheduleId;
    administerMedication.medicineName = [self getMedicineDisplayNameForAdministerScreen];
    
    // isFutureDate is checked for setting null values to field entries
    BOOL isFutureDate = (([administerMedication.scheduledTime compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedDescending) && medicationSlot.medicationAdministration.status);
    NSTimeInterval nextMedicationTimeInterval  = [administerMedication.scheduledTime timeIntervalSinceDate:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]];
    administerMedication.route = _selectedMedicationList.route;
    administerMedication.editable = enable;
    administerMedication.instruction = _selectedMedicationList.instruction;
    administerMedication.dosage = _selectedMedicationList.dosage;
    administerMedication.medicationCategory = _selectedMedicationList.medicineCategory;
    administerMedication.medicationStatus = medicationSlot.status;
    if (enable || isFutureDate) {
        administerMedication.administeredBy = EMPTY_STRING;
        administerMedication.checkedBy = EMPTY_STRING;
        administerMedication.notes = EMPTY_STRING;
        administerMedication.refusedNotes = EMPTY_STRING;
        administerMedication.omittedNotes = EMPTY_STRING;
        administerMedication.omittedReason = EMPTY_STRING;
        administerMedication.batchNumber = EMPTY_STRING;
        medicationSlot.administerMedication = administerMedication;
        if (nextMedicationTimeInterval <= ADMINISTER_IN_ONE_HOUR) {
            [self displayAdministerMedicationViewController:administerMedication];
        } else {
            if (enable) {
                //display early administartion warning pop up
                administerMedication.earlyAdministration = YES;
            }
            [self displayAdministerMedicationViewController:administerMedication];
        }
    }
    else {
        [self setAdministerMedicationForPastMedicationSlot:medicationSlot];
    }
}

- (void)getUpdatedAdministerMedicationObject:(DCAdministerMedication *)administerMedication {
    [self updateMedicationSlotForAdministerMedicationFromSelectedMedicationList:administerMedication];
}

- (IBAction)infoButtonPressed:(id)sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    
    DCMedicationDetailsViewController *medicationDetailsViewController = [mainStoryboard instantiateViewControllerWithIdentifier:DCMedicationDetailsViewController_STORYBOARD_ID];
    
    CGSize constrain = CGSizeMake(500, FLT_MAX);
    medicationDetailsViewController.selectedMedicationList = _selectedMedicationList;
    CGRect textRect = [_selectedMedicationList.name   boundingRectWithSize:constrain
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[DCFontUtility getLatoBoldFontWithSize:16.0f]}
                                                           context:nil];
    UIPopoverController *popOverController = [[UIPopoverController alloc] initWithContentViewController:medicationDetailsViewController];
    popOverController.backgroundColor = [UIColor getColorForHexString:@"#b1b1b1"];
    
    CGFloat popOverHeight = textRect.size.height + 70.0f + 10.0f;
    if (textRect.size.height > 35.0f) {
        popOverHeight += 20.0f;
    }
    if ([_selectedMedicationList.medicineCategory isEqualToString:WHEN_REQUIRED]) {
        popOverHeight -= 22.0f;
    }
    popOverController.popoverContentSize = CGSizeMake(500, popOverHeight);
    CGRect popOverRect = CGRectMake(565, -15, 60, 60);
    popOverController.popoverBackgroundViewClass = [DCMedicinalDetailsBackgroundView class];
    [popOverController presentPopoverFromRect:popOverRect
                                       inView:self.view
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
}

- (void)updateMedicationSlotForAdministerMedicationFromSelectedMedicationList:(DCAdministerMedication *)administerMedication  {
    
    if (administerMedication.isNewRequiredMedication) {
        DCMedicationSlot *newMedicationSlot = [[DCMedicationSlot alloc] init];
        newMedicationSlot.time = administerMedication.medicationTime;
        newMedicationSlot.status = administerMedication.medicationStatus;
        newMedicationSlot.administerMedication = administerMedication;
        
        NSString *date = [DCDateUtility convertDate:administerMedication.medicationTime FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
        BOOL medicationDateAlreadyPresent = NO;
        for (NSMutableDictionary *dict in _selectedMedicationList.timeChart) {
            if ([[dict valueForKey:MED_DATE] isEqualToString:date]) {
                NSInteger selectedIndex = [_selectedMedicationList.timeChart indexOfObject:dict];
                NSMutableArray *slotsArray = [NSMutableArray arrayWithArray:[dict valueForKey:MED_DETAILS]];
                [slotsArray addObject:newMedicationSlot];
                NSDictionary *updatedValue = @{MED_DETAILS : slotsArray, MED_DATE : [dict valueForKey:MED_DATE]};
                [_selectedMedicationList.timeChart replaceObjectAtIndex:selectedIndex withObject:updatedValue];
                medicationDateAlreadyPresent = YES;
                break;
            } 
        }
        if (!medicationDateAlreadyPresent) {
            NSDictionary *administerDictionary = @{MED_DATE : [DCDateUtility convertDate:administerMedication.medicationTime FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT], MED_DETAILS : @[newMedicationSlot]};
            [_selectedMedicationList.timeChart insertObject:administerDictionary atIndex:[_selectedMedicationList.timeChart count]];
        }
        //added reload instead of update as height for indexpath to handle error on cell expansion
        [medicationChartTableView reloadData];
    } else {
        //get administer slot from medication list and refresh corresponding table view cell
        for (NSDictionary *slotDictionary in _selectedMedicationList.timeChart) {
            NSMutableArray *slotArray = [slotDictionary objectForKey:MED_DETAILS];
            for (DCMedicationSlot *slot in slotArray) {
                if ([slot.time compare:administerMedication.scheduledTime] == NSOrderedSame) {
                    DCMedicationSlot *updatedMedicationSlot = [[DCMedicationSlot alloc] init];
                    if (administerMedication.medicationTime) {
                        updatedMedicationSlot.time = administerMedication.medicationTime;
                    } else {
                        updatedMedicationSlot.time = [DCDateUtility getDateInCurrentTimeZone:[NSDate date]];
                    }
                    updatedMedicationSlot.status = administerMedication.medicationStatus;
                    updatedMedicationSlot.administerMedication = administerMedication;
                    [slotArray replaceObjectAtIndex:[slotArray indexOfObject:slot] withObject:updatedMedicationSlot];
                    [medicationChartTableView beginUpdates];
                    [medicationChartTableView reloadRowsAtIndexPaths:@[selectedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [medicationChartTableView endUpdates];
                    break;
                }
            }
        }
    }
}

- (BOOL)nextMedicationAttemptedBeforeTwoHours {
    
    //next medication goven before 2 hours
    NSString *currentDate = [DCDateUtility convertDate:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]] FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
    for (NSMutableDictionary *dict in _selectedMedicationList.timeChart) {
        if ([[dict valueForKey:MED_DATE] isEqualToString:currentDate]) {
            NSMutableArray *slotsArray = [NSMutableArray arrayWithArray:[dict valueForKey:MED_DETAILS]];
            NSTimeInterval nextMedicationTimeInterval;
            if ([slotsArray count] > 0) {
                DCMedicationSlot *lastMedicationSlot = (DCMedicationSlot *)[slotsArray lastObject];
                nextMedicationTimeInterval  = [lastMedicationSlot.time timeIntervalSinceDate:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]];
                BOOL withInScheduledTime = NO;
                if (nextMedicationTimeInterval < 2*ADMINISTER_IN_ONE_HOUR) {
                    withInScheduledTime = YES;
                }
                return withInScheduledTime;
            }
            break;
        }
    }
    return NO;
}


- (NSIndexPath *)getIndexpathFromSelectedAdministerButton:(UIButton *) selectedButton {

    //get indexpath of table view cell from the administer button position
    CGPoint viewCenterRelativeToTableview = [medicationChartTableView convertPoint:CGPointMake(CGRectGetMidX(selectedButton.bounds), CGRectGetMidY(selectedButton.bounds)) fromView:selectedButton];
    NSIndexPath *cellIndexPath = [medicationChartTableView indexPathForRowAtPoint:viewCenterRelativeToTableview];
    return cellIndexPath;
}

#pragma mark - Button actions
- (IBAction)administerMedicationStatus:(UIButton *)sender {
    
    displayWhenRequired = YES;
    selectedIndexPath = [self getIndexpathFromSelectedAdministerButton:sender];
    DCAdministerMedication *administerMedication = [[DCAdministerMedication alloc] init];
    administerMedication.medicineName = [self getMedicineDisplayNameForAdministerScreen];
    administerMedication.route = _selectedMedicationList.route;
    administerMedication.editable = YES;
    administerMedication.instruction = _selectedMedicationList.instruction;
    administerMedication.medicationCategory = _selectedMedicationList.medicineCategory;
    administerMedication.dosage = _selectedMedicationList.dosage;
    administerMedication.isNewRequiredMedication = YES;
    if ([self nextMedicationAttemptedBeforeTwoHours]) {
        
        administerMedication.earlyAdministration = YES;
    } else {
        
       displayWhenRequired = YES;
    }
    [self displayAdministerMedicationViewController:administerMedication];
}

#pragma mark - Notification Methods

- (void)recievedAdministrationReason:(NSNotification *)notification {
    
    //recieved reason for early administration and present administer view
    NSDictionary *notificationInfo = notification.userInfo;
    NSString *administrationReason = [notificationInfo valueForKey:@"reason"];
    DCMedicationSlot *selectedMedicationSlot = [notificationInfo valueForKey:@"medicationSlot"];
    DCAdministerMedication *administerMedication = [[DCAdministerMedication alloc] init];
    administerMedication.medicationTime = selectedMedicationSlot.time;
    administerMedication.scheduledTime = selectedMedicationSlot.time;
    administerMedication.medicineName = [self getMedicineDisplayNameForAdministerScreen];
    administerMedication.route = _selectedMedicationList.route;
    administerMedication.editable = YES;
    administerMedication.instruction = _selectedMedicationList.instruction;
    administerMedication.dosage = _selectedMedicationList.dosage;
    administerMedication.medicationCategory = _selectedMedicationList.medicineCategory;
    administerMedication.medicationStatus = IS_GIVEN;
    administerMedication.notes = administrationReason;
    administerMedication.omittedNotes = administrationReason;
    administerMedication.refusedNotes = administrationReason;
    administerMedication.batchNumber = EMPTY_STRING;
    administerMedication.earlyAdministration = YES;
    if (!selectedMedicationSlot) {
        administerMedication.isNewRequiredMedication = YES;
    }
    [self displayAdministerMedicationViewController:administerMedication];
}

@end
