//
//  ViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/2/15.
//
//

#import "DCLoginViewController.h"
#import "DCLoginWebService.h"
#import "DCPatientListViewController.h"
#import "DCTextField.h"
#import <QuartzCore/QuartzCore.h>

#import "DCErrorPopOverBackgroundView.h"
#import "DCErrorPopOverViewController.h"

#define LOGIN_VIEW_INITIAL_Y_ALIGNMENT 0.0f
#define LOGIN_VIEW_EDIT_Y_ALIGNMENT    130.0f
#define LOGIN_VIEW_ANIMATION_DURATION  0.3

#define PATIENT_LIST_NAVIGATION_DELAY_DEMO 0.5

#define TEXTFIELD_BG_COLOR @"#B6C6DB"

@interface DCLoginViewController () <UITextFieldDelegate> {

    IBOutlet UITextField *userNameTextField;
    IBOutlet UITextField *passwordTextField;
    IBOutlet NSLayoutConstraint *loginViewYAlignmentConstraint;
    IBOutlet UIButton *loginButton;
    IBOutlet UIActivityIndicatorView *loginButtonIndicatorView;
    IBOutlet UIView *errorView;
    
    UITextField *activeTextField;
    UIPopoverController *popOverController;
    BOOL userNameNotEntered;
    BOOL passwordNotEntered;
    BOOL keyboardDismissed;
}

@property (nonatomic, strong) DCErrorPopOverViewController *errorViewController;

@end

@implementation DCLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureLoginViewElementsOnViewLoad];
    [self addTapGestureOnViewToDismissKeypadOnTap];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    // in the login view we should not show the navigation bar.
    // navigation bar is hidden on view appear
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    // On view disappear navigation bar is shown back.
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)configureLoginViewElementsOnViewLoad {
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [loginButtonIndicatorView setHidden:YES]; // on view load login activity indicator is hidden
    });
    [errorView setHidden:YES];
    UIColor *placeholderColor = [UIColor getColorForHexString:PLACEHOLDER_COLOR_HEX];
    if ([userNameTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        userNameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"USERNAME", @"") attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    }
    if ([passwordTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"PASSWORD", @"") attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    }
}

- (void)addTapGestureOnViewToDismissKeypadOnTap {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(dismissKeyboard:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (BOOL)loginFieldsAreValid {
    
    //validate entries
    if ([userNameTextField.text isEqualToString:EMPTY_STRING] || [passwordTextField.text isEqualToString:EMPTY_STRING]) {
        if ([userNameTextField.text isEqualToString:EMPTY_STRING] && [passwordTextField.text isEqualToString:EMPTY_STRING] ) {
            userNameNotEntered = YES;
            passwordNotEntered = YES;
            [DCUtility modifyViewComponentForErrorDisplay:userNameTextField];
            [DCUtility modifyViewComponentForErrorDisplay:passwordTextField];
        }
        else {
            if ([userNameTextField.text isEqualToString:EMPTY_STRING]) {
                userNameNotEntered = YES;
                [DCUtility modifyViewComponentForErrorDisplay:userNameTextField];
                passwordNotEntered = NO;
                [self resetTextFieldAfterErrorCorrection:passwordTextField];
            }
            else if ([passwordTextField.text isEqualToString:EMPTY_STRING]) {
                passwordNotEntered = YES;
                [DCUtility modifyViewComponentForErrorDisplay:passwordTextField];
                userNameNotEntered = NO;
                [self resetTextFieldAfterErrorCorrection:userNameTextField];
            }
        }
    }
    else {
        passwordNotEntered = NO;
        userNameNotEntered = NO;
        [self resetTextFieldAfterErrorCorrection:userNameTextField];
        [self resetTextFieldAfterErrorCorrection:passwordTextField];
        return YES;
        //TODO: Valid email check has to be done here after API implementation.
    }
    return NO;
}

- (void)makeWebServiceCallForLogin {
    //login web service call
    DCLoginWebService *loginWebService = [[DCLoginWebService alloc] init];
    [loginWebService loginUserWithEmail:userNameTextField.text
                               password:passwordTextField.text
                               callback:^(id response, NSDictionary *error) {
        NSString *statusString = [error objectForKey:STATUS_KEY];
        if ([statusString isEqualToString:STATUS_ERROR]) {
            [self performSelector:@selector(stopLoadingIndicatorOnLoginButton)
                       withObject:nil
                       afterDelay:PATIENT_LIST_NAVIGATION_DELAY_DEMO];
            [errorView setHidden:NO];
        }
        else {
            [errorView setHidden:YES];
            [self performSelector:@selector(displayWardsList)
                    withObject:nil
                    afterDelay:PATIENT_LIST_NAVIGATION_DELAY_DEMO];
        }
    }];
}

- (void)displayPatientsList {
    //load patients list
    [self stopLoadingIndicatorOnLoginButton];
    //push patients view
    [self performSegueWithIdentifier:SHOW_PATIENT_LIST sender:self];
}

- (void)displayWardsList {
    
    [self stopLoadingIndicatorOnLoginButton];
    //push patients view
    [self performSegueWithIdentifier:SHOW_WARDS_LIST sender:self];
}

- (void)displayLoadingIndicatorOnLoginButton {
    //add this if activity indicator is to be displayed on button
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [loginButtonIndicatorView setHidden:NO];
        [loginButton setBackgroundImage:[UIImage imageNamed:nil] forState:UIControlStateNormal];
        [loginButtonIndicatorView startAnimating];
    });
}

