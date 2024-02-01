//
//  SlikeMediaPlayerControl.m
//  Pods
//
//  Created by Aravind kumar on 6/6/18.
//

#import <MediaPlayer/MediaPlayer.h>
#import "SlikeMediaPlayerControl.h"
#import "NSBundle+Slike.h"
#import "EventManager.h"
#import "EventManagerProtocol.h"
#import "NSDictionary+Validation.h"
#import "SlikeTapGestureRecognizer.h"
#import "SlikePlayerConstants.h"
#import "CPSlider.h"
#import "SlikeMaterialDesignSpinner.h"
#import "SlikeSharedDataCache.h"
#import "SlikePreviewDraggingProgressView.h"
#import "UIView+SlikeAlertViewAnimation.h"
#import "StreamingInfo.h"
#import "SlikeUtilities.h"
#import "SlikeNetworkMonitor.h"
#import "SlikeCoachmarkView.h"


#define SLIKERGBA(r, g, b, a)  [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define SLIKERGB(r, g, b)      [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

#define SlikePlayerButtonNormal(file,imageBundle) [UIImage imageNamed:file inBundle:imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateNormal

#define SlikePlayerButtonSelected(file,imageBundle)  [UIImage imageNamed:file inBundle:imageBundle compatibleWithTraitCollection:nil] forState:UIControlStateSelected

#define SlikePlayerImage(file,imageBundle)  [UIImage imageNamed:file inBundle:imageBundle compatibleWithTraitCollection:nil]

// ** Customize these values **
static NSTimeInterval const kViewControllerControlsVisibleDuration = 5.0;
static NSTimeInterval const kViewControllerFadeControlsInAnimationDuration = 0.1;
static NSTimeInterval const kViewControllerFadeControlsOutAnimationDuration = 0.2;
static NSInteger const kiPhoneXContraintFxEnter = 75.0;
static NSInteger const kiPhoneXContraintFxExit = -5.0;
static NSInteger const kiPhoneXContraintBottomFxEnter = 15.0;
static NSInteger const kiPhoneXContraintBottomFxExit = -5.0;
static NSInteger const kDraggingViewWidth = 160;
static NSInteger const kDraggingViewHeight = 90;
static NSInteger kDraggingViewBottomOffset = 5;

@interface SlikeMediaPlayerControl()<CPSliderDelegate, EventManagerProtocol, SlikeCoachmarkViewDelegate> {
}
@property (weak, nonatomic) IBOutlet UILabel *dvrCurrentTime;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthCurrentTimeConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthDurationConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seekBarBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomBufferingConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingDuraionFullScreen;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblTitleXPoint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *gotoLiveTrailingOutlet;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewLeadinConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewTraillingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewLeadinConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnCloseConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnFullScreenWidthConstrain;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *birateWidthConstraints;

@property (weak, nonatomic) IBOutlet UIView *viewControls;
@property (weak, nonatomic) IBOutlet UIView *viewTopControls;
@property (weak, nonatomic) IBOutlet UIImageView *shadowTopImage;
@property (weak, nonatomic) IBOutlet UIButton *btnBitrate;
@property (weak, nonatomic) IBOutlet UIButton *btnActivityShare;
@property (weak, nonatomic) IBOutlet UIButton *btnCast;
@property (weak, nonatomic) IBOutlet UIView *viewAirPlayContainer;
@property (weak, nonatomic) IBOutlet UILabel *lblNowPlaying;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic)  IBOutlet UIButton *btnDoc;

@property (weak, nonatomic) IBOutlet UIView *viewBottomControls;
@property (weak, nonatomic) IBOutlet UIImageView *shadowBottomImage;
@property (weak, nonatomic) IBOutlet UIButton *btnBackToLive;
@property (weak, nonatomic) IBOutlet UILabel *lblCurrentTime;
@property (weak, nonatomic) IBOutlet UILabel *lblDuration;
@property (weak, nonatomic) IBOutlet CPSlider *seekBar;
@property (weak, nonatomic) IBOutlet UIButton *btnFullScreen;
@property (weak, nonatomic) IBOutlet UIProgressView *progressBuffering;
@property (weak, nonatomic) IBOutlet UIView *viewCenterControls;
@property (weak, nonatomic) IBOutlet UIButton *btnPlayPause;
@property (weak, nonatomic) IBOutlet UIButton *btnReplay;
@property (weak, nonatomic) IBOutlet UIButton *btnPrevious;
@property (weak, nonatomic) IBOutlet SlikeMaterialDesignSpinner *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

@property (assign, nonatomic) BOOL isControllHidden;
@property (assign, nonatomic) BOOL videoCompleted;
@property (assign, nonatomic) BOOL isVideoPaused;
@property (assign, nonatomic) BOOL isSharePause;
@property (assign, nonatomic) BOOL isSlideing;
@property (assign, nonatomic) BOOL isLiveStream;
@property (assign, nonatomic) BOOL isBitrateChange;

@property (assign, nonatomic) NSInteger draggingYposition;
@property (strong, nonatomic) NSDictionary* payload;
@property (strong, nonatomic) MPVolumeView *mpVolume;
@property (strong, nonatomic) NSTimer *controlTimer;
@property (weak,   nonatomic) SlikeConfig * mediaConfig;
@property (assign, nonatomic) SlikePlayerState playerCurrentState;
@property (assign, nonatomic) SlikeEventType playerEventType;
@property (weak,   nonatomic) id<ISlikePlayer> slikePlayer;
@property (strong, nonatomic) SlikeTapGestureRecognizer *tapGesture;
@property (strong, nonatomic) SlikePreviewDraggingProgressView* draggingProgressView;
@property (strong, nonatomic) UIActivityViewController *shareController;

@property (assign, nonatomic) NSInteger thumnailOffset;
@property (assign, nonatomic) NSInteger draggingLeftPadding;
@property (assign, nonatomic) NSInteger draggingRightPadding;
@property (assign, nonatomic) BOOL isUserSliding;

@property (weak, nonatomic) IBOutlet UIView *playlistNextItemView;
@property (weak, nonatomic) IBOutlet UIImageView *nextItemImageView;
@property (weak, nonatomic) IBOutlet UIProgressView *nextItemProgress;
@property (weak, nonatomic) IBOutlet UILabel *nextItemTitle;
@property (weak, nonatomic) IBOutlet UIButton *nextCardButton;
@property (assign, nonatomic) BOOL isNextCardVissible;
@property (assign, nonatomic) NSInteger cardFecthTime;
@property (assign, nonatomic) BOOL coachMarkVissible;
@property (strong, nonatomic) MPVolumeView *airPlayView;

@property (nonatomic, weak) IBOutlet UIButton *liveButton;
@property (nonatomic, readonly) CMTime time;

@end

