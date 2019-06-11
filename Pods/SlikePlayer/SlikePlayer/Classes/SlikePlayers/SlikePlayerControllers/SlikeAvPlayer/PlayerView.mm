
#import "PlayerView.h"
#import <QuartzCore/QuartzCore.h>
#import "SlikePlayerConstants.h"
#import "SlikeServiceError.h"
#import "SlikeNetworkMonitor.h"
#import "SlikeAssetLoaderDelegate.h"

@interface PlayerView() {
    NSDate *dtVideoLoadTime;
}
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger nStartTime;
@property (nonatomic, assign) NSInteger nTimeCodeToPlay;
@property (nonatomic, readwrite) BOOL isPlayerDestroyed;
@property (nonatomic, readwrite) BOOL isVideoTypeGif;
@property (nonatomic, readwrite) BOOL isObservers;
@property (nonatomic, readwrite) BOOL isPlayerAlreadyStarted;
@property (nonatomic, readwrite) BOOL playerFinish;
@property (nonatomic, readwrite) BOOL videoPaused;
@property (nonatomic, readwrite) BOOL isPlaybackReady;
@property (nonatomic, readwrite) BOOL bufferingStarted;
@property (nonatomic, assign) NSInteger playerDuration;
@property (nonatomic, strong) SlikeAssetLoaderDelegate *assetLoader;
@property (nonatomic, readwrite) BOOL isSeeking;

@end

@implementation PlayerView

//NSString * const kSlikePlayerTracksKey         = @"tracks";
NSString * const kSlikePlayerStatusKey             = @"status";
NSString * const kSlikePlayerErrorKey              = @"error";
NSString * const kSlikePlaybackBufferEmpty         = @"playbackBufferEmpty";
NSString * const kSlikePlaybackLikelyToKeepUp      = @"playbackLikelyToKeepUp";
NSString * const kSlikePlayerLoadedTimeRangesKey   = @"loadedTimeRanges";

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    }
    return self;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)avLayer {
    return (AVPlayerLayer *)self.layer;
}

- (AVPlayer *)player {
    return self.avLayer.player;
}
- (void)setPlayer:(AVPlayer *)player {
    
    if ( player == self.avLayer.player ) return;
    self.avLayer.player = player;
    
    CATransition *anima = [CATransition animation];
    anima.type = kCATransitionFade;
    anima.duration = 1.0f;
    [self.layer addAnimation:anima forKey:@"fadeAnimation"];
}

/**
 @param m3u8 - Playlist
 @param startTime - Media Start Time
 */
- (void)initialisePlayerWithPlaylist:(NSURL*)m3u8 withStartPos:(NSInteger)startTime {
    
    _isVideoTypeGif = NO;
    _playerFinish =  NO;
    _nTimeCodeToPlay = startTime;
    if(self.isPlayerDestroyed) return;
    [self queueUpContentIntoPlayer:m3u8];
}

// this function queues up content for playback by the AVPlayer object as if it were normal
// HLS playback.
// There are no special DRM considerations here
- (void)queueUpContentIntoPlayer:(NSURL*)m3u8  {
    if(self.isPlayerDestroyed || m3u8==nil) return;
    NSDate *dt = [NSDate date];
    {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:m3u8 options:nil];
        NSArray *keys = [NSArray arrayWithObjects:@"playable", @"duration", @"tracks", @"availableMediaCharacteristicsWithMediaSelectionOptions", nil];
        
        self.assetLoader =  [[SlikeAssetLoaderDelegate alloc] init];
        [asset.resourceLoader setDelegate:self.assetLoader queue:dispatch_get_main_queue()];
        
        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^()
         {
             NSError *error = nil;
             AVKeyValueStatus status = [asset statusOfValueForKey:@"playable" error:&error];
             BOOL isFailed = NO;
             BOOL isLoadSuccess = NO;
             switch (status) {
                     
                 case AVKeyValueStatusLoaded:
                     [SlikeDeviceSettings sharedSettings].nManifestLoadTime = [dt timeIntervalSinceNow] * -1000.0f;
                     self->dtVideoLoadTime = [NSDate date];
                     [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateDurationUpdateNotification object:[NSNumber numberWithLongLong:(long long)asset.duration.value]];
                     isLoadSuccess = YES;
                     break;
                 default:
                     // Handle all other cases
                     break;
             }
             
             // AVMediaSelectionGroup*  audioTracks = [asset mediaSelectionGroupForMediaCharacteristic:AVMediaCharacteristicVisual];
             isFailed = [asset availableMediaCharacteristicsWithMediaSelectionOptions].count == 0;
             if(isFailed) {
                 
                 [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStatePlaybackErrorNotification
                                                                     object:nil
                                                                   userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSError errorWithDomain:SlikeServiceErrorDomain code:SlikeServiceErrorM3U8FilerError userInfo:@{NSLocalizedDescriptionKey:@"M3u8 error."}], @"data", nil]];
             }
             
             if(isLoadSuccess) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self preparePlayer: asset];
                 });
             }
         }];
        
    }
}

