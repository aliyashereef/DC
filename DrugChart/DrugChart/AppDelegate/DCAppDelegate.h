//
//  AppDelegate.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/2/15.
//
//

#import <UIKit/UIKit.h>

@interface DCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) NSString *userRole;

- (BOOL)isNetworkReachable;

@end

