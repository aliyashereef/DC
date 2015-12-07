//
//  AppDelegate.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/2/15.
//

//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DCWindowState) {
    oneThirdWindow,
    halfWindow,
    twoThirdWindow,
    fullWindow,
};

@interface DCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) NSString *userRole;

@property (strong, nonatomic) NSString *baseURL;

@property (strong, nonatomic) NSString *authorizeURL;

@property DCWindowState windowState;

- (BOOL)isNetworkReachable;

@end

