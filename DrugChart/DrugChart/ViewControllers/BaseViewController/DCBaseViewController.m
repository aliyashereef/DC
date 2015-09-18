//
//  DCBaseViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/2/15.
//
//

#import "DCBaseViewController.h"
#import "DCMissedMedicationAlertViewController.h"

@interface DCBaseViewController ()

@end

@implementation DCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self addNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private Methods

- (void)addNotifications {
    //keyboard show/hide observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

#pragma mark - Public Methods

- (void)displayAlertWithTitle:(NSString *)title
                      message:(NSString *)message {
    //display alert view for view controllers
    UIAlertController *alertController = [UIAlertController
                               alertControllerWithTitle:title
                               message:message
                               preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:OK_BUTTON_TITLE style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action){
                                                   //dismiss alertview
                                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                                               }];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Notification Methods

- (void)keyboardDidShow:(NSNotification *)notification {
    self.keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
}

@end
