//
//  DCScrollView.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 6/15/15.
//
//

#import <UIKit/UIKit.h>

@protocol DCScrollViewDelegate <NSObject>

- (void)touchedScrollView:(UITouch *)touch;

@end

@interface DCScrollView : UIScrollView

@property (nonatomic, weak) id <DCScrollViewDelegate> scrollDelegate;

@end
