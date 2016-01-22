//
//  UIView+UIAppearence_Swift.h
//  DrugChart
//
//  Created by Felix Joseph on 18/01/16.
//
//

#import <Foundation/Foundation.h>

@interface UIView (UIViewAppearence_Swift)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)dc_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end
