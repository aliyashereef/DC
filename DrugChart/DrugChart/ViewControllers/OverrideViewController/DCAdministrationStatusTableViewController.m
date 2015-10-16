//
//  DCAdministrationStatusTableViewController.m
//  DrugChart
//
//  Created by aliya on 14/10/15.
//
//

#import "DCAdministrationStatusTableViewController.h"
#import "DCUser.h"

#define TABLE_REUSE_IDENTIFIER @"StatusCell"

@implementation DCAdministrationStatusTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _namesArray = @[ADMINISTERED, REFUSED, OMITTED];
    self.navigationController.navigationBarHidden = YES;
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
    NSString *status = [_namesArray objectAtIndex:indexPath.item];
    cell.textLabel.font = [UIFont systemFontOfSize:15.0];
    cell.textLabel.text = status;
    cell.accessoryType = ([status isEqualToString:_previousSelectedValue]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //pass the selected medication status to parent
    NSString *status = [_namesArray objectAtIndex:indexPath.row];
    if (self.medicationStatusDelegate && [self.medicationStatusDelegate respondsToSelector:@selector(selectedMedicationStatusEntry:)]) {
        [self.medicationStatusDelegate selectedMedicationStatusEntry:status];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