@implementation SlikeMediaPlayerControl

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    self.btnCast.hidden =  YES;
    return self;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    _dvrCurrentTime.hidden = YES;
    _liveButton.alpha = 0;
    _draggingLeftPadding = 20;
    _draggingRightPadding = 10;
    _cardFecthTime = 5;
    _thumnailOffset = kDraggingViewWidth/2 + _draggingLeftPadding;
    
    [self setupUIComponents];
    [self initialiseResources];
    [self addTargetSlider];
    [self registerEventManager];
    [self updateFullScreen:NO];
    [self setupPreviewDraggingProgressView];
    
    [self _headerFooterControlsAppearance:NO];
    [self slikeLoadingViewAppearance:YES];
    _playlistNextItemView.alpha = 0;
    _isNextCardVissible = NO;
    _nextCardButton.userInteractionEnabled = YES;
    self.alpha =1.0;
    _coachMarkVissible = NO;
    
}

//Add Airplay options if the aiplay devices is available
- (void)checkForAirPlayOptions {
    
    if (self.airPlayView && [_airPlayView superview]) {
        [_airPlayView removeFromSuperview];
        self.airPlayView = nil;
    }
    self.airPlayView = [[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    _airPlayView.showsVolumeSlider = NO;
    [_viewAirPlayContainer addSubview:_airPlayView];
    _viewAirPlayContainer.hidden = NO;
    _airPlayView.contentMode = UIViewContentModeScaleAspectFill;
    _viewAirPlayContainer.backgroundColor = [UIColor clearColor];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.viewBottomControls]) {
        return NO;
    }
    return YES;
}
- (void)hideAirPlayMode {
    if (self.airPlayView && [_airPlayView superview]) {
        [_airPlayView removeFromSuperview];
        self.airPlayView = nil;
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self setInitialPosition];
}

- (void)setupPreviewDraggingProgressView {
    _draggingProgressView = [SlikePreviewDraggingProgressView slikePreviewDraggingProgressView];
    [self addSubview:self.draggingProgressView];
    _draggingProgressView.frame = CGRectMake(0,0,kDraggingViewWidth,kDraggingViewHeight);
    _draggingProgressView.autoresizingMask = UIViewAutoresizingNone;
    _draggingProgressView.alpha=0;
    [self setInitialPosition];
}

- (void)setInitialPosition {
    CGRect theFrame = [_seekBar convertRect:_seekBar.frame toView:self];
    NSInteger verticalPos = CGRectGetMinY(theFrame) - (kDraggingViewBottomOffset+kDraggingViewHeight);
    _draggingProgressView.center = CGPointMake(_thumnailOffset, verticalPos);
    _activityIndicatorView.center = self.center;
    [_draggingProgressView setNeedsLayout];
}

-(BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}

- (void)setupUIComponents {
    NSBundle *imageBundle = [NSBundle slikeImagesBundle];
    
    if(!self.mediaConfig.streamingInfo.isLive) {
        [self.btnPlayPause setImage:SlikePlayerButtonSelected(@"player_pause",imageBundle)];
    }
    else {
        [self.btnPlayPause setImage:SlikePlayerButtonSelected(@"player_stop",imageBundle)];
    }
    
    [self.btnDoc setImage:SlikePlayerButtonNormal(@"Float",imageBundle)];
    [self.btnClose setImage:SlikePlayerButtonNormal(@"player_closebtn",imageBundle)];
    [self.btnCast setImage:SlikePlayerButtonNormal(@"cast_off",imageBundle)];
    [self.btnActivityShare setImage:SlikePlayerButtonNormal(@"player_share",imageBundle)];
    [self.btnBitrate setImage:SlikePlayerButtonNormal(@"bitrate_icon",imageBundle)];
    [self.btnFullScreen setImage:SlikePlayerButtonNormal(@"full-screen",imageBundle)];
    [self.btnFullScreen setImage:SlikePlayerButtonSelected(@"exit-full-screen",imageBundle)];
    [self.btnPlayPause setImage:SlikePlayerButtonNormal(@"player_play",imageBundle)];
    [self.btnNext setImage:SlikePlayerButtonNormal(@"player_fw",imageBundle)];
    [self.btnPrevious setImage:SlikePlayerButtonNormal(@"player_rv",imageBundle)];
    [self.btnReplay setImage:SlikePlayerButtonNormal(@"player_replay",imageBundle)];
    [self.shadowTopImage setImage:SlikePlayerImage(@"Shadow_top", imageBundle)];
    [self.shadowBottomImage setImage:SlikePlayerImage(@"Shadow_bottom", imageBundle)];
    [self.btnBackToLive setImage:[self _imageWithImage:SlikePlayerImage(@"player_nob", imageBundle) convertToSize:CGSizeMake(10, 10)] forState:UIControlStateNormal];
    self.seekBar.maximumValue          = 1;
    self.seekBar.minimumTrackTintColor = SLIKERGB(204, 52, 51);
    self.seekBar.maximumTrackTintColor = SLIKERGBA(208, 208, 208, 0.4);
    self.progressBuffering.progressTintColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
    self.progressBuffering.trackTintColor    = [UIColor clearColor];
    [self doSliderStyling];
    
    UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_tapSliderAction:)];
    [_seekBar addGestureRecognizer:sliderTap];
}

- (void)_tapSliderAction:(UITapGestureRecognizer *)tap {
    /* if ([tap.view isKindOfClass:[UISlider class]]) {
     UISlider *slider = (UISlider *)tap.view;
     CGPoint point = [tap locationInView:slider];
     CGFloat length = slider.frame.size.width;
     CGFloat tapValue = point.x / length;
     [self _progressSliderTap:tapValue];
     }*/
}

- (void)_progressSliderTap:(CGFloat)value {
    NSDictionary *seekedData = @{kSlikeSeekProgressKey:@(value)};
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_SEEKED dataPayload:seekedData slikePlayer:nil];
}

- (UIImage *)_imageWithImage:(UIImage *)image convertToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

- (void)initialiseResources {
    
    _videoCompleted = NO;
    self.btnClose.hidden                    =  YES;
    self.btnReplay.hidden                   =  YES;
    self.btnPrevious.hidden                 =  YES;
    self.btnNext.hidden                     =  YES;
    self.btnDoc.hidden                      =  YES;
    self.btnBackToLive.hidden               =  YES;
    self.btnBackToLive.hidden               =  YES;
    self.btnCast.hidden                     =  YES;
    self.lblCurrentTime.text                =  @"00:00";
    self.lblDuration.text                   =  @"00:00";
    self.activityIndicatorView.hidden       =  YES;
    self.lblCurrentTime.textColor =  [UIColor whiteColor];
    self.lblDuration.textColor =  [UIColor whiteColor];
    
    self.lblCurrentTime.font =  [UIFont fontWithName:@"HelveticaNeue" size: 14];
    self.lblDuration.font =  [UIFont fontWithName:@"HelveticaNeue" size: 14];
    self.lblNowPlaying.minimumScaleFactor = 0.5;
    self.lblNowPlaying.font =[UIFont fontWithName:@"HelveticaNeue" size: 14];
    self.progressBuffering.progress =  0.0;
    self.btnBackToLive.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size: 14];
    [self.btnBackToLive setTitle:[SlikePlayerSettings playerSettingsInstance].slikestrings.liveButtonTitle forState:UIControlStateNormal];
    self.btnBackToLive.userInteractionEnabled = NO;
    
    _tapGesture = [[SlikeTapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnControlsView:)];
    _tapGesture.numberOfTapsRequired = 1;
    _tapGesture.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:_tapGesture];
    [self _invalidateTimerAndHideControls];
    
    if([[SlikeDeviceSettings sharedSettings] isPhoneX]) {
        self.topViewLeadinConstraint.constant =  kiPhoneXContraintFxExit;
        self.topViewTraillingConstraint.constant = kiPhoneXContraintFxExit;
        self.bottomViewLeadinConstraint.constant =  kiPhoneXContraintFxExit;
        self.bottomViewTrailingConstraint.constant = kiPhoneXContraintFxExit;
        self.bottomViewBottomConstraint.constant = kiPhoneXContraintBottomFxExit;
        
        _draggingLeftPadding = kiPhoneXContraintFxExit+20;
        _draggingRightPadding = kiPhoneXContraintFxExit;
    }
}