/**
 Prepare the player with Asset
 @param asset - Asset
 */
- (void)preparePlayer:(AVURLAsset *)asset {
    
    [self removePlayerObservers];
    if(self.isPlayerDestroyed) return;
    
    _isPlaybackReady = NO;
    SlikeDLog(@"PLAYER: Preparing player...");
    
    self.playerItem = [[AVPlayerItem alloc] initWithAsset:asset];
    //need to change pefer bit rate
    if([[SlikeDeviceSettings sharedSettings] getcapLevel] >0 ) {
        self.playerItem.preferredPeakBitRate = [[SlikeDeviceSettings sharedSettings] isIPhoneDevice] ? [[SlikeDeviceSettings sharedSettings] getcapLevel] : [[SlikeDeviceSettings sharedSettings] getcapLevel];
    }
    
    if(self.player == nil) self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    else [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
    
    [self updateBitrate];
    
    [self.player setActionAtItemEnd:AVPlayerActionAtItemEndPause];
    self.player.closedCaptionDisplayEnabled = YES;
    [self addPlayerObservers];
    if(self.player == nil)[self setPlayer:self.player];
    SlikeDLog(@"PLAYER: Waiting for content to be ready for playback.  When it is ready, press play to begin.");
}
/**
 Called by the AVPlayer that it has completed the Asset sucessfully
 @param notification - Completion
 */
- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    if(self.isVideoTypeGif) {
        [self.player seekToTime:kCMTimeZero];
        [self.player play];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSlikeGifPlayerRestartedKey object:nil];
        
    } else {
        
        SlikeDLog(@"PLAYER: Playback is finished....");
        if(self.playerItem) {
            self.nCurrentTime = CMTimeGetSeconds(self.playerItem.asset.duration);
        }
        else {
            self.nCurrentTime = 0;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateFinishedNotification object:nil];
        _playerFinish = YES;
        [self stopTimer];
        
    }
}

- (BOOL)setPreferredBitrate:(NSInteger) nBitrate {
    if(self.playerItem) {
        self.playerItem.preferredPeakBitRate = nBitrate;
        return YES;
    }
    return NO;
}

- (void)startTimer {
    if(!self.player) return;
    if(self.timer == nil) {
        // dispatch_async(dispatch_get_main_queue(), ^{
        self.timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timerCallback:) userInfo:nil repeats:YES];
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer:self.timer forMode: NSRunLoopCommonModes];
        runner = nil;
        //});
    }
}

- (void)stopTimer {
    if(self.timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (void)timerCallback:(NSTimer *) timer {
    if(self.isPlayerDestroyed) {
        [self stopTimer];
    }
    if(self.isVideoTypeGif) {
        [self handleGifTimeForGif];
        
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateVideoTimeLabel:self.player.currentTime];
        });
    }
}

- (void)handleGifTimeForGif {
    [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateTimeUpdateNotification object:nil];
    return;
}

