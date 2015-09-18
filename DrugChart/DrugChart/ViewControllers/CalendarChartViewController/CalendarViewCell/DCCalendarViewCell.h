//
//  DCCalendarViewCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/6/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationSlot.h"


typedef void (^CalendarHandlerBlock) (NSArray *slotArray, NSInteger index, BOOL editable);

@interface DCCalendarViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *scrollViewHeight;
@property (nonatomic, weak) IBOutlet UIView *administerButtonContentView;
@property (nonatomic, weak) IBOutlet UIButton *administerButton;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) CalendarHandlerBlock calendarHandler;


- (void)displayMedicationTime:(NSArray *)timeArray isWhenRequired:(BOOL)whenRequired;

@end
