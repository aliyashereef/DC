//
//  DCPrescriberDetailsViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/12/15.
//
//

#import "DCPrescriberDetailsViewController.h"
#import "RoundRectPresentationController.h"
#import "DCPrescriberDetailsTimeView.h"

#define TIME_VIEW_X_INITIAL                     0.0f
#define TIME_VIEW_Y_INITIAL                     9.0f
#define TIME_VIEW_WIDTH                         100.0f
#define TIME_VIEW_HEIGHT                        41.0f
#define MEDICINE_NAME_MAX_HEIGHT                20.0f
#define TITLE_VIEW_CONTENTS_HEIGHT_EXCEPT_NAME  80.0f
#define NAME_OFFSET                             5.0f
#define SCROLL_CONTENT_HEIGHT_INITIAL           475.0f
#define TIME_SLOTS_MAX_COUNT                    5

@interface DCPrescriberDetailsViewController ()  <UIScrollViewDelegate>{
    
    __weak IBOutlet UILabel *medicineNameLabel;
    __weak IBOutlet UILabel *dateLabel;
    __weak IBOutlet UILabel *routeAndInstructionLabel;
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIScrollView *containerScrollView;
    __weak IBOutlet UILabel *administeredStatusLabel;
    __weak IBOutlet UILabel *administereddateAndTimeLabel;
    __weak IBOutlet UILabel *administeredByLabel;
    __weak IBOutlet UILabel *checkedByLabel;
    __weak IBOutlet UILabel *administeredNotesLabel;
    __weak IBOutlet UILabel *batchNoExpiryDateLabel;
    __weak IBOutlet UILabel *refusedDateAndTimeLabel;
    __weak IBOutlet UILabel *refusedNotesLabel;
    __weak IBOutlet UILabel *omittedReasonLabel;
    __weak IBOutlet UIView *administeredView;
    __weak IBOutlet UIView *refusedView;
    __weak IBOutlet UIView *omittedView;
    __weak IBOutlet UIView *notDueView;
    __weak IBOutlet UIButton *previousButton;
    __weak IBOutlet UIButton *nextButton;
    __weak IBOutlet UIView *containerView;
    __weak IBOutlet UIView *detailsContainerView;
    __weak IBOutlet UIView *topView;
    __weak IBOutlet NSLayoutConstraint *medicineNameHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *medicineTitleContainerHeightConstraint;
    __weak IBOutlet NSLayoutConstraint *scrollContentViewHeightConstraint;
    
    NSInteger selectedTimeViewTag;
}

@end

@implementation DCPrescriberDetailsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        if ([self respondsToSelector:@selector(setTransitioningDelegate:)]) {
            self.modalPresentationStyle = UIModalPresentationCustom;
            self.transitioningDelegate = self;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureViewElements];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLayoutSubviews {
    
    //round corners for top view and bottom content view
    [DCUtility roundCornersForView:topView roundTopCorners:YES];
    [DCUtility roundCornersForView:containerScrollView roundTopCorners:NO];
    [super viewDidLayoutSubviews];
}

#pragma mark - Private Methods

- (void)configureViewElements {
    
    medicineNameLabel.text = _medicationList.name;
    CGFloat medicineNameHeight = [DCUtility getHeightValueForText:_medicationList.name withFont:[DCFontUtility getLatoRegularFontWithSize:16.0f] maxWidth:medicineNameLabel.frame.size.width];
    if (medicineNameHeight > MEDICINE_NAME_MAX_HEIGHT) {
        medicineNameHeightConstraint.constant = medicineNameHeight + NAME_OFFSET;
        medicineTitleContainerHeightConstraint.constant = medicineNameHeight + TITLE_VIEW_CONTENTS_HEIGHT_EXCEPT_NAME;
        containerScrollView.scrollEnabled = YES;
        scrollContentViewHeightConstraint.constant = medicineTitleContainerHeightConstraint.constant + detailsContainerView.frame.size.height;
    } else {
        scrollContentViewHeightConstraint.constant = SCROLL_CONTENT_HEIGHT_INITIAL;
        containerScrollView.scrollEnabled = NO;
    }
    [self.view layoutSubviews];
    dateLabel.text = _displayDateString;
    [self populateRouteAndInstructionLabelWithRoute:_medicationList.route instruction:_medicationList.instruction];
    [self addTimeSlotsToScrollView];
}

