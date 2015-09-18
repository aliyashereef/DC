//
//  ErrorPopOverViewController.h
//  DrugChart
//
//  Created by Jilu Mary Joy on 3/31/15.
//
//

#import <UIKit/UIKit.h>

typedef void (^ViewLoadedAction)();

@interface DCErrorPopOverViewController : UIViewController

@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) UIView *presentedTextfield;
@property (nonatomic, strong) ViewLoadedAction viewLoaded;

@end
