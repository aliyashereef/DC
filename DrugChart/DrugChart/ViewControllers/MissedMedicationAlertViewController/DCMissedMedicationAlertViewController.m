//
//  DCMissedMedicationAlertViewController.m
//  DrugChart
//
//  Created by qbuser on 09/04/15.
//
//

#import "DCMissedMedicationAlertViewController.h"
#import "RoundRectPresentationController.h"

@interface DCMissedMedicationAlertViewController () {
    
    __weak IBOutlet UILabel *titleLabel;
    __weak IBOutlet UILabel *messageLabel;
    __weak IBOutlet UIButton *cancelButton;
    __weak IBOutlet UIButton *okButton;
    __weak IBOutlet UIButton *yesButton;
    __weak IBOutlet UIButton *removeMedicationButton;
}

@end

@implementation DCMissedMedicationAlertViewController

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
    [self configureViewParameters];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (void)configureViewParameters {
    
    switch (_alertType) {
            
        case eDeleteMedicationConfirmation:
            titleLabel.text = NSLocalizedString(@"CONFIRMATION", @"");
            messageLabel.text = [NSString stringWithFormat:@"%@ %@", self.medicineName, NSLocalizedString(@"MEDICATION_STOP_ALERT_MESSAGE", @"alert message")];
            [cancelButton setHidden:NO];
            [yesButton setHidden:NO];
            [okButton setHidden:YES];
            break;
        case eSaveAdministerDetails:
            titleLabel.text = NSLocalizedString(@"CONFIRMATION", @"");
            messageLabel.font = [UIFont fontWithName:@"Lato-Regular" size:13.5];
            messageLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"SAVE_ADMINISTER", @"alert message")];
            [cancelButton setHidden:NO];
            [yesButton setHidden:NO];
            [okButton setHidden:YES];
            break;
        case eErrorDefaultAlertType:
            titleLabel.text = [NSString stringWithFormat:@"%@",self.alertTitle];
            messageLabel.font = [UIFont fontWithName:@"Lato-Regular" size:13.5];
            messageLabel.text = [NSString stringWithFormat:@"%@",self.message];
            [cancelButton setHidden:YES];
            [yesButton setHidden:YES];
            [okButton setHidden:NO];
            break;
        case eOrderSetDeleteConfirmation:
            titleLabel.text = NSLocalizedString(@"CONFIRMATION", @"");
            messageLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"ORDERSET_DELETE_CONFIRMATION", @"alert message")];
            [cancelButton setHidden:NO];
            [yesButton setHidden:NO];
            [okButton setHidden:YES];
            break;
        case eOrderSetNameClearConfirmation:
        case eNewOrderSetSelection:
            titleLabel.text = NSLocalizedString(@"CONFIRMATION", @"");
            messageLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"ORDERSET_CLEAR_CONFIRMATION", @"alert message")];
            [cancelButton setHidden:NO];
            [yesButton setHidden:NO];
            [okButton setHidden:YES];
            break;
        case eAddSubstitute:
            titleLabel.text = NSLocalizedString(@"ADD_SUBSTITUTE_TITLE", @"");
            messageLabel.font = [UIFont fontWithName:@"Lato-Regular" size:13.5];
            messageLabel.text = [NSString stringWithFormat:@"%@ %@ ?", NSLocalizedString(@"ADD_SUBSTITUTE_MESSAGE", @"alert message"), self.medicineName];
            [cancelButton setHidden:NO];
            [yesButton setHidden:NO];
            [okButton setHidden:YES];
            [removeMedicationButton setHidden:NO];
            break;
        default:
            messageLabel.font = [UIFont fontWithName:@"Lato-Regular" size:14.0];
            break;
    }
}

- (IBAction)okButtonClicked:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.dismissView();
    }];
}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        self.dismissViewWithoutSaving();
     }];
}

- (IBAction)removeMedicationButtonPressed:(id)sender {
    
    //remove medication action
    [self dismissViewControllerAnimated:YES completion:^{
        self.removeMedication();
    }];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    RoundRectPresentationController *roundRectPresentationController = [[RoundRectPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    roundRectPresentationController.isMissedAlert = YES;
    return roundRectPresentationController;
}

@end
