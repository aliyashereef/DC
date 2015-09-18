//
//  DCAutoSearchView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/1/15.
//
//

#import "DCAutoSearchView.h"
#import "DCAutoSearchCell.h"
#import "DCOrderSetAutoSearchHeaderView.h"

#define LATO_REGULAR_SIXTEEN [UIFont fontWithName:@"Lato-Regular" size:16]
#define CELL_PADDING   15
#define AUTOSEARCH_MIN_CELL_HEIGHT  48.0f
#define SEARCH_CELL_VALUE @"search_cell_value"
#define SEARCH_NAME_LABEL @"search_name_label"
#define AUTOSEARCH_HEADER_HEIGHT 40
#define REGULAR @"Regular"
#define FAVOURITES @"Favourites"

@interface DCAutoSearchView () <UITableViewDataSource, UITableViewDelegate, DCAutoSearchHeaderDelegate> {
    DCOrderSetAutoSearchHeaderView *autoSearchHeaderView;
    float headerHeight;
    BOOL isShowAllTapped;
}

@end

@implementation DCAutoSearchView

- (id)initWithFrame:(CGRect)frame {
    
    if (self == [super initWithFrame:frame]) {
        self.frame = frame;
    }
    return self;
}

- (void)awakeFromNib {
    
    _autoFillTableView.layer.borderColor = [UIColor colorWithRed:177.0f/255.0f green:177.0f/255.0f blue:177.0f/255.0f alpha:1.0].CGColor;
    _autoFillTableView.separatorInset = UIEdgeInsetsZero;
    _autoFillTableView.layoutMargins = UIEdgeInsetsZero;
    [self initialiseSearchArrays];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
}

#pragma mark - Private Methods

- (void)initialiseSearchArrays {
    
    _searchListArray = [[NSMutableArray alloc] init];
    _searchedContentsArray = [[NSMutableArray alloc] init];
    _favouriteContentsArray = [[NSMutableArray alloc] init];
}

- (NSArray *)getFavouriteOrdersetArray {
    
    NSString *predicateString = @"isUserFavourite == YES";
    NSPredicate *orderSetCategoryPredicate = [NSPredicate predicateWithFormat:predicateString];
    NSMutableArray *favouriteOrderSetArray = (NSMutableArray *)[_searchListArray filteredArrayUsingPredicate:orderSetCategoryPredicate];
    return favouriteOrderSetArray;
}

#pragma mark - Public Methods

- (void)searchAutocompleteEntriesWithSubstring:(NSString *)substring {
    
    NSString *searchString = [NSString stringWithFormat:@"name contains[c] '%@'", substring];
    @try {
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:searchString];
        _searchedContentsArray =  [NSMutableArray arrayWithArray:[_searchListArray filteredArrayUsingPredicate:searchPredicate]];
        
        if (_autoSearchType == eOrderSet) {
            _favouriteContentsArray = [NSMutableArray arrayWithArray:[[self getFavouriteOrdersetArray] filteredArrayUsingPredicate:        searchPredicate]];
            if (substring.length == 0) {
                _searchedContentsArray = [NSMutableArray arrayWithArray:@[]];
                _favouriteContentsArray = [NSMutableArray arrayWithArray:[self getFavouriteOrdersetArray]];
                isShowAllTapped = NO;
            } else {
                if (_searchedContentsArray.count == 0) {
                    _searchedContentsArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"NO_ORDERSET", @"")]];
                }
                if (_favouriteContentsArray.count == 0) {
                    _favouriteContentsArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"NO_FAVOURITES", @"")]];
                }
            }
        } else {
            if ([_searchedContentsArray count] == 0) {
                if (substring.length < SEARCH_ENTRY_MIN_LENGTH) {
                    if (_minimumLimit) {
                        _searchedContentsArray = [NSMutableArray arrayWithArray:@[]];
                        [_activityIndicator startAnimating];
                    } else {
                        _searchedContentsArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"SEARCH_MEDICATION_MIN_LIMIT", @"")]];
                    }
                } else {
                    _searchedContentsArray = [NSMutableArray arrayWithArray:@[NSLocalizedString(@"NO_MEDICATIONS", @"")]];
                }
            }
        }
        [_autoFillTableView reloadData];
    }
    @catch (NSException *exception) {
        DCDebugLog(@"Exception raised %@", exception.description);
        [_activityIndicator stopAnimating];
    }
}

