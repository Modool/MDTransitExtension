//
//  MDSwipeInteractionController.m
//  MDTransitioning
//
//  Created by Jave on 2017/7/26.
//  Copyright © 2017年 markejave. All rights reserved.
//

#import "MDSwipeInteractionController.h"

@interface MDSwipeInteractionController ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL interactionInProgress;

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, strong) id<MDPercentDrivenInteractiveTransition> interactiveTransition;

@end

@implementation MDSwipeInteractionController

- (instancetype)init {
    return nil;
}

+ (instancetype)interactionControllerWithViewController:(UIViewController *)viewController{
    return [[self alloc] initWithViewController:viewController];
}

- (instancetype)initWithViewController:(UIViewController *)viewController{
    if (self = [super init]) {
        self.viewController = viewController;
        
        [self prepareGestureRecognizerInView:[viewController view]];
    }
    return self;
}

#pragma mark - accessor

- (void)setEnable:(BOOL)enable{
    self.panGestureRecognizer.enabled = enable;
}

- (BOOL)enable{
    return [[self panGestureRecognizer] isEnabled];
}

#pragma mark - protected

- (id<MDPercentDrivenInteractiveTransition>)requireInteractiveTransition;{
    return [UIPercentDrivenInteractiveTransition new];
}

- (void)prepareGestureRecognizerInView:(UIView*)view {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    self.panGestureRecognizer.delegate = self;
    [view addGestureRecognizer:[self panGestureRecognizer]];
}

#pragma mark - UIPanGestureRecognizer handlers

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[[self viewController] view]];
    CGPoint translation = [recognizer translationInView:[[self viewController] view]];
    CGPoint velocity = [recognizer velocityInView:[[self viewController] view]];
    
    CGFloat progress = [self progressTransform] ? self.progressTransform(location, translation, velocity) : 1.f;
    progress = MIN(1.0, MAX(0.0, progress));
    
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        self.interactionInProgress = YES;
        // Create a interactive transition and pop the view controller
        self.interactiveTransition = [self requireInteractiveTransition];
        if ([self begin]) {
            self.begin();
        }
    } else if ([recognizer state] == UIGestureRecognizerStateChanged) {
        // Update the interactive transition's progress
        [[self interactiveTransition] updateInteractiveTransition:progress];
    } else if ([recognizer state] == UIGestureRecognizerStateEnded || [recognizer state] == UIGestureRecognizerStateCancelled) {
        // Finish or cancel the interactive transition
        if (progress > 0.25) {
            [[self interactiveTransition] finishInteractiveTransition];
        } else {
            [[self interactiveTransition] cancelInteractiveTransition];
        }
        self.interactiveTransition = nil;
        self.interactionInProgress = NO;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[[self viewController] view]];
    CGPoint velocety = [recognizer velocityInView:[[self viewController] view]];
    
    return recognizer == [self panGestureRecognizer] && [self enableSwipeTransform] && self.enableSwipeTransform(location, velocety);
}

@end