- (void)updatePlayerPlayingStatus {
    
    NSUInteger playerDuration = CMTimeGetSeconds(self.player.currentItem.duration);
    BOOL isDurationUnAvailable = (_isLiveStream)? YES :( _nCurrentTime < playerDuration - 1);
    
    if (self.playerItem.isPlaybackBufferEmpty && _nCurrentTime > 0 && isDurationUnAvailable && !_playerFinish) {
        BOOL isNetworkReachible = [[SlikeNetworkMonitor sharedSlikeNetworkMonitor]isNetworkReachible];
        
        if (self.player.rate > 0 && isNetworkReachible &&!_videoPaused && !self.playerItem.isPlaybackLikelyToKeepUp) {
            SlikeDLog(@"PLAYER BUFFER: PlaybackBufferEmpty Net ON");
            [self startBuffering];
            
        } else if(!isNetworkReachible && !_videoPaused) {
            SlikeDLog(@"PLAYER BUFFER: PlaybackBufferEmpty Net OFF");
            [self stopBuffering];
            [self _postNetworkErrorMessage];
        }
        
    } else if (self.playerItem.isPlaybackLikelyToKeepUp && !_videoPaused && !_playerFinish) {
        SlikeDLog(@"PLAYER BUFFER: playbackLikelyToKeepUp");
        if (@available(iOS 10.0, *)) {
            if (self.player.timeControlStatus && self.player.timeControlStatus != AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate){
                [self stopBuffering];
            }
        } else {
            [self stopBuffering];
        }
    }
    else if (self.playerItem.isPlaybackBufferFull) {
        [self stopBuffering];
        
        SlikeDLog(@"PLAYER BUFFER: PlaybackBufferFull");
    }
}

- (void)updateVideoTimeLabel:(CMTime)time {
    
    NSUInteger currentSeconds = (NSUInteger) CMTimeGetSeconds(time);
    _playerDuration = currentSeconds;
    self.nCurrentTime = currentSeconds;
    
    BOOL isNetworkReachible = [[SlikeNetworkMonitor sharedSlikeNetworkMonitor]isNetworkReachible];
    
    if (@available(iOS 10.0, *)) {
        if (!_playerFinish && !_videoPaused && isNetworkReachible) {
            if (self.player.timeControlStatus && self.player.timeControlStatus == AVPlayerTimeControlStatusWaitingToPlayAtSpecifiedRate) {
                [self startBuffering];
            } else if (self.player.timeControlStatus && self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
                [self stopBuffering];
            }
        }
    }
    
    //Get the Current Bitrates. We will use this value for the Analytics
    if(self.player.currentItem.accessLog) {
        AVPlayerItemAccessLogEvent *evt = (AVPlayerItemAccessLogEvent *)[self.player.currentItem.accessLog.events lastObject];
        if(evt.indicatedBitrate) {
            [[SlikeDeviceSettings sharedSettings] setMeasuredBitrate:evt.indicatedBitrate];
        }
    }
    
    if(!isNetworkReachible && (self.playerItem.isPlaybackBufferEmpty && !self.playerItem.isPlaybackLikelyToKeepUp) && !_videoPaused && !_playerFinish) {
        [self _postNetworkErrorMessage];
    }
    
    if(!_playerFinish && !_isSeeking) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateTimeUpdateNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:currentSeconds], @"data", nil]];
    }
}

- (void)_postNetworkErrorMessage {
    [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStatePlaybackErrorNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSError errorWithDomain:SlikeServiceErrorDomain code:SlikeServiceErrorNoNetworkAvailable userInfo:@{NSLocalizedDescriptionKey:@"Internet not available."}], @"data", nil]];
}


/// Calculate buffer progress
- (NSTimeInterval)availablePlayableDuration {
    
    NSArray *timeRangeArray = _playerItem.loadedTimeRanges;
    CMTime currentTime = self.player.currentTime;
    BOOL foundRange = NO;
    CMTimeRange aTimeRange = {0};
    if (timeRangeArray.count) {
        aTimeRange = [[timeRangeArray objectAtIndex:0] CMTimeRangeValue];
        if (CMTimeRangeContainsTime(aTimeRange, currentTime)) {
            foundRange = YES;
        }
    }
    
    if (foundRange) {
        CMTime maxTime = CMTimeRangeGetEnd(aTimeRange);
        NSTimeInterval playableDuration = CMTimeGetSeconds(maxTime);
        if (playableDuration > 0) {
            return playableDuration;
        }
    }
    return 0;
}
- (void)playImmediatelyIfPossible {
    if ([self respondsToSelector:@selector(playImmediatelyAtRate:)]) {
        if (@available(iOS 10.0, *)) {
            [self.player playImmediatelyAtRate:1.f];
        }
    }
    else {
        [self play];
    }
}

