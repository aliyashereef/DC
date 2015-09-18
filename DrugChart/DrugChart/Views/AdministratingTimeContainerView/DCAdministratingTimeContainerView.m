//
//  DCAdministratingTimeContainerView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/8/15.
//
//

#import "DCAdministratingTimeContainerView.h"
#import "DCPlistManager.h"
#import "DCAdministratingTimeView.h"

#define TIME_VIEW_X_INITIAL                     10.0f
#define TIME_VIEW_Y_INITIAL                     10.0f
#define TIME_VIEW_WIDTH                         77.0f
#define TIME_VIEW_HEIGHT                        30.0f
#define TIME_VIEW_X_MAX                         440.0f

#define kAdminstratingViewTitlelabelTag  200

#define SELECTED    1
#define DESELECTED  0

@interface DCAdministratingTimeContainerView () {
    
    UIButton *addTimeButton;
}

@end

@implementation DCAdministratingTimeContainerView

- (id) initWithFrame:(CGRect)frame {
    
    if (self == [super initWithFrame:frame]) {
        self.frame = frame;
    }
    return self;
}

- (void)setTimeArray:(NSMutableArray *)timeArray {
    
    _timeArray = timeArray;
    [self addDefaultAdministratingTimeViews];
}

- (void)addDefaultAdministratingTimeViews {
    
    CGFloat yValue = TIME_VIEW_Y_INITIAL;
    CGFloat xValue = TIME_VIEW_X_INITIAL;
    int slotCountInRow = 1;
    
    for (NSDictionary *timeDictionary in _timeArray) {
        DCAdministratingTimeView *administratingTimeView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCAdministratingTimeView class]) owner:self options:nil] objectAtIndex:0];
        [administratingTimeView setFrame:CGRectMake(xValue, yValue, administratingTimeView.frame.size.width, administratingTimeView.frame.size.height)];
        [self addSubview:administratingTimeView];
        NSInteger timeViewTag = [_timeArray indexOfObject:timeDictionary];
        administratingTimeView.selectionButton.tag = timeViewTag;
        [administratingTimeView updateTimeViewWithDetails:timeDictionary];
        [administratingTimeView setTag:(100+timeViewTag)];
        [administratingTimeView.selectionButton addTarget:self action:@selector(administratingTimeViewSelectionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        slotCountInRow ++;
        if (timeViewTag == [_timeArray count] - 1) {
            CGRect addButtonFrame = CGRectMake(xValue + 87, yValue, 30, 30);
            [self displayadministratingTimeAddButtonInFrame:addButtonFrame];
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width , addButtonFrame.size.width + 20);
        }
        if (slotCountInRow == 6) {
            slotCountInRow = 1;
            xValue = TIME_VIEW_X_INITIAL;
            yValue += (TIME_VIEW_Y_INITIAL + 30);
        } else {
            xValue += (TIME_VIEW_WIDTH + TIME_VIEW_X_INITIAL);
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateAdministartingTimeContainerHeightConstraint)]) {
        [self.delegate updateAdministartingTimeContainerHeightConstraint];
    }
    [self layoutIfNeeded];
}

