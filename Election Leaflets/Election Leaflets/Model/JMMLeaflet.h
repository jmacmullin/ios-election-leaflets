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
@property (nonatomic, strong) NSString *transcript;
@property (nonatomic, strong) NSString *postcode;
@property (nonatomic, strong) NSString *electorate;
@property (nonatomic, strong) NSString *deliveryTime;
@property (nonatomic, strong) NSArray *partiesAttacked;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSString *tags;

@end