- (void)startBuffering {
    
    if (!_bufferingStarted) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateBufferingNotification object:nil userInfo:nil];
        SlikeDLog(@"PLAYER BUFFER: buffering Started...");
        _bufferingStarted = YES;
    }
}

- (void)stopBuffering {
    if (_bufferingStarted) {
        _bufferingStarted = NO;
        SlikeDLog(@"PLAYER BUFFER: buffering Stoped...");
        [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateBufferingEndedNotification object:nil userInfo:nil];
    }
}


- (NSNumber*)numberWithCGFloat: (CGFloat)value {
#if CGFLOAT_IS_DOUBLE
    return [NSNumber numberWithDouble: (double)value];
#else
    return [NSNumber numberWithFloat: value];
#endif
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if(self.isPlayerDestroyed) {
        return;
    }
    
    if([object isKindOfClass:[AVPlayer class]]) {
        
        AVPlayer *p = (AVPlayer *)object;
        if ([keyPath isEqualToString:kSlikePlayerErrorKey] && object == self.player) {
            SlikeDLog(@"PLAYER: Player error: %@", p.error);
            [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStatePlaybackErrorNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:p.error, @"data", nil]];
        }
        if (p.status == AVPlayerStatusReadyToPlay) {
            SlikeDLog(@"AVPlayerStatusReadyToPlay");
        }
        
        
    } else if([object isKindOfClass:[AVPlayerItem class]]) {
        
        AVPlayerItem* pi = (AVPlayerItem*)object;
        if ([keyPath isEqualToString:kSlikePlayerErrorKey] && pi == self.playerItem) {
            SlikeDLog(@"PLAYER: PlayerItem error: %@", pi.error);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStatePlaybackErrorNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:pi.error, @"data", nil]];
            
        }
        else if ([keyPath isEqualToString:kSlikePlaybackBufferEmpty]) {
            if (self.playerItem.playbackBufferEmpty) {
                [self updatePlayerPlayingStatus];
                
            }
        } else if ([keyPath isEqualToString:kSlikePlaybackLikelyToKeepUp]) {
            if (self.playerItem.playbackLikelyToKeepUp){
                [self updatePlayerPlayingStatus];
                
            }
            
        } else if ([keyPath isEqualToString:kSlikePlayerLoadedTimeRangesKey]) {
            
            NSTimeInterval timeInterval = [self availableDuration];
            float progress = timeInterval*1000 + 3000;
            
            //Post the Notification for the  player duration update
            [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerLoadedTimeRangesNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[self numberWithCGFloat:progress], @"loadTime", nil]];
            
        } else if ([keyPath isEqualToString:kSlikePlayerStatusKey]) {
            
            SlikeDLog(@"PLAYER: PlayerItem status: %d", (int)pi.status);
            if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStatePlaybackErrorNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.player.currentItem.error, @"data", nil]];
                
            }
            else if (!_isPlaybackReady && pi.status == AVPlayerItemStatusReadyToPlay && self.player) {
                
                [SlikeDeviceSettings sharedSettings].nVideoLoadTime = [dtVideoLoadTime timeIntervalSinceNow] * -1000.0f;
                
                _isPlaybackReady = YES;
                _playerFinish =  NO;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateDurationUpdateNotification object:[NSNumber numberWithLongLong:(long long)self.playerItem.asset.duration.value]];
                
                SlikeDLog(@"PLAYER: Content is ready for playback...");
                [self stopTimer];
                
                if(_nTimeCodeToPlay > 0) {
                    
                    _isSeeking = YES;
                    [self.player seekToTime:CMTimeMakeWithSeconds(_nTimeCodeToPlay / 1000, 1) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished)
                     {
                         self.isSeeking = NO;
                         [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateSeekUpdateNotification object:nil];
                         self.nTimeCodeToPlay=0;
                     }];
                    
                } else
                {
                    [self.player pause];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateReadyNotification object:nil];
                }
            }
        }
    }
}

- (NSTimeInterval)availableDuration {
    //Calculate buffer progress
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;
    return result;
}


- (void)resetPlayerForNextPlay {
    _isPlaybackReady = NO;
}

