//
//  MMSidebarImagePicker.m
//  LooseLeaf
//
//  Created by Adam Wulf on 3/27/14.
//  Copyright (c) 2014 Milestone Made, LLC. All rights reserved.
//

#import "MMSlidingSidebarView.h"
#import "MMLeftCloseButton.h"
#import "UIView+Animations.h"
#import "MMSlidingSidebarContainerView.h"
#import "FXBlurView.h"
#import "UIView+Debug.h"

@implementation MMSlidingSidebarView{
    // this is the button that'll trigger the sidebar
    MMSidebarButton* referenceButton;
    // this is our button inside the sidebar
    MMLeftCloseButton* closeButton;
    // the width of the strokes in the border
    CGFloat borderSize;
    // YES if we should animate from the left,
    // NO for the right
    BOOL directionIsFromLeft;
    
    FXBlurView* blurView;
    UIView* blurContainerView;
}

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame forButton:(MMSidebarButton*)_button animateFromLeft:(BOOL)fromLeft
{
    self = [super initWithFrame:frame];
    if (self) {
        
        blurContainerView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:blurContainerView];
        blurContainerView.frame = self.bounds;
        blurContainerView.contentScaleFactor = 1.0;

//        [blurContainerView showDebugBorder];
//        [blurView showDebugBorder];

        
//        
//        // blur view
//        UIBlurEffect* blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        UIVisualEffectView* background = [[UIVisualEffectView alloc] initWithEffect:blur];
//        CGRect size = self.bounds;
//        background.frame = size;
//        background.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        [self addSubview:background];
//        
//        // rect for blur
//        CGRect leftDarkArea = [self contentBounds];
//        if(directionIsFromLeft){
//            leftDarkArea.size.width += 3*kBounceWidth;
//            leftDarkArea.origin.x = 0;
//        }else{
//            leftDarkArea.origin.x -= kBounceWidth;
//            leftDarkArea.size.width += 3*kBounceWidth;
//        }
//

        // 2 points for the border size
        borderSize = 2;
        // store our direction and reference button
        directionIsFromLeft = fromLeft;
        referenceButton = _button;
        // make the button we'll use to close
        closeButton = [[MMLeftCloseButton alloc] initWithFrame:referenceButton.frame];
        closeButton.frame = [self rectForButton];
        [closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        if(!directionIsFromLeft){
            // flip the button to point to the right
            closeButton.rotation = M_PI;
        }
        [self addSubview:closeButton];
        
        
        if(directionIsFromLeft){
            CGRect buttonRect = [self rectForButton];
            CGFloat radius = buttonRect.size.width / 2;
            CGPoint buttonCenter = CGPointMake(buttonRect.origin.x + radius, buttonRect.origin.y + radius);
            CGFloat targetX = self.contentBounds.size.width + 3*kBounceWidth;
            CGFloat angle = acos(-(targetX - buttonRect.origin.x) / radius);
            
            
            UIBezierPath* maskPath = [UIBezierPath bezierPath];
            [maskPath moveToPoint:CGPointZero];
            [maskPath addLineToPoint:CGPointMake(self.contentBounds.size.width + 3*kBounceWidth, 0)];
            
            [maskPath addLineToPoint:CGPointMake(self.contentBounds.size.width + 3*kBounceWidth, buttonRect.origin.y)];
            [maskPath addArcWithCenter:buttonCenter radius:radius startAngle:(2*M_PI - angle) endAngle:angle clockwise:NO];
            [maskPath addLineToPoint:CGPointMake(self.contentBounds.size.width + 3*kBounceWidth, buttonRect.origin.y + buttonRect.size.height)];
            
            [maskPath addLineToPoint:CGPointMake(self.contentBounds.size.width + 3*kBounceWidth, self.contentBounds.size.height)];
            [maskPath addLineToPoint:CGPointMake(0, self.contentBounds.size.height)];
            [maskPath addLineToPoint:CGPointZero];
            [maskPath closePath];
            
            CGFloat stripeWidth = 2.0;
            targetX = targetX - stripeWidth;
            angle = acos(-(targetX - buttonRect.origin.x) / (radius - stripeWidth));
            
            [maskPath moveToPoint:CGPointMake(self.contentBounds.size.width + 3*kBounceWidth + stripeWidth, 0)];
            [maskPath addLineToPoint:CGPointMake(self.contentBounds.size.width + 3*kBounceWidth + stripeWidth, buttonRect.origin.y)];
            [maskPath addArcWithCenter:buttonCenter radius:radius - stripeWidth startAngle:(2*M_PI - angle) endAngle:angle clockwise:NO];
            [maskPath addLineToPoint:CGPointMake(self.contentBounds.size.width + 3*kBounceWidth + stripeWidth, buttonRect.origin.y + buttonRect.size.height)];
            [maskPath addLineToPoint:CGPointMake(self.contentBounds.size.width + 3*kBounceWidth + stripeWidth, self.contentBounds.size.height)];
            
            targetX = targetX - stripeWidth;
            angle = acos(-(targetX - buttonRect.origin.x) / (radius - stripeWidth*2));
            
            [maskPath addLineToPoint:CGPointMake(self.contentBounds.size.width + 3*kBounceWidth + stripeWidth*2, self.contentBounds.size.height)];
            [maskPath addArcWithCenter:buttonCenter radius:radius - stripeWidth*2 startAngle:angle endAngle:(2*M_PI - angle) clockwise:YES];
            [maskPath addLineToPoint:CGPointMake(self.contentBounds.size.width + 3*kBounceWidth + stripeWidth*2, 0)];
            [maskPath closePath];
            
            
            //        // create mask, including border
            //        // and button cutout
            CAShapeLayer* maskLayer = [CAShapeLayer layer];
            maskLayer.frame = self.bounds;
            maskLayer.path = maskPath.CGPath;
            maskLayer.fillColor = [UIColor whiteColor].CGColor;
            blurContainerView.layer.mask = maskLayer;
        }else{
            
            CGRect buttonRect = [self rectForButton];
            CGFloat radius = buttonRect.size.width / 2;
            CGPoint buttonCenter = CGPointMake(buttonRect.origin.x + radius, buttonRect.origin.y + radius);
            CGFloat targetX = buttonRect.origin.x + buttonRect.size.width - 2*kBounceWidth;
            CGFloat angle = acos((targetX - buttonCenter.x) / radius);
            
            
            UIBezierPath* maskPath = [UIBezierPath bezierPath];
            [maskPath moveToPoint:CGPointMake(targetX, 0)];
            [maskPath addLineToPoint:CGPointMake(targetX, buttonRect.origin.y)];
            
            [maskPath addArcWithCenter:buttonCenter radius:radius startAngle:(2*M_PI - angle) endAngle:angle clockwise:YES];

            [maskPath addLineToPoint:CGPointMake(targetX, buttonRect.origin.y + buttonRect.size.height)];
            [maskPath addLineToPoint:CGPointMake(targetX, self.contentBounds.size.height)];
            
            [maskPath addLineToPoint:CGPointMake(blurContainerView.bounds.size.width + kBounceWidth, self.contentBounds.size.height)];
            [maskPath addLineToPoint:CGPointMake(blurContainerView.bounds.size.width + kBounceWidth, 0)];
            [maskPath closePath];
            
            CGFloat stripeWidth = 2.0;
            targetX = targetX - stripeWidth;
            angle = acos((targetX - buttonCenter.x) / (radius - stripeWidth));

            [maskPath moveToPoint:CGPointMake(targetX, 0)];
            [maskPath addLineToPoint:CGPointMake(targetX, buttonRect.origin.y)];
            
            [maskPath addArcWithCenter:buttonCenter radius:radius - stripeWidth startAngle:(2*M_PI - angle) endAngle:angle clockwise:YES];
            
            [maskPath addLineToPoint:CGPointMake(targetX, buttonRect.origin.y + buttonRect.size.height)];
            [maskPath addLineToPoint:CGPointMake(targetX, self.contentBounds.size.height)];

            targetX = targetX - stripeWidth;
            angle = acos((targetX - buttonCenter.x) / (radius - stripeWidth*2));

            [maskPath addLineToPoint:CGPointMake(targetX, self.contentBounds.size.height)];
            [maskPath addArcWithCenter:buttonCenter radius:radius - stripeWidth*2 startAngle:angle endAngle:(2*M_PI - angle) clockwise:NO];
            [maskPath addLineToPoint:CGPointMake(targetX, 0)];
            [maskPath closePath];
            
            
            //        // create mask, including border
            //        // and button cutout
            CAShapeLayer* maskLayer = [CAShapeLayer layer];
            maskLayer.frame = self.bounds;
            maskLayer.path = maskPath.CGPath;
            maskLayer.fillColor = [UIColor whiteColor].CGColor;
            blurContainerView.layer.mask = maskLayer;
        }
        


        
        // for clarity
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
    }
    return self;
}