- (void)doSliderStyling {
    UIImage *img = SlikePlayerImage(@"player_nob", [NSBundle slikeImagesBundle]);
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class]]]
     setThumbImage:img forState:UIControlStateNormal];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class]]]
     setThumbImage:img forState:UIControlStateHighlighted];
    [[UISlider appearanceWhenContainedInInstancesOfClasses:@[[self class]]]
     setThumbImage:img forState:UIControlStateSelected];
}

/**
 Update the controlls
 @param isLive - Is media Stream Live
 */
- (void)updateLiveMediaControl:(BOOL)isLive {
    self.isLiveStream = isLive;
    NSBundle *imageBundle = [NSBundle slikeImagesBundle];
    
    if(!isLive) {
        [self.btnPlayPause setImage:SlikePlayerButtonSelected(@"player_pause", imageBundle)];
        self.btnBackToLive.hidden = YES;
        self.seekBar.hidden = NO;
        self.lblCurrentTime.hidden =  NO;
        self.lblDuration.hidden =  NO;
        self.progressBuffering.hidden = NO;
        
    } else {
        
        [self.btnPlayPause setImage:SlikePlayerButtonSelected(@"player_stop", imageBundle)];
        self.btnBackToLive.hidden = NO;
        self.seekBar.hidden = YES;
        self.lblCurrentTime.hidden =  YES;
        self.lblDuration.hidden =  YES;
        self.lblCurrentTime.hidden =  YES;
        self.lblDuration.hidden =  YES;
        self.progressBuffering.hidden = YES;
        
        _liveButton.alpha = 0;
        if ([self isMediaTypeDVR]) {
            [self setControlsForDVR];
        }
        if(self.mediaConfig.streamingInfo.currentStream.hasDVR) {
            _liveButton.alpha = 1;
            [self updateDVRButtonTitle];
        }
    }
}

- (void)setControlsForDVR {
    self.btnBackToLive.hidden = YES;
    self.seekBar.hidden = NO;
    self.lblCurrentTime.hidden =  NO;
    self.lblDuration.hidden =  NO;
    self.progressBuffering.hidden = NO;
}

/**
 Update the controlles state with the config media
 */
- (void)updateSlikeMediaData {
    if (self.mediaConfig) {
        
        [self updateLiveMediaControl:self.mediaConfig.streamingInfo.isLive];
        [self updatePlayerConfigControl];
        
        if (self.mediaConfig.autorotationMode == SlikeFullscreenAutorotationModeDefault) {
            _btnFullScreen.hidden = YES;
        }
    }
}

- (void)updatePlayerConfigControl {
    
    if(!self.mediaConfig.isCloseControl) {
        self.btnCloseConstraint.constant = 10.0;
        self.lblTitleXPoint.constant =  -25.0;
    }else
    {
        self.btnCloseConstraint.constant = 50.0;
        self.lblTitleXPoint.constant =  10.0;
    }
    
    if (self.mediaConfig) {
        self.btnClose.hidden = !self.mediaConfig.isCloseControl;
    }
    
    self.btnActivityShare.hidden =  !self.mediaConfig.isShareControl;
    
    if(!self.mediaConfig.isBitrateControl)
    {
        self.btnBitrate.hidden = YES;
        self.birateWidthConstraints.constant = 0;
        [self layoutIfNeeded];
    }
    
    if(!self.mediaConfig.isFullscreenControl && self.mediaConfig) {
        self.btnFullScreenWidthConstrain.constant = 0.0;
        self.btnFullScreen.hidden =  YES;
        self.gotoLiveTrailingOutlet.constant = 15;

    }else {
        self.gotoLiveTrailingOutlet.constant = 15 + self.btnFullScreenWidthConstrain.constant;
    }
    [self nextPreviousAppearance];
}

- (void)nextPreviousAppearance {
    _btnNext.hidden =  self.mediaConfig.isNextControl ?NO :YES;
    _btnPrevious.hidden =  self.mediaConfig.isPreviousControl ?NO :YES;
}

/**
 Register the class listen the events
 */
- (void)registerEventManager {
    [[EventManager sharedEventManager] registerEvent:self];
}

#pragma Event Listener
/**
 Method will be called by the Event menager
 
 @param playerEventType - Current event Type
 @param playerState - Current State
 @param payload - Payload if any
 @param player - Current Player
 */
