//
//  SlikeInAppBrowserViewController.h
//  Pods
//
//  Created by Aravind kumar on 5/4/17.
//
//

#import <UIKit/UIKit.h>

@interface SlikeInAppBrowserViewController : UIViewController
{
    __unsafe_unretained IBOutlet UILabel *lblTitle;
    __unsafe_unretained IBOutlet UIWebView *webViewInfo;
    
}
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
- (IBAction)clbClose:(id)sender;
@property(nonatomic,strong) NSURL *webURL;
@property(nonatomic,strong) NSString *titleInfo;
@end
