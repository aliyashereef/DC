//
//  DCWardsListingCollectionViewController.m
//  DrugChart
//
//  Created by Aliya on 14/08/15.
//
//

#import "DCWardsListingViewController.h"
#import "DCWardsPatientsListingViewController.h"
#import "DCWard.h"
#import "DCWardWebService.h"
#import "DCLogOutWebService.h"
#import "DCWardsCollectionViewCell.h"
#import "DCPatientMedicationHomeViewController.h"

// Constants
#define WARDS_CELL_IDENTIFIER @"WardsListCell"
#define SEARCH_PLACEHOLDER @"Search"
#define SEARCH_BAR_HEIGHT 44.0
#define CONTENT_OFFSET @"contentOffset"
#define SECTION_COUNT 2
#define SEARCH_VISIBLE_CONTENT_OFFSET -64
#define SEARCH_HIDDEN_CONTENT_OFFSET -20
#define SEARCH_BAR_REUSEIDENTIFIER @"searchBar"

@interface DCWardsListingViewController () < UIScrollViewDelegate,UISearchBarDelegate ,UICollectionViewDataSource, UICollectionViewDelegate> {
    
    NSMutableArray     *searchListArray;
    UISearchBar        *searchBar;
    UIRefreshControl   *refreshControl;
    BOOL               isSearching;
    BOOL               selectedWard;
}

@end

@implementation DCWardsListingViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configureNavigationBarForDisplay];
}

- (void)viewWillAppear:(BOOL)animated {
    
    selectedWard = NO;
    [self prepareUI];
    [self configureSearchBarViewProperties];
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
}

- (void)configureSearchBarViewProperties {
    
    if (isSearching) {
        [self.wardsCollectionView setContentOffset:CGPointMake(0,0)];
    } else {
        searchBar.text = EMPTY_STRING;
        [self performSelector:@selector(hideSearchBar) withObject:nil afterDelay:0.0];
    }
    [self.view layoutSubviews];
}

- (void)hideSearchBar {
    if ([searchBar isFirstResponder]) {
        [searchBar resignFirstResponder];
    }
    [self.wardsCollectionView setContentOffset:CGPointMake(0,SEARCH_HIDDEN_CONTENT_OFFSET)];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

#pragma mark - actions

-(void)refreashControlAction{
    
    [self cancelSearching];
    [self fetchAllWardsForUser];
}

-(void)cancelSearching{
    
    isSearching = NO;
    [searchBar resignFirstResponder];
    searchBar.text  = EMPTY_STRING;
}

#pragma mark - Prepare View Controller

-(void)prepareUI {
    
    [self addSearchBar];
    [self addRefreshControl];
}

-(void)addSearchBar {
    
    if (!searchBar) {
        searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width,SEARCH_BAR_HEIGHT)];
        [searchBar setTranslatesAutoresizingMaskIntoConstraints:NO];

        searchBar.searchBarStyle       = UISearchBarStyleDefault;
        searchBar.showsCancelButton = NO;
        searchBar.delegate             = self;
        searchBar.placeholder          = SEARCH_PLACEHOLDER;
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setTextColor:[UIColor blackColor]];
    }
}

-(void)addRefreshControl {
    
    if (!refreshControl) {
        refreshControl = [UIRefreshControl new];
        [refreshControl addTarget:self
                           action:@selector(refreashControlAction)
                 forControlEvents:UIControlEventValueChanged];
    }
    if (![refreshControl isDescendantOfView:self.view]) {
        [self.wardsCollectionView addSubview:refreshControl];
    }
}

-(void)startRefreshControl {
    
    if (!refreshControl.refreshing) {
        [refreshControl beginRefreshing];
    }
}

#pragma mark - Collection View Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 0;
    } else {
        if (isSearching || selectedWard) {
            return [searchListArray count];
        } else {
            return [_wardsListArray count];
        }
    }
}

//To set the content of each cell of collection view with the wards
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    DCWardsCollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:WARDS_CELL_IDENTIFIER
                                                                               forIndexPath:indexPath];
    if (cell==nil){
        cell=[[DCWardsCollectionViewCell alloc]init];
    }
    if (indexPath.section == 1) {
        DCWard *ward;
        if (isSearching || selectedWard) {
            ward = [searchListArray objectAtIndex:indexPath.item];
        } else {
            ward = [_wardsListArray objectAtIndex:indexPath.item];
        }
        cell.currentWard = ward;
        [cell configureWardDisplayCellForWard];
    }
    return cell;
}