-(void) setDelegate:(MMSlidingSidebarContainerView *)_delegate{
    delegate = _delegate;
}

-(void) willShow{
    if(!blurView){
        CGRect b = self.bounds;
        blurView = [[FXBlurView alloc] initWithFrame:self.bounds];
        blurView.contentScaleFactor = 1.0;
        blurView.blurEnabled = YES;
        blurView.dynamic = NO;
        blurView.tintColor = [[UIColor blackColor] colorWithAlphaComponent:1.0];
        [blurContainerView addSubview:blurView];
        blurView.frame = blurContainerView.bounds;
        blurView.underlyingView = delegate.viewForBlur;
        b = blurContainerView.bounds;
        
        // set the anchor to 0,0 for the sliding animations
        [UIView setAnchorPoint:CGPointZero forView:blurView];
    }

    CGRect fr = blurView.frame;
    if(directionIsFromLeft){
        fr.origin = CGPointMake(blurContainerView.bounds.size.width, 0);
    }else{
        fr.origin = CGPointMake(-blurContainerView.bounds.size.width, 0);
    }
    blurView.frame = fr;
    [blurView setNeedsDisplay];
    [blurView updateAsynchronously:NO completion:nil];
}

-(void) didHide{
    [blurView removeFromSuperview];
    blurView = nil;
}

