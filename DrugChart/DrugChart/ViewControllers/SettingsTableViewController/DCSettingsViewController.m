//
//  DCSettingsViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/04/15.
//
//

#import "DCSettingsViewController.h"

@interface DCSettingsViewController ()

@end

@implementation DCSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self edgesForExtendedLayout];
    [self configureNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.view.superview.layer.cornerRadius = 0.0f;
    self.view.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureNavigationBar {

    [self.navigationController.navigationBar setBarTintColor:[UIColor colorForHexString:@"#4dc8e9"]];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor colorForHexString:@"#ffffff"], NSFontAttributeName: [UIFont fontWithName:@"Lato-Bold" size:15.0]};
    self.view.superview.clipsToBounds = YES;
}

- (IBAction)logoutTapped:(UIButton *)sender {
    
  
    if (self.delegate && [self.delegate respondsToSelector:@selector(logOutTapped)]) {
        [self.delegate logOutTapped];
    }
}

@end