- (void)update:(SlikeEventType)playerEventType playerState:(SlikePlayerState)playerState dataPayload:(NSDictionary *)payload slikePlayer:(id<ISlikePlayer>)player {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(player) {
            self.slikePlayer =  player;
        }
        
        SlikeConfig * configModel = payload[kSlikeConfigModelKey];
        if (configModel) {
            self.mediaConfig = configModel;
        }
        
        self.playerEventType = playerEventType;
        if (self.playerEventType == MEDIA || self.playerEventType == GESTURE) {
            
            SlikeDLog(@"CONTROLS STATE: %ld",(long)playerState);
            if ( playerState == SL_READY  || playerState == SL_LOADED || playerState == SL_START ||
                playerState == SL_PLAYING || playerState == SL_PAUSE  || playerState == SL_BUFFERING || playerState == SL_SEEKING || playerState == SL_SEEKED ||
                playerState == SL_COMPLETED || playerState == SL_REPLAY || playerState == SL_PLAY || playerState == SL_ENDED) {
                self.playerCurrentState = playerState;
            }
            
            if(playerState == SL_LOADED ) {
                
                [self updateSlikeMediaData];
                [self _headerFooterControlsAppearance:NO];
                [self slikeLoadingViewAppearance:NO];
                [self _updatePlayerStateFromData:playerState payload:payload];
                
                if ([self.slikePlayer isFullScreen]) {
                    [self updateFullScreen:YES];
                    self.btnFullScreen.selected = YES;
                }
                
                [self hideControlsIfAutoPlayDesibale:YES];
            }
            else  if(playerState ==  SL_START) {
                
                if (self.mediaConfig.enableAirPlay) {
                    [self checkForAirPlayOptions];
                } else {
                    [self hideAirPlayMode];
                }
                
                self.nextCardButton.userInteractionEnabled = YES;
                [self hideControlsIfAutoPlayDesibale:NO];
                NSArray *bitratesArray = [[SlikeSharedDataCache sharedCacheManager] cachedBitratesModels];
                
                if ([bitratesArray count] == 2 && self.mediaConfig.isBitrateControl) {
                    self.btnBitrate.hidden = YES;
                    self.birateWidthConstraints.constant = 0;
                    [self layoutIfNeeded];
                }
                
                [self singleTapOnControlsView:nil];
                [self _reestablishTimer];
                
                self.videoCompleted = NO;
                [self updateSlikeMediaData];
                
                self.lblNowPlaying.text = [SlikeUtilities getVideoTitle:self.mediaConfig];
                [self slikeLoadingViewAppearance:NO];
                [self _updateMediaControlsAppearance:NO];
                [self _invalidateTimerAndHideControls];
                
            }
            else if(playerState == SL_PLAY) {
                self.videoCompleted = NO;
                [self _updatePlayerStateFromData:playerState payload:payload];
            }
            else if(playerState == SL_PAUSE) {
                [self _updatePlayerStateFromData:playerState payload:payload];
            }
            else if(playerState == SL_PLAYING && !self.isLiveStream) {
                [self _updatePlayerStateFromData:playerState payload:payload];
                // [self slikeLoadingViewAppearance:NO];
            }
            else if(playerState == SL_PLAYING && [self isMediaTypeDVR]) {
                [self _updatePlayerStateFromData:playerState payload:payload];
            }
            else if(playerState == SL_QUALITYCHANGE) {
                self->_isBitrateChange =  YES;
                [self _updatePlayerStateFromData:playerState payload:payload];
                [self slikeLoadingViewAppearance:YES];
            }
            else if(playerState == SL_SEEKPOSTIONUPDATE && !self.isLiveStream) {
                [self _updatePlayerStateFromData:playerState payload:payload];
            }
            else if(playerState == SL_SEEKPOSTIONUPDATE && [self isMediaTypeDVR]) {
                [self _updatePlayerStateFromData:playerState payload:payload];
            }
            else if(playerState == SL_BUFFERING) {
                
                if ([payload boolForKey:kSlikeBufferingEndedKey]) {
                    SlikeDLog(@"CONTROLS STATE: Buffering has ended");
                    [self slikeLoadingViewAppearance:NO];
                } else {
                    [self slikeLoadingViewAppearance:YES];
                    SlikeDLog(@"CONTROLS STATE: Buffering has started");
                }
                
            } else if(playerState ==  SL_COMPLETED && !self.isLiveStream) {
                
                [self _changeViewStateForPlaylist];
                
                [self _updatePlayerStateFromData:playerState payload:payload];
                [self _updateMediaControlsAppearance:YES];
                
                //Hide Next Play Item
                self.playlistNextItemView.alpha = 0;
                
                //Invalidate the timer and show all the controls
                [self _invalidateTimerAndShowControls];
                
            } else if(playerState ==  SL_REPLAY) {
                
                self.seekBar.value =  0.0f;
                self.lblCurrentTime.text =  @"00:00";
                
                self.progressBuffering.progress =  0.0;
                [self _updateMediaControlsAppearance:NO];
                [self setInitialPosition];
                
            } else if(playerState == SL_FSENTER) {
                [self showCoachMarkIfRequired];
                [self updateFullScreen:YES];
                
            } else if(playerState == SL_FSEXIT) {
                [self updateFullScreen:NO];
                
            } else if(playerState == SL_TIMELOADRANGE && !self.isLiveStream) {
                [self _updateBufferingProgress:payload];
                
            } else if(playerState == SL_SEEKING || playerState == SL_SEEKED) {
                [self _updatePlayerStateFromData:playerState payload:payload];
                
                if (playerState == SL_SEEKED) {
                    self.isSlideing= NO;
                    [self slikeLoadingViewAppearance:NO];
                } else {
                    [self slikeLoadingViewAppearance:YES];
                }
                
            } else  if(playerState == SL_HIDECONTROLS) {
                [self _invalidateTimerAndHideControls];
                
            } else  if(playerState == SL_SHOWCONTROLS) {
                [self _invalidateTimerAndShowControls];
                
            } else  if (playerState == SL_RESETCONTROLS) {
                [self _reestablishTimer];
                
            }  else if(playerState == SL_QUALITYCHANGED) {
                [self slikeLoadingViewAppearance:NO];
                
            } else if (playerState == SL_ERROR) {
                [self handleError:payload];
                
            } else if (playerState == SL_SET_NEXT_PLAYLIST_DATA) {
                SlikeConfig *nextItemConfig = payload[kSlikeConfigModelForNextItemKey];
                [self setupNextItemInfo:nextItemConfig];
                
            } else if (playerState == SL_HIDE_NEXT_PLAYLIST_DATA) {
                self.playlistNextItemView.alpha = 0;
                
            } else if (playerState == SL_MEDIA_PREVIEWS) {
                [self handlePanGestureForPreviews:payload];
            }
            
            //Update the Media position
            [self updateControlsVissibleState:playerState];
        }
    });
}

/**
 Look at the Errors . Netwok error| Players Errors
 @param payload - Need to check data | info keys
 */
- (void)handleError:(NSDictionary *)payload {
    if (payload) {
        SlikeDLog(@"CONTROLS STATE: Error - %@", payload);
    }
    
    [self slikeLoadingViewAppearance:NO];
    self.draggingProgressView.alpha =0.0;
}

- (void)_updatePlayerStateFromData:(SlikePlayerState)playerState payload:(NSDictionary*)payload {
    
    if (!payload ) {
        return;
    }
    
    if(self.isSlideing && playerState != SL_SEEKPOSTIONUPDATE) {
        return;
    }
    
    NSInteger playerCurrentPosition =  0;
    NSInteger playerDuration =  0;
    
    NSNumber *currentPosition = [payload numberForKey:kSlikeCurrentPositionKey];
    if (currentPosition !=nil) {
        playerCurrentPosition = [currentPosition integerValue];
    }
    
    NSNumber *duration = [payload numberForKey:kSlikeDurationKey];
    if (duration !=nil) {
        playerDuration =   [duration integerValue];
    }
    
    if ([self isMediaTypeDVR] && playerCurrentPosition) {
       // NSLog(@"data Aravind medicontrol== %ld",(long)playerCurrentPosition);
        //NSLog(@"data Aravind medicontrol== %ld",(long)playerCurrentPosition/100);
       dispatch_async(dispatch_get_main_queue(), ^{
           [self.dvrCurrentTime setText:[SlikeUtilities formatTime:playerCurrentPosition/1000]];
           [self.dvrCurrentTime setNeedsDisplay];
       });
        
       // self.dvrCurrentTime.backgroundColor = [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:1.0];

      //  NSLog(@"data Aravind medicontrol==== %@",[SlikeUtilities formatTime:playerCurrentPosition/1000]);
       // NSLog(@"data Aravind medicontrol label ==== %@",self.dvrCurrentTime.text);

        if((!_isSlideing && self.playerCurrentState == SL_PLAYING) || self.playerCurrentState == SL_COMPLETED) {
            CMTime time = CMTimeMakeWithSeconds(playerCurrentPosition/1000, NSEC_PER_SEC);
            [self updateStatusForDVR:time];
        }
        return;
    }
    
    
    if (currentPosition && duration) {
        NSInteger remaingTime = playerDuration/1000 - playerCurrentPosition/1000;
        
        [self setNextCardVissibility:remaingTime withPos:playerCurrentPosition withDuration:playerDuration];
        
        if(self.slikePlayer) {
            [self updateTimeLabel:[SlikeUtilities formatTime:playerCurrentPosition / 1000] withDuration:[SlikeUtilities formatTime:playerDuration / 1000]];
            [self updateSlider:playerCurrentPosition withPlayerDuation:playerDuration];
        }
    }
}

