//
//  DCWardsPatientsListingViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 04/06/15.
//
//

#import "DCWardsPatientsListingViewController.h"
#import "DCSettingsViewController.h"
#import "DCSettingsPopOverBackgroundView.h"
#import "DCLogOutWebService.h"
#import "DCPatientListViewController.h"
#import "DCWardsGraphicalDisplayViewController.h"
#import "DCSortTableViewController.h"

#define LIST_VIEW_INDEX         0
#define LIST_TITLE              @"List"
#define GRAPHICAL_TITLE         @"Graphical"

@interface DCWardsPatientsListingViewController () <DCSettingsViewControllerDelegate> {

    __weak IBOutlet UIView *holderView;
    __weak IBOutlet UIView *graphicalHolderView;
    UISegmentedControl *segmentedControl;
    UIPopoverController *settingsPopOverController;
    DCWardsGraphicalDisplayViewController *wardsGraphicalDisplayViewController;
}

@property (nonatomic, strong) DCPatientListViewController *patientListViewController;

@end

@implementation DCWardsPatientsListingViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [segmentedControl setUserInteractionEnabled:NO];
    [self addPatientListTableViewControllerAsChildView];
    [self configureViewDisplayElements];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {

     [super viewWillDisappear:YES];
}

- (void)disappearViewAfterDelay {
    
    [super viewWillDisappear:YES];
}

- (void)configureViewDisplayElements {
    
    [self configureNavigationBarItems];
}

- (void)configureNavigationBarItems {
    
    [self addSegmentedControlToNavigationBar];
    self.navigationItem.title = EMPTY_STRING;
}

- (void)addSegmentedControlToNavigationBar {
    
    //add segmented control
    NSArray *buttonsArray = [NSArray arrayWithObjects: LIST_TITLE, GRAPHICAL_TITLE, nil];
    segmentedControl = [[UISegmentedControl alloc] initWithItems:buttonsArray];
    segmentedControl.frame = CGRectMake(0,0,150, 32);
    segmentedControl.selectedSegmentIndex = 0;
    [segmentedControl addTarget:self action:@selector(segmentedControlSelected:)  forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    self.navigationItem.titleView = segmentBarItem.customView;
}

- (void)addSortBarButtonToNavigationBar {
    
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Sort"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self
                                                              action:@selector(sortButtonPressed:)];
    self.navigationItem.rightBarButtonItem = button;
}

#pragma mark - Public Methods

- (void)recievedPatientListingResponse {
    
    [segmentedControl setUserInteractionEnabled:YES];
}

#pragma mark - button actions

- (IBAction)settingButtonTapped:(UIButton *)sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:MAIN_STORYBOARD
                                                             bundle: nil];
    DCSettingsViewController *settingsViewController = [mainStoryboard instantiateViewControllerWithIdentifier:SETTINGS_VIEW_STORYBOARD_ID];
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:settingsViewController];
    settingsViewController.delegate = self;
    
    settingsPopOverController = [[UIPopoverController alloc] initWithContentViewController:navigationController];
    settingsPopOverController.popoverContentSize = CGSizeMake(170.0, 110.0);
    settingsPopOverController.popoverBackgroundViewClass = [DCSettingsPopOverBackgroundView class];
    [settingsPopOverController presentPopoverFromRect:sender.frame
                                            inView:self.view
                          permittedArrowDirections:UIPopoverArrowDirectionUp
                                          animated:YES];
}

- (IBAction)segmentedControlSelected:(UISegmentedControl *)sender {
    
    NSInteger selectedIndex = sender.selectedSegmentIndex;
    if (selectedIndex == LIST_VIEW_INDEX) {
        
        [self addPatientListTableViewControllerAsChildView];
    } else {
        
        if ([_patientListViewController.searchBar isFirstResponder]) {
            [_patientListViewController.searchBar resignFirstResponder];
        }
        self.navigationItem.rightBarButtonItem = nil;
        [self addGraphicalWardListAsChildView];
    }
}

- (IBAction)patientListDisplayButtonTapped:(UIButton *)sender {
    
    [self addPatientListTableViewControllerAsChildView];
}

- (IBAction)patientGraphicalDisplayButtonTapped:(UIButton *)sender {
    
    [self addGraphicalWardListAsChildView];
}

- (IBAction)sortButtonPressed:(id)sender {
    
    //sort list pop over display
    [self displaySortListPopOver];
}

#pragma mark - DCSettingsViewControllerDelegate implementation

- (void)logOutTapped {
    
    DCLogOutWebService *logOutWebService = [[DCLogOutWebService alloc] init];
    [logOutWebService logoutUserWithToken:nil callback:^(id response, NSDictionary *error) {
        
    }];
    [settingsPopOverController dismissPopoverAnimated:YES];
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

#pragma mark - Private methods

- (void)addGraphicalWardListAsChildView {
    
    [self toggleChildViews:NO];
    if (!wardsGraphicalDisplayViewController) {
        wardsGraphicalDisplayViewController  = [self.storyboard instantiateViewControllerWithIdentifier:WARDS_GRAPHICAL_DISPLAY_VC_SB_ID];
        wardsGraphicalDisplayViewController.bedsArray = self.bedsArray;
        wardsGraphicalDisplayViewController.wardDisplayed = self.selectedWard;
        [self addChildViewController:wardsGraphicalDisplayViewController];
        wardsGraphicalDisplayViewController.view.frame = CGRectMake(0, 0, holderView.fsw, holderView.fsh);
        [graphicalHolderView addSubview:wardsGraphicalDisplayViewController.view];
    }
    [wardsGraphicalDisplayViewController didMoveToParentViewController:self];
}

- (void)addPatientListTableViewControllerAsChildView {
    
    [self toggleChildViews:YES];
    if (!_patientListViewController) {
        _patientListViewController = [self.storyboard instantiateViewControllerWithIdentifier:PATIENT_LIST_VC_SB_ID];
        _patientListViewController.selectedWard = self.selectedWard;
        [self addChildViewController:_patientListViewController];
        _patientListViewController.view.frame = CGRectMake(0, 0, holderView.fsw, holderView.fsh);
        [holderView addSubview:_patientListViewController.view];
    }
    [_patientListViewController didMoveToParentViewController:self];
}

- (void)toggleChildViews:(BOOL)isListDisplay {
    
    if (isListDisplay) {
        graphicalHolderView.hidden = YES;
        holderView.hidden = NO;
    }
    else {
        holderView.hidden = YES;
        graphicalHolderView.hidden = NO;
    }
}

- (void)displaySortListPopOver {
    
    //show sort list pop over
    UIPopoverController *popOverController;
    DCSortTableViewController *sortViewController = [self.storyboard instantiateViewControllerWithIdentifier:SORT_VIEWCONTROLLER_STORYBOARD_ID];
    sortViewController.sortView = ePatientList;
    popOverController = [[UIPopoverController alloc] initWithContentViewController:sortViewController];
    popOverController.popoverContentSize = CGSizeMake(180, 88);
    [popOverController presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem
                              permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    sortViewController.criteria = ^ (NSString * type) {
        [popOverController dismissPopoverAnimated:YES];
    };
}

- (BOOL)viewIsPoppedFromNavigationStack {
    
    NSArray *viewControllers = [self.navigationController viewControllers];
    BOOL isViewPresent = [viewControllers containsObject:self];
    return isViewPresent;
}

@end
