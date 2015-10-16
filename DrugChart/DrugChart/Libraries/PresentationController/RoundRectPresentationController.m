//
//  RoundRectPresentationController.m
//  PresentationControllerSample
//
//  Created by Shinichiro Oba on 2014/10/08.
//  Copyright (c) 2014年 bricklife.com. All rights reserved.
//

#import "RoundRectPresentationController.h"

@interface RoundRectPresentationController ()

@property (nonatomic, readonly) UIView *dimmingView;

@end

@implementation RoundRectPresentationController

- (UIView *)dimmingView {
    static UIView *instance = nil;
    if (instance == nil) {
        instance = [[UIView alloc] initWithFrame:self.containerView.bounds];
        instance.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    }
    return instance;
}

- (void)presentationTransitionWillBegin {
    
    UIView *presentedView = self.presentedViewController.view;
    presentedView.layer.cornerRadius = 0.0f;
    presentedView.layer.shadowColor = [[UIColor blackColor] CGColor];
    //presentedView.layer.shadowOffset = CGSizeMake(0, 10);
    //presentedView.layer.shadowRadius = 10;
    //presentedView.layer.shadowOpacity = 0.5;

    self.dimmingView.frame = self.containerView.bounds;
    self.dimmingView.alpha = 0;
    [self.containerView addSubview:self.dimmingView];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 1;
    } completion:nil];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (void)dismissalTransitionWillBegin {
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0;
    } completion:nil];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    if (completed) {
        [self.dimmingView removeFromSuperview];
    }
}

- (CGRect)frameOfPresentedViewInContainerView {

    CGRect frame;
    switch (_viewType) {
            
        case eAdministerMedication:
            frame = CGRectMake((self.containerView.frame.size.width - 458) / 2,
                               (self.containerView.frame.size.height - 295) / 2,
                               458, self.isMissedAlert? 160 : 295);
            break;
            
        case eAddMedication:
            
            if (_frameSize.height >=  262.0f) {
                frame = CGRectMake((self.containerView.frame.size.width - 584) / 2,
                                   (self.containerView.frame.size.height - 262.0f) / 2,
                                   584, 262.0f);
            } else {
                frame = CGRectMake((self.containerView.frame.size.width - 584) / 2,
                                   (self.containerView.frame.size.height - _frameSize.height) / 2,
                                   584, _frameSize.height);
            }
//            frame = CGRectMake((self.containerView.frame.size.width - 584) / 2,
//                               (self.containerView.frame.size.height - 230) / 2,
//                               584, 230);
            break;
            
        case eSecurity:
            frame = CGRectMake((self.containerView.frame.size.width - 300) / 2,
                               (self.containerView.frame.size.height - 190) / 2,
                               300, 190);
            break;
            
        case ePrescriberDetails:
            frame = CGRectMake((self.containerView.frame.size.width - 601) / 2,
                               (self.containerView.frame.size.height - 520) / 2,
                               601, 520);
            break;
        
        case eOverride:
            frame = CGRectMake((self.containerView.frame.size.width - 458) / 2,
                               (self.containerView.frame.size.height - 200) / 2,
                               458, 200);
            break;
            
        default:
            break;
    }
    
    
    return frame;
}

- (void)containerViewWillLayoutSubviews {
    self.dimmingView.frame = self.containerView.bounds;
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
    self.presentedView.layer.cornerRadius = 0.0f;
}

@end
