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
    _instructionsTextView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
}

- (void)populatePlaceholderForFieldIsInstruction:(BOOL)isInstructionField {
    
    _isInstruction = isInstructionField;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeInlineDatePickers)]) {
        [self.delegate closeInlineDatePickers];
    }
    if ((_isInstruction && [textView.text isEqualToString:NSLocalizedString(@"INSTRUCTIONS", @"")]) || (!_isInstruction && [textView.text isEqualToString:NSLocalizedString(@"DESCRIPTION", @"")])) {
        textView.textColor = [UIColor blackColor];
        textView.text = EMPTY_STRING;
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateTextViewText:isInstruction:)]) {
        [self.delegate updateTextViewText:textView.text isInstruction:_isInstruction];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:EMPTY_STRING]) {
        textView.textColor = [UIColor colorForHexString:@"#8f8f95"];
        if (_isInstruction) {
            [textView setText:NSLocalizedString(@"INSTRUCTIONS", @"")];
        } else {
            [textView setText:NSLocalizedString(@"DESCRIPTION", @"")];
        }
    }
    [textView scrollRangeToVisible:NSMakeRange (0, 0)];
}

@end
