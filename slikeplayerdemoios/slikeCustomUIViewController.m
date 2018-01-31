//
//  slikeCustomUIViewController.m
//  TOI
//
//  Created by Aravind kumar on 1/11/18.
//  Copyright © 2018 Times Internet Limited. All rights reserved.
//

#import "slikeCustomUIViewController.h"
#import "SlikeConfig.h"
#import "SlikePlayer.h"
#import "SlikeDeviceSettings.h"
#define TOISlikePlayerImage(file)                 [UIImage imageNamed:file]
#define RGBA(r, g, b, a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define RGB(r, g, b)                            [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

@interface slikeCustomUIViewController ()

{
    id<ISlikePlayer> myPlayer;
    UIAlertController *actionSheet;

}
@end

@implementation slikeCustomUIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initilizeResources];
    // Do any additional setup after loading the view from its nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - ISlikePlayerControl implementation
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
    
}


-(void)viewWillEnterForeground
{
}
-(void)playBitrate
{
    [myPlayer play:NO];
   [self showProcessingView:YES];
//        NSArray * bitrateArray   = [myPlayer showBitrateChooser:YES];
//        [self loadBitrateCustomView:bitrateArray];
    
}
-(void)viewWillEnterBackground
{
}
-(void)showControllerFrombackground
{
    if(!self.slikeConfig.isDocEnable) self.view.hidden = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlls) object: nil];
    [self performSelector:@selector(hideControlls) withObject:nil afterDelay:1.5];
    
}
//-(void) showBitrateChooser:(BOOL) flag
//-(NSArray*) showBitrateChooser:(BOOL)flag
//{
//  return   [myPlayer showBitrateChooser:flag];
//
//}
-(NSInteger) getFlavourIndex:(NSString *) strCurrentURL forVideoType:(VideoSource) sourceType withCurrentArray:(NSArray*)arr
{
    if(!strCurrentURL) return -1;
    if([strCurrentURL isEqualToString:@""]) return -1;
    NSInteger nIndex, nLen = arr.count;
    if(nLen == 1) return 0;
    Stream *stream;
    for(nIndex = 0; nIndex < nLen; nIndex++)
    {
        stream = [arr objectAtIndex:nIndex];
        if([strCurrentURL isEqualToString:stream.strURL])
        {
            return nIndex;
        }
    }
    
    return -1;
}

-(void) setHostPlayer:(id<ISlikePlayer>) hostPlayer
{
    myPlayer = hostPlayer;
}
-(void) setPlayerData:(SlikeConfig *)config
{
    self.slikeConfig = config;
}
-(void) setAdsMarkers:(NSMutableArray *) arrMarkers
{
    //self.seekBar.arrMarkers = arrMarkers;
    //TODO::
}
-(void) setAdMarkerDone:(NSInteger) index
{
    //
}
-(void) updateFullScreen:(BOOL) isFullScreen
{
    _fullScreenBtn.selected = isFullScreen;
    if(actionSheet)
    {
        [actionSheet dismissViewControllerAnimated:NO completion:nil];
    }
}
-(void) showFullscreenButton:(BOOL) flag
{
    [myPlayer toggleFullScreen];
}
-(void)updateBtnImage
{
    
}
-(void) updateBufferPlaybackProgress
{
    
        float currentBufferPos = [myPlayer getLoadTimeRange];
        float dur = [myPlayer getDuration];
        if(dur > 0)
        {
            NSLog(@"%f",currentBufferPos/dur);
            self.progressView.progress = currentBufferPos/dur;
        }else
        {
            self.progressView.progress = 0.0;
        }
    
}

-(void)updatePlaybackProgress
{
    NSLog(@"-----> %@",self.view);
   
    if([myPlayer isPlaying])
    {
        [self showProcessingView:NO];
    }
    [myPlayer setVideoPlaceHolder:NO];
    float currentPos = [myPlayer getPosition];
    float duration = [myPlayer getDuration];
  if(!self.slikeConfig.streamingInfo.isLive)
  {
      NSInteger currentTime = (NSInteger) roundf(currentPos/1000);
      NSInteger totalTime = (NSInteger) roundf(duration/1000);
  [self slikePlayerCurrentTime:currentTime totalTime:totalTime];
  }

}