- (void)setNextCardVissibility:(NSInteger)remaingTime withPos:(NSInteger)playerCurrentPosition withDuration:(NSInteger)playerDuration{
    
    if (_isNextCardVissible && remaingTime <= _cardFecthTime && playerCurrentPosition >0  && playerDuration>0) {
        
        NSInteger leastTime = playerDuration - playerCurrentPosition;
        if (leastTime <=2) {
            _nextCardButton.userInteractionEnabled = NO;
        } else {
            _nextCardButton.userInteractionEnabled = YES;
        }
        if (_playlistNextItemView.alpha ==0) {
            [_playlistNextItemView slike_appearState:YES];
        }
    } else {
        
        if (_playlistNextItemView.alpha ==1) {
            [_playlistNextItemView slike_appearState:NO];
        }
    }
}

- (void)_updateBufferingProgress:(NSDictionary*)payload {
    
    if (!payload ) {
        return;
    }
    float playerCurrentBufferPos = 0;
    float playerDuration = 0;
    NSNumber *currentBufferPos = [payload numberForKey:kSlikeBufferPositionKey];
    if (currentBufferPos != nil) {
        playerCurrentBufferPos = [currentBufferPos floatValue];
    }
    NSNumber *duration = [payload numberForKey:kSlikeDurationKey];
    if (duration != nil) {
        playerDuration = [duration floatValue];
    }
    
    if (currentBufferPos && playerDuration) {
        if(playerDuration > 0) {
            self.progressBuffering.progress = playerCurrentBufferPos/playerDuration;
        } else{
            self.progressBuffering.progress = 0.0;
        }
    }
}

#pragma MARK SeeK Bar Actions===
- (void)addTargetSlider {
    
    self.seekBar.delegate = self;
    self.seekBar.continuous = YES;
    
    [self.seekBar addTarget:self action:@selector(sliderValueDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.seekBar addTarget:self action:@selector(slidingStart:)forControlEvents:UIControlEventTouchDown];
    [self.seekBar addTarget:self action:@selector(slidingStopped:)forControlEvents:UIControlEventTouchUpInside];
    [self.seekBar addTarget:self action:@selector(slidingStopped:)forControlEvents:UIControlEventTouchUpOutside];
    [self.seekBar addTarget:self action:@selector(slidingStopped:)forControlEvents:UIControlEventTouchCancel];
    [self.seekBar addTarget:self action:@selector(sliderDragged:)forControlEvents:UIControlEventTouchDragInside];
    
}

- (void)sliderDragged:(UISlider *) sender {
    
    if ([self isMediaTypeDVR]) {
        [self updateStatusForDVR:self.time];
        return;
    }
    
    SlikeDLog(@"CONTROLS: Seekbar sliderDragged...");
    _isUserSliding = YES;
    [self _updateDraggingPosition];
    NSDictionary *seekedData = @{kSlikeSeekProgressKey:@(sender.value)};
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_SEEKPOSTIONUPDATE dataPayload:seekedData slikePlayer:nil];
}

- (void)fetchThumbnailsForStream:(CGFloat)progress {
    if (![self.mediaConfig isMediaThumbnailsAvailable]) {
        return;
    }
    
    NSInteger videoDuration = [self.slikePlayer getDuration]/1000;
    NSInteger secs = progress * videoDuration;
    
    self.draggingProgressView.screenShotTimeLabel.text = [SlikeUtilities formatTime: secs];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.slikePlayer getScreenShotAtPosition:secs withCompletionBlock:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                
                self.draggingProgressView.previewThumnail.image = image;
                [self.draggingProgressView.previewThumnail setNeedsDisplay];
            });
            
        }];
    });
}

- (void)_updateDraggingPosition {
    
    CGRect theFrame = [_seekBar convertRect:_seekBar.frame toView:self];
    NSInteger verticalPos = CGRectGetMinY(theFrame) - (kDraggingViewBottomOffset+kDraggingViewHeight);
    
    CGRect trackRect = [self.seekBar trackRectForBounds:self.seekBar.bounds];
    CGRect thumbRect = [self.seekBar thumbRectForBounds:self.seekBar.bounds
                                              trackRect:trackRect
                                                  value:self.seekBar.value];
    
    NSInteger horizentalPosition = thumbRect.origin.x + self.seekBar.frame.origin.x+_draggingLeftPadding;
    //NSInteger horizentalPosition = thumbRect.origin.x + self.seekBar.frame.origin.x;
    if (horizentalPosition > (self.frame.origin.x + kDraggingViewWidth/2+_draggingLeftPadding)) {
        _draggingProgressView.center = CGPointMake(horizentalPosition, verticalPos);
    }
}

- (void)sliderValueDidChange:(CPSlider *)sender {
    [self fetchThumbnailsForStream:sender.value];
    SlikeDLog(@"CONTROLS: Seekbar sliderValueDidChange...");
}

- (void)slidingStart:(CPSlider *)sender {
    [self _invalidateTimerAndShowControls];
    
    SlikeDLog(@"CONTROLS: Seekbar slidingStart...");
    
    [self bringSubviewToFront:_draggingProgressView];
    if ([self.mediaConfig isMediaThumbnailsAvailable]) {
        [_draggingProgressView slike_appearState:YES];
        [self _updateDraggingPosition];
    }
    //SlikeDLog(@"CONTROLS: Seekbar start...");
    _isSlideing= YES;
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_SEEKING dataPayload:@{} slikePlayer:nil];
}

- (void)slidingStopped:(CPSlider *)sender {
    //SlikeDLog(@"CONTROLS: Seekbar stoped...");
    [self _reestablishTimer];
    
    if ([self.mediaConfig isMediaThumbnailsAvailable]) {
        [_draggingProgressView slike_appearState:NO];
    }
    [self sliderStopped];
}

- (void)sliderStopped {
    [self slikeLoadingViewAppearance:YES];
    NSDictionary *seekedData = @{kSlikeSeekProgressKey:@(self.seekBar.value)};
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_SEEKED dataPayload:seekedData slikePlayer:nil];
}

#pragma mark - Slider Delegate
- (void)slider:(CPSlider *)slider didChangeToSpeed:(CGFloat)speed whileTracking:(BOOL)tracking {
}

- (void)slider:(CPSlider *)slider didChangeToSpeedIndex:(NSUInteger)index whileTracking:(BOOL)tracking {
}

#pragma mark IBAction====
- (IBAction)playPauseButtonClicked:(id)sender {
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_PLAY dataPayload:@{kSlikePlayPauseByUserKey : @YES} slikePlayer:nil];
}