#pragma mark - table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (_autoSearchType == eOrderSet) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSUInteger searchArrayCount = [_searchedContentsArray count];
    if (section == 0 && _autoSearchType == eOrderSet ) {
        if (isShowAllTapped) {
            searchArrayCount = ORDERSET_FAVOURITE_DEFAULT_CELL_COUNT;
        } else {
            searchArrayCount = [_favouriteContentsArray count];
        }
    } else if (section == 1){
        searchArrayCount = [_searchedContentsArray count];
    } 
    return searchArrayCount;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    autoSearchHeaderView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCOrderSetAutoSearchHeaderView class]) owner:self options:nil] objectAtIndex:0];
    autoSearchHeaderView.headerDelegate = self;
    if (section == 0 && _autoSearchType == eOrderSet) {
        autoSearchHeaderView.headerTitleLabel.text = FAVOURITES;
        if (_favouriteContentsArray.count > ORDERSET_FAVOURITE_DEFAULT_CELL_COUNT) {
            if (_searchedContentsArray.count > 0) {
                autoSearchHeaderView.buttonTitleLabel.hidden = NO;
                if (isShowAllTapped) {
                    autoSearchHeaderView.buttonTitleLabel.text = @"Show All";
                } else {
                    autoSearchHeaderView.buttonTitleLabel.text = @"Hide";
                }
            } else {
                autoSearchHeaderView.buttonTitleLabel.hidden = YES;
            }
        } else {
            autoSearchHeaderView.buttonTitleLabel.hidden = YES;
        }
        
    } else {
        autoSearchHeaderView.headerTitleLabel.text = REGULAR;
        UIView *dividerView = [[UIView alloc]initWithFrame:CGRectMake(0,0,540,1)];
        [dividerView setBackgroundColor:[UIColor getColorForHexString:@"#C4D3D5"]];
        [autoSearchHeaderView addSubview:dividerView];
        autoSearchHeaderView.searchListVisibilityButton.hidden = YES;
        autoSearchHeaderView.buttonTitleLabel.hidden = YES;
    }
    return autoSearchHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    headerHeight = 0.0f;
    if(_autoSearchType == eOrderSet ) {
        if (section == 0) {
            if(_favouriteContentsArray.count != 0) {
                headerHeight = AUTOSEARCH_HEADER_HEIGHT;
            }
        } else {
            if( _searchedContentsArray.count != 0) {
                headerHeight = AUTOSEARCH_HEADER_HEIGHT;
            }
        }
    }
    return headerHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DCAutoSearchCell *searchCell = (DCAutoSearchCell *)[tableView dequeueReusableCellWithIdentifier:AUTO_SEARCH_CELL_IDENTIFIER];
    if (searchCell == nil) {
        searchCell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCAutoSearchCell class]) owner:self options:nil] objectAtIndex:0];
    }
    searchCell.layoutMargins = UIEdgeInsetsZero;
    NSDictionary *searchValueDictionary = [self getSearchCellValueAndSearchNameLabelFromIndexPath:indexPath];
    searchCell.searchValue = [searchValueDictionary valueForKey:SEARCH_CELL_VALUE];
    searchCell.searchNameLabel.text = [searchValueDictionary valueForKey:SEARCH_NAME_LABEL];
    return searchCell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row) {
        [_activityIndicator stopAnimating];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *searchValueDictionary = [self getSearchCellValueAndSearchNameLabelFromIndexPath:indexPath];
    CGSize stepSize = [DCUtility getRequiredSizeForText:[searchValueDictionary valueForKey:SEARCH_CELL_VALUE]
                                                   font:LATO_REGULAR_SIXTEEN
                                               maxWidth:290];
    CGFloat searchCellHeight = CELL_PADDING + stepSize.height;
    searchCellHeight = searchCellHeight < AUTOSEARCH_MIN_CELL_HEIGHT? AUTOSEARCH_MIN_CELL_HEIGHT :searchCellHeight ;
    _searchTableViewCellHeight = searchCellHeight ;
    return searchCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (_autoSearchType == eOrderSet) {
            DCOrderSet *orderSet = [_favouriteContentsArray objectAtIndex:indexPath.row];
            if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(selectedOrderSet:)]) {
                [self.searchDelegate selectedOrderSet:orderSet];
            }
        } else {
            DCMedication *medication = [_searchedContentsArray objectAtIndex:indexPath.row];
            if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(selectedMedication:)]) {
                [self.searchDelegate selectedMedication:medication];
            }
        }
    } else {
        if ([[_searchedContentsArray objectAtIndex:indexPath.row] isKindOfClass:[DCOrderSet class]]) {
            DCOrderSet *orderSet = [_searchedContentsArray objectAtIndex:indexPath.row];
            if (self.searchDelegate && [self.searchDelegate respondsToSelector:@selector(selectedOrderSet:)]) {
                [self.searchDelegate selectedOrderSet:orderSet];
            }
        }
    }
}

