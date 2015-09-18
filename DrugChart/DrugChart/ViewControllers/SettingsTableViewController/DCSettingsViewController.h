//
//  DCSettingsViewController.h
//  DrugChart
//
//  Created by Muhammed Shaheer on 29/04/15.
//
//

#import <UIKit/UIKit.h>

@protocol DCSettingsViewControllerDelegate <NSObject>

- (void)logOutTapped;

@end

@interface DCSettingsViewController : UIViewController

@property (nonatomic, assign) id <DCSettingsViewControllerDelegate> delegate;

@end
