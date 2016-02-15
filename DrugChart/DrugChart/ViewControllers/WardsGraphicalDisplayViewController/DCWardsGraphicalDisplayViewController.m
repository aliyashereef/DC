//
//  DCWardsGraphicalDisplayViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 04/06/15.
//
//

#import "DCWardsGraphicalDisplayViewController.h"
#import "DCPrescriberMedicationViewController.h"

#import "DCPatientGraphicalRepresentationView.h"
#import "DCPositionableGraphicsView.h"
#import "DCMedicationSchedulesWebService.h"

#import "DCBed.h"
#import "DCPositionableGraphics.h"

#import "DCPlistManager.h"

@interface DCWardsGraphicalDisplayViewController ()<DCPatientGraphicalRepresentationViewDelegate> {
    
    DCPatient *selectedPatient;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *wardsGraphicalView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *graphicalScrollWidth;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *graphicalScrollHeight;


@end

@implementation DCWardsGraphicalDisplayViewController

#pragma mark - View Management Methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureGraphicalView];
}

- (void)viewWillAppear:(BOOL)animated {
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:CANCEL_BUTTON_TITLE style:UIBarButtonItemStylePlain  target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.title = self.wardDisplayed.wardName;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private methods

- (void)setGraphicalContentSize {
    
    CGFloat scrollHeight = self.wardDisplayed.wardDimensions.height;
    CGFloat scrollWidth = self.wardDisplayed.wardDimensions.width;
    self.graphicalScrollHeight.constant = scrollHeight!= 0.0 ? scrollHeight : self.view.fsh;
    self.graphicalScrollWidth.constant = scrollWidth!= 0.0 ? scrollWidth : self.view.fsw;
    [self.view layoutIfNeeded];
}

- (void)configureScrollViewProperties {
    
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 3.0;
}

- (void)addPatientBedViews {
    
    for (DCBed *bed in self.bedsArray) {
        if (!CGRectIsEmpty(bed.bedFrame)) {
            
            DCPatientGraphicalRepresentationView *graphicalRepresentationView = [[DCPatientGraphicalRepresentationView alloc] initWithBedDetails:bed];
            graphicalRepresentationView.delegate = self;
            [graphicalRepresentationView populateValuesToViewElements];
            graphicalRepresentationView.frame = bed.bedFrame;
            [self.wardsGraphicalView addSubview:graphicalRepresentationView];
            if ([bed.headDirection isEqualToString:BOTTOM_DIRECTION]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.01 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [graphicalRepresentationView adjustViewFrame];
                });
            }
        }
    }
}

- (void)fetchAndAddPositionableGraphicsViews {
    
    NSArray *positionableGraphicsArray = self.wardDisplayed.positionableGraphicsArray;
    for (DCPositionableGraphics *positionableGraphics in positionableGraphicsArray) {
        
        DCPositionableGraphicsView *positionableGraphicsView = [[DCPositionableGraphicsView alloc]
                                                                initWithGraphicsType:positionableGraphics.positionableGraphicsType
                                                                andFrame:positionableGraphics.viewFrame];
        if (positionableGraphicsView != nil) {
            [self.wardsGraphicalView addSubview:positionableGraphicsView];
        }
        
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    
    return self.wardsGraphicalView;
}

- (void)configureGraphicalView {
    
    [self setGraphicalContentSize];
    [self configureScrollViewProperties];
    [self addPatientBedViews];
    [self fetchAndAddPositionableGraphicsViews];
}

#pragma mark - delegate methods

- (void)goToPatientDetailView:(DCPatient *)currentPatient {
    
    selectedPatient = currentPatient;
    UIStoryboard *prescriberStoryBoard = [UIStoryboard storyboardWithName:PRESCRIBER_DETAILS_STORYBOARD bundle:nil];
    DCPrescriberMedicationViewController *prescriberMedicationViewController = [prescriberStoryBoard instantiateViewControllerWithIdentifier:PRESCRIBER_MEDICATION_SBID];
    prescriberMedicationViewController.patient = selectedPatient;
    [self.navigationController pushViewController:prescriberMedicationViewController animated:YES];
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
