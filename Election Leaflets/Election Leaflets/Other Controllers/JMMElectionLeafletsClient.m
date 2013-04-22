//
//  JMMElectionLeafletsClient.m
//  Election Leaflets
//
//  Created by Jake MacMullin on 22/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import <AFNetworking/AFJSONRequestOperation.h>
#import "JMMElectionLeafletsClient.h"
#import "JMMLeaflet.h"

static NSString * const kElectionLeafletsBaseURLString = @"http://www.electionleaflets.org.au/api/";

@interface JMMElectionLeafletsClient()
@property (nonatomic, copy) LeafletsSuccessBlock leafletsSuccess;
@end

@implementation JMMElectionLeafletsClient

+ (JMMElectionLeafletsClient *)sharedClient
{
    static JMMElectionLeafletsClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[JMMElectionLeafletsClient alloc] initWithBaseURL:[NSURL URLWithString:kElectionLeafletsBaseURLString]];
    });
    return _sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self!=nil) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];        
        [self setDefaultHeader:@"Accept" value:@"application/json"];
    }
    
    return self;
}

- (void)getLatestLeafletsAndProcessWithBlock:(LeafletsSuccessBlock)success
{
    [self setLeafletsSuccess:success];
    
    NSDictionary *params = @{ @"method" : @"latest", @"count" : @"10", @"output" : @"json" };
    
    [self getPath:@"call.php"
       parameters:params
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              NSMutableArray *leaflets = [NSMutableArray array];
              
              for (NSDictionary *dict in responseObject) {
                  JMMLeaflet *leaflet = [[JMMLeaflet alloc] init];

                  NSString *title = [dict valueForKey:@"title"];
                  [leaflet setTitle:title];

                  NSString *publishedBy = [dict valueForKey:@"published_by"];
                  [leaflet setPublishedBy:publishedBy];
                  
                  NSString *imageURLString = [dict valueForKey:@"image_url"];
                  NSURL *imageURL = [NSURL URLWithString:imageURLString];
                  [leaflet setImageURL:imageURL];

                  [leaflets addObject:leaflet];
              }
              
              self.leafletsSuccess(leaflets);
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              self.leafletsSuccess(nil);
          }];
}

@end
