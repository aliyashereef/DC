//
//  DCOverrideViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 5/29/15.
//
//

#import "DCOverrideViewController.h"
#import "RoundRectPresentationController.h"

#define BORDER_WIDTH 0.6
#define CORNER_RADIUS 3

@interface DCOverrideViewController () <UIViewControllerTransitioningDelegate> {
    
    __weak IBOutlet UITextView *reasonTextView;
    BOOL blankReason;
    UIPopoverController *popOverController;
    DCErrorPopOverViewController *errorViewController;
}

@end

@implementation DCOverrideViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    //registering presentation controller
    self = [super initWithCoder:aDecoder];
    if (self && [self respondsToSelector:@selector(setTransitioningDelegate:)]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
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

#pragma mark - Private Methods

- (void)configureViewElements {
    
    reasonTextView.layer.borderWidth = BORDER_WIDTH;
    reasonTextView.layer.cornerRadius = CORNER_RADIUS;
    reasonTextView.layer.borderColor = [UIColor getColorForHexString:@"#b1b1b1"].CGColor;
    [reasonTextView setTextContainerInset:TEXTVIEW_EDGE_INSETS];
    reasonTextView.text = NSLocalizedString(@"OVERRIDE REASON", @"");
}

- (void)displayErrorPopOverView:(UITextView *)textView {
    
    //display error pop over here
    popOverController = [DCUtility getDisplayPopOverControllerOnView:textView];
    errorViewController = (DCErrorPopOverViewController *)popOverController.contentViewController;
    __weak __typeof(self)weakSelf = self;
    errorViewController.viewLoaded = ^ {
        [weakSelf displayErrorMessage:NSLocalizedString(@"INVALID_REASON", @"")];
    };
}

- (void)repositionPopOverControllerInView {
    
    //reposition error pop over on keyboard show/hide
    if (errorViewController && blankReason) {
        [popOverController dismissPopoverAnimated:YES];
        [errorViewController removeFromParentViewController];
        popOverController = [DCUtility getDisplayPopOverControllerOnView:reasonTextView];
        errorViewController = (DCErrorPopOverViewController *)popOverController.contentViewController;
        __weak __typeof(self)weakSelf = self;
        errorViewController.viewLoaded = ^ {
            [weakSelf displayErrorMessage:NSLocalizedString(@"INVALID_REASON", @"")];
        };
    }
}

- (void)displayErrorMessage:(NSString *)error {
    
    //set error message to viewcontroller
    errorViewController.errorMessage = error;
}

#pragma mark - TextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:NSLocalizedString(@"OVERRIDE REASON", @"")]) {
        textView.text = EMPTY_STRING;
    }
    if (blankReason) {
        [self displayErrorPopOverView:textView];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (![text isEqualToString:EMPTY_STRING]) {
        blankReason = NO;
        if (popOverController) {
            [popOverController dismissPopoverAnimated:YES];
        }
    } else if ([text isEqualToString:EMPTY_STRING] && range.location == 0 && [DCUtility isDetectedErrorField:textView]) {
        blankReason = YES;
        [self displayErrorPopOverView:textView];
    }
    return YES;
}

#pragma mark - Action Methods

- (IBAction)doneButtonPressed:(id)sender {
    
    [reasonTextView resignFirstResponder];
    if ([reasonTextView.text isEqualToString:EMPTY_STRING] || [reasonTextView.text isEqualToString:NSLocalizedString(@"OVERRIDE REASON", @"")]) {
        //validation
        blankReason = YES;
        [DCUtility modifyViewComponentForErrorDisplay:reasonTextView];
    } else  {
        self.reasonSubmitted (YES);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [reasonTextView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:^{
        self.reasonSubmitted (NO);
    }];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    RoundRectPresentationController *roundRectPresentationController = [[RoundRectPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    roundRectPresentationController.viewType = eOverride;
    return roundRectPresentationController;
}

#pragma mark - keyboard notification Methods

- (void)keyboardDidShow:(NSNotification *)notification {
    
    //override keyboard show notification
    [self repositionPopOverControllerInView];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = CGRectMake(self.view.frame.origin.x,
                                  keyboardSize.height/4,
                                  self.view.frame.size.width, self.view.frame.size.height);
        self.view.frame = frame;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    //override keyboard hide notification
    [self repositionPopOverControllerInView];
    [self.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    UIWindow *mainWindow = [UIApplication sharedApplication].windows[0];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = CGRectMake(self.view.frame.origin.x,
                                  (mainWindow.frame.size.height - self.view.frame.size.height) / 2,
                                  self.view.frame.size.width, self.view.frame.size.height);
        self.view.frame = frame;
        [self.view layoutIfNeeded];
    }];
}

@end
