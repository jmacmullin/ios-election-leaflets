//
//  JMMElectionLeafletsClient.h
//  Election Leaflets
//
//  Created by Jake MacMullin on 22/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <AFNetworking/AFHTTPClient.h>

typedef void (^ LeafletsSuccessBlock)(NSArray *leaflets);

@interface JMMElectionLeafletsClient : AFHTTPClient

+ (JMMElectionLeafletsClient *)sharedClient;

/**
 Request a list of the latest leaflets and process it with the given block.
 In the event of some sort of error the block will be called with a nil
 parameter.
 */
- (void)getLatestLeafletsAndProcessWithBlock:(LeafletsSuccessBlock)success;


@end
