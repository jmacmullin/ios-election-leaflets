//
//  DetailsViewController.h
//  Election Leaflets
//
//  Created by Lachlan Wright on 4/05/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsViewController : UITableViewController <UITextViewDelegate, UITextFieldDelegate>

//User inputs
@property (weak, nonatomic) IBOutlet UITextField *leafletTitle;
@property (weak, nonatomic) IBOutlet UITextView *leafletTranscript;
@property (weak, nonatomic) IBOutlet UITextField *leafletPostcode;
@property (weak, nonatomic) IBOutlet UITextView *leafletTags;
@property (weak, nonatomic) IBOutlet UITextField *submitterName;
@property (weak, nonatomic) IBOutlet UITextField *submitterEmail;

//Upload Key
@property (nonatomic, strong) NSString *uploadKey;

//Uploaded Images HTML response
@property (nonatomic, strong) NSData *htmlData;

@end