- (void)actionAfterReady {
    SlikeDLog(@"PLAYER: ...actionAfterReady...");
    [self addPlayerObservers];
    if(!_isPlayerAlreadyStarted) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateStartNotification object:nil];
        _isPlayerAlreadyStarted = YES;
    }
}

/**
 Start the Media
 
 @param isFirst -
 */
- (void)startPlayingVideo:(BOOL)isFirst {
    
    if(self.player.rate != 0.0) return;
    [self.player play];
    [self startTimer];
    [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStatePlayNotification object:nil];
}


/**
 Add the Player Observers
 */
- (void)addPlayerObservers {
    
    if(_isPlayerDestroyed) return;
    if(self.playerItem && !_isObservers) {
        
        SlikeDLog(@"PLAYER: ...Setting observers...");
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        
        [self.player addObserver:self forKeyPath:kSlikePlayerErrorKey options:0 context:nil];
        [self.playerItem addObserver:self forKeyPath:kSlikePlayerStatusKey options:NSKeyValueObservingOptionNew context:nil];
        [self.playerItem addObserver:self forKeyPath:kSlikePlayerErrorKey options:0 context:nil];
        [self.playerItem addObserver:self forKeyPath:kSlikePlayerLoadedTimeRangesKey options:NSKeyValueObservingOptionNew context:nil];
        [self.playerItem addObserver:self forKeyPath:kSlikePlaybackBufferEmpty options:NSKeyValueObservingOptionNew context:nil];
        [self.playerItem addObserver:self forKeyPath:kSlikePlaybackLikelyToKeepUp options:NSKeyValueObservingOptionNew context:nil];

        _isObservers = YES;
        [self startTimer];
    }
}

/**
 Remove the Player's Observers
 */
- (void)removePlayerObservers {
    
    if(self.playerItem && _isObservers) {
        
        SlikeDLog(@"PLAYER: ...Unsetting observers...");
        @try {
            [self.player removeObserver:self forKeyPath:kSlikePlayerErrorKey];
            [self.playerItem removeObserver:self forKeyPath:kSlikePlayerStatusKey];
            [self.playerItem removeObserver:self forKeyPath:kSlikePlayerErrorKey];
            [self.playerItem removeObserver:self forKeyPath:kSlikePlayerLoadedTimeRangesKey];
            [self.playerItem removeObserver:self forKeyPath:kSlikePlaybackBufferEmpty];
            [self.playerItem removeObserver:self forKeyPath:kSlikePlaybackLikelyToKeepUp];
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
        @catch (NSException *exception) {
            SlikeDLog(@"PLAYER: Exception - removePlayerObservers (%@)", exception);
        }
        @finally {
            _isObservers = NO;
        }
        [self stopTimer];
    }
    
}

/**
 Update the player's Bitrate
 */
- (void)updateBitrate {
    
    NSString *str = [[SlikeDeviceSettings sharedSettings] savedMediaBitrate];
    if([str isEqualToString:@"none"]) {
        self.player.currentItem.preferredPeakBitRate = 0.0f;
    } else {
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSNumber *myNumber = [f numberFromString:str];
        if(![myNumber boolValue]) {
            self.player.currentItem.preferredPeakBitRate = 0.0f;
        } else {
            self.player.currentItem.preferredPeakBitRate = [myNumber floatValue];
            
        }
    }
}

/**
 Seek the Player to spacifc time
 @param time - Seek Time
 @param isFastSeek - Is fast seek required
 */
- (void)seekPlayerToTime:(CMTime)time fastSeek:(BOOL) isFastSeek  completionBlock:(void (^ __nullable)(BOOL finished))completionHandler {
    
    //[_player seekToTime:seekTime toleranceBefore:CMTimeMake(1,1) toleranceAfter:CMTimeMake(1,1) completionHandler:completionHandler];
    if(self.isPlayerDestroyed) return;
    
    if (self.player) {
        
        [self.player.currentItem cancelPendingSeeks];
        SlikeDLog(@"PLAYER: Waiting for content to be ready for playback.  When it is ready, press play to begin.\nSeeking to %f", CMTimeGetSeconds(time));
        
        if ([self.player respondsToSelector:@selector(seekToTime:toleranceBefore:toleranceAfter:completionHandler:)]) {
            
            SlikeDLog(@"PLAYER: seek started");
            [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateSeekStartNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:CMTimeGetSeconds(self.player.currentTime)], @"data", nil]];
            
            self.isSeeking = YES;
            [self.player seekToTime:time toleranceBefore:isFastSeek ? kCMTimePositiveInfinity : kCMTimeZero toleranceAfter:isFastSeek ? kCMTimePositiveInfinity : kCMTimeZero completionHandler:^(BOOL finished) {
                
                SlikeDLog(@"PLAYER: seek %s", ((finished) ? "completed" : "incomplete"));
                self.isSeeking = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:finished ?SlikePlayerPlaybackStateSeekEndNotification :SlikePlayerPlaybackStateSeekFailedNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:CMTimeGetSeconds(self.player.currentTime)], @"data", nil]];
                
                self.nCurrentTime = CMTimeGetSeconds(self.player.currentTime);
                if (completionHandler){
                    completionHandler(finished);
                }
                
            }];
            
        } else {
            
            SlikeDLog(@"PLAYER: seek started without handler...");
            
            [self.player seekToTime:time toleranceBefore:kCMTimePositiveInfinity toleranceAfter:kCMTimePositiveInfinity];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateSeekEndNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithUnsignedInteger:CMTimeGetSeconds(self.player.currentTime)], @"data", nil]];
            
            if (completionHandler) {
                completionHandler(YES);
            }
        }
    }
    else {
        if (completionHandler) {
            completionHandler(YES);
        }
        SlikeDLog(@"PLAYER: seek DISABLED: please load a video first!");
    }
}

