//
//  DCAddMedicationDetailViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/3/15.
//
//

#import "DCOverrideViewController.h"
#import "DCAddMedicationInitialViewController.h"
#import "DrugChart-Swift.h"

#define DEFAULT_SECTION_COUNT                   1


@interface DCOverrideViewController () {
    
    __weak IBOutlet UITableView *detailTableView;
    
    BOOL doneClicked;
}

@end

@implementation DCOverrideViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureViewElements];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    CGRect titleBarFrame = self.navigationController.navigationBar.frame;
    if ([DCAPPDELEGATE windowState] == oneThirdWindow || [DCAPPDELEGATE windowState] == halfWindow) {
        titleBarFrame.size.height = NAVIGATION_BAR_HEIGHT_WITH_STATUS_BAR;
    } else {
        titleBarFrame.size.height = NAVIGATION_BAR_HEIGHT_NO_STATUS_BAR;
    }
    self.navigationController.navigationBar.frame = titleBarFrame;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)configureViewElements {
    
    //configure view properties
    [self configureNavigationBarItems];
    [detailTableView setHidden:NO];
}

- (void)configureNavigationBarItems {
    
    [self configureNavigationTitleView];
    [self addNavigationBarButtonItems];
}

- (void)configureNavigationTitleView {
    
    //populate navigation title
    self.title = NSLocalizedString(@"REASON", @"");
}

- (void)addNavigationBarButtonItems {
    
    //navigation bar button items
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:CANCEL_BUTTON_TITLE  style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
                                   initWithTitle:DONE_BUTTON_TITLE style:UIBarButtonItemStylePlain  target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;

}

#pragma mark - UITableView Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return DEFAULT_SECTION_COUNT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = OVERRIDE_REASON_CELL_ID;
    DCReasonCell *reasonCell = [detailTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (reasonCell == nil) {
        reasonCell = [[DCReasonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    reasonCell.reasonTextView.textColor = doneClicked ? [UIColor redColor] : [UIColor colorForHexString:@"#8f8f95"];
    return reasonCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([DCAPPDELEGATE windowState] == oneThirdWindow || [DCAPPDELEGATE windowState] == halfWindow) {
        return (self.view.frame.size.height-133);
    } else {
        return (self.view.frame.size.height-114);
    }
}

#pragma mark - Action Methods

- (IBAction)doneButtonPressed:(id)sender {
    
    doneClicked = YES;
    DCReasonCell *reasonCell = (DCReasonCell *)[detailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    if (![reasonCell.reasonTextView.text isEqualToString:EMPTY_STRING] && ![reasonCell.reasonTextView.text isEqualToString:REASON]) {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(overrideReasonSubmittedInDetailView:)]) {
                [self.delegate overrideReasonSubmittedInDetailView:reasonCell.reasonTextView.text];
            }
        }];
    } else {
        [detailTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }

}

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end
