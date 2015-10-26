//
//  AppDelegate.m
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/2/15.
//
//

#import "DCAppDelegate.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#define CRASHLYTICS_KEY @"4a2b5d073fadf25858561722b765f22b48ff0895"

@interface DCAppDelegate ()

@end

@implementation DCAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Fabric with:@[CrashlyticsKit]];
    [Crashlytics startWithAPIKey:CRASHLYTICS_KEY];
    [self configureAppearanceSettings];
    [self trackNetworkConnection];
    [self setDefaultPreferencesForSettings];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Private Methods

- (void)trackNetworkConnection {
    
    //reachability checking
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        DCDebugLog(@"Reachability status is %ld", (long)status);
        if (status != AFNetworkReachabilityStatusNotReachable) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkAvailable object:nil];
        }
    }];
}

- (void)configureAppearanceSettings {
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    // bar color
   // [[UINavigationBar appearance] setBarTintColor:[UIColor getColorForHexString:@"#eff6fa"]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor getColorForHexString:@"#007aff"]];
    [[UINavigationBar appearance] setTranslucent:YES];
    //bar title color
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName: [UIColor blackColor],NSFontAttributeName: [UIFont systemFontOfSize:18.0],
                                                           }];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor getColorForHexString:@"#007aff"], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor], NSForegroundColorAttributeName,nil] forState:UIControlStateDisabled];
}

- (void)setDefaultPreferencesForSettings {
// Register the preference defaults early.
    NSDictionary *appDefaults = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:SETTINGS_TOGGLE_BUTTON_KEY];

    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)isNetworkReachable {
    
    AFNetworkReachabilityStatus status = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
    DCDebugLog(@"isReachable is %d", [[AFNetworkReachabilityManager sharedManager] isReachable]);
    BOOL connected = (status == AFNetworkReachabilityStatusNotReachable) ? NO : YES;
    if (!connected) {
        [DCUtility displayAlertWithTitle:NSLocalizedString(@"ERROR", @"")
                                 message:NSLocalizedString(@"INTERNET_CONNECTION_ERROR", @"")];
    }
    return connected;
}

@end
