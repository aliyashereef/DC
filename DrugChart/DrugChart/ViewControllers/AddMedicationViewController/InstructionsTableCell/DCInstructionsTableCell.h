//
//  DCInstructionsTableCell.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/3/15.
//
//

#import <UIKit/UIKit.h>

@protocol InstructionCellDelegate <NSObject>

- (void)closeInlineDatePickers;
- (void)updateInstructionsText:(NSString *)instructions;

@end

@interface DCInstructionsTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UITextView *instructionsTextView;
@property (nonatomic, weak) id <InstructionCellDelegate> delegate;


@end
