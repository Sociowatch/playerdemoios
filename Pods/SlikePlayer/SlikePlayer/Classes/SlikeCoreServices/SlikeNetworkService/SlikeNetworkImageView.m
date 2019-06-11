//
//  NetworkImageView.m
//
//  Created by TIL on 13/09/16.
//
//

#import "SlikeNetworkImageView.h"
#import "SlikeNetworkManager.h"

static const double kFadeInTime = 0.25;

@implementation SlikeNetworkImageView

- (SlikeNetworkManager *)networkManager {
    return [SlikeNetworkManager defaultManager];
}

- (NSCache *)imageCache {
    return [SlikeNetworkManager imageCache];
}

- (void)setURL:(NSURL *)URL {
    [self setURL:URL animated:YES];
}

- (void)setURL:(NSURL *)URL animated:(BOOL)animated {
    if (!URL) {
        self.image = nil;

        return;
    }
    _URL = URL;

    __weak typeof(self) weakSelf = self;
    UIImage *image = [self.imageCache objectForKey:URL];
    if (image) {
        self.image = image;
    } else {
        [[self networkManager] getImageForURL:URL
                               completion:^(UIImage *image,
                                            NSString *localFilepath,
                                            BOOL isFromCache,
                                            NSInteger statusCode,
                                            NSError *error) {
            if ([self.URL isEqual:URL]) {
                if (image && URL) {
                    [self.imageCache setObject:image forKey:URL];
                    [weakSelf setImage:image animated:animated];
                }
            }
        }];
    }
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    [self.layer setMinificationFilter:kCAFilterTrilinear];

    if (!image) {
        if (_URL) {
            if ([[SlikeNetworkManager defaultManager] isProcessingURL:_URL]) {
                [[SlikeNetworkManager defaultManager] cancelAllRequestForURL:_URL];
            }
        }
        _URL = nil;
    }
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated {
    if (!animated) {
        self.image = image;
    } else {
        [UIView transitionWithView:self
                          duration:kFadeInTime
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.image = image;
                        }
                        completion:nil];
    }
}

@end
