//
//  NameSelectionTableViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 17/03/15.
//
//

#import "NameSelectionTableViewController.h"

#define TABLE_REUSE_IDENTIFIER @"NameCell"

@interface NameSelectionTableViewController () {
    
}

@end

@implementation NameSelectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

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
    cell.textLabel.text = [_namesArray objectAtIndex:indexPath.item];
    cell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:14.0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //pass the selected user name to parent
    NSString *selectedName = [_namesArray objectAtIndex:indexPath.row];
    self.userSelectionHandler(selectedName);
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