- (void)displayadministratingTimeAddButtonInFrame:(CGRect) frame {
    
    //display administarting time
    addTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addTimeButton setImage:[UIImage imageNamed:PLUS_IMAGE] forState:UIControlStateNormal];
    [addTimeButton setFrame:frame];
    [self addSubview:addTimeButton];
    [addTimeButton addTarget:self action:@selector(administratingTimeAddButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)updateTimeContainerViewWithSelectedTime:(NSDate *)time {
    
    NSString *selectedDateString = [DCDateUtility getDisplayDateInTwentyFourHourFormat:time];
    NSDictionary *timeDictionary = @{@"time" : selectedDateString, @"selected" : @1};
    BOOL timeAlreadyAdded = NO;
    NSInteger alreadyAddedSlotTag = 0;
    for (NSDictionary *dict in _timeArray) {
        if ([[dict valueForKey:@"time"] isEqualToString:[timeDictionary valueForKey:@"time"]]) {
            timeAlreadyAdded = YES;
            alreadyAddedSlotTag = [_timeArray indexOfObject:dict];
            break;
        }
    }
    if (!timeAlreadyAdded) {
        [_timeArray addObject:timeDictionary];
        _timeArray = [NSMutableArray arrayWithArray:[DCUtility sortArray:_timeArray basedOnKey:@"time" ascending:YES]];
        //remove all subviews from administratingTimeContainerView
        for (UIView *subView in self.subviews) {
            if (subView.tag != kAdminstratingViewTitlelabelTag) {
                [subView removeFromSuperview];
            }
        }
        [self updateNewAdministratingTimeSlot:timeDictionary];
    } else {
        
        //*******Time Slot already added.*******
        DCAdministratingTimeView *administratingTimeView = (DCAdministratingTimeView *)[self viewWithTag:alreadyAddedSlotTag+100];
        [DCUtility shakeView:administratingTimeView completion:^(BOOL completed) {
            if (completed) {
                NSDictionary *updatedDictionary = [_timeArray objectAtIndex:alreadyAddedSlotTag];
                updatedDictionary = @{@"time" : selectedDateString, @"selected" : @1};
                [_timeArray replaceObjectAtIndex:alreadyAddedSlotTag withObject:updatedDictionary];
                NSInteger selected = 1;
                [administratingTimeView setStatusImageForSelectionState:selected];
            }
        }];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatedTimeArray:)]) {
        [self.delegate updatedTimeArray:_timeArray];
    }
}

- (void)updateNewAdministratingTimeSlot:(NSDictionary *)timeDictionary {
    
    NSInteger newTimeIndex = [_timeArray indexOfObject:timeDictionary];
    CGFloat yValue = TIME_VIEW_Y_INITIAL;
    CGFloat xValue = TIME_VIEW_X_INITIAL;
    __block CGFloat yValueNewSlot = 0.0;
    __block CGFloat xValueNewSlot = 0.0;
    for (NSDictionary *dict in _timeArray) {
        DCAdministratingTimeView *administratingTimeView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCAdministratingTimeView class]) owner:self options:nil] objectAtIndex:0];
        CGFloat width;
        if (newTimeIndex == [_timeArray indexOfObject:dict]) {
            [administratingTimeView setFrame:CGRectMake(xValue, yValue, 0.0, administratingTimeView.frame.size.height)];
            yValueNewSlot = yValue;
            xValueNewSlot = xValue;
            width = 0.0;
        } else {
            [administratingTimeView setFrame:CGRectMake(xValue, yValue, administratingTimeView.frame.size.width, administratingTimeView.frame.size.height)];
            width = administratingTimeView.frame.size.width;
        }
        [administratingTimeView updateTimeViewWithDetails:dict];
        [self addSubview:administratingTimeView];
        NSInteger timeViewTag = [_timeArray indexOfObject:dict];
        administratingTimeView.selectionButton.tag = timeViewTag;
        [administratingTimeView setTag:(100+timeViewTag)];
        [administratingTimeView.selectionButton addTarget:self action:@selector(administratingTimeViewSelectionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        if (xValue > TIME_VIEW_X_MAX) {
            xValue = TIME_VIEW_X_INITIAL;
            yValue += (10 + TIME_VIEW_HEIGHT);
        } else {
            xValue += (width + TIME_VIEW_X_INITIAL);
        }
        if (timeViewTag == [_timeArray count] - 1) {
            CGRect addButtonFrame = CGRectMake(xValue + 10, yValue, 30, 30);
            [self displayadministratingTimeAddButtonInFrame:addButtonFrame];
        }
    }
    NSInteger totalRowCount = [_timeArray count]/6;
    CGFloat containerHeight = (35 * (totalRowCount + 1)) + ((totalRowCount + 1) * 30) + 20;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, containerHeight);
    [self layoutIfNeeded];
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateAdministartingTimeContainerHeightConstraint)]) {
        [self.delegate updateAdministartingTimeContainerHeightConstraint];
    }
    [self animateTimeViewWithNewTimeCordinatesxValue:xValueNewSlot yValue:yValueNewSlot withIndexValue:newTimeIndex];
}

