//
//  UploadPictureCell.h
//  Election Leaflets
//
//  Created by Lachlan Wright on 27/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UploadPictureCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *uploadedPictureContentView;
@property (weak, nonatomic) IBOutlet UIView *uploadedPictureView;
@property (weak, nonatomic) IBOutlet UILabel *uploadedPictureLabel;

- (void) updateImage:(UIImage*)newImage;

@end
