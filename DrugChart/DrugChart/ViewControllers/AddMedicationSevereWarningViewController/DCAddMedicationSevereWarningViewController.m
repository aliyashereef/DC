//
//  DCAddMedicationSevereWarningViewController.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/21/15.
//
//

#import "DCAddMedicationSevereWarningViewController.h"
#import "RoundRectPresentationController.h"
#import "DCWarningsPopoverCell.h"


@interface DCAddMedicationSevereWarningViewController () <UIViewControllerTransitioningDelegate> {
    
    IBOutlet UITableView *warningsTableView;
    IBOutlet UIView *topView;
    WarningType warningType;
    NSInteger severeWarningsCount;
    NSArray *warningsArray;
    CGFloat contentViewHeight;
}

@end

@implementation DCAddMedicationSevereWarningViewController

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
}

- (void)viewDidLayoutSubviews {
    
    [DCUtility roundCornersForView:topView roundTopCorners:YES];
    [super viewDidLayoutSubviews];
}

#pragma mark - Public Methods

- (void)populateViewWithWarningsDetails:(NSArray *)warnings {
    
    warningsArray = warnings;
    [self displayWarningsArrayContent];
}

#pragma mark - Private Methods

- (void)displayWarningsArrayContent {
    
    NSMutableArray *contentArray = [[NSMutableArray alloc] init];
    NSArray *severeWarnings;
    if ([self hasWarningForType:eSevere]) {
        severeWarnings = [[warningsArray objectAtIndex:0]valueForKey:SEVERE_WARNING];
        [contentArray addObjectsFromArray:severeWarnings];
        if ([self hasWarningForType:eMild]) {
            NSArray *mildArray = [self getMildWarningsFromWarningsArrayIndex:1];
            [contentArray addObjectsFromArray:mildArray];
        }
    } else {
        NSArray *mildArray = [self getMildWarningsFromWarningsArrayIndex:0];
        [contentArray addObjectsFromArray:mildArray];
    }
    severeWarningsCount = [severeWarnings count];
    warningsArray = [NSMutableArray arrayWithArray:contentArray];
    [self calculateContentViewHeight];
    [warningsTableView reloadData];
}

- (void)calculateContentViewHeight {
    
    NSMutableArray *contentHeightsArray = [[NSMutableArray alloc] init];
    for (DCWarning *warning in warningsArray) {
        UIFont *titleFont;
        if ([warning.severity isEqualToString:SEVERE_KEY]) {
            //handle severe warning case
            titleFont = [DCFontUtility getLatoRegularFontWithSize:15.0];
        } else if ([warning.severity isEqualToString:MILD_KEY]) {
            //handle mild warning case
            titleFont = [DCFontUtility getLatoRegularFontWithSize:13.0];
        }
        CGFloat titleHeight = [DCUtility getRequiredSizeForText:warning.title font:titleFont maxWidth:300.0f].height;
        titleHeight = titleHeight < 35.0f ? titleHeight + 2 : titleHeight;
        CGFloat descriptionHeight = [DCUtility getRequiredSizeForText:warning.detail
                                                                             font:[DCFontUtility getLatoRegularFontWithSize:13.0]
                                                                         maxWidth:262.0f].height;
        if (titleHeight > descriptionHeight) {
            [contentHeightsArray addObject:[NSNumber numberWithFloat:titleHeight + 10]];
            contentViewHeight += (titleHeight + 15);
        } else {
            [contentHeightsArray addObject:[NSNumber numberWithFloat:descriptionHeight + 10]];
            contentViewHeight += (descriptionHeight + 15);
        }
    }
    NSLog(@"contentViewHeight is %f", contentViewHeight);
}

- (NSArray *)getMildWarningsFromWarningsArrayIndex:(NSInteger)index {
    
     NSArray *mildArray = [[warningsArray objectAtIndex:index] valueForKey:MILD_WARNING];
    return mildArray;
}

- (BOOL)hasWarningForType:(WarningType )type {
    
    BOOL hasWarning = NO;
    for (NSDictionary *dict in warningsArray) {
        if (type == eSevere && [dict valueForKey:SEVERE_WARNING]) {
            hasWarning = YES;
        }
        if (type == eMild && [dict valueForKey:MILD_WARNING]) {
            hasWarning = YES;
        }
    }
    return hasWarning;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    
    RoundRectPresentationController *roundRectPresentationController = [[RoundRectPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    roundRectPresentationController.viewType = eAddMedication;
    roundRectPresentationController.frameSize = CGSizeMake(584.0f, contentViewHeight + 42.0f);
    return roundRectPresentationController;
}

#pragma mark - TableView Methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [warningsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCWarningsPopoverCell *warningsCell = (DCWarningsPopoverCell *)[tableView dequeueReusableCellWithIdentifier:WARNINGS_POPOVER_CELL_IDENTIFIER];
    if (warningsCell == nil) {
        warningsCell = [[DCWarningsPopoverCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WARNINGS_POPOVER_CELL_IDENTIFIER];
    }
    DCWarning *warning = [warningsArray objectAtIndex:indexPath.row];
    [warningsCell configureWarningsCellForWarningsObject:warning];
        //add separator between severe warnings and mild warnings section
    warningsCell.separatorView.hidden = (indexPath.row == severeWarningsCount - 1) ? NO : YES;
    return warningsCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCWarningsPopoverCell *warningsCell = (DCWarningsPopoverCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    if (warningsCell.titleHeightConstraint.constant > warningsCell.descriptionHeightConstraint.constant) {
        return warningsCell.titleHeightConstraint.constant + 15;
    } else {
        return warningsCell.descriptionHeightConstraint.constant + 15;
    }
}

#pragma mark - Action Methods

- (IBAction)donotUseDrugButtonPressed:(id)sender {
    
    //don't use drug button action
    [self dismissViewControllerAnimated:YES completion:^{
         self.overrideAction(NO);
    }];
}

- (IBAction)overrideWarningsButtonPressed:(id)sender {
    
    //override drug
    self.overrideAction(YES);
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
