//
//  DCPositionableGraphicsView.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 14/06/15.
//
//

#import <UIKit/UIKit.h>
#import "DCPositionableGraphics.h"

@interface DCPositionableGraphicsView : UIView

- (id)initWithGraphicsType:(PositionableGraphicsType)graphicsType
                  andFrame:(CGRect)viewFrame;

@end