#pragma mark - Collection View delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    selectedWard = YES;
    [self performSegueWithIdentifier:SHOW_PATIENT_LIST sender:indexPath];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:EMPTY_STRING
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:nil
                                                                            action:nil];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return SECTION_COUNT;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return CGSizeZero;
    }else {
        return CGSizeMake(self.view.frame.size.width, SEARCH_BAR_HEIGHT);
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableview = nil;
    if (indexPath.section == 0) {
        if (kind == UICollectionElementKindSectionHeader) {
            UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:SEARCH_BAR_REUSEIDENTIFIER forIndexPath:indexPath];
            [headerView addSubview:searchBar];
            NSDictionary* viewDict = @{@"searchBar":searchBar, @"collectionView": headerView};
            
            NSArray* sHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchBar(==collectionView)]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:viewDict];
            
            [headerView addConstraints:sHorizontal];
            reusableview = headerView;
        }
    }
    return reusableview;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:SHOW_PATIENT_LIST]) {
        if (searchBar.isFirstResponder) {
            [searchBar resignFirstResponder];
        }
        DCWardsPatientsListingViewController *wardsPatientsListingViewController = (DCWardsPatientsListingViewController *)segue.destinationViewController;
        NSIndexPath *selectedIndexPath = (NSIndexPath *)sender;
        DCWardsCollectionViewCell *wardsCollectionViewCell = (DCWardsCollectionViewCell *)[self.wardsCollectionView cellForItemAtIndexPath:selectedIndexPath];
        wardsPatientsListingViewController.selectedWard = wardsCollectionViewCell.currentWard;
    }
}

#pragma mark - Private methods

- (void)configureNavigationBarForDisplay {
    
    self.navigationItem.hidesBackButton = YES;
    self.title = NSLocalizedString(@"WARDS_TITLE" , @"title string");
}

- (void)searchWardListWithText:(NSString *)searchText {
    
    NSString *wardNameString = [NSString stringWithFormat:@"wardName contains[c] '%@'", searchText];
    NSPredicate *wardNamePredicate = [NSPredicate predicateWithFormat:wardNameString];
    searchListArray = (NSMutableArray *)[_wardsListArray filteredArrayUsingPredicate:wardNamePredicate];
}

- (void)fetchAllWardsForUser {
    
    DCWardWebService *wardsWebService = [[DCWardWebService alloc] init];
    [wardsWebService getAllWardsForUser:nil withCallBackHandler:^(id response, NSError *error) {
        [refreshControl endRefreshing];
        if (!error) {
            NSArray *responseArray = [NSMutableArray arrayWithArray:response];
            NSMutableArray *wardsArray = [[NSMutableArray alloc] init];
            for (NSDictionary *wardsDictionary in responseArray) {
                DCWard *ward = [[DCWard alloc] initWithDicitonary:wardsDictionary];
                [wardsArray addObject:ward];
            }
            _wardsListArray = wardsArray;
            [self.wardsCollectionView reloadData];
        }
    }];
}

- (void)resetCollectionViewContentOffset {
    
    [self.wardsCollectionView setContentOffset:CGPointMake(0,SEARCH_HIDDEN_CONTENT_OFFSET) animated:YES];
}

#pragma mark - Search Methods

- (void)searchBar:(UISearchBar *)searchedBar textDidChange:(NSString *)searchText {
    
    if (searchText.length > 0) {
        // Search and Reload data source
        isSearching = YES;
        [self searchWardListWithText:searchText];
        [self.wardsCollectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
    } else {
        isSearching = NO;
        [self.wardsCollectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    
    [self cancelSearching];
    [self.wardsCollectionView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    isSearching = YES;
    [self.view endEditing:YES];
}

#pragma mark - ScrollView Delegates

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    
    CGFloat contentOffset = scrollView.contentOffset.y;
    if((contentOffset > -SEARCH_BAR_HEIGHT && contentOffset < 50)) {
        [self performSelector:@selector(resetCollectionViewContentOffset)
                   withObject:nil
                   afterDelay:0.0];
    }
}

@end
