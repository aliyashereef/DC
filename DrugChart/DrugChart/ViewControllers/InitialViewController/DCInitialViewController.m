//
//  DCInitialViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 05/05/15.
//
//

#import "DCInitialViewController.h"
#import "DCAuthorizationViewController.h"
#import "DCWardsListingViewController.h"
#import "DCWardWebService.h"
#import "DCWard.h"

@interface DCInitialViewController () <DCAuthorizationViewControllerDelegate> {
    
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    DCAuthorizationViewController *authorizationViewController;
    BOOL isDismissActionForLogin;
    NSMutableArray *wardsArray;
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
    if ([destinationViewController isKindOfClass:[DCWardsListingViewController class]]) {
        
        DCWardsListingViewController *wardsListViewController = (DCWardsListingViewController *)destinationViewController;
        wardsListViewController.wardsListArray = wardsArray;
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

- (void)fetchAllWardsForUser {
    
    DCWardWebService *wardsWebService = [[DCWardWebService alloc] init];
    [activityIndicator startAnimating];
    [wardsWebService getAllWardsForUser:nil withCallBackHandler:^(id response, NSError *error) {
        [activityIndicator stopAnimating];
        DCDebugLog(@"the wards web response: %@", response);
        if (!error) {
            NSArray *responseArray = [NSMutableArray arrayWithArray:response];
            wardsArray = [[NSMutableArray alloc] init];
            for (NSDictionary *wardsDictionary in responseArray) {
                DCWard *ward = [[DCWard alloc] initWithDicitonary:wardsDictionary];
                [wardsArray addObject:ward];
            }
            if ([wardsArray count] > 0) {
                DCDebugLog(@"the wards list array: %@", wardsArray);
                if ([wardsArray count] == 1) {
                    DCDebugLog(@"Single ward available");
                    [self performSegueWithIdentifier:SHOW_PATIENT_LIST_FROM_INITIAL_VIEW sender:nil];
                } else {
                    [self performSegueWithIdentifier:WARDS_SEGUE_ID sender:nil];
                }
            } else {
                [self displayAlertWithTitle:NSLocalizedString(@"WARNING", @"") message:NSLocalizedString(@"NO_WARDS_MESSAGE", @"No wards message")];
            }
        } else {
            if (error.code == NETWORK_NOT_REACHABLE) {
                [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
            } else if (error.code == WEBSERVICE_UNAVAILABLE) {
                
                [self displayAlertWithTitle:NSLocalizedString(@"ERROR", @"") message:NSLocalizedString(@"WEBSERVICE_UNAVAILABLE", @"")];
                
            } else {
                [self displayAlertWithTitle:NSLocalizedString(@"WARNING", @"") message:NSLocalizedString(@"NO_WARDS_MESSAGE", @"No wards message")];
            }
        }
        [authorizationViewController dismissViewControllerAnimated:YES completion:nil];
    }];
}


#pragma mark - DCAuthorizationViewControllerDelegate implementation

- (void)successfulLoginAction {
    
    isDismissActionForLogin = YES;
    if ([DCAPPDELEGATE isNetworkReachable]) {
        [self fetchAllWardsForUser];
    }
    [authorizationViewController dismissViewControllerAnimated:YES completion:nil];
}


@end
