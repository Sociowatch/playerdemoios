//
//  SlikeInAppBrowserViewController.m
//  Pods
//
//  Created by Aravind kumar on 5/4/17.
//
//

#import "SlikeInAppBrowserViewController.h"
#import "SlikeAvPlayerViewController.h"
#import "NSBundle+Slike.h"

@interface SlikeInAppBrowserViewController () {
}
@property (weak, nonatomic) IBOutlet UIView *webContainer;

@end

@implementation SlikeInAppBrowserViewController
@synthesize titleInfo;
@synthesize webURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    _wkWebView = [[WKWebView alloc] initWithFrame:self.webContainer.frame configuration:configuration];
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    
    // Do any additional setup after loading the view.
    [self.btnClose setImage:[UIImage imageNamed:@"player_closebtn" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    [_wkWebView setBackgroundColor:[UIColor clearColor]];
    [_wkWebView setOpaque:NO];
    lblTitle.text =  @"Slike";
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL:self.webURL];
    [_wkWebView loadRequest:nsrequest];
    _wkWebView.UIDelegate = self;
    _wkWebView.navigationDelegate = self;
    if(self.titleInfo  && self.titleInfo!=nil)
    {
        lblTitle.text =  self.titleInfo;
    }
    
    [_webContainer addSubview:_wkWebView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    _wkWebView.frame = _webContainer.frame;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _wkWebView.frame = _webContainer.frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clbClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*****************************************************************/

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"%@", navigation);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    NSLog(@"%@", navigation);
}
- (void)dealloc {
    [_wkWebView stopLoading];
    _wkWebView.UIDelegate = nil;
    self.wkWebView = nil;
}
@end
