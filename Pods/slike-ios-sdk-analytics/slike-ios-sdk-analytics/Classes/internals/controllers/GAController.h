//
//  GAController.h
//  Pods
//
//  Created by Aravind kumar on 9/27/17.
//
//

#import <Foundation/Foundation.h>
#import "ISlikeAnlytics.h"
#import <GAI.h>
#import "GAITracker.h"
#import "GAITrackedViewController.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "GAILogger.h"
#import "SlikeConfig.h"

@interface GAController : NSObject<ISlikeAnlytics>
{
}
-(id) init:(id) tracker;
@end
