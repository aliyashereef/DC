//
//  AddNewDosageCell.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 4/23/15.
//
//

#import "DCAddNewDosageCell.h"

static CGFloat kBorderWidth  =  2.6;

@implementation DCAddNewDosageCell

- (void)awakeFromNib {
    // Initialization code
    [self addNotifications];
    self.contentView.layer.borderWidth = kBorderWidth;
    self.layer.cornerRadius = ZERO_CONSTRAINT;
    self.contentView.layer.borderColor = [[UIColor getColorForHexString:@"#c4d3d5"] CGColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addNotifications {
    //keyboard show/hide observer
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

#pragma mark - Notification Methods

- (void)keyboardDidShow:(NSNotification *)notification {
    
}

- (void)keyboardDidHide:(NSNotification *)notification {
    
    if ([_addNewTextField.text isEqualToString:EMPTY_STRING]) {
        _addNewTextField.text = NSLocalizedString(@"ADD_NEW", @"");
    }
}

#pragma mark - UITextFieldDelegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if ([textField.text isEqualToString:NSLocalizedString(@"ADD_NEW", @"")]) {
        textField.text = EMPTY_STRING;
    }
    [self layoutIfNeeded];
    _tickButtonWidthConstraint.constant = 30;
    _closeButtonWidthConstraint.constant = 30;
    [UIView animateWithDuration:0.6
                     animations:^{
                         [self layoutIfNeeded];
                     }];

}

#pragma mark - Action Methods

- (IBAction)clearAddNewDosageFieldButtonPressed:(id)sender {
    
    //clear button action in new dosgae field
    _addNewTextField.text = NSLocalizedString(@"ADD_NEW", @"");
    _tickButtonWidthConstraint.constant = ZERO_CONSTRAINT;
    _closeButtonWidthConstraint.constant = ZERO_CONSTRAINT;
    [_addNewTextField resignFirstResponder];
}

- (IBAction)addNewDosageButtonPressed:(id)sender {
    
    if (![_addNewTextField.text isEqualToString:EMPTY_STRING] && ![_addNewTextField.text isEqualToString:NSLocalizedString(@"ADD_NEW", @"")]) {
        self.newDosageAdded(_addNewTextField.text);
    }
}

@end
