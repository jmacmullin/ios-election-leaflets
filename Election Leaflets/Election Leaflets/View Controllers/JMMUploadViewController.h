//
//  JMMUploadViewController.h
//  Election Leaflets
//
//  Created by Jake MacMullin on 24/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JMMUploadViewController : UITableViewController <UIImagePickerControllerDelegate>

@property (nonatomic, strong) UIImagePickerController * imagePickerController;
@property (nonatomic, strong) id <UIImagePickerControllerDelegate> delegate;

@end
