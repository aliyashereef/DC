//
//  DCOrderSetAutoSearchHeaderView.h
//  DrugChart
//
//  Created by aliya on 06/08/15.
//
//

#import <UIKit/UIKit.h>

@protocol DCAutoSearchHeaderDelegate <NSObject>

@required
- (void)showAllButtonTapped;

@end

@interface DCOrderSetAutoSearchHeaderView : UIView

@property (strong, nonatomic) IBOutlet UILabel *headerTitleLabel;
@property (strong, nonatomic) IBOutlet UIButton *searchListVisibilityButton;
@property (strong, nonatomic) IBOutlet UILabel *buttonTitleLabel;
@property (nonatomic, weak) id <DCAutoSearchHeaderDelegate> headerDelegate;

@end
