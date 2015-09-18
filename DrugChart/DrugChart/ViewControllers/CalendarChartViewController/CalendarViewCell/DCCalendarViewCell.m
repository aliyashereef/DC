//
//  DCCalendarViewCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/6/15.
//
//

#import "DCCalendarViewCell.h"
#import "DCTimeView.h"

#define XVALUE_INITIAL              25.0f
#define TIME_VIEW_Y_INITIAL_VALUE   18.0f
#define TIME_VIEW_WIDTH             100.0f
#define TIME_VIEW_HEIGHT            35.0f
#define VIEW_SPACING                125.0f
#define SCROLL_OFFSET               20.f


@interface DCCalendarViewCell () {
    
}

@end

@implementation DCCalendarViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    
    [super layoutSubviews];

}

- (void)displayMedicationTime:(NSArray *)timeArray isWhenRequired:(BOOL)whenRequired {
    //display the medication time based on status
   
    CGFloat xValue = XVALUE_INITIAL;
    CGFloat yValue = TIME_VIEW_Y_INITIAL_VALUE;
    _scrollViewHeight.constant = CALENDAR_TABLE_CELL_HEIGHT;
    for (DCMedicationSlot *medicationSlot in timeArray) {

        id calenderTapped = ^{
            BOOL administerMedicationEditable = [self enableAdministerMedicationForSlot:medicationSlot FromContentArray:timeArray];
            //self.calendarHandler(medicationSlot, administerMedicationEditable);
            self.calendarHandler (timeArray, [timeArray indexOfObject:medicationSlot], administerMedicationEditable);
        };
        @autoreleasepool {
            DCTimeView *timeView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DCTimeView class]) owner:self options:nil] objectAtIndex:0];
            timeView.timeAction = calenderTapped;
            [timeView displayTimeViewForMedicationSlot:medicationSlot];
//            timeView.medicationSlot = medicationSlot;
            NSInteger index = [timeArray indexOfObject:medicationSlot];
            NSInteger rowCount;
            NSInteger columnCount;
            if (whenRequired) {
                rowCount = index / 3;
                columnCount = index % 3;
            } else {
                rowCount = index / 4;
                columnCount = index % 4;
            }
            
            yValue = (rowCount * (TIME_VIEW_Y_INITIAL_VALUE + TIME_VIEW_HEIGHT)) + TIME_VIEW_Y_INITIAL_VALUE;
            xValue = (columnCount * VIEW_SPACING) + XVALUE_INITIAL;
            _scrollViewHeight.constant = yValue + TIME_VIEW_HEIGHT + SCROLL_OFFSET;
            timeView.frame = CGRectMake(xValue, yValue, TIME_VIEW_WIDTH, TIME_VIEW_HEIGHT);
            [self.scrollView addSubview:timeView];
            [self layoutSubviews];
        }
    }
 }

- (BOOL)enableAdministerMedicationForSlot:(DCMedicationSlot *)medicationSlot
                         FromContentArray:(NSArray *)timeArray {
    
    //method for checking whether administer medication section is to be enabled
    BOOL administerMedicationEditable = NO;
    NSDate *currentSystemDate = [DCDateUtility getDateInCurrentTimeZone:[NSDate date]];
    NSString *medicationSlotDateString = [DCDateUtility convertDate:medicationSlot.time FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
    NSString *currentDateString = [DCDateUtility convertDate:currentSystemDate FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
    
    NSMutableArray *filteredArray = [[NSMutableArray alloc] init];
    //get medication slots array of current week
    for (DCMedicationSlot *slot in timeArray) {
        NSString *timeString = [DCDateUtility convertDate:slot.time FromFormat:DEFAULT_DATE_FORMAT ToFormat:SHORT_DATE_FORMAT];
        if ([timeString isEqualToString:currentDateString]) {
            [filteredArray addObject:slot];
        }
    }
    //get the next time slot or nearest date
    NSDate *nearestDate;
    if ([medicationSlotDateString isEqualToString:currentDateString]) {
        NSDate *laterDate;
        for(DCMedicationSlot *slot in filteredArray) {
            laterDate = [currentSystemDate laterDate:slot.time];
            if(![laterDate isEqualToDate:currentSystemDate]){
                nearestDate = [laterDate earlierDate:nearestDate];
            }
        }
        if ((nearestDate && [nearestDate compare:medicationSlot.time] == NSOrderedSame) ||
            [medicationSlot.status isEqualToString:YET_TO_GIVE]) {
            administerMedicationEditable = YES;
        }
    }
    else {
        if ([medicationSlot.status isEqualToString:YET_TO_GIVE]) {
            administerMedicationEditable = YES;
        }
    }
    return administerMedicationEditable;
}

@end