- (void)populateRouteAndInstructionLabelWithRoute:(NSString *)route instruction:(NSString *)instruction {
    
    //get dosage and instruction text for display
    
    NSDictionary *dosageAttributes = @{
                                       NSFontAttributeName : [DCFontUtility getLatoBoldFontWithSize:17.0f],
                                       NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#3b3b3b"]
                                       };
    NSMutableAttributedString *dosageAttributedString = [[NSMutableAttributedString alloc] initWithString:route];
    [dosageAttributedString setAttributes:dosageAttributes range:NSMakeRange(0, [dosageAttributedString length])];
    NSString *medicineInstruction = instruction;
    NSString *instructionDisplayString = medicineInstruction.length?[NSString stringWithFormat:@" (%@)", medicineInstruction]:@"";
    NSMutableAttributedString *medicineInstructionAttributedString = [[NSMutableAttributedString alloc]
                                                                      initWithString:instructionDisplayString];
    NSDictionary *instructionAttributes = @{
                                            NSFontAttributeName : [DCFontUtility getLatoRegularFontWithSize:15.0f],
                                            NSForegroundColorAttributeName : [UIColor getColorForHexString:@"#676767"]
                                            };
    [medicineInstructionAttributedString setAttributes:instructionAttributes range:NSMakeRange(0, [instructionDisplayString length])];
    [dosageAttributedString appendAttributedString:medicineInstructionAttributedString];
   routeAndInstructionLabel.attributedText = dosageAttributedString;
}

- (void)displayNotDueViewDetails:(DCMedicationSlot *)medicationSlot {
    
    [notDueView setHidden:NO];
    [administeredView setHidden:YES];
    [refusedView setHidden:YES];
    [omittedView setHidden:YES];
    containerView.layer.borderColor = [UIColor getColorForHexString:@"#cecece"].CGColor;
}

- (void)displayAdministeredViewDetails:(DCMedicationSlot *)medicationSlot {
    
    NSString *dateDisplayString = [DCDateUtility convertDate:medicationSlot.time FromFormat:DEFAULT_DATE_FORMAT ToFormat:DATE_FORMAT_WITH_DAY];
    [administeredView setHidden:NO];
    [notDueView setHidden:YES];
    [refusedView setHidden:YES];
    [omittedView setHidden:YES];
    administereddateAndTimeLabel.text = dateDisplayString;
    //TODO: for demo purpose
    if (medicationSlot.medicationAdministration) {
        administeredByLabel.text = medicationSlot.medicationAdministration.administratingUser.displayName;
        // checkedByLabel.text = medicationSlot.medicationAdministration.checkedBy;
        batchNoExpiryDateLabel.text = medicationSlot.medicationAdministration.batch;
        if ([medicationSlot.status isEqualToString:IS_GIVEN]) {
            administeredNotesLabel.text = medicationSlot.medicationAdministration.notes;
        } else {
            administeredNotesLabel.text = @"-";
        }
    }else if (medicationSlot.administerMedication) {
        administeredByLabel.text = medicationSlot.administerMedication.administeredBy;
        checkedByLabel.text = medicationSlot.administerMedication.checkedBy;
        batchNoExpiryDateLabel.text = medicationSlot.administerMedication.batchNumber;
        if ([medicationSlot.status isEqualToString:IS_GIVEN]) {
            administeredNotesLabel.text = medicationSlot.administerMedication.notes;
        } else {
            administeredNotesLabel.text = @"-";
        }
    }
    else {
        if ([medicationSlot.status isEqualToString:IS_GIVEN]) {
            administeredNotesLabel.text = NSLocalizedString(@"ADMINISTER_NOTES", @"administration notes");
        } else {
            administeredNotesLabel.text = @"-";
        }
    }
    [administeredNotesLabel sizeToFit];
    containerView.layer.borderColor = [UIColor getColorForHexString:@"#b7d6a3"].CGColor;
}

