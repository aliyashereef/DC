//
//  DCNameSelectionTableViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 17/03/15.
//
//

#import "DCNameSelectionTableViewController.h"
#import "DCUser.h"

#define TABLE_REUSE_IDENTIFIER @"NameCell"

@interface DCNameSelectionTableViewController () {
    
}

@end

@implementation DCNameSelectionTableViewController

#pragma mark - View Management Methods

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
}

- (void)viewDidLayoutSubviews {
    
    [super viewDidLayoutSubviews];
}

#pragma mark - Memory Management Methods

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    [self.navigationController popViewControllerAnimated:YES];
}

@end
