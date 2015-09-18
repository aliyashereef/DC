//
//  DCWardsGraphicalDisplayViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 04/06/15.
//
//

#import "DCWardsGraphicalDisplayViewController.h"
#import "DCPatientMedicationHomeViewController.h"

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

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setGraphicalContentSize];
    [self configureScrollViewProperties];
    [self addPatientBedViews];
    [self fetchAndAddPositionableGraphicsViews];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

#pragma mark - Configure Segue for Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UIViewController *destinationViewController = [segue destinationViewController];
    if ([destinationViewController isKindOfClass:[DCPatientMedicationHomeViewController class]]) {
        DCPatientMedicationHomeViewController *patientMedicationHomeViewController = (DCPatientMedicationHomeViewController *)destinationViewController;
         patientMedicationHomeViewController.patient = selectedPatient;
    }
}

#pragma mark - delegate methods

- (void)goToPatientDetailView:(DCPatient *)currentPatient {
    
    selectedPatient = currentPatient;
    [self performSegueWithIdentifier:GOTO_PATIENT_LIST sender:nil];
}

@end
