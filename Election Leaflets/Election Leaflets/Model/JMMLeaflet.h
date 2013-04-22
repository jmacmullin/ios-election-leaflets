//
//  JMMLeaflet.h
//  Election Leaflets
//
//  Created by Jake MacMullin on 22/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMMLeaflet : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *publishedBy;
@property (nonatomic, strong) NSURL *imageURL;

@end
