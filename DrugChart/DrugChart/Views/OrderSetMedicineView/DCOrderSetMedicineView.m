//
//  DCOrderSetMedicineView.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 7/2/15.
//
//

#import "DCOrderSetMedicineView.h"

#define SELECTION_BUTTON_MULTIPLIER 100
#define DELETE_BUTTON_MULTIPLIER    200

#define DELETE_CLOSE_IMAGE [UIImage imageNamed:@"OrderSetRemoved"]

#define SELECTED_FONT_COLOR [UIColor getColorForHexString:@"#d0edff"]
#define UNSELECTED_FONT_COLOR [UIColor getColorForHexString:@"#898989"]
#define BLUE_COLOR [UIColor getColorForHexString:@"#0079C2"]


@implementation DCOrderSetMedicineView

- (void)configureViewElementsForMedication:(DCMedicationDetails *)medication {
    
    _medication = medication;
    //populate view elements
    [_selectionButton setTag:SELECTION_BUTTON_MULTIPLIER * self.tag];
    [_deleteButton setTag:DELETE_BUTTON_MULTIPLIER * self.tag];
    [_deleteButton setHidden:YES];
    [self configureCountLabelAndCompletionStatusImageView];
    [self addLongPressGestureForSelectionButton];
    [self addTapGestureForSelectionButton];
}

- (void)updateMedicationViewOnSelection:(BOOL)select {
    
    if (!select) {
        [_highlightButton setSelected:NO];
        _medicineNameLabel.textColor = UNSELECTED_FONT_COLOR;
        _countLabel.textColor = UNSELECTED_FONT_COLOR;
    } else {
        [_highlightButton setSelected:YES];
        _medicineNameLabel.textColor = SELECTED_FONT_COLOR;
        _countLabel.textColor = BLUE_COLOR;
    }
    [self configureCountLabelAndCompletionStatusImageView];
}

- (void)configureCountLabelAndCompletionStatusImageView {
    
    //update view elements based on add medication completion status
    if (_medication.addMedicationCompletionStatus) {
        [_countLabel setHidden:YES];
        [_completionStatusImageView setHidden:NO];
    } else {
        [_countLabel setHidden:NO];
        [_completionStatusImageView setHidden:YES];
    }
    [_deleteButton setImage:DELETE_CLOSE_IMAGE forState:UIControlStateNormal];
}

- (void)addLongPressGestureForSelectionButton {
    
    //add long press gesture for selection button
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressActionOnSelectionButton:)];
    [_selectionButton addGestureRecognizer:longPress];
}

- (void)addTapGestureForSelectionButton {
    
    //add tap gesture for selection button
    if (_medication.addMedicationCompletionStatus) {
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectionButtonPressed:)];
        [_selectionButton addGestureRecognizer:gesture];
    }
}

#pragma mark - Action Methods

- (IBAction)selectionButtonPressed:(UIGestureRecognizer *)sender {
    
    //selection button pressed
    UIButton *selectedButton  = (UIButton *)sender.view;
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedMedicineSelectionButtonWithViewTag:)]) {
        [self.delegate selectedMedicineSelectionButtonWithViewTag:(int)selectedButton.tag/100];
    }
}

- (IBAction)deleteButtonPressed:(id)sender {
    
    //delete Action
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectedDeleteMedicineButtonWithViewTag:)]) {
        [self.delegate selectedDeleteMedicineButtonWithViewTag:(int)self.deleteButton.tag/200];
    }
}

- (IBAction)longPressActionOnSelectionButton:(UIGestureRecognizer *)gesture {
    
    //long press on selection button
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(longPressActionOnMedicineView)]) {
            [self.delegate longPressActionOnMedicineView];
        }
    }
}

@end