- (void)displayRefusedViewDetails:(DCMedicationSlot *)medicationSlot {
    
    [refusedView setHidden:NO];
    [administeredView setHidden:YES];
    [notDueView setHidden:YES];
    [omittedView setHidden:YES];
    NSString *dateDisplayString = [DCDateUtility convertDate:medicationSlot.time FromFormat:DEFAULT_DATE_FORMAT ToFormat:DATE_FORMAT_WITH_DAY];
    refusedDateAndTimeLabel.text = dateDisplayString;
    if (medicationSlot.medicationAdministration) {
        refusedNotesLabel.text = medicationSlot.medicationAdministration.notes;
    }
    else  if (medicationSlot.administerMedication) {
        //TODO: added for demo
        refusedNotesLabel.text = medicationSlot.administerMedication.refusedNotes;
    }
    else {
        refusedNotesLabel.text = NSLocalizedString(@"REFUSED_NOTES", @"Refused Notes");
    }
    [refusedNotesLabel sizeToFit];
    containerView.layer.borderColor = [UIColor getColorForHexString:@"#efadad"].CGColor;
}

- (void)displayOmittedViewDetails:(DCMedicationSlot *)medicationSlot {
    
    NSString *dateDisplayString = [DCDateUtility convertDate:medicationSlot.time FromFormat:DEFAULT_DATE_FORMAT ToFormat:DATE_FORMAT_WITH_DAY];
    [omittedView setHidden:NO];
    [refusedView setHidden:YES];
    [administeredView setHidden:YES];
    [notDueView setHidden:YES];
    if (medicationSlot.medicationAdministration) {
        omittedReasonLabel.text = medicationSlot.medicationAdministration.notes;
    }
    else if (medicationSlot.administerMedication) {
        omittedReasonLabel.text = medicationSlot.administerMedication.omittedReason;
    }
    else {
        omittedReasonLabel.text = NSLocalizedString(@"OMITTED_REASON", @"Omitted reason");
    }
    [omittedReasonLabel sizeToFit];
    refusedDateAndTimeLabel.text = dateDisplayString;
    containerView.layer.borderColor = [UIColor getColorForHexString:@"#9ed6dd"].CGColor;
}
- (void)displayStatusViewForMedicationslot:(DCMedicationSlot *)medicationSlot {
    
    //display view as per medication status
    if ([medicationSlot.time compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedDescending) {
        [self displayNotDueViewDetails:medicationSlot];
    } else if ([medicationSlot.time compare:[DCDateUtility getDateInCurrentTimeZone:[NSDate date]]] == NSOrderedAscending) {
        //time past
        if ([medicationSlot.status isEqualToString:IS_GIVEN] || [medicationSlot.status isEqualToString:SELF_ADMINISTERED]) {
            [self displayAdministeredViewDetails:medicationSlot];
        } else if ([medicationSlot.status isEqualToString:REFUSED]) {
            [self displayRefusedViewDetails:medicationSlot];
        } else if ([medicationSlot.status isEqualToString:OMITTED]) {
            [self displayOmittedViewDetails:medicationSlot];
        }
        else {
            [self displayAdministeredViewDetails:medicationSlot];
        }
    } else {
        [self displayNotDueViewDetails:medicationSlot];
    }
}

- (void)addTimeSlotsToScrollView {
    
    //add time slots to view
    CGFloat xValue = TIME_VIEW_X_INITIAL;
    switch ([_slotsArray count]) {
        case 1:
            xValue = (scrollView.frame.size.width / 2.0) - 50;
            break;
        case 2:
            xValue = (scrollView.frame.size.width / 2.0) - 100;
            break;
        case 3:
            xValue = (scrollView.frame.size.width / 2.0) - 150;
            break;
        case 4:
            xValue = (scrollView.frame.size.width / 2.0) - 200;
            break;
    }
    
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    for (DCMedicationSlot *slot in _slotsArray) {
        DCPrescriberDetailsTimeView *timeView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCPrescriberDetailsTimeView class]) owner:self options:nil] objectAtIndex:0];
        timeView.frame = CGRectMake(xValue, TIME_VIEW_Y_INITIAL, TIME_VIEW_WIDTH, TIME_VIEW_HEIGHT);
        [scrollView addSubview:timeView];
        __block NSInteger tag = [_slotsArray indexOfObject:slot] + 1;
        timeView.tag = [_slotsArray indexOfObject:slot] + 1;
        timeView.timeButton.tag = 100 + [_slotsArray indexOfObject:slot] + 1;
        timeView.medicationSlot = slot;
        timeView.timeAction = ^{
            selectedTimeViewTag = tag;
            [self resetTimeViewsForSelectedTimeViewTag:tag];
            [self displayStatusViewForMedicationslot:slot];
        };
        [timeView setMedicationSlotValuesForSelectedState:NO];
        xValue += (TIME_VIEW_WIDTH + 9.45);
    }
    [scrollView setContentSize:CGSizeMake(xValue + 60, scrollView.frame.size.height)];
    [self loadDetailsForSelectedMedicationSlotAtIndex:0];
    [self configureTimeContentScrollView];
}

