//
//  LeafletTagAndSubmitCell.h
//  Election Leaflets
//
//  Created by Lachlan Wright on 4/05/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeafletTagAndSubmitCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextView *leafletTags;
@property (weak, nonatomic) IBOutlet UITextField *leafletSubmitterName;
@property (weak, nonatomic) IBOutlet UITextField *leafletSubmitterEmail;

@end
