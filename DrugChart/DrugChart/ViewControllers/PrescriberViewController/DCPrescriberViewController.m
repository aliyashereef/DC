//
//  DCPrescriberViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/24/15.
//
//

#import "DCPrescriberViewController.h"
#import "DCPrescriberMedicationCell.h"
#import "DCPrescriberFilterTableViewController.h"
#import "DCWeekView.h"
#import "DCPrescriberFilterBackgroundView.h"
#import "DCMedicationListWebService.h"
#import "DCMissedMedicationAlertViewController.h"
#import "DCPatientMedicationHomeViewController.h"
#import "DCPrescriberDetailsViewController.h"
#import "DCPrescriberTimeView.h"
#import "DCPrescriberMedicationSlotDisplayView.h"
#import "DCStopMedicationWebService.h"
#import "DrugChart-Swift.h"

#define PRESCRIBER_MEDICATION_CELL_IDENTIFIER @"PrescriberMedicationCellIdentifier"
#define PRESCRIBER_CALENDAR_CELL_IDENTIFIER  @"PrescriberCalendarCellIdentifier"

#define SORT_KEY_MEDICINE_NAME @"name"
#define SORT_KEY_MEDICINE_START_DATE @"startDate"

#define WEEK_VIEW_WIDTH     105.0
#define WEEK_VIEW_HEIGHT    35.0

#define SECTION_HEADER_HEIGHT   24.0f

#define TODAY_CALENDAR_COLOR [UIColor colorWithRed:13.0/255.0 green:119.0/255.0  blue:200.0/255.0  alpha:1.0]

#define DAYS_0F_WEEK 7

typedef enum : NSUInteger {
    prescriberCellsLeft,
    prescriberCellsCenter,
    prescriberCellsRight
} PrescriberCellsPosition;

typedef enum : NSUInteger {
    calendarPreviousWeek,
    calendarThisWeek,
    calendarNextWeek
} CalendarType;

typedef enum : NSUInteger {
    kSortDrugType,
    kSortDrugStartDate,
    kSortDrugName
} SortType;

@interface DCPrescriberViewController () <UIGestureRecognizerDelegate, DCPrescriberCellDelegate, UIGestureRecognizerDelegate, DCPrescriberFilterTableViewControllerDelegate> {
    
    IBOutlet UILabel *weekLabel;
    IBOutlet UIView *weekContainerView;
    IBOutlet UIView *rightWeekContainerView;
    IBOutlet UITableView *prescriberTableView;
    IBOutlet UIView *leftWeekContainerView;
    IBOutlet UILabel *filterTextLabel;
    IBOutlet UIButton *todayButton;
    IBOutlet UIButton *includeDiscontinuedButton;
    IBOutlet UIButton *previousButton;
    IBOutlet UIButton *nextButton;
    IBOutlet UILabel *noMedicationsMessageLabel;

    
    NSMutableArray *displayMedicationListArray;
    NSMutableArray *onceMedicationArray;
    NSMutableArray *whenrequiredMedicationArray;
    NSMutableArray *regularMedicationArray;
    
    NSDate *calendarDisplayStartDate;
    NSDate *calendarDisplayEndDate;
    NSMutableArray *calendarDisplayWeekArray;
    NSMutableArray *calendarLeftWeekArray;
    NSMutableArray *calendarRightWeekArray;
    
    NSMutableArray *currentWeekDatesArray;
    NSMutableArray *nextWeekDatesArray;
    NSMutableArray *previousWeekDatesArray;
    
    NSMutableArray *indexPathArray;
    SortType sortType;
    BOOL todayAction;
    BOOL thisWeekInLeftContainer;
}
@end

@implementation DCPrescriberViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureViewElements];
    [[NSUserDefaults standardUserDefaults] setObject:DRUG_TYPE forKey:kSortType];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    prescriberTableView.panGestureRecognizer.delaysTouchesBegan = prescriberTableView.delaysContentTouches;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [leftWeekContainerView setHidden:YES];
    [rightWeekContainerView setHidden:YES];
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].windows[0] animated:YES];
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
    [leftWeekContainerView setHidden:NO];
    [rightWeekContainerView setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)addPanGestures {
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveMedicationCalendarDisplayForPanGesture:)];
    [prescriberTableView addGestureRecognizer:panRecognizer];
    panRecognizer.delegate = self;
}

