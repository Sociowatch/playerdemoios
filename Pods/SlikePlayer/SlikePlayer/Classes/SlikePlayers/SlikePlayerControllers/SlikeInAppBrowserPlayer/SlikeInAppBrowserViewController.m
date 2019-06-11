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

@end

@implementation SlikeInAppBrowserViewController
@synthesize titleInfo;
@synthesize webURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnClose setImage:[UIImage imageNamed:@"player_closebtn" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    [webViewInfo setBackgroundColor:[UIColor clearColor]];
    [webViewInfo setOpaque:NO];
    lblTitle.text =  @"Slike";
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:self.webURL];
    [webViewInfo loadRequest:nsrequest];
    if(self.titleInfo  && self.titleInfo!=nil)
    {
        lblTitle.text =  self.titleInfo;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clbClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
/*****************************************************************/
//Web view Delegate---------------------------------------------
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error
{
    
}

@end
