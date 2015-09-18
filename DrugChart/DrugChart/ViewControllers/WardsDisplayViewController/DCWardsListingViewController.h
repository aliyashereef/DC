//
//  DCWardsListingViewController.h
//  DrugChart
//
//  Created by aliya on 24/08/15.
//
//

#import <UIKit/UIKit.h>

@interface DCWardsListingViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *wardsListArray;
@property (strong, nonatomic) IBOutlet UICollectionView *wardsCollectionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *collectionViewTopSpaceConstraint;

@end