- (void) moveMedicationCalendarDisplayForPanGesture:(UIPanGestureRecognizer *) panGestureRecognizer {
    
    UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
    CGPoint translation = [panGestureRecognizer translationInView:self.view.superview];
    CGPoint velocity = [panGestureRecognizer velocityInView:self.view];
    [weekLabel setTranslatesAutoresizingMaskIntoConstraints:YES];
    if ([panGestureRecognizer state] == UIGestureRecognizerStateBegan) {
       
        indexPathArray = (NSMutableArray *)[prescriberTableView indexPathsForVisibleRows];
        [self positionWeekContainersInView];
    }
    if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
    [self translateWeekContainerViewsForTranslation:translation];
    for (NSInteger count = 0; count < [indexPathArray count]; count++) {
        
        NSIndexPath *indexPath = [indexPathArray objectAtIndex:count];
        DCPrescriberMedicationCell *meditationCell = (DCPrescriberMedicationCell *)[prescriberTableView cellForRowAtIndexPath:indexPath];
        meditationCell.rightCalendarTralilingConstraint.constant = meditationCell.rightCalendarTralilingConstraint.constant - translation.x;
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            if (velocity.x > 0) {
                // animate to left. show previous week
                if ((meditationCell.calendarView.frame.origin.x < mainWindow.frame.size.width/4) /*&& timeCounter > 0*/) {
                    //maintain cureent week view
                    [self animateMedicationCellToOriginalPosition:meditationCell];
                    
                } else {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self configureDisplayDatesForNextWeekSelection:NO];
                        if (count == [indexPathArray count] - 1) {
                            [self animateToDisplayPreviousWeek:meditationCell isLastCell:YES];
                            [self animateWeekContainerViewToLeft];
                        }
                        else {
                            [self animateToDisplayPreviousWeek:meditationCell isLastCell:NO];
                        }
                    });
                }
              }
            else {
                
                if ((meditationCell.calendarView.frame.origin.x > mainWindow.frame.size.width/4) /*&& timeCounter > 0*/) {
                    //maintain current week view
                    [self animateMedicationCellToOriginalPosition:meditationCell];
                    
                } else {
                    
                    // animate to left. show previous week
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self configureDisplayDatesForNextWeekSelection:YES];
                        if (count == [indexPathArray count] - 1) {
                            [self animateToDisplayNextWeek:meditationCell isLastCell:YES];
                            //here..
                            [self animateWeekContainerViewToRight];
                        }
                        else {
                            [self animateToDisplayNextWeek:meditationCell isLastCell:NO];
                        }
                    });
                }
            }
        }
    }
    [panGestureRecognizer setTranslation:CGPointMake(0, 0) inView:panGestureRecognizer.view];
}

// method sets and resets the frames of the weekContainerViews as in the beginning.
- (void)positionWeekContainersInView {
    
    leftWeekContainerView.frame = CGRectMake(-734.0 , weekContainerView.foy, leftWeekContainerView.fsw, weekContainerView.fsh);
    weekContainerView.frame = CGRectMake(0, weekContainerView.foy, weekContainerView.fsw, weekContainerView.fsh);
    rightWeekContainerView.frame = CGRectMake(weekContainerView.fsw, weekContainerView.foy, rightWeekContainerView.fsw, weekContainerView.fsh);
}

// method translates the container views depending on the translation of the pan gesture
// translation.
- (void)translateWeekContainerViewsForTranslation:(CGPoint)translation {
    
    weekContainerView.center = CGPointMake(weekContainerView.center.x + translation.x, weekContainerView.center.y);
    leftWeekContainerView.center = CGPointMake(leftWeekContainerView.center.x + translation.x, leftWeekContainerView.center.y);
    rightWeekContainerView.center = CGPointMake(rightWeekContainerView.center.x + translation.x, rightWeekContainerView.center.y);
}

// animates the medication cells to the right, to display the previous week details.
- (void)animateToDisplayPreviousWeek:(DCPrescriberMedicationCell *)meditationCell
                          isLastCell:(BOOL)isLastCell {
    // get the cells on the left and display previous week data in it.
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.4 animations:^{
        meditationCell.rightCalendarTralilingConstraint.constant = -1464;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (isLastCell) {
            [self displayPreviousWeekDetails];
        }
    }];
}

- (void)animateToDisplayNextWeek:(DCPrescriberMedicationCell *)meditationCell
                      isLastCell:(BOOL)isLastCell{
    // get the cells on the right and display the next week data in it. Once it is completed
    // reload the table.
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.4 animations:^{
        
        //To Do : Temporary fix for the calender swipe issue
        NSIndexPath *indexPath = [indexPathArray objectAtIndex:0];
        DCPrescriberMedicationCell *firstMeditationCell = (DCPrescriberMedicationCell *)[prescriberTableView cellForRowAtIndexPath:indexPath];
        if (firstMeditationCell.rightCalendarTralilingConstraint.constant != 0) {
            
            firstMeditationCell.rightCalendarTralilingConstraint.constant = 0;
        }
           
        meditationCell.rightCalendarTralilingConstraint.constant = 0;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        if (isLastCell) {
            [self displayNextWeekDetails];
        }
        
    }];
}

- (void)animateMedicationCellToOriginalPosition:(DCPrescriberMedicationCell *)meditationCell {
    
    [UIView animateWithDuration:0.4 animations:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        [self animateWeekContainerViewToOriginalPosition];
        meditationCell.rightCalendarTralilingConstraint.constant = -732;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
    }];
}

- (void)animateWeekContainerViewToLeft {
    
    [UIView animateWithDuration:0.4 animations:^{
        leftWeekContainerView.frame = CGRectMake(0, weekContainerView.foy, weekContainerView.fsw, weekContainerView.fsh);
        weekContainerView.frame = CGRectMake(weekContainerView.fsw, weekContainerView.foy, weekContainerView.fsw, weekContainerView.fsh);
        rightWeekContainerView.frame = CGRectMake(2 *weekContainerView.fsw, weekContainerView.foy, weekContainerView.fsw, weekContainerView.fsh);
        
    } completion:^(BOOL finished) {
        [self positionWeekContainersInView];
    }];
}

- (void)animateWeekContainerViewToRight {
    
    [UIView animateWithDuration:0.4 animations:^{
        leftWeekContainerView.frame = CGRectMake(-2 * weekContainerView.fsw, weekContainerView.foy, weekContainerView.fsw, weekContainerView.fsh);
        weekContainerView.frame = CGRectMake(-weekContainerView.fsw, weekContainerView.foy, weekContainerView.fsw, weekContainerView.fsh);
        rightWeekContainerView.frame = CGRectMake(0, weekContainerView.foy, weekContainerView.fsw, weekContainerView.fsh);
        
    } completion:^(BOOL finished) {
        [self positionWeekContainersInView];
    }];
}

