//
//  RoundRectPresentationController.h
//  PresentationControllerSample
//
//  Created by Shinichiro Oba on 2014/10/08.
//  Copyright (c) 2014年 bricklife.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoundRectPresentationController : UIPresentationController

@property (nonatomic, assign) BOOL isMissedAlert;
@property (nonatomic) SelectedPresentationViewType viewType;
@property (nonatomic) CGSize frameSize;

@end
