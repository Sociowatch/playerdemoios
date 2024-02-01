//
//  NSBundle+Slike.m
//  slikeplayerlite
//
//  Created by Sanjay Singh Rathor on 18/05/18.
//

#import "NSBundle+Slike.h"
#import "SlikeAvPlayerViewController.h"

@implementation NSBundle (Slike)

+ (NSBundle *)slikeNibsBundle {
    
    static NSBundle* resourcesBundle = nil;
    NSBundle *containingBundle = [NSBundle bundleForClass:[SlikeAvPlayerViewController class]];
    NSURL *resourcesBundleURL = [containingBundle URLForResource:@"SlikePlayerResources" withExtension:@"bundle"];
    if (resourcesBundleURL) {
        resourcesBundle = [NSBundle bundleWithURL:resourcesBundleURL];
    }
    return resourcesBundle;
    
}

+ (NSBundle *)slikeImagesBundle {
    
    static NSBundle* resourcesBundle = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSBundle *containingBundle = [NSBundle bundleForClass:[SlikeAvPlayerViewController class]];
        NSURL *resourcesBundleURL = [containingBundle URLForResource:@"SlikePlayerResources" withExtension:@"bundle"];
        NSString* frameworkBundlePath = [[resourcesBundleURL path] stringByAppendingPathComponent:@"SlikePlayer.bundle"];
        resourcesBundle = [NSBundle bundleWithPath:frameworkBundlePath];
        
    });
    return resourcesBundle;
    
}

@end