- (void)animateWeekContainerViewToOriginalPosition {
    
    leftWeekContainerView.frame = CGRectMake(-734.0, weekContainerView.foy, leftWeekContainerView.fsw, weekContainerView.fsh);
    weekContainerView.frame = CGRectMake(0, weekContainerView.foy, weekContainerView.fsw, weekContainerView.fsh);
    rightWeekContainerView.frame = CGRectMake(weekContainerView.fsw, weekContainerView.foy, rightWeekContainerView.fsw, weekContainerView.fsh);
}

- (void)animateToDisplayCurrentWeek {
    
    BOOL leftTranslation;
    //check for today date location animate views accordingly
    if ([calendarDisplayStartDate compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedDescending) {
        leftTranslation = YES;
        thisWeekInLeftContainer = YES;
    } else {
        leftTranslation = NO;
        thisWeekInLeftContainer = NO;
    }
     [prescriberTableView reloadData];
}

- (void)loadThisWeekDetailsOnTableViewReloadCompletion {
    
    NSDate *initialDisplayDate = [DCDateUtility getInitialDateOfWeekForDisplay:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]];
    NSMutableArray *thisWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:initialDisplayDate];
    NSDate *displayStartDate = [thisWeekDatesArray objectAtIndex:0];
    NSDate *displayEndDate = [thisWeekDatesArray objectAtIndex:6];
    NSMutableArray *displayWeekArray = [DCDateUtility getDateDisplayStringForDateArray:thisWeekDatesArray];
    weekLabel.text = [DCDateUtility getDisplayStringForStartDate:displayStartDate andEndDate:displayEndDate];    
    if (thisWeekInLeftContainer) {
        [self loadWeekContainerView:leftWeekContainerView withWeekDisplayArray:displayWeekArray withWeekDaysArray:thisWeekDatesArray];
        [self performSelector:@selector(animateWeekContainerViewToLeft) withObject:nil afterDelay:0.2];
    } else {
        [self loadWeekContainerView:rightWeekContainerView withWeekDisplayArray:displayWeekArray withWeekDaysArray:thisWeekDatesArray];
        [self performSelector:@selector(animateWeekContainerViewToRight) withObject:nil afterDelay:0.2];
    }
    
    NSNumber *leftTranslationValue =[NSNumber numberWithBool:thisWeekInLeftContainer];
    [self performSelector:@selector(displayThisWeekMedicalSlotsForLeftTranslation:) withObject:leftTranslationValue afterDelay:0.2];
}

- (void)displayThisWeekMedicalSlotsForLeftTranslation:(NSNumber *)leftTranslationValue {
    
    BOOL leftTranslation = [leftTranslationValue boolValue];
    __block CGFloat animationConstant = 0.0;
    if (leftTranslation) {
        animationConstant = -1464.0;
    }
    for (NSInteger count = 0; count < [indexPathArray count]; count++) {
        
        NSIndexPath *indexPath = [indexPathArray objectAtIndex:count];
        DCPrescriberMedicationCell *meditationCell = (DCPrescriberMedicationCell *)[prescriberTableView cellForRowAtIndexPath:indexPath];
        [UIView animateWithDuration:0.4 animations:^{
            meditationCell.rightCalendarTralilingConstraint.constant = animationConstant;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
            if (count == [indexPathArray count] - 1) {
                [self displayCurrentWeekDetails];
                todayAction = NO;
                thisWeekInLeftContainer = NO;
            }
        }];
    }
}

- (void)configureViewElements {
    
    //display current week's medication data
    NSDate *initialDisplayDate = [DCDateUtility getInitialDateOfWeekForDisplay:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]];
    currentWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:initialDisplayDate];
    [self populateMedicationWeekDaysForDisplayInCalendar];
    [self configureDisplayOfWeekDatesInCalendar];
    // add pan gesture to view.
    [self addPanGestures];
    _discontinuedMedicationShown = NO;
    [self todayButtonEnable:NO];
    [includeDiscontinuedButton setSelected:NO];
    //[self includeDiscontinuedButtonPressed:nil];
}

- (void)todayButtonEnable:(BOOL)enable {
    
    if (enable) {
        [todayButton setAlpha:1.0];
        [todayButton setUserInteractionEnabled:YES];
    } else {
        [todayButton setAlpha:0.4];
        [todayButton setUserInteractionEnabled:NO];
    }
}

- (void)configurePreviousAndNextButtons {
    
    //previous/next buttons enable/disable
    if ([displayMedicationListArray count] > 0) {
        [previousButton setAlpha:1.0];
        [previousButton setUserInteractionEnabled:YES];
        [nextButton setAlpha:1.0];
        [nextButton setUserInteractionEnabled:YES];
    } else {
        [previousButton setAlpha:0.4];
        [previousButton setUserInteractionEnabled:NO];
        [nextButton setAlpha:0.4];
        [nextButton setUserInteractionEnabled:NO];
    }
}

