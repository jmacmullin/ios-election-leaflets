//
//  JMMLeafletCell.h
//  Election Leaflets
//
//  Created by Jake MacMullin on 22/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Nimbus/NINetworkImageView.h>
#import "JMMLeaflet.h"


@interface JMMLeafletCell : UITableViewCell <NINetworkImageViewDelegate>

@property (nonatomic, strong) JMMLeaflet *leaflet;

@property (nonatomic, strong) IBOutlet UILabel *publishedByLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet NINetworkImageView *leafletImageView;
@property (nonatomic, strong) IBOutlet UIView *leafletContentView;

@end
