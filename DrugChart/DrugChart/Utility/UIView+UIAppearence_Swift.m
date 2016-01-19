//
//  UIView+UIAppearence_Swift.m
//  DrugChart
//
//  Created by Felix Joseph on 18/01/16.
//
//

#import "UIView+UIAppearence_Swift.h"

@implementation UIView (UIViewAppearence_Swift)
+ (instancetype)dc_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}
@end
