//
//  DCInitialViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 05/05/15.
//
//

#import "DCInitialViewController.h"
#import "DCAuthorizationViewController.h"
#import "DCWardWebService.h"
#import "DCBedsAndPatientsWebService.h"
#import "DCWard.h"
#import "DCBed.h"
#import "DCPatient.h"
#import "DrugChart-Swift.h"
#import "DCPatientDetailsHelper.h"


@interface DCInitialViewController () <DCAuthorizationViewControllerDelegate> {
    
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    DCAuthorizationViewController *authorizationViewController;
    BOOL isDismissActionForLogin;
    NSMutableArray *wardsArray;
    NSMutableArray *patientsListArray;
    NSMutableArray *sortedPatientsListArray;

}

@end

@implementation DCInitialViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self configureNavigationBarItems];
    if (!isDismissActionForLogin) {
        [self displayLoginAuthorizationWebView];
    }
    isDismissActionForLogin = NO;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    UIViewController *destinationViewController = [segue destinationViewController];
    if ([destinationViewController isKindOfClass:[DCPatientListingViewController class]]) {
        
        DCPatientListingViewController *listViewController = (DCPatientListingViewController *)destinationViewController;
        listViewController.sortedPatientListArray = sortedPatientsListArray;
        listViewController.patientListArray = patientsListArray;
        listViewController.wardsListArray = wardsArray;
        DCWard *initialWard = [wardsArray objectAtIndex:0];
        listViewController.viewTitle = initialWard.wardName;
    }
}

#pragma mark - Private Methods

- (void)configureNavigationBarItems {
    
    self.title = NSLocalizedString(@"LOGIN", @"");
}

- (void)displayLoginAuthorizationWebView {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:AUTHORIZATION_STORYBOARD bundle:nil];
    authorizationViewController = [storyBoard instantiateInitialViewController];
    authorizationViewController.delegate = self;
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self presentViewController:authorizationViewController animated:YES completion:nil];
    });
}

- (void)fetchAllWardsForUserwithCallBackHandler:(void (^)(NSError *error))callBackHandler {
    
    DCWardWebService *wardsWebService = [[DCWardWebService alloc] init];
    [activityIndicator startAnimating];
    [wardsWebService getAllWardsForUser:nil withCallBackHandler:^(id response, NSError *error) {
        [activityIndicator stopAnimating];
        if (!error) {
            NSArray *responseArray = [NSMutableArray arrayWithArray:response];
            wardsArray = [[NSMutableArray alloc] init];
            for (NSDictionary *wardsDictionary in responseArray) {
                DCWard *ward = [[DCWard alloc] initWithDicitonary:wardsDictionary];
                [wardsArray addObject:ward];
            }
            DCPatientDetailsHelper *helper = [[DCPatientDetailsHelper alloc] init];
            [helper fetchPatientsInWard:[wardsArray objectAtIndex:0] ToGetPatientListwithCallBackHandler:^(NSError *error, NSArray *patientsArray) {
                if (!error) {
                    patientsListArray = [NSMutableArray arrayWithArray:patientsArray];
                    callBackHandler(nil);
                }
            }];
        } else {
        
            if (error.code == NETWORK_NOT_REACHABLE) {
                [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
            } else if (error.code == WEBSERVICE_UNAVAILABLE) {
                
                [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"WEBSERVICE_UNAVAILABLE", @"")];
                
            } else {
                [self displayAlertWithTitle:NSLocalizedString(@"WARNING", @"") message:NSLocalizedString(@"NO_WARDS_MESSAGE", @"No wards message")];
            }
            callBackHandler(error);
        }
        [authorizationViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}


#pragma mark - DCAuthorizationViewControllerDelegate implementation

- (void)successfulLoginAction {
    
    isDismissActionForLogin = YES;
    if ([DCAPPDELEGATE isNetworkReachable]) {
        [self fetchAllWardsForUserwithCallBackHandler:^(NSError *error) {
            if(!error){
                DCPatientDetailsHelper *helper = [[DCPatientDetailsHelper alloc] init];
                sortedPatientsListArray = (NSMutableArray *)[helper categorizePatientListBasedOnEmergency:patientsListArray];
                [self performSegueWithIdentifier:WARDS_SEGUE_ID sender:nil];
            } else {
                
            }
        }];
    }
    [authorizationViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
