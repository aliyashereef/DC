//
//  DCSecurityPinViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/30/15.
//
//

#import "DCSecurityPinViewController.h"
#import "RoundRectPresentationController.h"
#import "DCSecurityPinWebService.h"

@interface DCSecurityPinViewController ()  <UIViewControllerTransitioningDelegate> {
    
    IBOutlet UITextField *firstDigitTextfield;
    IBOutlet UITextField *secondDigitTextField;
    IBOutlet UITextField *thirdDigitTextField;
    IBOutlet UITextField *fourthDigitTextfield;
    IBOutlet UIView *errorView;
}

@end

@implementation DCSecurityPinViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
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

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [firstDigitTextfield becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)configureViewElements {
    [firstDigitTextfield setTextAlignment:NSTextAlignmentCenter];
    [secondDigitTextField setTextAlignment:NSTextAlignmentCenter];
    [thirdDigitTextField setTextAlignment:NSTextAlignmentCenter];
    [fourthDigitTextfield setTextAlignment:NSTextAlignmentCenter];
}

- (BOOL)securityPinIsValid {
    
    //check for pin validity
    BOOL isValid = YES;
    if ([firstDigitTextfield.text isEqualToString:EMPTY_STRING]) {
        [DCUtility modifyViewComponentForErrorDisplay:firstDigitTextfield];
        isValid = NO;
    } else {
        [DCUtility resetTextFieldAfterErrorCorrection:firstDigitTextfield withColor:[UIColor clearColor]];
    }
    if ([secondDigitTextField.text isEqualToString:EMPTY_STRING]) {
        [DCUtility modifyViewComponentForErrorDisplay:secondDigitTextField];
        isValid = NO;
    } else {
        [DCUtility resetTextFieldAfterErrorCorrection:secondDigitTextField withColor:[UIColor clearColor]];
    }
    if ([thirdDigitTextField.text isEqualToString:EMPTY_STRING]) {
        [DCUtility modifyViewComponentForErrorDisplay:thirdDigitTextField];
         isValid = NO;
    } else {
        [DCUtility resetTextFieldAfterErrorCorrection:secondDigitTextField withColor:[UIColor clearColor]];
    }
    if ([fourthDigitTextfield.text isEqualToString:EMPTY_STRING]) {
        [DCUtility modifyViewComponentForErrorDisplay:fourthDigitTextfield];
         isValid = NO;
    } else {
        [DCUtility resetTextFieldAfterErrorCorrection:fourthDigitTextfield withColor:[UIColor clearColor]];
    }
    
    return isValid;
}

- (void)callSecurityPinWebService:(NSString *)pin {
    
    //Security pin web service call
    DCSecurityPinWebService *securityPinWebService = [[DCSecurityPinWebService alloc] init];
    [securityPinWebService checkSecurityPin:pin withCallbackHandler:^(id response, NSError *error) {
        
        if (response) {
            
            [self dismissViewControllerAnimated:YES completion:^{
                
                self.securityPinEntered (pin);
            }];
        } else {
            
            [DCUtility modifyViewComponentForErrorDisplay:firstDigitTextfield];
            [DCUtility modifyViewComponentForErrorDisplay:secondDigitTextField];
            [DCUtility modifyViewComponentForErrorDisplay:thirdDigitTextField];
            [DCUtility modifyViewComponentForErrorDisplay:fourthDigitTextfield];
            [errorView setHidden:NO];
        }
    }];
}

#pragma mark - TextFieldDelegate Methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ((textField.text.length >= 1) && (string.length > 0)) {
        
        NSInteger nextTag = textField.tag + 1;
        // find next responder
        UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
        if (nextResponder) {
            [nextResponder becomeFirstResponder];
            UITextField *nextTextfield = (UITextField *)[self.view viewWithTag:nextTag];
            nextTextfield.text = string;
        } else {
            
            nextResponder = [textField.superview viewWithTag:1];
        }
        return NO;
    }  else {
        if (string.length == 0 && textField.text.length == 1) {
            
            textField.text = string;
            NSInteger previousTag = textField.tag - 1;
            // find previous responder
            UIResponder *previousResponder = [textField.superview viewWithTag:previousTag];
            if (previousResponder) {
                [previousResponder becomeFirstResponder];
            } else {
                previousResponder = [textField.superview viewWithTag:1];
            }
            return NO;
        }
    }
    return YES;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    RoundRectPresentationController *roundRectPresentationController = [[RoundRectPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    roundRectPresentationController.viewType = eSecurity;
    return roundRectPresentationController;
}

#pragma mark - keyboard notification Methods

- (void)keyboardDidShow:(NSNotification *)notification {
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self.view setTranslatesAutoresizingMaskIntoConstraints:YES];
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = CGRectMake(self.view.frame.origin.x,
                                  keyboardSize.height/2,
                                  self.view.frame.size.width, self.view.frame.size.height);
        DDLogInfo(@"%f %f",frame.size.height,frame.size.width);
        self.view.frame = frame;
        [self.view layoutSubviews];
    }];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
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

#pragma mark - Action Methods

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)okButtonPressed:(id)sender {
    
    if ([self securityPinIsValid]) {
        
        [errorView setHidden:YES];
        NSString *pin = [NSString stringWithFormat:@"%@%@%@%@", firstDigitTextfield.text, secondDigitTextField.text, thirdDigitTextField.text,fourthDigitTextfield.text];
        [self callSecurityPinWebService:pin];
        
//        [self dismissViewControllerAnimated:YES completion:^{
//            self.securityPinEntered (pin);
//        }];
    } else {
        
        [errorView setHidden:NO];
    }
}

@end
