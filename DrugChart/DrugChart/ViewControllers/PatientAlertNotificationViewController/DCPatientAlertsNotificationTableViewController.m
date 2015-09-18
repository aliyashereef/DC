//
//  DCPatientAlertsNotificationTableViewController.m
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/04/15.
//
//

#import "DCPatientAlertsNotificationTableViewController.h"
#import "DCPatientAlertsNotificationTableViewCell.h"

#define LATO_REGULAR_TWELVE [UIFont fontWithName:@"Lato-Regular" size:12]
#define WIDTH_ALERT_NAME_LABEL 313
#define ALERT_CELL_HEIGHT_MIN 65
#define ALERT_CELL_HEIGHT_MAX 390
#define CELL_PADDING 50



@interface DCPatientAlertsNotificationTableViewController (){
    NSMutableArray *cellHeightArray;
}

@end

@implementation DCPatientAlertsNotificationTableViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        cellHeightArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.scrollEnabled = YES;
    
    [self configureNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.navigationController.view.superview.layer.cornerRadius = 2.0f;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureNavigationBar {
    
    NSShadow* shadow = [NSShadow new];
    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor getColorForHexString:@"#ffffff"], NSFontAttributeName: [UIFont fontWithName:@"Lato-Bold" size:15.0]};
    [self.navigationController.navigationBar setBarTintColor:[UIColor getColorForHexString:@"#4dc8e9"]];
}

#pragma mark - Table view data source
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {    
//    return [self.patientsAlertsArray count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    DCPatientAlertsNotificationTableViewCell *patientAlertsNotificationTableViewCell =
//    [tableView dequeueReusableCellWithIdentifier:PATIENT_ALERTS_NOTIFICATION_CELL_IDENTIFIER
//                                    forIndexPath:indexPath];
//    if (patientAlertsNotificationTableViewCell == nil) {
//        patientAlertsNotificationTableViewCell =
//        [[DCPatientAlertsNotificationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                                        reuseIdentifier:PATIENT_ALERTS_NOTIFICATION_CELL_IDENTIFIER];
//    }
//    DCPatientAlert *patientAlert = [self.patientsAlertsArray objectAtIndex:indexPath.item];
//    [patientAlertsNotificationTableViewCell configurePatientsAlertCell:patientAlert];
//    return patientAlertsNotificationTableViewCell;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;{
    
    CGFloat heightForCell = [[cellHeightArray objectAtIndex:indexPath.row] floatValue];
    return (heightForCell > ALERT_CELL_HEIGHT_MIN ? heightForCell : ALERT_CELL_HEIGHT_MIN);
}

- (CGFloat )computeTotalCellsHeightAndPrepareCellHeightsArrayForAllergyTableView {
    
    cellHeightArray = [[NSMutableArray alloc] init];
    CGFloat totalAlertCellsHeight;
    for(DCPatientAlert *patientAlert in self.patientsAlertsArray){
        CGSize stepSize = [DCUtility getRequiredSizeForText:patientAlert.alertText
                                                       font:LATO_REGULAR_TWELVE
                                                   maxWidth:WIDTH_ALERT_NAME_LABEL];
        
        CGFloat alertCellHeight = CELL_PADDING + stepSize.height ;
        [cellHeightArray addObject:[NSNumber numberWithFloat:alertCellHeight]];
        totalAlertCellsHeight += alertCellHeight;
    }
    return totalAlertCellsHeight;
}
- (CGFloat)getTableViewHeight {
    
    CGFloat totalAlertCellsHeight = [self computeTotalCellsHeightAndPrepareCellHeightsArrayForAllergyTableView];
    CGFloat heightForFirstCell = [[cellHeightArray objectAtIndex:0] floatValue];
    if (_patientsAlertsArray.count == 1) {
        return heightForFirstCell;
    }
    else {
        if (totalAlertCellsHeight > ALERT_CELL_HEIGHT_MAX || _patientsAlertsArray.count > 5) {
            return ALERT_CELL_HEIGHT_MAX;
        }
        return totalAlertCellsHeight;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
