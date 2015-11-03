//
//  DCPrescriberFilterTableViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/1/15.
//
//

#import "DCPrescriberFilterTableViewController.h"
#import "DCPrescriberFilterCell.h"

@interface DCPrescriberFilterTableViewController () {
    NSArray *filterArray;
    NSIndexPath *previousIndexPath;
}

@end

@implementation DCPrescriberFilterTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize=self.tableView.contentSize;
    filterArray = @[DRUG_TYPE, START_DATE_ORDER, ALPHABETICAL_ORDER];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureViewElements];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Private Methods

- (void)configureViewElements {
    self.view.layer.borderColor = [UIColor clearColor].CGColor;
    self.view.layer.cornerRadius = 0.0f;
    self.view.superview.layer.cornerRadius = 0.0;
    [self.view clipsToBounds];
}

- (void)getPreviousIndexPathFromSortedType {
    
    NSString *sortType = [[NSUserDefaults standardUserDefaults] valueForKey:kSortType];
    if ([sortType isEqualToString:DRUG_TYPE]) {
        
        previousIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    } else if ([sortType isEqualToString:START_DATE_ORDER]) {
        
        previousIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    } else {
        
        previousIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCPrescriberFilterCell *filterCell = (DCPrescriberFilterCell *)[tableView dequeueReusableCellWithIdentifier:MEDICINE_FILTER_CELL_IDENTIFIER];
    if (filterCell == nil) {
        filterCell = [[DCPrescriberFilterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MEDICINE_FILTER_CELL_IDENTIFIER];
    }
    filterCell.textLabel.backgroundColor = [UIColor clearColor];
    filterCell.textLabel.font = [DCFontUtility getLatoRegularFontWithSize:13.0f];
    filterCell.textLabel.textColor = [UIColor getColorForHexString:@"#676767"];
    filterCell.textLabel.text = [filterArray objectAtIndex:indexPath.row];
    NSString *sortType = [[NSUserDefaults standardUserDefaults] valueForKey:kSortType];
    if ([sortType isEqualToString:filterCell.textLabel.text]) {
        
        [filterCell.selectionImageView setImage:[UIImage imageNamed:TICK_IMAGE]];
    } else {
        
        [filterCell.selectionImageView setImage:nil];
    }
    if (previousIndexPath == nil) {
        previousIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    return filterCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self getPreviousIndexPathFromSortedType];
    DCPrescriberFilterCell *previousFilterCell = (DCPrescriberFilterCell *)[tableView cellForRowAtIndexPath:previousIndexPath];
    [previousFilterCell.selectionImageView setImage:nil];
    NSString *selectedfilter = [filterArray objectAtIndex:indexPath.row];
    DCPrescriberFilterCell *filterCell = (DCPrescriberFilterCell *)[tableView cellForRowAtIndexPath:indexPath];
    [filterCell.selectionImageView setImage:[UIImage imageNamed:TICK_IMAGE]];
    [[NSUserDefaults standardUserDefaults] setObject:selectedfilter forKey:kSortType];
    self.filterCriteria (selectedfilter);
    [self dismissViewControllerAnimated:YES completion:^{
        [self.delegate sortMedicationListSelectionChanged:indexPath.row];
    }];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