- (void)animateTimeViewWithNewTimeCordinatesxValue:(CGFloat)xValue yValue:(CGFloat)yValue withIndexValue:(NSInteger) index{
    
    __block CGFloat yNewValue = yValue;
    __block CGFloat xNewValue = xValue;
    [UIView animateWithDuration:0.9 animations:^{
        
        DCAdministratingTimeView *newAdministratingTimeView = (DCAdministratingTimeView *)[self viewWithTag:(100 + index)];
        NSInteger viewTag = newAdministratingTimeView.tag;
        [newAdministratingTimeView setFrame:CGRectMake(xValue, yValue, TIME_VIEW_WIDTH, newAdministratingTimeView.frame.size.height)];
        for (DCAdministratingTimeView *timeView in self.subviews) {
            NSInteger subViewTag = timeView.tag;
            if (subViewTag > viewTag && subViewTag != kAdminstratingViewTitlelabelTag) {
                if (xNewValue > TIME_VIEW_X_MAX) {
                    xNewValue = TIME_VIEW_X_INITIAL;
                    yNewValue += 40;
                } else {
                    xNewValue += (TIME_VIEW_WIDTH + TIME_VIEW_X_INITIAL);
                }
                timeView.frame = CGRectMake(xNewValue, yNewValue, TIME_VIEW_WIDTH, TIME_VIEW_HEIGHT);
            }
        }
        CGRect addButtonFrame = CGRectMake(xNewValue + 95, yNewValue, 32, 30);
        [addTimeButton setFrame:addButtonFrame];
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, (addButtonFrame.origin.y + addButtonFrame.size.height + 40));
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(updateAdministartingTimeContainerHeightConstraint)]) {
            [self.delegate updateAdministartingTimeContainerHeightConstraint];
        }
        [self layoutIfNeeded];
    }];
}

- (void)deselectAdministratingTimeSlots {
    
    //deselect all time slots
    _timeArray =  [NSMutableArray arrayWithArray:[DCPlistManager getAdministratingTimeList]];
    for (DCAdministratingTimeView *timeView in self.subviews) {
        if ([timeView isKindOfClass:[DCAdministratingTimeView class]]) {
            [timeView setStatusImageForSelectionState:0];
        }
    }
}

- (void)configureTimeViewsInContainerView {
    
    //select/deselect time Views In containerView
    @try {
        
        for (NSDictionary *timeDictionary in _timeArray) {
            
            NSInteger timeViewTag = [_timeArray indexOfObject:timeDictionary];
            DCAdministratingTimeView *timeView = (DCAdministratingTimeView *)[self viewWithTag:(100 + timeViewTag)];
            if ([timeView isKindOfClass:[DCAdministratingTimeView class]]) {
                [timeView setStatusImageForSelectionState:[[timeDictionary valueForKey:@"selected"] boolValue]];
            }
        }
    }
    @catch (NSException *exception) {
        DCDebugLog(@"Error in time views %@", exception.description);
    }
}

#pragma mark - Action Methods

- (IBAction)administratingTimeViewSelectionButtonPressed:(id)sender {
    
    UIButton *selectionButton = (UIButton *)sender;
   // minorChange = YES;
    NSInteger buttonTag = selectionButton.tag;
    NSDictionary *selectedTimeDictionary = [_timeArray objectAtIndex:buttonTag];
    NSInteger selected = [[selectedTimeDictionary valueForKey:@"selected"] integerValue];
    selected = (selected == SELECTED)? DESELECTED : SELECTED;
    NSDictionary *updatedDictionary = @{@"time" : [selectedTimeDictionary valueForKey:@"time"], @"selected" : [NSNumber numberWithInteger:selected]};
    [_timeArray replaceObjectAtIndex:buttonTag withObject:updatedDictionary];
    DCAdministratingTimeView *newAdministratingTimeView = (DCAdministratingTimeView *)[self viewWithTag:(100 + buttonTag)];
    [newAdministratingTimeView setStatusImageForSelectionState:selected];
    if (self.delegate && [self.delegate respondsToSelector:@selector(updatedTimeArray:)]) {
        [self.delegate updatedTimeArray:_timeArray];
    }
}

- (IBAction)administratingTimeAddButtonPressed:(id)sender {
    
    //select administrating time
    if (self.delegate && [self.delegate respondsToSelector:@selector(addNewTimeButtonAction:)]) {
        [self.delegate addNewTimeButtonAction:sender];
    }
}

@end