- (void)playerMute:(BOOL)isMute {
    if(self.player) {
        self.player.muted = isMute;
    }
}

- (BOOL)getPlayerMuteStatus {
    if(self.player) {
        return self.player.isMuted;
    }
    return NO;
}

- (void)play {
    if(self.player) {
        _playerFinish =  NO;
        [self startTimer];
        SlikeDLog(@"PLAYER: Trying to play (rate: %f)", self.player.rate);
        if(self.player.rate == 0.0) {
            _videoPaused =  NO;
            [self.player play];
            [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStatePlayNotification object:nil];
        }
    }
}

- (void)pause {
    if(self.player) {
        
        [self stopTimer];
        SlikeDLog(@"PLAYER: Trying to pause (rate: %f)", self.player.rate);
        if(self.player.rate != 0.0){
            [self.player pause];
            [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStatePauseNotification object:nil];
            _videoPaused =  YES;
            self.nCurrentTime = CMTimeGetSeconds(self.player.currentTime);
        }
    }
}

- (BOOL)isPlaying {
    if(!self.player) return NO;
    return (self.player.rate != 0.0);
}

- (BOOL)isPlayerExist {
    return (self.player != nil);
}

/*
 Play the GIF Video .. No need to  for time update and also run in infinite loop
 */
- (void)playMp4Video:(NSString*)urlString {
    self.isVideoTypeGif =  YES;
    [self queueUpContentIntoPlayer:[NSURL URLWithString:urlString]];
}
/**
 Current Playback URI
 @return - Current URI
 */

- (NSString *)currentPlaybackItemURI {
    if(!self.player) return @"";
    if(!self.player.currentItem) return @"";
    NSString * currentURI = @"";
    AVPlayerItemAccessLog *accessLog = self.player.currentItem.accessLog;
    if(accessLog !=nil && [accessLog.events count]>0) {
        AVPlayerItemAccessLogEvent *evt = [accessLog.events lastObject];
        if(evt && evt.URI != nil) {
            currentURI = [NSString stringWithFormat:@"%@",evt.URI];
        }
        evt = nil;
    }
    return currentURI;
}

/**
 Get the player position
 @return - position
 */
- (NSUInteger)getPlayerPosition {
    
    if(!self.player || !self.player.currentItem) {
        return 0;
    }
    
    CGFloat currentTime = CMTimeGetSeconds(self.player.currentItem.currentTime);
    if(currentTime == 0)
        currentTime = self.nCurrentTime;
    
    return currentTime * 1000;
}
/**
 Get the player duration
 @return - Duration
 */
- (NSUInteger)getPlayerDuration {
    if(!self.player || !self.player.currentItem)
        return 0;
    return CMTimeGetSeconds(self.player.currentItem.duration) * 1000;
}

