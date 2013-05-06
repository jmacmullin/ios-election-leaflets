//
//  Button.m
//  Election Leaflets
//
//  Created by Lachlan Wright on 6/05/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import "LeafletButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation LeafletButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self format];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self format];
    }
    return self;
}

- (void)format
{
    // Set the button Text Color
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    // Set default backgrond color
    [self setBackgroundColor:[UIColor blackColor]];
    
    // Draw a custom gradient
    CAGradientLayer *btnGradient = [CAGradientLayer layer];
    btnGradient.frame = self.bounds;
    btnGradient.colors = [NSArray arrayWithObjects:
                          (id)[[UIColor colorWithRed:102.0f / 255.0f green:102.0f / 255.0f blue:102.0f / 255.0f alpha:1.0f] CGColor],
                          (id)[[UIColor colorWithRed:51.0f / 255.0f green:51.0f / 255.0f blue:51.0f / 255.0f alpha:1.0f] CGColor],
                          nil];
    [self.layer insertSublayer:btnGradient atIndex:0];
    
    // Round button corners
    CALayer *btnLayer = [self layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    // Apply a 1 pixel, black border around button
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    [[self superview] setHidden:NO];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