- (void)slikePlayerCurrentTime:(NSInteger)aCurrentTime totalTime:(NSInteger)aTotalTime {
    if (aTotalTime == 0) {
        return;
    }
    NSInteger proMin = aCurrentTime / 60;
    NSInteger proSec = aCurrentTime % 60;
    NSInteger durMin = aTotalTime / 60;
    NSInteger durSec = aTotalTime % 60;
    if (!self.isDragged) {
        float sliderValue = (float)aCurrentTime/(float)aTotalTime;
        self.videoSlider.value           = sliderValue;
        //self.bottomProgressView.progress = sliderValue;
        self.currentTimeLabel.text       = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    }
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
}

-(void)showLiveStreams
{
}

-(void) playbackTimeUpdate
{
}


-(void) updateButtons:(SlikePlayerState) state
{
    NSLog(@"playerstaus %ld",(long)state);

    if(state == START) {
        
        [myPlayer setVideoPlaceHolder:NO];

        
        
    }
    if(state == LOADED) {
        NSLog(@"isAdPlaying LOADED");
    }
    
    status = state;
    if(status == LOADED)
    {
        [self showHideLiveButton:NO];
    }
}
-(void)updateButtonsAccordingPlayerStatus
{
    
}
-(void)updateDMReplay
{
    [self updateReplayButtons:YES];
}
-(void)updateButtonsAccordingPlayerInformation
{
    
}
-(id<ISlikePlayer>) getHostPlayer
{
    return myPlayer;
}
-(void) show
{
    
}
-(void) hide
{
    
}
-(BOOL) isVisible
{
    return !self.view.hidden;
}

-(BOOL) isUserPausedVideo
{
    return NO;
}


-(void) updateReplayButtons:(BOOL) isReplay
{
    
}
-(void) showHideControls:(BOOL) show animated:(BOOL) animated
{
    
}
-(void) showHideLiveButton:(BOOL) show
{
    
}
-(void) showHUD:(BOOL) show
{
}
-(UINavigationController *) getNavigationController
{
    if(!self.parentViewController) return nil;
    if([self.parentViewController isKindOfClass:[UINavigationController class]]) return self.navigationController;
    return nil;
}

-(void) updateBitrateButton
{
    
}


-(void) toggleControls
{
    
}
-(void)hideControlls
{
    
}

- (IBAction)clbFullScreen:(id)sender
{
    
    [myPlayer toggleFullScreen];
}


-(void) doStyling
{
    
}


-(void) showHideViewWithAnimation:(UIView *) myView isShow:(BOOL) show animated:(BOOL) animated
{
    if(!animated)
    {
        if(!show)
        {
            if(!myView.hidden)
            {
                myView.hidden = YES;
            }
        }
        else
        {
            if(myView.hidden)
            {
                myView.hidden = NO;
            }
        }
        return;
    }
    if(!show)
    {
        if(!myView.hidden)
        {
            [UIView animateWithDuration:0.4
                             animations:^{myView.alpha = 1.0;}
                             completion:^(BOOL finished){ myView.hidden = YES; }];
        }
    }
    else
    {
        if(myView.hidden)
        {
            myView.hidden = NO;
            myView.alpha = 1.0;
            [UIView animateWithDuration:0.4
                             animations:^{myView.alpha = 1.0;}
                             completion:^(BOOL finished){}];
        }
    }
}
-(void) showProcessingHUD:(BOOL) show
{
    [self showProcessingView:show];
    
}
///////////////////////////////
//Processing view
-(void)showProcessingView:(BOOL)isShow
{
    
}

#pragma mark - GCKDeviceScannerListener
- (IBAction)clbCast:(id)sender {
    
    //   // open this code
    //    self.viewControls.hidden = YES;
    //    [myPlayer pause:NO];
    //
    //   // [myCast showCastList];
    
}
-(void)endPlayerView
{
    [[SlikePlayer getInstance] stopPlayer];
    [self.view removeFromSuperview];
}

-(void)updateDocBtn:(BOOL)isShow
{
}

