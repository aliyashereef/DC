//
//  NameSelectionTableViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 17/03/15.
//
//

#import "NameSelectionTableViewController.h"
#import "DCUser.h"

#define TABLE_REUSE_IDENTIFIER @"NameCell"

@interface NameSelectionTableViewController () {
    
}

@end

@implementation NameSelectionTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self addNavigationBarButtons];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
    [self displayNavigationBarBasedOnSizeClass];
}

- (void)displayNavigationBarBasedOnSizeClass {
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    CGFloat windowWidth = [DCUtility getMainWindowSize].width;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if ((orientation == UIInterfaceOrientationLandscapeLeft) || (orientation == UIInterfaceOrientationLandscapeRight)) {
        if (windowWidth > screenWidth/2) {
            [self showNavigationBar:NO];
        } else {
            [self showNavigationBar:YES];
        }
    } else {
        if (windowWidth < screenWidth) {
            [self showNavigationBar:YES];
        } else {
            [self showNavigationBar:NO];
        }
    }
}

- (void)addNavigationBarButtons {
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
}

- (void)showNavigationBar:(BOOL)show {
    
    if (show) {
        self.navigationController.navigationBarHidden = NO;
    } else {
        self.navigationController.navigationBarHidden = YES;
    }
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [_namesArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TABLE_REUSE_IDENTIFIER forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TABLE_REUSE_IDENTIFIER];
    }
    DCUser *user = [_namesArray objectAtIndex:indexPath.item];
    NSString *name = user.displayName;
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.text = name;
    cell.accessoryType = ([name isEqualToString:_previousSelectedValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //pass the selected user name to parent
    DCUser *selectedUser = [_namesArray objectAtIndex:indexPath.row];
    if (self.namesDelegate && [self.namesDelegate respondsToSelector:@selector(selectedUserEntry:)]) {
        [self.namesDelegate selectedUserEntry:selectedUser];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Action Methods

- (IBAction)cancelButtonPressed:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