- (void)populateMedicationWeekDaysForDisplayInCalendar {
    //add week days top view
    CGFloat xValue = 0;
    for (int count = 0; count < DAYS_0F_WEEK; count ++) {
        DCWeekView *weekView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCWeekView class])
                                                              owner:self
                                                            options:nil] objectAtIndex:0];
        //        weekView.tag = count;
        [weekView setTranslatesAutoresizingMaskIntoConstraints:YES];
        [weekView setFrame:CGRectMake(xValue , 0, WEEK_VIEW_WIDTH, WEEK_VIEW_HEIGHT)];
        weekView.dayLabel.text = [calendarDisplayWeekArray objectAtIndex:count];
        
        DCWeekView *leftWeekView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCWeekView class])
                                                                  owner:self
                                                                options:nil] objectAtIndex:0];
        [leftWeekView setTranslatesAutoresizingMaskIntoConstraints:YES];
        [leftWeekView setFrame:CGRectMake(xValue , 0, WEEK_VIEW_WIDTH, WEEK_VIEW_HEIGHT)];
        leftWeekView.dayLabel.text = [calendarLeftWeekArray objectAtIndex:count];
        
        DCWeekView *rightWeekView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCWeekView class])
                                                                   owner:self
                                                                 options:nil] objectAtIndex:0];
        [rightWeekView setTranslatesAutoresizingMaskIntoConstraints:YES];
        [rightWeekView setFrame:CGRectMake(xValue , 0, WEEK_VIEW_WIDTH, WEEK_VIEW_HEIGHT)];
        rightWeekView.dayLabel.text = [calendarRightWeekArray objectAtIndex:count];
        
        
        [weekContainerView addSubview:weekView];
        [leftWeekContainerView addSubview:leftWeekView];
        [rightWeekContainerView addSubview:rightWeekView];
        xValue += WEEK_VIEW_WIDTH;
    }
}

- (void)loadWeekContainerView:(UIView *)containerView
         withWeekDisplayArray:(NSMutableArray *)displayArray
            withWeekDaysArray:(NSMutableArray *)actualWeeksArray {
    
    BOOL currentWeek = NO;
    NSString *todayDate = [DCDateUtility convertDate:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]] FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
    for (DCWeekView *weekView in containerView.subviews) {
        @try {
            NSString *calendarWeekDate = [DCDateUtility convertDate:(NSDate*)[actualWeeksArray objectAtIndex:[containerView.subviews indexOfObject:weekView]] FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
           
            if ([todayDate isEqualToString:calendarWeekDate]) {
                
                weekView.backgroundView.backgroundColor = NAVIGATION_BAR_COLOR;
                weekView.dayLabel.textColor = [UIColor whiteColor];
                currentWeek = YES;
            } else {
                weekView.backgroundView.backgroundColor = [UIColor getColorForHexString:@"#ddeff9"];
                weekView.dayLabel.textColor = [UIColor getColorForHexString:@"#314856"];
            }
            weekView.dayLabel.text = [displayArray objectAtIndex:[containerView.subviews indexOfObject:weekView]];
        }
        @catch (NSException *exception) {
            DCDebugLog(@"Issue in calendar week day display in prescriber: %@",exception.description);
        }
    }
    if (containerView == weekContainerView) {
        if (currentWeek) {
            [self todayButtonEnable:NO];
        } else {
            [self todayButtonEnable:YES];
        }
    }
}

- (void)configureDisplayOfWeekDatesInCalendar {
    
    //get the week days for display in calendar view
    calendarDisplayStartDate = [currentWeekDatesArray objectAtIndex:0];
    calendarDisplayEndDate = [currentWeekDatesArray objectAtIndex:6];
    calendarDisplayWeekArray = [DCDateUtility getDateDisplayStringForDateArray:currentWeekDatesArray];
    weekLabel.text = [DCDateUtility getDisplayStringForStartDate:calendarDisplayStartDate andEndDate:calendarDisplayEndDate];
    
    [self loadWeekContainerView:weekContainerView withWeekDisplayArray:calendarDisplayWeekArray withWeekDaysArray:currentWeekDatesArray];
    
    NSDate *previousWeekEndDate = [DCDateUtility getPreviousWeekEndDate:calendarDisplayStartDate];
    NSDate *nextDate = [DCDateUtility getNextWeekStartDate:calendarDisplayEndDate];
    nextWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:nextDate];
    previousWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:previousWeekEndDate];
    
    calendarLeftWeekArray = [DCDateUtility getDateDisplayStringForDateArray:previousWeekDatesArray];
    calendarRightWeekArray = [DCDateUtility getDateDisplayStringForDateArray:nextWeekDatesArray];
    
    [self loadWeekContainerView:rightWeekContainerView withWeekDisplayArray:calendarRightWeekArray withWeekDaysArray:nextWeekDatesArray];
    [self loadWeekContainerView:leftWeekContainerView withWeekDisplayArray:calendarLeftWeekArray withWeekDaysArray:previousWeekDatesArray];
    
    [prescriberTableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void)checkAndReloadPrescriberTableViewWithLoadingCompletion:(BOOL)isCompleted {
    
    if ([displayMedicationListArray count] <= 0) {
        prescriberTableView.hidden = YES;
        if (isCompleted) {
            noMedicationsMessageLabel.hidden = NO;
        } else {
            noMedicationsMessageLabel.hidden = YES;
        }
    }
    else {
        prescriberTableView.hidden = NO;
        noMedicationsMessageLabel.hidden = YES;
        [prescriberTableView reloadData];
    }
}

- (void)configureDisplayDatesForNextWeekSelection:(BOOL)nextWeekSelected {
    
    NSDate *previousWeekStartDate = [DCDateUtility getPreviousWeekEndDate:calendarDisplayStartDate];
    NSDate *nextDate = [DCDateUtility getNextWeekStartDate:calendarDisplayEndDate];
    if (nextWeekSelected) {
        currentWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:nextDate];
    }
    else {
        currentWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:previousWeekStartDate];
    }
    NSDate *startDate = [currentWeekDatesArray objectAtIndex:0];
    NSDate *endDate = [currentWeekDatesArray objectAtIndex:6];
    weekLabel.text = [DCDateUtility getDisplayStringForStartDate:startDate andEndDate:endDate];
    [weekLabel updateConstraintsIfNeeded];
}

