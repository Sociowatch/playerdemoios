//
//  SlikeGifView.m
//  SlikePlayer
//
//  Created by Sanjay Singh Rathor on 08/03/18.
//
#import <UIKit/UIKit.h>
#import "SlikeGifView.h"
#import "SlikeAnimatedImageView.h"
#import "SlikeAnimatedImage.h"
#import "PlayerView.h"
#import "SlikeGlobals.h"
#import "SlikePlayerConstants.h"
#import "NSBundle+Slike.h"
#import "SlikeUtilities.h"
#import "SlikeMaterialDesignSpinner.h"


typedef NS_ENUM(NSInteger, SlikeGifMediaType) {
    SlikeGifMediaTypeGif = 0x0,
    SlikeGifMediaTypeMp4
};

@interface SlikeGifView() {
}
@property(nonatomic,assign) BOOL hasObserver;

@property (weak, nonatomic) IBOutlet PlayerView *mp4PlayerView;
@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet SlikeAnimatedImageView *gifImageView;
@property (assign, nonatomic)UIDeviceOrientation currentOrientation;
@property (assign, nonatomic)SlikeGifMediaType currentGifMediaType;
@property (assign) BOOL playerObserverAdded;
@property (assign) BOOL isGIFStatePaused;
@property (weak, nonatomic) IBOutlet UIButton *gifImageButton;
@property (strong, nonatomic) NSString* mp4UrlString;
@property (weak, nonatomic) IBOutlet SlikeMaterialDesignSpinner *loadingView;
@end

@implementation SlikeGifView

- (id)initWithFrame:(CGRect)frame {
    
    self =  [super initWithFrame:frame];
    [self commonInit];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self commonInit];
    return self;
}

- (void)commonInit {
    
    [[NSBundle slikeNibsBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil];
    [self addSubview:_contentView];
    self.contentView.frame = self.bounds;
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //Add the Long Gesture Recognizer to GIF View
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(gestureHandler:)];
    
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [self.contentView addGestureRecognizer:tapGesture];
    [self.contentView  setUserInteractionEnabled:YES];
    _currentGifMediaType = SlikeGifMediaTypeMp4;
    
    [_gifImageButton setImage:[UIImage imageNamed:@"gif" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
    
    _gifImageButton.alpha=0.0;
    _mp4Duration =-1;
    _isGIFStatePaused=NO;
    [_loadingView hidesWhenStopped];
    
}

- (void)gestureHandler:(UITapGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self changeCurrentMediaState];
    }
    else if (gesture.state == UIGestureRecognizerStateBegan) {
        
    }
}

//Change the current media stream
- (void)changeCurrentMediaState {
    
    if (_currentGifMediaType == SlikeGifMediaTypeMp4) {
        
        if ([self.mp4PlayerView isPlaying]) {
            _isGIFStatePaused=YES;
            [self pauseCurrentMedia];
        } else {
            _isGIFStatePaused=NO;
            [self playCurrentMedia];
        }
        
    } else {
        
        if ([self.gifImageView isGifPlaying]) {
            _isGIFStatePaused=YES;
            [self pauseCurrentMedia];
            
        } else {
            _isGIFStatePaused=NO;
            [self playCurrentMedia];
        }
    }
}
#pragma mar- Player Implementation
/*
 Play Gif Image
 */
- (void)loadGifPlayer:(NSString *)gifUrlString {
    
    _currentGifMediaType = SlikeGifMediaTypeGif;
    [_mp4PlayerView setHidden:YES];
    [_gifImageView setHidden:NO];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:gifUrlString] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            
            [self.loadingView stopAnimating];
            if ([self.delegate respondsToSelector:@selector(gifPlayerFailed:)]) {
                [self.delegate gifPlayerFailed:error];
            }
            return ;
        }
        
        [self.loadingView stopAnimating];
        if ([self.delegate respondsToSelector:@selector(gifPlayerLoaded:)]) {
            [self.delegate gifPlayerLoaded:self];
        }
        
        SlikeAnimatedImage *gifImage = [[SlikeAnimatedImage alloc] initWithAnimatedGIFData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.gifImageView.animatedImage = gifImage;
            
            if ([self.delegate respondsToSelector:@selector(gifPlayerStartPlaying:)]) {
                [self.delegate gifPlayerStartPlaying:self];
            }
        });
        
    }] resume];
}


- (void)loadMP4Player:(NSString *)playerUrlString {
    
    if (playerUrlString !=nil) {
        
        _currentGifMediaType = SlikeGifMediaTypeMp4;
        _mp4UrlString = playerUrlString;
        [_mp4PlayerView setHidden:NO ];
        [_gifImageView setHidden:YES];
        //Stop the current player if already exists
        [_mp4PlayerView stopVideo:YES];
        
        //Remove the observers if already there
        [self removePlayerEventObserver];
        //Again add the observers
        [self addPlayerEventObserver];
        //Play the video
        [_mp4PlayerView playMp4Video:playerUrlString];
    }
}


#pragma mark - Utility Methods
//Pause the current media either itis gif or mp4
- (void)pauseCurrentMedia {
    
    _gifImageButton.alpha=1.0;
    if(_currentGifMediaType == SlikeGifMediaTypeMp4) {
        [_mp4PlayerView pause];
    } else {
        [self.gifImageView pauseGifPlayer];
    }
}