- (void)stopLoadingIndicatorOnLoginButton {
    
    [self.view setUserInteractionEnabled:YES];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [loginButtonIndicatorView stopAnimating];
        [loginButtonIndicatorView setHidden:YES];
        [loginButton setBackgroundImage:[UIImage imageNamed:@"LoginButton"] forState:UIControlStateNormal];
    });
}

- (void)resetTextFieldAfterErrorCorrection:(UIView *)view {
    [view layer].borderColor = [UIColor getColorForHexString:TEXTFIELD_BG_COLOR].CGColor;
}

- (void)displayLoginFieldsErrorPopOverView:(UITextField *)textField {
    
    popOverController = [DCUtility getDisplayPopOverControllerOnView:textField];
    _errorViewController = (DCErrorPopOverViewController *)popOverController.contentViewController;
    __weak __typeof(DCErrorPopOverViewController *)weakErrorPopUp = _errorViewController;
    _errorViewController.viewLoaded = ^ {
        weakErrorPopUp.presentedTextfield = textField;
        if (textField.tag == 1) {
            weakErrorPopUp.errorMessage = NSLocalizedString(@"Blank Username", @"");
        }
        else {
            weakErrorPopUp.errorMessage = NSLocalizedString(@"Blank Password", @"");
        }
    };

}

- (void)repositionPopOverControllerInView:(UIView *)textField {
    
    //reposition error pop over on keyboard show/hide
    if (_errorViewController) {
        if ((_errorViewController.presentedTextfield == userNameTextField && userNameNotEntered) ||
            (_errorViewController.presentedTextfield == passwordTextField && passwordNotEntered)) {
            [popOverController dismissPopoverAnimated:YES];
            [_errorViewController removeFromParentViewController];
            popOverController = [DCUtility getDisplayPopOverControllerOnView:textField];
            _errorViewController = (DCErrorPopOverViewController *)popOverController.contentViewController;
            __weak __typeof(DCErrorPopOverViewController *)weakErrorPopUp = _errorViewController;
            __weak __typeof(UITextField *)weakUsernameTextField = userNameTextField;
            __weak __typeof(self)weakSelf = self;
            _errorViewController.viewLoaded = ^ {
                weakErrorPopUp.presentedTextfield = textField;
                NSString *errorMessage;
                if (textField == weakUsernameTextField) {
                    errorMessage = NSLocalizedString(@"Blank Username", @"");
                } else {
                    errorMessage = NSLocalizedString(@"Blank Password", @"");
                }
                [weakSelf displayErrorMessage:errorMessage];
            };
        }
    }
}

- (void)displayErrorMessage:(NSString *)error {
    
    //set error message to viewcontroller
    _errorViewController.errorMessage = error;
}

- (void)dismissPopOverController {
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (popOverController) {
            [popOverController dismissPopoverAnimated:YES];
        }
    });
}

#pragma mark - Textfield Delegate Methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    activeTextField = textField;
    if (textField == userNameTextField && userNameNotEntered) {
        [self displayLoginFieldsErrorPopOverView:textField];
    }
    else if (textField == passwordTextField && passwordNotEntered) {
        [self displayLoginFieldsErrorPopOverView:textField];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == userNameTextField) {
        if (![string isEqualToString:EMPTY_STRING]) {
            userNameNotEntered = NO;
            [self dismissPopOverController];
        } else if ([string isEqualToString:EMPTY_STRING] && range.location == 0 && [DCUtility isDetectedErrorField:textField]) {
            userNameNotEntered = YES;
            [self displayLoginFieldsErrorPopOverView:textField];
        }
    } else {
        
        if (![string isEqualToString:EMPTY_STRING]) {
            passwordNotEntered = NO;
            [self dismissPopOverController];
        } else if ([string isEqualToString:EMPTY_STRING] && range.location == 0 && [DCUtility isDetectedErrorField:textField]) {
            passwordNotEntered = YES;
            [self displayLoginFieldsErrorPopOverView:textField];
        }
    }
    return YES;
}

#pragma mark - Action Methods

- (IBAction)loginButtonPressed:(id)sender {
    
    if (DEBUG) {
        //TODO: Just for debug purpose. to be deleted for release.
        userNameTextField.text = @"doctor";
        passwordTextField.text = @"doctor";
    }
    if ([self loginFieldsAreValid]) {
        [activeTextField resignFirstResponder];
        [self.view setUserInteractionEnabled:NO];
        [self displayLoadingIndicatorOnLoginButton];
        [self makeWebServiceCallForLogin];
    }
}

- (IBAction)dismissKeyboard:(id)gesture {
    
    [activeTextField resignFirstResponder];
}

#pragma keyboard notification Methods

- (void)keyboardDidShow:(NSNotification *)notification {
    
    [self repositionPopOverControllerInView:_errorViewController.presentedTextfield];
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [UIView animateWithDuration:LOGIN_VIEW_ANIMATION_DURATION animations:^{
        loginViewYAlignmentConstraint.constant = keyboardSize.height/2 - 10;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    [self repositionPopOverControllerInView:_errorViewController.presentedTextfield];
    [UIView animateWithDuration:LOGIN_VIEW_ANIMATION_DURATION animations:^{
        loginViewYAlignmentConstraint.constant = LOGIN_VIEW_INITIAL_Y_ALIGNMENT;
        [self.view layoutIfNeeded];
    }];
}

@end