- (NSMutableArray *)medicationSlotsWithViewTags:(DCMedicationScheduleDetails *)medicationList
                                        forCell:(DCPrescriberMedicationCell *)medicationCell {
    
    currentWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:calendarDisplayStartDate];
    NSMutableArray *displayMedicationSlotsArray = [[NSMutableArray alloc] init];
    NSInteger count = 0, weekDays = 7;
    while (count < weekDays) {
        
        NSMutableDictionary *slotsDictionary = [[NSMutableDictionary alloc] init];
        if (count <[currentWeekDatesArray count] ) {
            NSString *formattedDateString = [DCDateUtility convertDate:[currentWeekDatesArray objectAtIndex:count] FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
            NSString *predicateString = [NSString stringWithFormat:@"medDate contains[cd] '%@'",formattedDateString];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
            NSArray *slotsDetailsArray = [medicationList.timeChart filteredArrayUsingPredicate:predicate];
            if ([slotsDetailsArray count] > 0) {
                NSMutableArray *medicationSlotArray = [[slotsDetailsArray objectAtIndex:0] valueForKey:MED_DETAILS];
                [slotsDictionary setObject:medicationSlotArray forKey:PRESCRIBER_TIME_SLOTS];
            }
        }
        [slotsDictionary setObject:[NSNumber numberWithInteger:count+1] forKey:PRESCRIBER_SLOT_VIEW_TAG];
        [displayMedicationSlotsArray addObject:slotsDictionary];
        count++;
    }
    return displayMedicationSlotsArray;
}

- (NSMutableArray *)medicationSlotsWithViewTagsforCurrentWeek:(DCMedicationScheduleDetails *)medicationList
                                              leftTranslation:(BOOL)leftTranslation {
    
    NSDate *initialDisplayDate = [DCDateUtility getInitialDateOfWeekForDisplay:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]];
    currentWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:initialDisplayDate];
    NSInteger tagAdder = 0;
    tagAdder = leftTranslation ? 200 : 300;
    NSMutableArray *displayMedicationSlotsArray = [[NSMutableArray alloc] init];
    for (NSInteger count = 0; count < [currentWeekDatesArray count]; count++) {
        
        NSMutableDictionary *slotsDictionary = [[NSMutableDictionary alloc] init];
        NSString *formattedDateString = [DCDateUtility convertDate:[currentWeekDatesArray objectAtIndex:count] FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
        NSString *predicateString = [NSString stringWithFormat:@"medDate contains[cd] '%@'",formattedDateString];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString];
        NSArray *slotsDetailsArray = [medicationList.timeChart filteredArrayUsingPredicate:predicate];
        if ([slotsDetailsArray count] > 0) {
            NSMutableArray *medicationSlotArray = [[slotsDetailsArray objectAtIndex:0] valueForKey:MED_DETAILS];
            [slotsDictionary setObject:[NSNumber numberWithInteger:tagAdder+count+1] forKey:PRESCRIBER_SLOT_VIEW_TAG];
            [slotsDictionary setObject:medicationSlotArray forKey:PRESCRIBER_TIME_SLOTS];
            [displayMedicationSlotsArray addObject:slotsDictionary];
        }
    }
    if ([displayMedicationSlotsArray count] > 0) {
        return displayMedicationSlotsArray;
    }
    return nil;
}

- (DCMedicationScheduleDetails *)getMedicationListForTableCellAtIndexPath:(NSIndexPath *)indexPath {
    
    DCMedicationScheduleDetails *medicationList;
    if (sortType == kSortDrugType) {
        NSMutableArray *medicationArray = [[NSMutableArray alloc] init];
        MedicationTableSection tableSection = [self getDisplaySectionForSection:indexPath.section];
        switch (tableSection) {
            case kSectionRegular: {
                medicationArray = regularMedicationArray;
                medicationList = [medicationArray objectAtIndex:indexPath.row];
            }
                break;
            case kSectionOnce:{
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
        medicationList = [displayMedicationListArray objectAtIndex:indexPath.row];
    }
    return medicationList;
}

// get only the medication whose isActive is true.
- (NSArray *)getActiveMedicationsList {
    
    NSString *predicateString = @"isActive == YES";
    NSPredicate *medicineCategoryPredicate = [NSPredicate predicateWithFormat:predicateString];
    NSMutableArray *activeMedicationsArray = (NSMutableArray *)[self.medicationListArray filteredArrayUsingPredicate:medicineCategoryPredicate];
    return activeMedicationsArray;
}

- (void)deleteMedicationListAtIndexPath:(NSIndexPath *)indexPath {
    

    DCPatientMedicationHomeViewController *patientMedicationHomeViewController = (DCPatientMedicationHomeViewController*)self.parentViewController;
    [patientMedicationHomeViewController fetchMedicationListForPatient];
}

- (void)displayDeleteConfirmationAlertViewControllerForSelectedIndexPath:(NSIndexPath *)indexPath {
    
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD
                                                                   bundle: nil];
    DCMissedMedicationAlertViewController *alertViewController = [administerStoryboard instantiateViewControllerWithIdentifier:MISSED_ADMINISTER_VIEW_CONTROLLER];
    alertViewController.alertType = eDeleteMedicationConfirmation;
    DCMedicationScheduleDetails *medicationList = [self getMedicationListForTableCellAtIndexPath:indexPath];
    alertViewController.medicineName = medicationList.name;
    
    alertViewController.dismissView = ^ {
        [self dismissViewControllerAnimated:YES completion:nil];
        [self stopMedicationAtIndexPath:indexPath];
    };
    alertViewController.dismissViewWithoutSaving = ^ {
    };
    [alertViewController setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [self presentViewController:alertViewController animated:YES completion:nil];
}

- (void)displayPreviousWeekDetails {
    
    NSDate *previousDate = [DCDateUtility getPreviousWeekEndDate:calendarDisplayStartDate];
    [currentWeekDatesArray removeAllObjects];
    [calendarDisplayWeekArray removeAllObjects];
    currentWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:previousDate];
    [self configureDisplayOfWeekDatesInCalendar];
}

- (void)displayNextWeekDetails {
    
    NSDate *nextDate = [DCDateUtility getNextWeekStartDate:calendarDisplayEndDate];
    [currentWeekDatesArray removeAllObjects];
    [calendarDisplayWeekArray removeAllObjects];
    currentWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:nextDate];
    [self configureDisplayOfWeekDatesInCalendar];
}

