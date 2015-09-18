//
//  DCPrescriberMedicationCellTableViewCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/24/15.
//
//

#import <UIKit/UIKit.h>
#import "DCMedicationScheduleDetails.h"

@protocol DCPrescriberCellDelegate <NSObject>

- (void)editMedicationForSelectedIndexPath:(NSIndexPath *)indexPath;
- (void)stopMedicationForSelectedIndexPath:(NSIndexPath *)indexPath;
- (void)displayMedicationDetailsViewAtIndexPath:(NSIndexPath *)indexPath
                                  withButtonTag:(NSInteger)tag
                                     slotsArray:(NSArray *)slotsArray;

@end

typedef enum : NSUInteger {
    prescriberCellLeft,
    prescriberCellCenter,
    prescriberCellRight
} PrescriberCellPosition;

@interface DCPrescriberMedicationCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *medicationNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *routeAndInstructionLabel;
@property (nonatomic, weak) IBOutlet UILabel *discontinuedLabel;
@property (nonatomic, weak) IBOutlet UIView *medicationView;
@property (nonatomic, strong) IBOutlet UIView *editView;
@property (nonatomic, strong) IBOutlet UIView *calendarView;
@property (nonatomic, strong) IBOutlet UIView *leftCalendarView;
@property (nonatomic, strong) IBOutlet UIView *rightCalendarView;
@property (nonatomic, weak) IBOutlet UIButton *editButton;
@property (nonatomic, weak) IBOutlet UIButton *stopButton;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *medicationViewLeadingConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *stopButtonWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *EditButtonWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *rightCalendarTralilingConstraint;
@property (nonatomic, strong) NSArray *medicationSlotsArray;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id <DCPrescriberCellDelegate> delegate;

- (void)configurePrescriberMedicationCellForMedication:(DCMedicationScheduleDetails *)medicationList;
- (void)addMedicationTimeAndStatusIconsFromMedicationSlotsArray:(NSArray *)medicationSlotsArray;
- (void)addOverLayButtonForMedicationSlots:(NSArray *)medicationSlotsArray;
- (void)hideLoadingIndicator;

@end