/**
 Restart the media Stream.
 @param start - Value at which media will be started
 @param completionHandler - Completion handler
 */
- (void)restart:(NSInteger)start completionBlock:(void (^ __nullable)(BOOL finished))completionHandler {
    
    _playerFinish =  NO;
    _nTimeCodeToPlay = start;
    _videoPaused =  NO;
    
    if(self.player) {
        [self stopTimer];
        [self startTimer];
        [self seekPlayerToTime:CMTimeMakeWithSeconds(_nTimeCodeToPlay, NSEC_PER_SEC) fastSeek:YES completionBlock:^(BOOL finished) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStatePlayNotification object:nil];
            if (completionHandler) {
                completionHandler(finished);
            }
        }];
    }
}

- (void)cleanupAVPlayerResources {
    
    if(self.isPlayerDestroyed) return;
    self.isPlayerDestroyed = YES;
    if([self isPlayerExist]) {
        [self stopVideo:YES];
    }
    [self removePlayerObservers];
    [self stopTimer];
    self.playerItem = nil;
    [self setPlayer:nil];
    self.player = nil;
    if(self) [self removeFromSuperview];
}

- (void)stopVideo:(BOOL)cleanVideo {
    
    if(self.player) {
        [self stopTimer];
        [self removePlayerObservers];
        if(cleanVideo) {
            SlikeDLog(@"PLAYER: Stop playback and destroy the current player instance.");
            [[NSNotificationCenter defaultCenter] postNotificationName:SlikePlayerPlaybackStateStopNotification object:nil];
            [self setPlayer:nil];
            self.player = nil;
        }
    } else {
        SlikeDLog(@"PLAYER: stop DISABLED: please load a video first!");
    }
}

- (void)resetAvPlayer {
    
    if(self.player) {
        
        [self stopTimer];
        [self removePlayerObservers];
        [[NSNotificationCenter defaultCenter]postNotificationName:SlikePlayerPlaybackStateStopNotification object:nil];
        self.playerItem = nil;
        self.player = nil;
        self.isPlayerDestroyed = NO;
        _isPlayerAlreadyStarted = NO;
        _nCurrentTime = 0;
        _nStartTime = 0;
        _nTimeCodeToPlay= 0;
        _playerFinish = NO;
        _videoPaused = NO;
        _isPlaybackReady = NO;
        _bufferingStarted =NO;
        _playerDuration =0;
        _isSeeking = NO;
    }
}

- (void)dealloc {
    SlikeDLog(@"dealloc- Cleaning up AVPlayer");
}

/*
 - (void)playerHanging {
    SlikeDLog(@"PLAYER BUFFER: playerHanging");
    BOOL isNetworkReachible = [[SlikeNetworkMonitor sharedSlikeNetworkMonitor]isNetworkReachible];
    if (self.player.rate == 0 && !_handlingStalling && _nCurrentTime >=1
        && !_videoPaused && isNetworkReachible && !_playerFinish ) {
        
        _handlingStalling = YES;
        [self handleStalled];
    }
}

- (void)handleStalled {
    
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleStalled) object:nil];
    if ([self isPlaying]) {
        _handlingStalling = NO;
        return;
    }
    
    NSInteger minBufferTime = 2;
    NSInteger plableDuration = [self availablePlayableDuration];
    if (plableDuration == 0) {
        plableDuration = [self availableDuration];
    }
    
    if (plableDuration == 0 && !self.player.currentItem.isPlaybackBufferEmpty) {
        plableDuration = minBufferTime+1;
    }
    
    if (self.player.currentItem.isPlaybackLikelyToKeepUp &&
        plableDuration > minBufferTime) {
        _handlingStalling = NO;
        NSLog(@"STALLED: PLAY");
        
        BOOL isNetworkReachible = [[SlikeNetworkMonitor sharedSlikeNetworkMonitor]isNetworkReachible];
        if (isNetworkReachible && !_videoPaused) {
            [self.player play];
        }
        
        [self stopBuffering];
        [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(handleStalled) object:nil];
        return;
        
    } else {
        [self startBuffering];
    }
    
    [self performSelector:@selector(handleStalled) withObject:nil afterDelay:0.5];
}*/

@end