- (void)displayCurrentWeekDetails {
    
    [currentWeekDatesArray removeAllObjects];
    [calendarDisplayWeekArray removeAllObjects];
    NSDate *initialDisplayDate = [DCDateUtility getInitialDateOfWeekForDisplay:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]];
    currentWeekDatesArray = [DCDateUtility getDaysOfWeekFromDate:initialDisplayDate];
    [self configureDisplayOfWeekDatesInCalendar];
}

- (void)getMedicationArrayToDisplay {
    if (_discontinuedMedicationShown) {
        displayMedicationListArray = self.medicationListArray;
    }
    else {
        displayMedicationListArray = [NSMutableArray arrayWithArray:[self getActiveMedicationsList]];
    }
    [self configurePreviousAndNextButtons];
    DCPatientMedicationHomeViewController *patientMedicationHomeViewController = (DCPatientMedicationHomeViewController*)self.parentViewController;
    onceMedicationArray = [patientMedicationHomeViewController getAllOnceMedicationList: displayMedicationListArray];
    regularMedicationArray = [patientMedicationHomeViewController getAllRegularMedicationList:displayMedicationListArray];
    whenrequiredMedicationArray = [patientMedicationHomeViewController getAllWhenRequiredMedicationList:displayMedicationListArray];
}

- (void)sortPrescriberMedicationList {
    
    NSString *sortKey;
    if (sortType == kSortDrugName) {
        sortKey = SORT_KEY_MEDICINE_NAME;
    }
    else if (sortType == kSortDrugStartDate) {
        sortKey = SORT_KEY_MEDICINE_START_DATE;
    }
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
    NSArray *descriptorArray = @[sortDescriptor];
    NSMutableArray *sortedMedicationArray = [[NSMutableArray alloc] initWithArray:[displayMedicationListArray sortedArrayUsingDescriptors:descriptorArray]];
    displayMedicationListArray = sortedMedicationArray;
}

- (void)stopMedicationAtIndexPath :(NSIndexPath *)indexPath {
    
    DCMedicationScheduleDetails *medicationList = [self getMedicationListForTableCellAtIndexPath:indexPath];
    DCPatientMedicationHomeViewController *patientMedicationHomeViewController = (DCPatientMedicationHomeViewController*)self.parentViewController;
    DCStopMedicationWebService *webService = [[DCStopMedicationWebService alloc] init];
//[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [webService stopMedicationForPatientWithId:patientMedicationHomeViewController.patient.patientId drugWithScheduleId:medicationList.scheduleId withCallBackHandler:^(id response, NSError *error) {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        if (!error) {
            //To Do : Have to modify the method once the getMedicationList API start function perfect.
            [self deleteMedicationListAtIndexPath:indexPath];
//            [prescriberTableView beginUpdates];
//            [prescriberTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [prescriberTableView endUpdates];
//            [prescriberTableView reloadData];
        } else {
            //To Do : have to modify the alert message after API implementation is complete
            //[self displayAlertWithTitle:NSLocalizedString(@"ERROR",@"") message:@"webservice under construction"];
            [prescriberTableView reloadData];
        }
    }];
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

- (CGFloat)getCellHeightWithMedicationList:(DCMedicationScheduleDetails *)medicationList {
    
    CGSize constrain = CGSizeMake(266, FLT_MAX);
    CGRect textRect;
    textRect = [medicationList.name   boundingRectWithSize:constrain
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName:[DCFontUtility getLatoRegularFontWithSize:17.0f]}
                                                           context:nil];
    CGFloat height = textRect.size.height + 82;
    return height;
}

- (void)addCalendarViewsToCell:(DCPrescriberMedicationCell *)prescriberMedicationCell
             forMedicationList:(DCMedicationScheduleDetails *)medicationList
                   atIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat x, y, height, width;
    x = 0;
    y = 0;
    height = [self getCellHeightWithMedicationList:medicationList] - 1;
    for (NSInteger position = 0; position < 7; position++) {
        
        width = (position == 6) ? 104: 103.5;
        
        UIView *calendarView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        calendarView.backgroundColor = [UIColor whiteColor];
        calendarView.tag = position + 1;
        [prescriberMedicationCell.calendarView addSubview:calendarView];
        
        UIView *leftCalendarView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        leftCalendarView.backgroundColor = [UIColor whiteColor];
        [prescriberMedicationCell.leftCalendarView addSubview:leftCalendarView];
        
        UIView *rightCalendarView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        [prescriberMedicationCell.rightCalendarView addSubview:rightCalendarView];
        rightCalendarView.backgroundColor = [UIColor whiteColor];
        x = 1 + position + (position + 1) * width;
    }
}

