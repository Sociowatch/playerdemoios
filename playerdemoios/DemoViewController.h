//
//  DemoViewController.h
//  slikeplayerdemoios
//
//  Created by Aravind Kumar on 05/09/18.
//  Copyright © 2018 BBDSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWAdStatusInfo.h"
#import <SWPlayer.h>
#import <SWGlobals.h>

@interface DemoViewController : UIViewController
{
    
}
@property(nonatomic,assign) NSInteger playType;
@property (strong, nonatomic) SWConfig *slikeConfigPrevious;

@end
