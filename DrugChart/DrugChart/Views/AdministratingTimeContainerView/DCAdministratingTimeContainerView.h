//
//  DCAdministratingTimeContainerView.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/8/15.
//
//

#import <UIKit/UIKit.h>

@protocol DCAdministratingTimeContainerDelegate <NSObject>

- (void)updatedTimeArray:(NSArray *)timeArray;
- (void)addNewTimeButtonAction:(id)sender;
- (void)updateAdministartingTimeContainerHeightConstraint;

@end

@interface DCAdministratingTimeContainerView : UIView

@property (nonatomic, strong) NSMutableArray *timeArray;
@property (nonatomic, weak) id <DCAdministratingTimeContainerDelegate> delegate;

- (void)updateTimeContainerViewWithSelectedTime:(NSDate *)time;
- (void)deselectAdministratingTimeSlots;
- (void)configureTimeViewsInContainerView;

@end
