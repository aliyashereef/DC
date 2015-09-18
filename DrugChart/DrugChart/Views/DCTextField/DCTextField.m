//
//  DCTextField.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/3/15.
//
//

#import "DCTextField.h"

#define CONTENT_INSET_DEFAULT 0.0f
#define CONTENT_INSET_LEFT 15.0f

@implementation DCTextField


- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(CONTENT_INSET_DEFAULT,
                                           CONTENT_INSET_LEFT,
                                           CONTENT_INSET_DEFAULT,
                                           CONTENT_INSET_DEFAULT);
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        self.edgeInsets = UIEdgeInsetsMake(CONTENT_INSET_DEFAULT,
                                           CONTENT_INSET_LEFT,
                                           CONTENT_INSET_DEFAULT,
                                           CONTENT_INSET_DEFAULT);
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

@end