- (IBAction)replayButtonClicked:(id)sender {
    self.seekBar.value =  0.0f;
    self.lblCurrentTime.text =  @"00:00";
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_REPLAY dataPayload:@{} slikePlayer:nil];
    
}

- (IBAction)previousButtonClicked:(id)sender {
    
    self.alpha =0.0;
    _playlistNextItemView.alpha = 0;
    [self _invalidateTimerAndHideControls];
    
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_PREVIOUS dataPayload:@{kSlikeADispatchEventToParentKey: @(YES)} slikePlayer:nil];
}

- (IBAction)nextButtonClicked:(id)sender {
    self.alpha =0.0;
    _playlistNextItemView.alpha = 0;
    [self _invalidateTimerAndHideControls];
    
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_NEXT dataPayload:@{kSlikeADispatchEventToParentKey: @(YES)} slikePlayer:nil];
}

- (IBAction)birateButtonClicked:(id)sender {
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_QUALITYCHANGECLICKED dataPayload:@{} slikePlayer:nil];
}

- (IBAction)shareActivityButtonClicked:(id)sender {
    
    if (self.mediaConfig.shareText && self.mediaConfig.shareText.length == 0) {
        
        NSMutableDictionary *payloadInfo =  [[NSMutableDictionary alloc]init];
        [payloadInfo setObject:@(YES) forKey:kSlikeADispatchEventToParentKey];
        [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_SHARE dataPayload:payloadInfo slikePlayer:nil];
        return;
    }
    
    //Do the share controlls-
    //create a message
    NSString *theMessage = self.mediaConfig.shareText;
    NSArray *items = @[theMessage];
    
    // build an activity view controller
    _shareController = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    
    // and present it
    [self presentActivityController:_shareController];
    
}

- (void)presentActivityController:(UIActivityViewController *)controller {
    if(!self.isVideoPaused)
    {
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_PAUSE dataPayload:@{kSlikePlayPauseByUserKey : @YES} slikePlayer:nil];
        self.isSharePause =  YES;
    }else
    {
        [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_PAUSE dataPayload:@{} slikePlayer:nil];
        self.isSharePause =  NO;
    }
    // for iPad: make the presentation a Popover
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[SlikeUtilities topMostController] presentViewController:controller animated:YES completion:nil];
    } else {
        
        controller.modalPresentationStyle = UIModalPresentationPopover;
        controller.popoverPresentationController.sourceView = self;
        controller.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
        controller.popoverPresentationController.sourceRect = _btnActivityShare.frame;
        [[SlikeUtilities topMostController] presentViewController:controller animated:YES completion:nil];
    }
    
    // access the completion handler
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        if(self.isSharePause)
        {
        [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_PLAY dataPayload:@{kSlikePlayPauseByUserKey : @YES} slikePlayer:nil];
        }else
        {
            [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_PLAY dataPayload:@{} slikePlayer:nil];
        }
        
        if (error) {
            SlikeDLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
}

- (IBAction)castButtonClicked:(id)sender {
}

- (IBAction)dockButtonClicked:(id)sender {
}

- (IBAction)closeButtonClicked:(id)sender
{
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_CLOSE dataPayload:@{kSlikeADispatchEventToParentKey: @(YES)} slikePlayer:nil];
}

- (IBAction)fullScreenButtonClicked:(id)sender {
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_FULLSCREENCLICKED dataPayload:@{} slikePlayer:nil];
}

- (IBAction) backToLiveButtonClicked:(id)sender {
}

#pragma Mark Action Task-
- (void)updateControlsVissibleState:(SlikePlayerState)state {
    
    if(state == SL_PLAY || state == SL_PAUSE)
    {
        self.videoCompleted = NO;
        [self upDatePlayPauseButtonState:state];
    }
    else  if(state == SL_PLAYING) {
        self.videoCompleted = NO;
        [self upDatePlayPauseButtonState:state];
    }
}

- (void)upDatePlayPauseButtonState:(SlikePlayerState)state {
    //[self _centerControlsAppearanceHidden:YES];
    if(state == SL_PAUSE) {
        self.btnPlayPause.selected =  NO;
        self.isVideoPaused=YES;
        [self _invalidateTimerAndShowControls];
        
    } else if(state == SL_PLAY || state == SL_PLAYING) {
        self.btnPlayPause.selected =  YES;
        self.isVideoPaused=NO;
        
        if(state == SL_PLAY) {
            [self _reestablishTimer];
        }
    }
}
-(void)updateTime
{
    _isBitrateChange =  NO;
}
- (void)updateTimeLabel:(NSString *)currTime withDuration:(NSString *)strDuration
{
    
    if(_isBitrateChange && [currTime isEqualToString:@"00:00"])
    {
        return;
    }else if(_isBitrateChange && ![currTime isEqualToString:@"00:00"])
    {
        [self performSelector:@selector(updateTime) withObject:nil afterDelay:1.0];
        return;
    }
    
    if([currTime length] != 0)
        self.lblCurrentTime.text = currTime;
    else
        self.lblCurrentTime.text  =  @"00:00";
    if([strDuration length] != 0)
        self.lblDuration.text = strDuration;
}

- (void)updateFullScreen:(BOOL)isPlayerFullScreen {
    
    self.btnFullScreen.selected = isPlayerFullScreen;
    self.lblNowPlaying.hidden = !self.btnFullScreen.isSelected;
    [_shareController dismissViewControllerAnimated:NO completion:nil];
    
    if([[SlikeDeviceSettings sharedSettings] isPhoneX]) {
        
        if(isPlayerFullScreen) {
            self.topViewLeadinConstraint.constant =  kiPhoneXContraintFxEnter;
            self.topViewTraillingConstraint.constant = kiPhoneXContraintFxEnter;
            self.bottomViewLeadinConstraint.constant =  kiPhoneXContraintFxEnter;
            self.bottomViewTrailingConstraint.constant = kiPhoneXContraintFxEnter;
            self.bottomViewBottomConstraint.constant = kiPhoneXContraintBottomFxEnter;
            
            _draggingLeftPadding = kiPhoneXContraintFxEnter;
            _draggingRightPadding = kiPhoneXContraintFxEnter;
            
        } else {
            self.topViewLeadinConstraint.constant =  kiPhoneXContraintFxExit;
            self.topViewTraillingConstraint.constant = kiPhoneXContraintFxExit;
            self.bottomViewLeadinConstraint.constant =  kiPhoneXContraintFxExit;
            self.bottomViewTrailingConstraint.constant = kiPhoneXContraintFxExit;
            self.bottomViewBottomConstraint.constant = kiPhoneXContraintBottomFxExit;
            
            _draggingLeftPadding = kiPhoneXContraintFxExit+20;
            _draggingRightPadding = kiPhoneXContraintFxExit;
            
        }
    }
    //[self layoutIfNeeded];
    [self _updateDraggingPosition];
}