- (void)includeDiscontinuedMedications {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (_discontinuedMedicationShown) {
            _discontinuedMedicationShown = NO;
            [self getMedicationArrayToDisplay];
        } else {
            _discontinuedMedicationShown = YES;
            [self getMedicationArrayToDisplay];
            if (sortType != kSortDrugType) {
                [self sortPrescriberMedicationList];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configurePreviousAndNextButtons];
            [self checkAndReloadPrescriberTableViewWithLoadingCompletion:YES];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
    });
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    
    UIView *gestureView = [gestureRecognizer view];
    CGPoint translation = [gestureRecognizer translationInView:[gestureView superview]];
    if ([gestureRecognizer isEqual:self.navigationController.interactivePopGestureRecognizer]) {
        return NO;
    } else {
        
        if (fabs(translation.x) > fabs(translation.y)) {
            return YES;
        }
        return NO;
    }
}

#pragma mark - Table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (sortType == kSortDrugType) {
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
    
    if (sortType == kSortDrugType) {
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
        return [displayMedicationListArray count];
    }
    return 0;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCPrescriberMedicationCell *medicationCell = (DCPrescriberMedicationCell *)[tableView dequeueReusableCellWithIdentifier:PRESCRIBER_MEDICATION_CELL_IDENTIFIER];
    if (medicationCell == nil) {
        medicationCell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCPrescriberMedicationCell class]) owner:self options:nil] objectAtIndex:0];
    }
    DCMedicationScheduleDetails *medicationList = [self getMedicationListForTableCellAtIndexPath:indexPath];
    medicationCell.indexPath = indexPath;
    medicationCell.delegate = self;
    [self addCalendarViewsToCell:medicationCell forMedicationList:medicationList atIndexPath:indexPath];
    [medicationCell configurePrescriberMedicationCellForMedication:medicationList];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//        NSMutableArray *medicationsSlotArray = [self medicationSlotsWithViewTags:medicationList forCellPosition:prescriberCellsCenter];
        NSMutableArray *medicationsSlotArray = [self medicationSlotsWithViewTags:medicationList forCell:medicationCell];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (medicationsSlotArray) {
                [medicationCell addMedicationTimeAndStatusIconsFromMedicationSlotsArray:medicationsSlotArray];
                [medicationCell addOverLayButtonForMedicationSlots:medicationsSlotArray];
            }
        });
    });
    return medicationCell;
}

#pragma mark - Table view delegate methods

///// neeeded
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (sortType == kSortDrugType) {
        return SECTION_HEADER_HEIGHT;
    }
    return 0;
}

///// neeeded
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    DCMedicationScheduleDetails *medicationList = [self getMedicationListForTableCellAtIndexPath:indexPath];
    CGFloat height = [self getCellHeightWithMedicationList:medicationList];
    return height;
}


///// neeeded
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view
       forSection:(NSInteger)section {
    
    view.tintColor = [UIColor getColorForHexString:@"#d8e3e5"];
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [DCFontUtility getLatoBoldFontWithSize:17.0f];
    [header.textLabel setTextColor:[UIColor getColorForHexString:@"#393d3e"]];
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) {
        //end of loading, dismiss activity indicator
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].windows[0] animated:YES];
        if (todayAction) {
            [self loadThisWeekDetailsOnTableViewReloadCompletion];
        }
    }
}

///// neeeded -- all the delegate methods needed. Like todayAction, sortByDrugType, alphabetical order, include discontinued.

#pragma mark - Action Methods

- (IBAction)previousButtonPressed:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self configureDisplayDatesForNextWeekSelection:NO];
    [indexPathArray removeAllObjects];
    indexPathArray = (NSMutableArray *)[prescriberTableView indexPathsForVisibleRows];
    for (NSInteger count = 0; count < [indexPathArray count]; count++) {
        
        NSIndexPath *indexPath = [indexPathArray objectAtIndex:count];
        DCPrescriberMedicationCell *meditationCell = (DCPrescriberMedicationCell *)[prescriberTableView cellForRowAtIndexPath:indexPath];
        if (count == [indexPathArray count] -1) {
            [self animateToDisplayPreviousWeek:meditationCell isLastCell:YES];
            [self animateWeekContainerViewToLeft];
        }
        else {
            [self animateToDisplayPreviousWeek:meditationCell isLastCell:NO];
        }
    }
}

- (IBAction)nextButtonPressed:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self configureDisplayDatesForNextWeekSelection:YES];
    [indexPathArray removeAllObjects];
    indexPathArray = (NSMutableArray *)[prescriberTableView indexPathsForVisibleRows];
    for (NSInteger count = 0; count < [indexPathArray count]; count++) {
        
        NSIndexPath *indexPath = [indexPathArray objectAtIndex:count];
        DCPrescriberMedicationCell *meditationCell = (DCPrescriberMedicationCell *)[prescriberTableView cellForRowAtIndexPath:indexPath];
        if (count == [indexPathArray count] -1) {
            [self animateToDisplayNextWeek:meditationCell isLastCell:YES];
            [self animateWeekContainerViewToRight];
        }
        else {
            [self animateToDisplayNextWeek:meditationCell isLastCell:NO];
        }
    }
}

