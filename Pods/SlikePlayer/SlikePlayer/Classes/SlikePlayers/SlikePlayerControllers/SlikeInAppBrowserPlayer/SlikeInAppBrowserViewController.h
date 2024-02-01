//
//  SlikeInAppBrowserViewController.h
//  Pods
//
//  Created by Aravind kumar on 5/4/17.
//
//

#import <UIKit/UIKit.h>
#import <WebKit/WKWebView.h>
#import <WebKit/WebKit.h>


@interface SlikeInAppBrowserViewController : UIViewController <WKUIDelegate, WKNavigationDelegate> {
    __unsafe_unretained IBOutlet UILabel *lblTitle;
}
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
- (IBAction)clbClose:(id)sender;
@property(nonatomic,strong) NSURL *webURL;
@property(nonatomic,strong) NSString *titleInfo;
@property (nonatomic, strong) WKWebView *wkWebView;

@end
