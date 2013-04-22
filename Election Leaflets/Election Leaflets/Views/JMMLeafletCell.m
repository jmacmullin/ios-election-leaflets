//
//  JMMLeafletCell.m
//  Election Leaflets
//
//  Created by Jake MacMullin on 22/04/13.
//  Copyright (c) 2013 Jake MacMullin. All rights reserved.
//

#import "JMMLeafletCell.h"

@interface JMMLeafletCell()
- (void)initialise;
@end

@implementation JMMLeafletCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self!=nil) {
        [self initialise];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self!=nil) {
        [self initialise];
    }
    return self;
}

- (void)initialise
{
    [self addObserver:self
           forKeyPath:@"leaflet"
              options:NSKeyValueObservingOptionNew
              context:NULL];
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"leaflet"];
}

- (void)prepareForReuse
{
    [self.imageView prepareForReuse];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"leaflet"]) {
        [self.publishedByLabel setText:self.leaflet.publishedBy];
        [self.imageView setPathToNetworkImage:self.leaflet.imageURL.absoluteString];
        [self.imageView setDelegate:self];
        [self.titleLabel setText:self.leaflet.title];
        
        NSLog(@"%@", self.leaflet.imageURL.absoluteString);
    }
}

#pragma mark - NINetworkImageView Delegate Methods

- (void)networkImageView:(NINetworkImageView *)imageView didFailWithError:(NSError *)error
{
    NSLog(@"fail! - %@", error);
}

- (void)networkImageView:(NINetworkImageView *)imageView didLoadImage:(UIImage *)image
{
    NSLog(@"did load!");
    [self.imageView setHidden:NO];
    [self.publishedByLabel setHidden:YES];
}

@end
