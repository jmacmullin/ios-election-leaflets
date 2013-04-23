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
    [super prepareForReuse];
    [self.leafletImageView prepareForReuse];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"leaflet"]) {
        [self.publishedByLabel setText:self.leaflet.publishedBy];
        [self.leafletImageView setPathToNetworkImage:self.leaflet.imageURL.absoluteString
                                      forDisplaySize:CGSizeMake(280.0, 280.0)
                                         contentMode:UIViewContentModeScaleAspectFill];
        [self.leafletImageView setDelegate:self];
        [self.titleLabel setText:self.leaflet.title];
    }
}

#pragma mark - NINetworkImageView Delegate Methods

- (void)networkImageView:(NINetworkImageView *)imageView didFailWithError:(NSError *)error
{
}

- (void)networkImageView:(NINetworkImageView *)imageView didLoadImage:(UIImage *)image
{
}

@end