- (void)updateSlider:(NSInteger)playerCurrentPos withPlayerDuation:(NSInteger)playerDuration {
    
    if(_isBitrateChange || playerCurrentPos < 1000) return;
    
    float sliderPercentage = 0;
    if(playerCurrentPos!=0) {
        
        sliderPercentage = (float) playerCurrentPos/playerDuration;
    }
    
    if((!_isSlideing && self.playerCurrentState == SL_PLAYING) || self.playerCurrentState == SL_COMPLETED) {
        [self.seekBar setValue:sliderPercentage animated:YES];
        self.nextItemProgress.progress = sliderPercentage;
    }
}

/**
 Update the Media Controls
 @param appearance - TRUE|FALSE
 */
- (void)_updateMediaControlsAppearance:(BOOL)appearance {
    self.btnPlayPause.hidden  =  appearance;
    self.btnReplay.hidden     =  !appearance;
    self.videoCompleted  =   appearance;
    self.viewCenterControls.hidden = NO;
    self.isVideoPaused = YES;
    if (self.mediaConfig.isCloseControl && !self.btnReplay.hidden) {
        _btnClose.hidden = NO;
    }
    
    [self _headerFooterControlsAppearance:appearance];
}

-(void)dealloc {
    SlikeDLog(@"dealloc- Cleaning up SlikeMediaPlayerControl");
}

#pragma mark - Hide/Show Controls basis of touch and time

/**
 Tap Gesture to show and hide the controls
 @param gesture -
 */
- (void)singleTapOnControlsView:(UITapGestureRecognizer *)gesture {
    
    if (!self.btnReplay.isHidden && self.videoCompleted) {
        return;
    }
    if(self.playerCurrentState == SL_READY) return;
    
    if (gesture) {
        if ([self showCoachMarkIfRequired]) {
            return;
        }
    }
    if(self.viewControls.alpha == 0.f) {
        [self fadeControlsIn];
    } else if (self.viewControls.alpha == 1.f) {
        [self fadeControlsOut];
    }
}
/**
 Invalidate the timer and show all the controls
 */
- (void)_invalidateTimerAndShowControls {
    [self.controlTimer invalidate];
    if(self.playerCurrentState == SL_READY) return;
    [self showControls];
}

- (void)_invalidateTimerAndHideControls {
    [self.controlTimer invalidate];
    [self hideControls];
}

/**
 Reestablish the timer again
 */
- (void)_reestablishTimer {
    [self.controlTimer invalidate];
    self.controlTimer = [NSTimer scheduledTimerWithTimeInterval:kViewControllerControlsVisibleDuration target:self selector:@selector(fadeControlsOut) userInfo:nil repeats:NO];
}

- (void)fadeControlsIn {
    [UIView animateWithDuration:kViewControllerFadeControlsInAnimationDuration animations:^{
        [self showControls];
    } completion:^(BOOL finished) {
        if(finished) {
            if (self.playerCurrentState == SL_PAUSE || self.playerCurrentState == SL_COMPLETED || self.isVideoPaused) {
                //NOTE: Controlls should be vissible if user is in pause|Completed state
                // 'If' condition should be removed if above functionality does not needed
            } else {
                [self _reestablishTimer];
            }
        }
    }];
}

- (void)fadeControlsOut {
    [UIView animateWithDuration:kViewControllerFadeControlsOutAnimationDuration animations:^{
        [self hideControls];
    }];
}

- (void)hideControls {
    self.viewControls.alpha = 0.f;
}
- (void)showControls {
    self.viewControls.alpha = 1.f;
}

#pragma mark - Show/Hide Loading
- (void)slikeLoadingViewAppearance:(BOOL)appearance {
    [self _centerControlsAppearanceIsHidden:appearance];
    
    if(appearance) {
        self.activityIndicatorView.hidden = NO;
        [self.activityIndicatorView startAnimating];
        if(self.superview) {
            [self.superview bringSubviewToFront:self.activityIndicatorView];
        } else {
            [self bringSubviewToFront:self.activityIndicatorView];
        }
        
    } else {
        self.activityIndicatorView.hidden  = YES;
        [self.activityIndicatorView stopAnimating];
    }
}

- (void)_headerFooterControlsAppearance:(BOOL)appearance {
    self.viewTopControls.hidden = appearance;
    self.viewBottomControls.hidden = appearance;
}

- (void)_centerControlsAppearanceIsHidden:(BOOL)isHide {
    self.viewCenterControls.hidden  = isHide;
    self.btnPlayPause.hidden = isHide ?YES :NO;
    self.btnReplay.hidden =  YES;
}


/**
 Setup the Next Item Info
 */
- (void)setupNextItemInfo:(SlikeConfig *)nextItemConfig {
    __weak __typeof__(self) weakSelf = self;
    
    _nextItemTitle.text = [SlikeUtilities getNextVideoTitle:nextItemConfig];
    _isNextCardVissible = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [ self.playlistNextItemView slike_appearState:YES];
        [[SlikeNetworkManager defaultManager] getImageForURL:[NSURL URLWithString:[SlikeUtilities getNextPosterImage:nextItemConfig]] completion:^(UIImage *image, NSString *localFilepath, BOOL isFromCache, NSInteger statusCode, NSError *error) {
            weakSelf.nextItemImageView.image = image;
        }];
    });
}

/**
 Is Player is handling the playlist
 */
- (void)_changeViewStateForPlaylist  {
    
    if ([[SlikeSharedDataCache sharedCacheManager]isPlayListVideo]) {
        if(self.mediaConfig.isAutoPlayNext && [[SlikeSharedDataCache sharedCacheManager] isLastPlaylistItem]) {
            self.alpha =1.0;
        } else {
            
            SlikeDLog(@"CONTROLS STATE: HIDE THE VIEW");
            self.alpha =0.0;
            [self _invalidateTimerAndHideControls];
        }
    }
}

- (void)hideControlsIfAutoPlayDesibale:(BOOL)disable {
    if (self.mediaConfig.isAutoPlay == FALSE) {
        if (disable) {
            self.viewTopControls.alpha=0;
            self.viewBottomControls.alpha=0;
        } else {
            [self.viewTopControls slike_appearState:YES];
            [self.viewBottomControls slike_appearState:YES];
        }
    }
}

#pragma mark-  Update the Values
- (void)handlePanGestureForPreviews:(NSDictionary *)payloadData {
    if (!payloadData) {
        return;
    }
    
    NSNumber *startPosition = [payloadData numberForKey:kSlikePreviewStartedKey];
    if (startPosition) {
        [[EventManager sharedEventManager] dispatchEvent:GESTURE playerState:SL_SHOWCONTROLS dataPayload:@{} slikePlayer:nil];
        
        //Not using the payload.
        [self slidingStart:_seekBar];
    }
    
    NSNumber *progressPosition = [payloadData numberForKey:kSlikePreviewProgressKey];
    if (progressPosition) {
        _seekBar.value = [progressPosition floatValue];
        [self sliderValueDidChange:_seekBar];
        [self sliderDragged:_seekBar];
    }
    
    NSNumber *stopPosition = [payloadData numberForKey:kSlikePreviewStopKey];
    if (stopPosition) {
        //Not using the payload.
        if ([stopPosition floatValue] < 0) {
            _draggingProgressView.alpha = 0;
            [self _invalidateTimerAndHideControls];
        } else {
            [self slidingStopped:_seekBar];
        }
    }
}

