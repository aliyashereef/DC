//
//  DCInstructionsTableCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 9/3/15.
//
//

#import "DCInstructionsTableCell.h"


@implementation DCInstructionsTableCell

- (void)awakeFromNib {
    // Initialization code
    _instructionsTextView.text = NSLocalizedString(@"INSTRUCTIONS", @"Instructions field placeholder");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeInlineDatePickers)]) {
        [self.delegate closeInlineDatePickers];
    }
    if ([textView.text isEqualToString:NSLocalizedString(@"INSTRUCTIONS", @"")]) {
        textView.textColor = [UIColor blackColor];
        textView.text = EMPTY_STRING;
        if (self.delegate && [self.delegate respondsToSelector:@selector(scrollTableViewToInstructionsCell)]) {
            [self.delegate scrollTableViewToInstructionsCell];
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:EMPTY_STRING]) {
        textView.textColor = [UIColor colorForHexString:@"#8f8f95"];
        [textView setText:NSLocalizedString(@"INSTRUCTIONS", @"")];
    }
}



@end