-(void) showForDuration:(CGFloat)duration{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    bounceAnimation.removedOnCompletion = YES;
    bounceAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.0],
                                [NSNumber numberWithFloat:0.7],
                                [NSNumber numberWithFloat:1.0], nil];
    if(directionIsFromLeft){
        bounceAnimation.values = [NSArray arrayWithObjects:
                                  [NSValue valueWithCGPoint:CGPointMake(blurView.bounds.size.width, 0)],
                                  [NSValue valueWithCGPoint:CGPointMake(-kBounceWidth, 0)],
                                  [NSValue valueWithCGPoint:CGPointMake(0, 0)], nil];
    }else{
        bounceAnimation.values = [NSArray arrayWithObjects:
                                  [NSValue valueWithCGPoint:CGPointMake(-blurView.bounds.size.width, 0)],
                                  [NSValue valueWithCGPoint:CGPointMake(kBounceWidth, 0)],
                                  [NSValue valueWithCGPoint:CGPointMake(0, 0)], nil];
    }
    bounceAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn], nil];
    [bounceAnimation setDuration:duration];
    
    [blurView.layer addAnimation:bounceAnimation forKey:@"bounceAnimation"];
    
    blurView.frame = blurContainerView.bounds;
}

-(void) hideAnimation{
    CGRect fr = blurView.frame;
    if(directionIsFromLeft){
        fr.origin.x = blurView.bounds.size.width/4;
    }else{
        fr.origin.x = -blurView.bounds.size.width/4;
    }
    blurView.frame = fr;
}

-(BOOL) isVisible{
    return [self.delegate isVisible];
}

// the contentBounds defines what area inside of this view
// is available for the content to be placed. placing content
// outside of this view will probably look very awkward.
//
// the frame of this ContentView lies partially outside of
// the parent view by 1*kBounceWidth. This CGRect calculates
// an area 1*kBounceWidth margin inside of that for content.
-(CGRect) contentBounds{
    CGRect contentBounds = self.bounds;
    contentBounds.size.width -= 2*kBounceWidth;
    if(directionIsFromLeft){
        contentBounds.origin.x = 2*kBounceWidth;
    }else{
        contentBounds.origin.x = kBounceWidth;
        contentBounds.origin.x += referenceButton.frame.size.width;
    }
    contentBounds.size.width -= kBounceWidth;
    contentBounds.size.width -= referenceButton.frame.size.width;
    return contentBounds;
}

// the rectForButton defines where the frame of the button
// will be and is particularly helpful when drawing the
// notch to fit the button in.
-(CGRect) rectForButton{
    CGRect fr = referenceButton.frame;
    if(directionIsFromLeft){
        fr.origin.x = [self contentBounds].origin.x + [self contentBounds].size.width;
        fr.origin.x -= kBounceWidth / 2;
    }else{
        fr.origin.x = [self contentBounds].origin.x - referenceButton.frame.size.width;
        fr.origin.x += kBounceWidth / 2;
    }
    fr.origin.x = ceilf(fr.origin.x);
    fr.origin.y = ceilf(fr.origin.y);
    return fr;
}


#pragma mark - Drawing

// a very dark grey
+(UIColor*) backgroundColor{
    return [UIColor colorWithRed: 0.26 green: 0.26 blue: 0.26 alpha: 0.8];
}

// a semi-opaque white
+(UIColor*) lightBackgroundColor{
    return [UIColor colorWithRed: 0.84 green: 0.84 blue: 0.84 alpha: 0.5];
}

// helper function to erase everything
// inside of the input path
-(void) erase:(UIBezierPath*)path atContext:(CGContextRef)context{
    CGContextSetBlendMode(context, kCGBlendModeClear);
    [[UIColor whiteColor] setFill];
    [path fill];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
}


#pragma mark - UIButton Event

// tell our delegate to close us down
-(void) closeButtonTapped:(UIButton*)button{
    [self.delegate sidebarCloseButtonWasTapped];
}


@end
