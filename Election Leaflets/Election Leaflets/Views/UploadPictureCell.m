//
//  UploadPictureCell.m
//  Election Leaflets
//
//  Created by Lachlan Wright on 27/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "UploadPictureCell.h"

@interface UploadPictureCell()
@property (nonatomic, strong) CALayer *contentLayer;
@end

@implementation UploadPictureCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    if (self.contentLayer==nil) {
        [self setContentLayer:self.uploadedPictureContentView.layer];
        [self.contentLayer setBorderWidth:1.0];
        [self.contentLayer setBorderColor:[UIColor lightGrayColor].CGColor];
        [self.contentLayer setCornerRadius:3.0];
    }
}

- (void) updateImage:(UIImage*)newImage
{
    //clear any existing subviews (i.e. images)
    for (UIView *subview in [self.uploadedPictureView subviews]) {
        [subview removeFromSuperview];
    }
    UIImageView *newImageView = [[UIImageView alloc] initWithImage:newImage]; 
    [newImageView setContentMode:UIViewContentModeScaleAspectFit];
    CGRect newFrame = newImageView.frame; //get the old frame
    newFrame.size = self.uploadedPictureView.frame.size; //expand the frame size
    newImageView.frame = newFrame; //set back to image view frame
    [self.uploadedPictureView addSubview:newImageView]; //add the new image view
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.0f];
    
    for (UIView *subview in self.subviews) {
        
        
        if ([NSStringFromClass([subview class]) isEqualToString:@"UITableViewCellDeleteConfirmationControl"]) {
            CGRect newFrame = subview.frame;
            newFrame.origin.x = 230;
            newFrame.origin.y = -135;
            subview.frame = newFrame;
        }
    }
    [UIView commitAnimations];
}

@end
