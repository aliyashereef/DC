//
//  ErrorPopOverViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/31/15.
//
//

#import "DCErrorPopOverViewController.h"

static CGFloat kCornerRadius = 3.5f;

@interface DCErrorPopOverViewController ()

@property (nonatomic, weak) IBOutlet UILabel *errorLabel;

@end

@implementation DCErrorPopOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.superview.layer.cornerRadius = kCornerRadius;
    self.viewLoaded();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setErrorMessage:(NSString *)errorMessage {
    //set error message to label
    dispatch_async(dispatch_get_main_queue(), ^{
        _errorLabel.text = errorMessage;
    });
}


@end
