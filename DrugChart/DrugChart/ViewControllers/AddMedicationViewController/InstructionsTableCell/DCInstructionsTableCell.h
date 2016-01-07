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
- (void)updateTextViewText:(NSString *)instructions isInstruction:(BOOL)isInstruction;

@end

@interface DCInstructionsTableCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UITextView *instructionsTextView;
@property (nonatomic, weak) id <InstructionCellDelegate> delegate;
@property (nonatomic) BOOL isInstruction;

- (void)populatePlaceholderForFieldIsInstruction:(BOOL)isInstructionField;

@end