- (void)orientationChanged:(NSNotification *)notification{
    if(SK_IS_IPHONE_X)
    {
        [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    }
}
- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            //load the portrait view
         
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
}
-(void)updateMyCastView:(NSString*)deviceName
{
    
}

-(void) updatreCastPlay:(BOOL)isPlaying
{
}
-(BOOL) isCastPlaying
{
    return NO;
}

-(void) updateCastIcon:(BOOL)isShow
{
}


#pragma mark TOi Custom Event
- (void)initilizeResources
{

    [self.startBtn setImage:TOISlikePlayerImage(@"ZFPlayer_play") forState:UIControlStateNormal];
    [self.startBtn setImage:TOISlikePlayerImage(@"ZFPlayer_pause") forState:UIControlStateSelected];
    [self.startBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.repeatBtn setImage:TOISlikePlayerImage(@"ZFPlayer_repeat_video") forState:UIControlStateNormal];
    [self. repeatBtn addTarget:self action:@selector(repeatBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.repeatBtn.hidden = YES;
    
    self.topImageView.userInteractionEnabled = YES;
    self.topImageView.image                  = TOISlikePlayerImage(@"ZFPlayer_top_shadow");
    
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:15.0];
    self.titleLabel.numberOfLines = 3;
    self.titleLabel.text =  self.slikeConfig.title;
    
    [self.resolutionBtn setImage:TOISlikePlayerImage(@"ZFPlayer_resolution") forState:UIControlStateNormal];
    [self.resolutionBtn addTarget:self action:@selector(resolutionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    if(self.slikeConfig.streamingInfo.isLive)
    {
        self.resolutionBtn.alpha = 0.5;
        self.resolutionBtn.userInteractionEnabled =  NO;
    }else
    {
        self.resolutionBtn.alpha = 1.0;
        self.resolutionBtn.userInteractionEnabled =  YES;
    }
    [self.shareBtn setImage:TOISlikePlayerImage(@"ZFPlayer_share") forState:UIControlStateNormal];
    [self.shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.closeBtn setImage:TOISlikePlayerImage(@"ZFPlayer_close") forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    self.progressView.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.progressView.trackTintColor    = [UIColor clearColor];
    
    
    _videoSlider.popUpViewCornerRadius = 0.0;
    _videoSlider.popUpViewColor = RGBA(19, 19, 9, 1);
    _videoSlider.popUpViewArrowLength = 8;
    
    [_videoSlider setThumbImage:TOISlikePlayerImage(@"ZFPlayer_slider") forState:UIControlStateNormal];
    _videoSlider.maximumValue          = 1;
    _videoSlider.minimumTrackTintColor = RGB(204, 52, 51);
    _videoSlider.maximumTrackTintColor = RGBA(208, 208, 208, 0.4);
    
    [_videoSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [_videoSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [_videoSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    self.videoSlider.value            = 0.0;

    UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
    [_videoSlider addGestureRecognizer:sliderTap];
    
    [_fullScreenBtn setImage:TOISlikePlayerImage(@"ZFPlayer_fullscreen") forState:UIControlStateNormal];
    [_fullScreenBtn setImage:TOISlikePlayerImage(@"ZFPlayer_shrinkscreen") forState:UIControlStateSelected];
    [_fullScreenBtn addTarget:self action:@selector(fullScreenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognizer:)];
    panRecognizer.delegate = self;
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setDelaysTouchesBegan:YES];
    [panRecognizer setDelaysTouchesEnded:YES];
    [panRecognizer setCancelsTouchesInView:YES];
    [_videoSlider addGestureRecognizer:panRecognizer];


    _currentTimeLabel.textColor     = [UIColor whiteColor];
    _currentTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
    _currentTimeLabel.textAlignment = NSTextAlignmentCenter;

    _totalTimeLabel.textColor     = [UIColor whiteColor];
    _totalTimeLabel.font          = [UIFont systemFontOfSize:12.0f];
    _totalTimeLabel.textAlignment = NSTextAlignmentCenter;


    self.currentTimeLabel.text       = @"00:00";
    self.totalTimeLabel.text         = @"00:00";
    
}
- (void)tapSliderAction:(UITapGestureRecognizer *)tap {
}
- (void)panRecognizer:(UIPanGestureRecognizer *)sender {
    
}
- (void)progressSliderTouchBegan:(ASValueTrackingSlider *)sender {
   
}

- (void)progressSliderValueChanged:(ASValueTrackingSlider *)sender {
  
}

- (void)progressSliderTouchEnded:(ASValueTrackingSlider *)sender {
}


- (void)toiSlikeCustomView:(UIView *)aControlView progressSliderTap:(CGFloat)value {
    // to do hitesh
    /*
     CGFloat total = (CGFloat)self.playerItem.duration.value / self.playerItem.duration.timescale;
     NSInteger dragedSeconds = floorf(total * value);
     [self.controlView zf_playerPlayBtnState:YES];
     [self seekToTime:dragedSeconds completionHandler:^(BOOL finished) {}];
     */
}

- (void)toiSlikeCustomView:(UIView *)aControlView progressSliderValueChanged:(UISlider *)slider {
    // to do hitesh
    /*
     if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
     self.isDragged = YES;
     BOOL style = false;
     CGFloat value   = slider.value - self.sliderLastValue;
     if (value > 0) { style = YES; }
     if (value < 0) { style = NO; }
     if (value == 0) { return; }
     
     self.sliderLastValue  = slider.value;
     
     CGFloat totalTime     = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
     
     CGFloat dragedSeconds = floorf(totalTime * slider.value);
     
     CMTime dragedCMTime   = CMTimeMake(dragedSeconds, 1);
     
     [_toiSlikeCustomControllView zf_playerDraggedTime:dragedSeconds totalTime:totalTime isForward:style hasPreview:self.isFullScreen ? self.hasPreviewView : NO];
     
     if (totalTime > 0) {
     if (self.isFullScreen && self.hasPreviewView) {
     [self.imageGenerator cancelAllCGImageGeneration];
     self.imageGenerator.appliesPreferredTrackTransform = YES;
     self.imageGenerator.maximumSize = CGSizeMake(100, 56);
     AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
     if (result != AVAssetImageGeneratorSucceeded) {
     dispatch_async(dispatch_get_main_queue(), ^{
     [self.toiSlikeCustomControllView zf_playerDraggedTime:dragedSeconds sliderImage:self.thumbImg ? : TOISlikePlayerImage(@"ZFPlayer_loading_bgView")];
     });
     }
     else {
     self.thumbImg = [UIImage imageWithCGImage:im];
     dispatch_async(dispatch_get_main_queue(), ^{
     [self.toiSlikeCustomControllView zf_playerDraggedTime:dragedSeconds sliderImage:self.thumbImg ? : TOISlikePlayerImage(@"ZFPlayer_loading_bgView")];
     });
     }
     };
     [self.imageGenerator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:dragedCMTime]] completionHandler:handler];
     }
     }
     else {
     slider.value = 0;
     }
     }
     else {
     slider.value = 0;
     }
     */
}

- (void)toiSlikeCustomView:(UIView *)aControlView progressSliderTouchEnded:(UISlider *)slider
{
    // to do hitesh
    /*
     if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
     self.isPauseByUser = NO;
     self.isDragged = NO;
     CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
     NSInteger dragedSeconds = floorf(total * slider.value);
     [self seekToTime:dragedSeconds completionHandler:nil];
     }
     */
}


- (void)playBtnClick:(id)sender {
    if([myPlayer isPlaying])
    {
        [myPlayer pause:YES];
        self.startBtn.selected =  YES;
    }else
    {
        [myPlayer play:YES];
        self.startBtn.selected =  NO;
        
    }
}
- (void)resolutionBtnClick:(UIButton *)sender
{
    [myPlayer showBitrateChooser:NO];
}

- (void)repeatBtnClick:(UIButton *)sender
{
    [myPlayer replay];
}
- (void)fullScreenBtnClick:(UIButton *)sender {
    
    [myPlayer toggleFullScreen];
}
- (void)closeBtnClick:(UIButton *)sender
{
    [[SlikePlayer getInstance] stopPlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)shareBtnClick:(UIButton *)sender {
}
-(void) loadBitrateCustomView:(NSArray*)array
{
    SlikeDLog(@"Bitrateview is loading...");
    
    if(![self.slikeConfig.streamingInfo hasBitratesAvailable])
    {
        SlikeDLog(@"Bitrates not available to show...");
        return;
    }
    NSInteger nCurrentPlayingIndex = 0;
    NSString * currentEvtURI =  [myPlayer currentBitRateURI];
    if(currentEvtURI && [currentEvtURI length] > 0)
    {
        nCurrentPlayingIndex = [self  getFlavourIndex:currentEvtURI forVideoType:[self.slikeConfig.streamingInfo getStreamType] withCurrentArray:array];
    }
    [myPlayer pause:NO];
    NSString *str = [[SlikeDeviceSettings sharedSettings] strSavedBitrate];
    NSString *strMsg = @"Video quality is Auto.";
    
    NSArray *arr = array;
    NSInteger nIndex, nLen = arr.count;
    BOOL isNone = [str isEqualToString:@"none"];
    strMsg = [NSString stringWithFormat:@"Currently chosen quality is %@.", [self.slikeConfig.streamingInfo getCurrentStream].strLabel];
    BOOL isIPad = ![SlikeDeviceSettings sharedSettings].isIPhoneDevice;
    
    NSMutableAttributedString *strTitle = [[NSMutableAttributedString alloc] initWithString:@"Select Quality"];
    [strTitle addAttribute:NSFontAttributeName
                     value:[UIFont systemFontOfSize:18.0]
                     range:NSMakeRange(0, 14)];
    [strTitle addAttribute:NSForegroundColorAttributeName
                     value:RGBA(24, 45, 45, 1.0)
                     range:NSMakeRange(0, 14)];
    actionSheet = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet setValue:strTitle forKey:@"attributedMessage"];
    
    UIViewController *cntrlr = self;
    if(self.presentedViewController) cntrlr = self.presentedViewController;
    BOOL hasAuto = [self.slikeConfig.streamingInfo getStreamType] == VIDEO_SOURCE_HLS;
    
    if(hasAuto)
    {
        [actionSheet addAction:[UIAlertAction actionWithTitle:isNone ? @"✓ Auto" : @"Auto" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if(myPlayer)
            {
                [myPlayer updateCustomBitrate:nil];
                
            }
        }]];
    } else isNone = NO;
    
    Stream *stream;
    for(nIndex = hasAuto ? 1 : 0; nIndex < nLen; nIndex++)
    {
        stream = [arr objectAtIndex:nIndex];
        str = [NSString stringWithFormat:@"%@%@", !isNone && nCurrentPlayingIndex == nIndex ? @"✓ " : @"", stream.strLabel];
        [actionSheet addAction:[UIAlertAction actionWithTitle:str style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            if(myPlayer)
            {
                [myPlayer updateCustomBitrate:stream];
                
            }
        }]];
        [actionSheet setValue:strTitle forKey:@"attributedMessage"];
        
    }
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [myPlayer play:NO];
    }]];
    
    UIView *firstView = actionSheet.view.subviews.firstObject;
    if(firstView)
    {
        UIView *nextView = firstView.subviews.firstObject;
        if(nextView)
        {
            nextView.backgroundColor = [UIColor whiteColor];
            nextView.layer.cornerRadius = 10.0f;
        }
    }
    
    if(isIPad)
    {
        [actionSheet setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [actionSheet popoverPresentationController];
        popPresenter.sourceView = self.resolutionBtn;
        popPresenter.sourceRect = self.resolutionBtn.bounds;
        [self presentViewController:actionSheet animated:YES completion:nil];
    }
    else
    {
        // Present action sheet.
        [cntrlr presentViewController:actionSheet animated:YES completion:nil];
        
        SlikePlayer *manager = [SlikePlayer getInstance];
        if(manager.playerStyleBitrateBackground) actionSheet.view.backgroundColor = manager.playerStyleBitrateBackground;
        if(manager.playerStyleBitrateContentColor) actionSheet.view.tintColor = manager.playerStyleBitrateContentColor;
    }
    
}

@end
