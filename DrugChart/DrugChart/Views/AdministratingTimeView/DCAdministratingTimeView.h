//
//  DCAdministratingTimeView.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/17/15.
//
//

#import <UIKit/UIKit.h>

@interface DCAdministratingTimeView : UIView

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIButton *selectionButton;
@property (nonatomic, weak) IBOutlet UIImageView *statusImageView;

- (void)setStatusImageForSelectionState:(NSInteger)state;
- (void)updateTimeViewWithDetails:(NSDictionary *)timeDictionary;

@end