/**
 * Manage "Gesture Show case View" screen with preferences to show it only for 1st time.
 */
- (BOOL)showCoachMarkIfRequired {
    if (!_mediaConfig.enableCoachMark) {
        return NO;
    }
    
    if ([[SlikeDeviceSettings sharedSettings] hasCoachMarkShown] || [self.slikePlayer isAdPlaying]) {
        return NO;
    }
    
    if (_coachMarkVissible) {
        //Coachmark is allready there . So need to return from here
        return NO;
    }
    
    _coachMarkVissible = YES;
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_PAUSE dataPayload:@{} slikePlayer:nil];
    SlikeCoachmarkView *coachMarkView = [[SlikeCoachmarkView alloc]initWithView:self coachMarkImageName:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"ipad_coachmark" : @"iphone_coachmark"];
    coachMarkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    coachMarkView.frame = self.frame;
    coachMarkView.backgroundColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.90];
    coachMarkView.delegate = self;
    [coachMarkView setAutoHideAfterInterval:FALSE];
    [coachMarkView showCoachMark];
    [self bringSubviewToFront:coachMarkView];
    
    [self _invalidateTimerAndHideControls];
    
    return YES;
}

#pragma mark - SlikeCoachmarkView Delegate
- (void)coachMarksView:(SlikeCoachmarkView*)coachMarksView didTapOnScreen:(id)sender {
    [coachMarksView hideCoachMark];
    [[SlikeDeviceSettings sharedSettings]updateCoachMarkStatus:YES];
    [[EventManager sharedEventManager] dispatchEvent:CONTROLS playerState:SL_PLAY dataPayload:@{} slikePlayer:nil];
    [self _invalidateTimerAndShowControls];
}

#pragma mark DVR Stream Implementation

- (IBAction)switchStremDidClicked:(id)sender {
    [self _invalidateTimerAndHideControls];
    
    if (self.mediaConfig.streamingInfo.mediaStreamType == SLKMediaPlayerStreamTypeLive) {
        [_liveButton setTitle:[SlikePlayerSettings playerSettingsInstance].slikestrings.goToDvrButtonTitle forState:UIControlStateNormal];
        [self.slikePlayer switchToStream:SLKMediaPlayerStreamTypeDVR];
    } else if (self.mediaConfig.streamingInfo.mediaStreamType == SLKMediaPlayerStreamTypeDVR) {
        [_liveButton setTitle:[SlikePlayerSettings playerSettingsInstance].slikestrings.goToLiveButtonTitle forState:UIControlStateNormal];
               [self.slikePlayer switchToStream:SLKMediaPlayerStreamTypeLive];
    }
    [self updateSlikeMediaData];
}

- (void)updateDVRButtonTitle {
    if (self.mediaConfig.streamingInfo.mediaStreamType == SLKMediaPlayerStreamTypeLive) {
           [_liveButton setTitle:[SlikePlayerSettings playerSettingsInstance].slikestrings.goToDvrButtonTitle forState:UIControlStateNormal];
        [_liveButton setTitle:[SlikePlayerSettings playerSettingsInstance].slikestrings.goToDvrButtonTitle forState:UIControlStateSelected];

        _dvrCurrentTime.hidden = YES;
       } else if (self.mediaConfig.streamingInfo.mediaStreamType == SLKMediaPlayerStreamTypeDVR) {
           [_liveButton setTitle:[SlikePlayerSettings playerSettingsInstance].slikestrings.goToLiveButtonTitle forState:UIControlStateNormal];
           [_liveButton setTitle:[SlikePlayerSettings playerSettingsInstance].slikestrings.goToLiveButtonTitle forState:UIControlStateSelected];

           _dvrCurrentTime.hidden = NO;

    }
}


/// Update position for DVR (SeekBar and Positons label)
/// @param time - time  data

- (void)updateStatusForDVR:(CMTime)time {
   // [self bringSubviewToFront:_liveButton];
    if (SLK_CMTIMERANGE_IS_NOT_EMPTY([_slikePlayer getTimeRange]) && SRG_CMTIMERANGE_IS_DEFINITE([_slikePlayer getTimeRange])) {
        
        float timeseSlapsed = CMTimeGetSeconds([_slikePlayer getTimeRange].duration);
        /*
        NSLog(@"timeseSlapsed float %f",timeseSlapsed);

        NSLog(@"timeseSlapsed start %f",CMTimeGetSeconds([_slikePlayer getTimeRange].start));
        NSLog(@"timeseSlapsed duration %f", CMTimeGetSeconds([_slikePlayer getTimeRange].duration));
        
        NSLog(@"timeseSlapsed seekValue %f",CMTimeGetSeconds(CMTimeSubtract(time, [_slikePlayer getTimeRange].start)));
        */
        if (timeseSlapsed <= 60) {
           self.lblDuration.hidden = YES;
           self.lblCurrentTime.hidden = YES;
           self.seekBar.hidden = YES;
            self.progressBuffering.hidden = YES;
           return;
        }
        self.lblDuration.hidden = NO;
        self.lblCurrentTime.hidden = NO;
        self.seekBar.hidden = NO;
        self.progressBuffering.hidden = NO;


        self.seekBar.maximumValue = CMTimeGetSeconds([_slikePlayer getTimeRange].duration);
        self.seekBar.value = CMTimeGetSeconds(CMTimeSubtract(time, [_slikePlayer getTimeRange].start));

        self.widthDurationConst.constant = 0.0;
        self.widthCurrentTimeConst.constant = 0.0;
        self.seekBarBottomConst.constant = 6.0 + 25.0;
        self.bottomBufferingConst.constant = 18.0 + 25.0;
        if (!self.btnFullScreen.hidden) {
            self.trailingDuraionFullScreen.constant = -30;
        }
        _dvrCurrentTime.hidden = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.lblCurrentTime.text = [SlikeUtilities formatTime:self.seekBar.value];
            self.lblDuration.text = [SlikeUtilities formatTime:(self.seekBar.maximumValue - self.seekBar.value)];
        });
    
    }
}

- (CMTime)time {
    CMTimeRange timeRange = [self.slikePlayer getTimeRange];
    if (CMTIMERANGE_IS_EMPTY(timeRange)) {
        return kCMTimeZero;
    }
    CMTime relativeTime = CMTimeMakeWithSeconds(self.seekBar.value, NSEC_PER_SEC);
    return CMTimeAdd(timeRange.start, relativeTime);
}

/// isDvr Stream is live
- (BOOL)isLiveDVR {
    return (self.mediaConfig.streamingInfo.mediaStreamType == SLKMediaPlayerStreamTypeDVR && (self.seekBar.maximumValue - self.seekBar.value < self.mediaConfig.streamingInfo. liveTolerance));
}

- (BOOL)isMediaTypeDVR {
    if (self.mediaConfig && self.mediaConfig.streamingInfo.mediaStreamType == SLKMediaPlayerStreamTypeDVR) {
        return YES;
    }
    return NO;
}

@end