- (NSDictionary *)getSearchCellValueAndSearchNameLabelFromIndexPath :(NSIndexPath *)indexPath {
    
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    if (indexPath.section == 0 && _autoSearchType == eOrderSet) {
        if ([[_favouriteContentsArray objectAtIndex:indexPath.row] isKindOfClass:[DCOrderSet class]]) {
            DCOrderSet *orderSet = [_favouriteContentsArray objectAtIndex:indexPath.row];
            [searchDictionary setValue:orderSet.name forKey:SEARCH_CELL_VALUE];
            [searchDictionary setValue:orderSet.name forKey:SEARCH_NAME_LABEL];
        } else {
            [searchDictionary setValue:[_favouriteContentsArray objectAtIndex:indexPath.row] forKey:SEARCH_CELL_VALUE];
            [searchDictionary setValue:[_favouriteContentsArray objectAtIndex:indexPath.row] forKey:SEARCH_NAME_LABEL];
        }
    } else {
        if ([[_searchedContentsArray objectAtIndex:indexPath.row] isKindOfClass:[DCOrderSet class]]) {
            DCOrderSet *orderSet = [_searchedContentsArray objectAtIndex:indexPath.row];
            [searchDictionary setValue:orderSet.name forKey:SEARCH_CELL_VALUE];
            [searchDictionary setValue:orderSet.name forKey:SEARCH_NAME_LABEL];
        } else if ([[_searchedContentsArray objectAtIndex:indexPath.row] isKindOfClass:[DCMedication class]]) {
            DCMedication *searchMedication = [_searchedContentsArray objectAtIndex:indexPath.row];
            [searchDictionary setValue:searchMedication.name forKey:SEARCH_CELL_VALUE];
            [searchDictionary setValue:searchMedication.name forKey:SEARCH_NAME_LABEL];
        } else {
            [searchDictionary setValue:[_searchedContentsArray objectAtIndex:indexPath.row] forKey:SEARCH_CELL_VALUE];
            [searchDictionary setValue:[_searchedContentsArray objectAtIndex:indexPath.row] forKey:SEARCH_NAME_LABEL];
        }
    }
    return searchDictionary;
}

#pragma mark - Header Delegate Methods

- (void)showAllButtonTapped {

    CGRect autoSearchViewBounds = [self bounds];
    if (_favouriteContentsArray.count > ORDERSET_FAVOURITE_DEFAULT_CELL_COUNT) {
        if (isShowAllTapped) {
            
            NSUInteger totalCellCount = [self.favouriteContentsArray count] - ORDERSET_FAVOURITE_DEFAULT_CELL_COUNT;
            int searchContentHeight = totalCellCount * self.searchTableViewCellHeight;
            if(autoSearchViewBounds.size.height < 287) {
                [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width,(autoSearchViewBounds.size.height + searchContentHeight))];
            }
        } else {
            if(autoSearchViewBounds.size.height < 287) {
                int searchContentHeight = ORDERSET_FAVOURITE_DEFAULT_CELL_COUNT * self.searchTableViewCellHeight;
                [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.bounds.size.width,(autoSearchViewBounds.size.height - searchContentHeight))];
            }
        }
        isShowAllTapped = !isShowAllTapped;
        [_autoFillTableView reloadData];
    }
}

@end