- (IBAction)filterButtonPressed:(id)sender {
    //filter list for active and non active medicines
    DCPrescriberFilterTableViewController *filterTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:PRESCRIBER_FILTER_TABLE_VIEW_CONTROLLER];
    filterTableViewController.delegate = self;
    UIPopoverController *popOverController = [[UIPopoverController alloc] initWithContentViewController:filterTableViewController];
    filterTableViewController.filterCriteria = ^ (NSString *criteria) {
        
        DCDebugLog(@"criteria is %@", criteria);
    };
    popOverController.popoverBackgroundViewClass = [DCPrescriberFilterBackgroundView class];
    popOverController.backgroundColor = [UIColor getColorForHexString:@"#b1b1b1"];
    popOverController.popoverContentSize = CGSizeMake(200.0, 150);
    CGRect popOverRect = CGRectMake(60, - 30, 50, 50);
    [popOverController presentPopoverFromRect:popOverRect
                                       inView:sender
                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                     animated:YES];
}

- (IBAction)todayButtonTapped:(id)sender {
    
    [self todayButtonAction];
}

- (IBAction)includeDiscontinuedButtonPressed:(id)sender {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIButton *button = (UIButton *)sender;
        if (button.selected) {
            [button setSelected:NO];
            //remove inactive from list
            if (_discontinuedMedicationShown) {
                _discontinuedMedicationShown = NO;
                [self getMedicationArrayToDisplay];
            }
        } else {
            [button setSelected:YES];
            if (!_discontinuedMedicationShown) {
                _discontinuedMedicationShown = YES;
                [self getMedicationArrayToDisplay];
                if (sortType != kSortDrugType) {
                    [self sortPrescriberMedicationList];
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self configurePreviousAndNextButtons];
            [self checkAndReloadPrescriberTableViewWithLoadingCompletion:YES];
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        });
    });
}

#pragma mark - UIViewControllerTransitioningDelegate

// to be retained within the main class
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    RoundRectPresentationController *roundRectPresentationController = [[RoundRectPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    roundRectPresentationController.viewType = eAddMedication;
    return roundRectPresentationController;
}

#pragma mark - DCPrescriberFilterTableViewControllerDelegate methods

- (void)sortMedicationListSelectionChanged:(NSInteger)currentSelection {
    // complete the method definition.
    sortType = kSortDrugType;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (currentSelection == 1) {
            sortType = kSortDrugStartDate;
            [self sortPrescriberMedicationList];
        }
        else if (currentSelection == 2) {
            sortType = kSortDrugName;
            [self sortPrescriberMedicationList];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [prescriberTableView reloadData];
        });
    });
}

#pragma mark - DCPrescriberCellDelegate Methods

- (void)editMedicationForSelectedIndexPath:(NSIndexPath *)indexPath {
    
    //edit medication action
//    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].windows[0] animated:YES];
//    DCPatientMedicationHomeViewController *patientMedicationHomeViewController = (DCPatientMedicationHomeViewController*)self.parentViewController;
//    DCMedicationScheduleDetails *medicationList =  [self getMedicationListForTableCellAtIndexPath:indexPath];
//    [patientMedicationHomeViewController editSelectedMedication:medicationList];
}

- (void)stopMedicationForSelectedIndexPath:(NSIndexPath *)indexPath {
    
    //Display confirmation alert
    [self stopMedicationAtIndexPath:indexPath];
    //[self displayDeleteConfirmationAlertViewControllerForSelectedIndexPath:indexPath];
}

- (void)displayMedicationDetailsViewAtIndexPath:(NSIndexPath *)indexPath
                                  withButtonTag:(NSInteger)tag
                                     slotsArray:(NSArray *)slotsArray {
    
    //display calendar slot detail screen
    UIStoryboard *administerStoryboard = [UIStoryboard storyboardWithName:ADMINISTER_STORYBOARD bundle:nil];
    DCCalendarSlotDetailViewController *detailViewController = [administerStoryboard instantiateViewControllerWithIdentifier:CALENDAR_SLOT_DETAIL_STORYBOARD_ID];
    DCMedicationScheduleDetails *medicationList =  [self getMedicationListForTableCellAtIndexPath:indexPath];
    detailViewController.medicationDetails = medicationList;
    detailViewController.medicationSlotsArray = slotsArray;
    detailViewController.medicationDetails = medicationList;
   // detailViewController.weekDate =
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Public methods implementation

// get the regular, once and when required medications separately for the initial display
// separately as sections in table view. At first display of medicines are based on
// drug type (regular, once or when needed).
- (void)reloadPrescriberViewWithMedicationListWithLoadingCompletion:(BOOL)isCompleted {

    sortType = kSortDrugType;
    [self configurePreviousAndNextButtons];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if([self.parentViewController isKindOfClass:[DCPatientMedicationHomeViewController class]]) {
            [self getMedicationArrayToDisplay];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self checkAndReloadPrescriberTableViewWithLoadingCompletion:isCompleted];
            if ([displayMedicationListArray count] == 0) {
                [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].windows[0] animated:YES];
            }
        });
    });
}

- (void)todayButtonAction {
    //TODO: progresshud call is hidden as HUD is not dismissed when action from toolbar. Will be fixed on changing Hud to native control 
   // [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    todayAction = YES;
    [self animateToDisplayCurrentWeek];
}

- (void)sortCalendarViewBasedOnCriteria:(NSString *)criteriaString {
    
    sortType = kSortDrugType;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if ([criteriaString isEqualToString:INCLUDE_DISCONTINUED]) {
            [self includeDiscontinuedMedications];
        }
        if ([criteriaString isEqualToString:START_DATE_ORDER]) {
            sortType = kSortDrugStartDate;
            [self sortPrescriberMedicationList];
        }
        else if ([criteriaString isEqualToString:ALPHABETICAL_ORDER]) {
            sortType = kSortDrugName;
            [self sortPrescriberMedicationList];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
            [prescriberTableView reloadData];
        });
    });
}

@end
