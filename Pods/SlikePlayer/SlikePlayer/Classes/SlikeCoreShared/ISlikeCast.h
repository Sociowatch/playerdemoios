//
//  ISlikeCast.h
//  Pods
//
//  Created by Aravind kumar on 9/6/17.
//
//

#import <Foundation/Foundation.h>

@protocol ISlikePlayer;
//@class SlikeConfig;

@protocol ISlikeCast

//@property (nonatomic, strong) SlikeConfig *slikeConfig;

/**
 To init the cast

 @param strID cast Id
 */
- (void)initCastWithKey:(NSString *) strID;

/**
 Set the cast button

 @param btn cast btn object pass by control
 */
- (void)setCastButton:(id) btn;

/**
// Swich cast view to player mode
 @param isPlayerMode - Pass YES to switch cast to player
 */
-(void)swichPlayerToCast:(BOOL)isPlayerMode;

/**
 To Set cast button

 @param root UIViewController to set cast UI
 @param btn Cast button
 */
- (void)startWithRootController:(UIViewController *) root withCastButton:(id) btn;

/**
 Load cast media information

 @param si Stream info
 @param theFrame Cast UI Frame
 @param myView View where the cast UI is appered
 */
-(void) loadMediaWithInfo:(StreamingInfo *) si withRect:(CGRect) theFrame inView:(UIView *) myView;

/**
 Update cast media information

 @param si Stream info
 @param theFrame Cast UI Frame
 @param myView View where the cast UI is appered
 */
-(void) updateMediaWithInfo:(StreamingInfo *) si withRect:(CGRect) theFrame inView:(UIView *) myView;

/**
 Disconnect Cast
 */
-(void) disconnectDevice;

/**
 To Get device is connected with

 @return YES if deivce is conneted
 */
-(BOOL) isDeviceConnected;

/**
 Play cast video
 */
-(void) playVideo;

/**
 Pause cast video
 */
-(void) pauseVideo;

/**
 Get cast is playing

 @return YES if cast is playing otherwise NO
 */
-(BOOL) isPlaying;

/**
 Seek to duration

 @param nTime duration to particular duration
 */
-(void) seekDeviceToTime:(NSInteger) nTime;

/**
 toggleVideo
 */
-(void) toggleVideo;

/**
 Stop cast to play
 */
-(void) stopVideo;

/**
 To Start scan to search device

 @param start YES to start scan and NO to Stop
 */
-(void) startStopScanning:(BOOL) start;

/**
 Clear all memory and stop player
 */
-(void) cleanUpAndStop;

/**
 To Get the Device is connected

 @return YES if device is connected
 */
-(BOOL) isConnected;

/**
 To Show cast UI(Button)

 @param on YES to Visible otherwise No
 */
-(void) showCastOn:(BOOL) on;

/**
 To Set host player ie SlikePlayer

 @param hostPlayer ISlikePlayer obj
 */
-(void) setHostPlayer:(id<ISlikePlayer>) hostPlayer;

/**
 To Set player configartion

 @param cnfg SlikeConfig
 */
-(void) setPlayerConfigaration:(SlikeConfig*)cnfg;
/**
 // Swich cast view to player mode
 @param isPlayerMode - Pass YES to switch cast to player
 */
-(void)switchPlayerCastMode:(BOOL)isPlayerMode;

/**
 To Update the current player time

 @param nTime Player time
 */
-(void) updateCurrentTime:(float) nTime;

/**
 To Show all devices
 */
-(void)showCastList;
/**
 To connect a particular device

 @param btn Cast Button
 */
-(void)connectToPlayingDevice:(id) btn;
@end