//Play the current media either itis gif or mp4
- (void)playCurrentMedia {
    
    _gifImageButton.alpha=0.0;
    if(_currentGifMediaType == SlikeGifMediaTypeMp4) {
        [_mp4PlayerView play];
    } else {
        [self.gifImageView playGifPlayer];
    }
}

//Resume the contents after the network issues
- (void)resumeGifAfterNetworkIssue {
    
    if(_currentGifMediaType == SlikeGifMediaTypeMp4) {
        if ([_mp4PlayerView isPlayerExist]) {
            [self playCurrentMedia];
        } else {
            [self loadMP4Player:_mp4UrlString];
        }
    } else {
        [self playCurrentMedia];
    }
}

//Pause the GIF
- (void)pauseGif {
    [self pauseCurrentMedia];
}

//Play the GIF
- (void)playGif {
    [self playCurrentMedia];
}

//Is Media is playing in the Fullscreen mode
- (BOOL)isPlayerInFullScreen {
    return self.isFullScreen;
}

//Is contents are playing
- (BOOL)isPlaying {
    if(_currentGifMediaType == SlikeGifMediaTypeMp4) {
        [_mp4PlayerView isPlaying];
    }
    return [self.gifImageView isGifPlaying];
}

//Set the full screen mode for the contents
- (void)setFullscreen:(BOOL)fullscreen {
    
    self.isFullScreen = fullscreen;
    [self toggleFullscreen:fullscreen];
}

- (void)playerOrientationDidChanged {
}

#pragma mark - addPlayerEventObserver
- (void)addPlayerEventObserver {
    
    if (_playerObserverAdded) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateReadyNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateDurationUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStatePlaybackErrorNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:kSlikeGifPlayerRestartedKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifications:) name:SlikePlayerPlaybackStateTimeUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillDeactive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    _playerObserverAdded=YES;
    
}

#pragma mark- Notification events
- (void)receiveNotifications:(NSNotification *) notification {
    
    if([notification.name isEqualToString:SlikePlayerPlaybackStateReadyNotification]) {
        [_mp4PlayerView startPlayingVideo:YES];
        
        if ([self.delegate respondsToSelector:@selector(gifPlayerStartPlaying:)]) {
            [self.delegate gifPlayerStartPlaying:self];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopAnimating];
            
        });
    }
    if([notification.name isEqualToString:SlikePlayerPlaybackStateDurationUpdateNotification]) {
        if (notification.object !=nil) {
            _mp4Duration =  [notification.object integerValue];
        }
        if ([self.delegate respondsToSelector:@selector(gifPlayerLoaded:)]) {
            [self.delegate gifPlayerLoaded:self];
        }
    }
    if([notification.name isEqualToString:kSlikeGifPlayerRestartedKey]) {
        if ([self.delegate respondsToSelector:@selector(gifPlayerReStarted)]) {
            [self.delegate gifPlayerReStarted];
        }
    }
    
    if([notification.name isEqualToString:SlikePlayerPlaybackStatePlaybackErrorNotification]) {
        if ([self.delegate respondsToSelector:@selector(gifPlayerFailed:)]) {
            [self.delegate gifPlayerFailed:nil];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopAnimating];
        });
    }
    
    if([notification.name isEqualToString:SlikePlayerPlaybackStateTimeUpdateNotification]) {
        if ([self.delegate respondsToSelector:@selector(gifPlayerUpdateTime:)]) {
            [self.delegate gifPlayerUpdateTime:self];
        }
    }
}

- (NSUInteger)gifMp4PlayerCurrentPosition {
    
    if (_currentGifMediaType == SlikeGifMediaTypeMp4) {
        if(!self.mp4PlayerView.player) return 0;
        if(!self.mp4PlayerView.player.currentItem) return 0;
        return CMTimeGetSeconds(self.mp4PlayerView.player.currentItem.currentTime) * 1000;
    }
    return 0;
}



//Remove the Observers if they are added for events
- (void)removePlayerEventObserver {
    if (!_playerObserverAdded) {
        return;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateReadyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateDurationUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStatePlaybackErrorNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSlikeGifPlayerRestartedKey object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SlikePlayerPlaybackStateTimeUpdateNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    _playerObserverAdded=NO;
}

//Cleanup the resources
- (void)cleanupGifResources {
    
    self.parentController = nil;
    [self removeObserver];
    
    if(_currentGifMediaType == SlikeGifMediaTypeMp4) {
        [_mp4PlayerView cleanupAVPlayerResources];
        
    } else {
        [self.gifImageView pauseGifPlayer];
    }
    [self removePlayerEventObserver];
}


#pragma mark - device evnets handling
- (void)applicationWillDeactive {
    if([self isPlaying]) {
        _isGIFStatePaused =NO;
        [self pauseCurrentMedia];
    } else {
        // [self pauseCurrentMedia];
    }
}

- (void) applicationDidActive {
    if(![self isPlaying] && !_isGIFStatePaused){
        [self playCurrentMedia];
    }
}

- (void)applicationWillActive {
    if(![self isPlaying] && !_isGIFStatePaused){
        [self playCurrentMedia];
    }
}
@end