- (void)configureTimeContentScrollView {
    
    if ([_slotsArray count] > TIME_SLOTS_MAX_COUNT) {
        [scrollView setScrollEnabled:YES];
        [previousButton setHidden:NO];
        [nextButton setHidden:NO];
    } else {
        [scrollView setScrollEnabled:NO];
        [previousButton setHidden:YES];
        [nextButton setHidden:YES];
    }
}

- (void)configureScrollViewNavigationButtonVisibility {
    
    if (selectedTimeViewTag == 1) {
        [previousButton setAlpha:0.3];
        [previousButton setUserInteractionEnabled:NO];
    } else if (selectedTimeViewTag == _slotsArray.count) {
        [nextButton setAlpha:0.3];
        [nextButton setUserInteractionEnabled:NO];
    } else {
        [previousButton setAlpha:1.0];
        [previousButton setUserInteractionEnabled:YES];
        [nextButton setAlpha:1.0];
        [nextButton setUserInteractionEnabled:YES];
    }

}

- (void) layoutScrollViewWithSelectedTimeViewTag : (NSInteger) timeViewTag {
    
    [scrollView setContentOffset:CGPointMake(109.75 * timeViewTag ,0) animated:YES];
}

- (void)loadDetailsForSelectedMedicationSlotAtIndex:(NSInteger)index {
    
    //load details for initial tiem slot in scrollview
    DCPrescriberDetailsTimeView *selectedTimeView = (DCPrescriberDetailsTimeView *)[scrollView viewWithTag:index + 1];
    DCMedicationSlot *medicationSlot = (DCMedicationSlot *)[_slotsArray objectAtIndex:index];
    [selectedTimeView timeViewButtonClicked:nil];
    [self displayStatusViewForMedicationslot:medicationSlot];
}

- (void)resetTimeViewsForSelectedTimeViewTag:(NSInteger)tag {
    
    [self configureScrollViewNavigationButtonVisibility];
    for (int count = 0; count < _slotsArray.count; count ++) {
        DCPrescriberDetailsTimeView *subView = (DCPrescriberDetailsTimeView *)[scrollView viewWithTag:count + 1];
        if (subView.tag == tag) {
            [subView setMedicationSlotValuesForSelectedState:YES];
        } else {
            [subView setMedicationSlotValuesForSelectedState:NO];
        }
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    RoundRectPresentationController *roundRectPresentationController = [[RoundRectPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    roundRectPresentationController.viewType = ePrescriberDetails;
    return roundRectPresentationController;
}

#pragma mark - UIScrollViewDElegate 

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self configureScrollViewNavigationButtonVisibility];
    
}

#pragma mark - Action Methods

- (IBAction)closeButtonPressed:(id)sender {
    
    //dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)previousButtonPressed:(id)sender {

    if (selectedTimeViewTag > 1) {
        selectedTimeViewTag --;
        [self loadDetailsForSelectedMedicationSlotAtIndex:selectedTimeViewTag - 1];
    }
    [self layoutScrollViewWithSelectedTimeViewTag:selectedTimeViewTag - 1];
}

- (IBAction)nextButtonPressed:(id)sender {
    
    [self layoutScrollViewWithSelectedTimeViewTag:selectedTimeViewTag];
    if (selectedTimeViewTag < _slotsArray.count) {
        selectedTimeViewTag ++;
        [self loadDetailsForSelectedMedicationSlotAtIndex:selectedTimeViewTag - 1];
    }
}

@end
