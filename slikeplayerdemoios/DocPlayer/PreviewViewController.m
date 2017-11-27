//
//  ViewController.m
//  DocplayerDemo
//
//  Created by Aravind kumar on 11/3/17.
//  Copyright © 2017 Aravind kumar. All rights reserved.
//

#import "PreviewViewController.h"
#import "SecondViewController.h"

@interface PreviewViewController ()
{
    //local Frame store
    CGRect youtubeFrame;
    CGRect tblFrame;
    CGRect menuFrame;
    CGRect viewFrame;
    CGRect minimizedYouTubeFrame;
    CGRect growingTextViewFrame;;
    
    //local touch location
    CGFloat _touchPositionInHeaderY;
    CGFloat _touchPositionInHeaderX;
    
    //local restriction Offset--- for checking out of bound
    float restrictOffset,restrictTrueOffset,restictYaxis;
    
    //detecting Pan gesture Direction
    UIPanGestureRecognizerDirection direction;
    
    
    //Creating a transparent Black layer view
    UIView *transaparentVw;
    
    //Just to Check wether view  is expanded or not
    BOOL isExpandedMode;
    float currentViewAlpha;
    float oldHeight;
    UIInterfaceOrientation  lastOrientation;
    
}
@end

@implementation PreviewViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    currentViewAlpha =  1.0;
    isExpandedMode =  YES;
//    isArticalPlayer =  YES;
    // Do any additional setup after loading the view, typically from a nib.
    self.viewHeaderPlayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.viewHeaderPlayer.frame.size.height);

    [self loadPlayer];
    
    
    youtubeFrame =  self.viewHeaderPlayer.bounds;
    self.smallGestureView.backgroundColor = [UIColor clearColor];

       [self addGestureOnView];
    oldHeight =  self.view.frame.size.height;
    lastOrientation = UIInterfaceOrientationPortrait;
   
  
}
-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];

}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}
- (void)orientationChanged:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];

}
- (void) adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
         
//            if( [[[SlikePlayer getInstance] getAnyPlayer] isFullScreen])
//            {
//                [[[SlikePlayer getInstance] getAnyPlayer] toggleFullScreen];
//
//            }
           if(lastOrientation == orientation)
           {
               
           }else if(lastOrientation == orientation)
           {
               
           }else
           {
//               if(!isArticalPlayer)
               [self backToPortate];
//               else
//                   [self minimizeViewOnPan];
           }
          
            
        }
            
            break;
        case UIInterfaceOrientationLandscapeLeft:
        {
            //load the landscape view
            if( [[[SlikePlayer getInstance] getAnyPlayer] isFullScreen])
            {

                
            }else
            {
                [[[SlikePlayer getInstance] getAnyPlayer] toggleFullScreen];
            }
        }
            break;

        case UIInterfaceOrientationLandscapeRight:
        {
            //load the landscape view
        if( [[[SlikePlayer getInstance] getAnyPlayer] isFullScreen])
        {

            
        }else
        {
            [[[SlikePlayer getInstance] getAnyPlayer] toggleFullScreen];
        }
        }
            break;
        case UIInterfaceOrientationUnknown:break;
    }
    lastOrientation = orientation;
}

-(void)addGestureOnView
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self.smallGestureView addGestureRecognizer:tapRecognizer];
    
    //adding Pan Gesture
    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPlayerAction:)];
    pan.delegate=self;
    [self.smallGestureView addGestureRecognizer:pan];
    
    
    
    UISwipeGestureRecognizer * swipeleft=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeleft:)];
    swipeleft.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.smallGestureView addGestureRecognizer:swipeleft];
    
    UISwipeGestureRecognizer * swiperight=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swiperight:)];
    swiperight.direction=UISwipeGestureRecognizerDirectionRight;
    [self.smallGestureView addGestureRecognizer:swiperight];
    
    //adding Pan Gesture
    UIPanGestureRecognizer *panPlayer=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPlayerAction:)];
    panPlayer.delegate=self;
    [self.viewHeaderPlayer addGestureRecognizer:panPlayer];
    
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)loadPlayer
{
    /*
    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"NBT Khabar express 26 09 2016 new" withID:@"1x1ch55glk" withSection:@"videos.entertainment" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    //    SlikeConfig *slikeConfig = [[SlikeConfig alloc] initWithTitle:@"NBT Khabar express 26 09 2016 new" withID:@"1_oprrpt0x" withSection:@"videos.news" withMSId:@"56087249" posterImage:@"http://slike.indiatimes.com/thumbs/1x/11/1x115ai9g6/thumb.jpg"];
    
    slikeConfig.ssoid = @"7ccgp8cpng4vcw9rg2tqvlkqc";
    slikeConfig.channel = @"toi";
    slikeConfig.isCloseControl = NO;
    slikeConfig.isSkipAds =  YES;
    slikeConfig.isAutoPlay = YES;
    slikeConfig.isFullscreenControl  = YES;
    slikeConfig.isShareControl =  YES;
    slikeConfig.isFullscreenControl =  YES;
    
    //
    [slikeConfig setLatitudeLongitude:@"26.539345" Longitude:@"80.487820"];
    [slikeConfig setCountry_State_City:@"IN" State:@"UP" City:@"Unnao"];
    [slikeConfig setUserInformation:@"Male" Age:28];
    //
    
    slikeConfig.pid = @"102";
    slikeConfig.shareText =  @"";
   slikeConfig.shareText =  @"Share Text here";
   
    */
    [[SlikePlayer getInstance] playVideo:self.playerConfig inParent:self.viewHeaderPlayer withAds:nil withProgressHandler:^(SlikeEventType type, SlikePlayerState name, StatusInfo *statusInfo) {
        
//        NSLog(@"SlikeEventType %ld", (long)type);
//         NSLog(@"SlikePlayerState %ld", name);
        if( [[[SlikePlayer getInstance] getAnyPlayer] getControl] && self.playerConfig.isDocEnable && self.isArticalShow)
        {
            [[[[SlikePlayer getInstance] getAnyPlayer] getControl] updateDocBtn:NO];
        }
        if(statusInfo != nil)
        {
            
          //  NSLog(@"%@", [statusInfo getString]);
        }
        

        if(type == MEDIA && name == ERROR)
        {
//            NSLog(@"%@", [statusInfo getString]);

           // NSLog(@"Error while playing media: %@", statusInfo.error);
            
        }
        if(type == CONTROLS)
        {
            if(name == DOCTAP)
            {
                [self minimizeViewOnPan];
                return ;
            }
        }
        if(type == MEDIA)
        {
              if( name == FSENTER)
              {
                  NSLog(@"%@", @"FSENTER");
                  [self expandViewOnPan];

              }
              else  if( name == FSEXIT)
            {
                NSLog(@"%@", @"FSEXIT");
                NSLog(@"%d",self.isArticalShow);
//                if(!isArticalPlayer)
                [self expandViewOnPan];
//                else
//                    [self minimizeViewOnPan];


            }
        }
        
        if(type == MEDIA)
        {
        if( name == COMPLETED || name == ENDED || name ==  REPLAY || name == BUFFERING)
        {
           if(!isExpandedMode) [[[SlikePlayer getInstance] getAnyPlayer].getControl hide];

        }
        
        }
    }];

}

#pragma mark- Pan Gesture Selector Action
-(void)detectPanDirection:(CGPoint )velocity
{
    BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
    
    if (isVerticalGesture) {
        if (velocity.y > 0) {
            direction = UIPanGestureRecognizerDirectionDown;
            
        } else {
            direction = UIPanGestureRecognizerDirectionUp;
        }
    }
    else
    
    {
        if(velocity.x > 0)
        {
            direction = UIPanGestureRecognizerDirectionRight;
        }
        else
        {
            direction = UIPanGestureRecognizerDirectionLeft;
        }
        
    }
    
}

-(void)panPlayerAction:(UIPanGestureRecognizer *)recognizer
{
    if(!self.isArticalShow)
    {
    [[[SlikePlayer getInstance] getAnyPlayer].getControl hide];

    UIWindow *window =  [UIApplication sharedApplication].keyWindow;
    
    CGFloat y = [recognizer locationInView:window].y;
    
    if(recognizer.state == UIGestureRecognizerStateBegan){
        
        direction = UIPanGestureRecognizerDirectionUndefined;
        //storing direction
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        [self detectPanDirection:velocity];
        
        //Snag the Y position of the touch when panning begins
        _touchPositionInHeaderY = [recognizer locationInView:self.view].y;
        _touchPositionInHeaderX = [recognizer locationInView:self.view].x;
      
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged){
        
        
        if(direction==UIPanGestureRecognizerDirectionDown || direction==UIPanGestureRecognizerDirectionUp)
        {
            
            CGFloat trueOffset = y - _touchPositionInHeaderY;
            CGFloat xOffset = (y - _touchPositionInHeaderY)*0.35;
            [self adjustViewOnVerticalPan:trueOffset :xOffset recognizer:recognizer];
            
        }
        else if (direction==UIPanGestureRecognizerDirectionRight || direction==UIPanGestureRecognizerDirectionLeft)
        {
           if(!isExpandedMode) [self adjustViewOnHorizontalPan:recognizer];
        }
        
       
    }
    else if(recognizer.state == UIGestureRecognizerStateEnded){
       
        NSLog(@"======>  %f",self.view.frame.origin.y);
        
        if(direction==UIPanGestureRecognizerDirectionDown || direction==UIPanGestureRecognizerDirectionUp)
        {
            
            if(self.view.frame.origin.y<0)
            {
                [self expandViewOnPan];
                
//                [recognizer setTranslation:CGPointZero inView:recognizer.view];
                
                return;
                
            }
            else if(self.view.frame.origin.y>=([UIApplication sharedApplication].keyWindow.frame.size.height/2))
            {
                
                [self minimizeViewOnPan];
                //[recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
                
                
            }
            else if(self.view.frame.origin.y<([UIApplication sharedApplication].keyWindow.frame.size.height/2))
            {
                [self expandViewOnPan];
               // [recognizer setTranslation:CGPointZero inView:recognizer.view];
                return;
                
            }
        }
        else if (direction==UIPanGestureRecognizerDirectionLeft)
        {
            if(self.view.alpha<=1)
            {
                if(self.view.frame.origin.x<-50)
                {
                    [self removeView];
                }
                else
                {
                    [self animateViewToRight:recognizer];
                }
            }
        }
        else if (direction==UIPanGestureRecognizerDirectionRight)
        {
            if(self.view.frame.origin.x +50 > [UIApplication sharedApplication].keyWindow.frame.size.width)
            {
                [self removeView];
            }
            else
            {
                [self animateViewToRight:recognizer];
            }
        }
    }
    }
}

-(void)adjustViewOnHorizontalPan:(UIPanGestureRecognizer *)recognizer {
    //CGFloat x = [recognizer locationInView:self.view].x;
    
    if (direction==UIPanGestureRecognizerDirectionLeft)
    {
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            
            BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
        
            CGPoint translation = [recognizer translationInView:recognizer.view];
            
            self.view.center = CGPointMake(self.view.center.x + translation.x,
                                                 self.view.center.y );
            
            if (!isVerticalGesture) {
                
                CGPoint originGlobal = [self.view.superview convertPoint:self.view.frame.origin
                                                               toView:[UIApplication sharedApplication].keyWindow];
                
                CGFloat percentage =  (originGlobal.x+self.view.frame.size.width-100)/[UIApplication sharedApplication].keyWindow.frame.size.width;
                if(percentage>1.0)
                {
                    percentage =  1.0;
                }
                 self.view.alpha = percentage;
                currentViewAlpha =  percentage;
            }
            
            [recognizer setTranslation:CGPointZero inView:self.view];
      
    }
    else if (direction==UIPanGestureRecognizerDirectionRight)
    {
        
        CGPoint velocity = [recognizer velocityInView:recognizer.view];
        
        BOOL isVerticalGesture = fabs(velocity.y) > fabs(velocity.x);
        
        CGPoint translation = [recognizer translationInView:recognizer.view];
        
        self.view.center = CGPointMake(self.view.center.x + translation.x,
                                       self.view.center.y );
        
        if (!isVerticalGesture) {
            
            CGPoint originGlobal = [self.view.superview convertPoint:self.view.frame.origin
                                                              toView:[UIApplication sharedApplication].keyWindow];
            float v1 = [UIApplication sharedApplication].keyWindow.frame.size.width;
            float v2 = originGlobal.x*2+self.view.frame.size.width;
            float percentage =  v1/v2;
            
            self.view.alpha = percentage;
            currentViewAlpha =  percentage;
            
        }
        
        [recognizer setTranslation:CGPointZero inView:self.view];
        
    }
    
}

-(void)adjustViewOnVerticalPan:(CGFloat)trueOffset :(CGFloat)xOffset recognizer:(UIPanGestureRecognizer *)recognizer
{
        NSLog(@" trueOffset %f",[UIApplication sharedApplication].keyWindow.frame.size.height-trueOffset);
if([UIApplication sharedApplication].keyWindow.frame.size.height-trueOffset > 130)
{
    float ratio = self.view.frame.size.height/ oldHeight;

//    NSLog(@" ratio1 %f",oldHeight);
//    NSLog(@" ratio2 %f",self.view.frame.size.height);
//    NSLog(@" ratio3 %f",ratio);
//    NSLog(@" ratio4 %f",youtubeFrame.size.height*ratio);

    self.view.frame =  CGRectMake(xOffset, trueOffset, [UIApplication sharedApplication].keyWindow.frame.size.width-xOffset, [UIApplication sharedApplication].keyWindow.frame.size.height-trueOffset);
   
if(youtubeFrame.size.height*ratio > 90)
{
    self.viewHeaderPlayer.frame =  CGRectMake(0, 0, self.view.frame.size.width,youtubeFrame.size.height*ratio);
}else
{
    self.viewHeaderPlayer.frame =  CGRectMake(0, 0, self.view.frame.size.width,90);

}
    self.tbView.frame =  CGRectMake(0, self.viewHeaderPlayer.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    self.tbView.alpha =  ratio;
//    NSLog(@" ratio*3 %f",ratio*0.85);

//    oldHeight =  self.view.frame.size.height;
}
}
-(void)minimizeViewOnPan
{
    //self.btnDown.hidden=TRUE;
    // self.viewHeaderPlayer.autoresizesSubviews  = NO;
//    isArticalPlayer =  YES;
    if(self.isArticalShow)
    {
        self.isArticalShow =  NO;
        UIWindow *window =     [UIApplication sharedApplication].keyWindow;

        [window addSubview:self.view];

        [[[SlikePlayer getInstance] getAnyPlayer].getControl hide];
        
        viewFrame =  CGRectMake([UIApplication sharedApplication].keyWindow.frame.size.width-160-5, [UIApplication sharedApplication].keyWindow.frame.size.height-90-5, 160, 90);
        self.view.frame=viewFrame;

        isExpandedMode =  NO;
                             self.viewHeaderPlayer.frame=self.view.bounds;
                             [[[[SlikePlayer getInstance] getAnyPlayer] getControl] hide];
                             self.smallGestureView.frame = self.viewHeaderPlayer.frame;
                             [self.viewHeaderPlayer addSubview:self.smallGestureView];
                             self.tbView.alpha =  1.0;
                             
        
    }else
    {
    [[[SlikePlayer getInstance] getAnyPlayer].getControl hide];
    viewFrame =  CGRectMake([UIApplication sharedApplication].keyWindow.frame.size.width-160-5, [UIApplication sharedApplication].keyWindow.frame.size.height-90-5, 160, 90);
    
    isExpandedMode =  NO;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.view.frame=viewFrame;
                         self.viewHeaderPlayer.frame=self.view.bounds;
                         self.tbView.alpha =  0.0;
                         
                     }
                     completion:^(BOOL finished) {
                         self.viewHeaderPlayer.frame=self.view.bounds;
                         [[[[SlikePlayer getInstance] getAnyPlayer] getControl] hide];
                         self.smallGestureView.frame = self.viewHeaderPlayer.frame;
                         [self.viewHeaderPlayer addSubview:self.smallGestureView];
                         self.tbView.alpha =  0.0;
                         
                     }];
    }
    
}

-(void)expandViewOnPan
{
    isExpandedMode =  YES;
    UIWindow *window =     [UIApplication sharedApplication].keyWindow;
    
    [self.smallGestureView removeFromSuperview];
    //    self.view.transform=CGAffineTransformMakeScale(0.2, 0.2);
    
    [UIView animateWithDuration:0.3f animations:^{
        //        self.view.transform=CGAffineTransformMakeScale(1.0, 1.0);
        //        self.view.alpha=1;
        self.view.frame=CGRectMake(window.frame.origin.x, window.frame.origin.y, window.frame.size.width, window.frame.size.height);
        self.viewHeaderPlayer.frame = CGRectMake(0, 0, self.view.frame.size.width, youtubeFrame.size.height);
        self.tbView.alpha =  1.0;
        self.tbView.frame =  CGRectMake(0, self.viewHeaderPlayer.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-self.viewHeaderPlayer.frame.size.height);

        
    } completion:^(BOOL finished) {
        self.tbView.alpha =  1.0;
        self.tbView.frame =  CGRectMake(0, self.viewHeaderPlayer.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-self.viewHeaderPlayer.frame.size.height);

        

    }];
   
    
}
-(void)expandViewOnPanFromHome
{
    isExpandedMode =  YES;
//    isArticalPlayer = NO;
    UIWindow *window =     [UIApplication sharedApplication].keyWindow;
    
    [self.smallGestureView removeFromSuperview];
    //    self.view.transform=CGAffineTransformMakeScale(0.2, 0.2);
    
    [UIView animateWithDuration:0.3f animations:^{
        //        self.view.transform=CGAffineTransformMakeScale(1.0, 1.0);
        //        self.view.alpha=1;
        self.view.frame=CGRectMake(window.frame.origin.x, window.frame.origin.y, window.frame.size.width, window.frame.size.height);
        self.viewHeaderPlayer.frame = CGRectMake(0, 0, self.view.frame.size.width, youtubeFrame.size.height);
        self.tbView.alpha =  1.0;
        self.tbView.frame =  CGRectMake(0, self.viewHeaderPlayer.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-self.viewHeaderPlayer.frame.size.height);
        
        
    } completion:^(BOOL finished) {
        self.tbView.alpha =  1.0;
        self.tbView.frame =  CGRectMake(0, self.viewHeaderPlayer.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-self.viewHeaderPlayer.frame.size.height);
        
        
        
    }];
    if([[[SlikePlayer getInstance] getAnyPlayer] getStatus] == COMPLETED || [[[SlikePlayer getInstance] getAnyPlayer] getStatus] == ENDED)
    {
        [[[SlikePlayer getInstance] getAnyPlayer] replay];
    }
    
}
-(void)backToPortate
    {
        isExpandedMode =  YES;
        UIWindow *window =     [UIApplication sharedApplication].keyWindow;
        
        [self.smallGestureView removeFromSuperview];
      
            self.view.frame=CGRectMake(window.frame.origin.x, window.frame.origin.y, window.frame.size.width, window.frame.size.height);
            self.viewHeaderPlayer.frame = CGRectMake(0, 0, self.view.frame.size.width, youtubeFrame.size.height);
            self.tbView.alpha =  1.0;
            self.tbView.frame =  CGRectMake(0, self.viewHeaderPlayer.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
            self.tbView.alpha =  1.0;
            self.tbView.frame =  CGRectMake(0, self.viewHeaderPlayer.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
       
        
    }
-(void)removeView
{
    if(!isExpandedMode)
    {
    [[SlikePlayer getInstance]  stopPlayer];
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha= 0.0;
    } completion:^(BOOL finished) {
        self.playerConfig = nil;
        [self.view removeFromSuperview];

    }];
    [transaparentVw removeFromSuperview];
    }
}
-(void)removeViewFromStart
{
   
        [[SlikePlayer getInstance]  stopPlayer];
        [UIView animateWithDuration:0.3 animations:^{
            self.view.alpha= 0.0;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];

        }];
        [transaparentVw removeFromSuperview];
    
}

-(void)animateViewToRight:(UIPanGestureRecognizer *)recognizer{
    if(!isExpandedMode)
    {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.view.frame=viewFrame;
                         self.view.alpha=1;
                 
                     }
                     completion:^(BOOL finished) {

                     }];
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
}

-(void)animateViewToLeft:(UIPanGestureRecognizer *)recognizer{
    if(!isExpandedMode)
    {
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^ {
                         self.view.frame=viewFrame;
                         self.view.alpha=1;
                         
                     }
                     completion:^(BOOL finished) {
                     }];
    
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    }
}

// Implement Gesture Methods

-(void)swipeleft:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //Do what you want here
    if(!isExpandedMode)
    [self removeView];
}

-(void)swiperight:(UISwipeGestureRecognizer*)gestureRecognizer
{
    //Do what you want here
    if(!isExpandedMode)
    [self removeView];
}
- (void)tapAction:(UITapGestureRecognizer*)sender {
    if(!isExpandedMode)
    {
//        isArticalPlayer =  NO;
    [self expandViewOnPan];
    }
}
#pragma mark Table View-
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header;
    header= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    header.backgroundColor =[UIColor whiteColor];
    return header;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 500;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"infoCell";
    
    
    UITableViewCell *cell;
    cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    UILabel *infoLbl = (UILabel*)[cell.contentView viewWithTag:11];
    infoLbl.text =@"There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet. It uses a dictionary of over 200 Latin words, combined with a handful of model sentence structures, to generate Lorem Ipsum which looks reasonable. The generated Lorem Ipsum is therefore always free from repetition, injected humour, or non-characteristic words etc. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.";
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
-(void)articleDoc
{
    self.isArticalShow =  NO;
    UIWindow *window =     [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:self.view];
    
    [[[SlikePlayer getInstance] getAnyPlayer].getControl hide];
    
    viewFrame =  CGRectMake([UIApplication sharedApplication].keyWindow.frame.size.width-160-5, [UIApplication sharedApplication].keyWindow.frame.size.height-90-5, 160, 90);
    
    self.view.frame=viewFrame;
    
    isExpandedMode =  NO;
    self.viewHeaderPlayer.frame=self.view.bounds;
    [[[[SlikePlayer getInstance] getAnyPlayer] getControl] hide];
    self.smallGestureView.frame = self.viewHeaderPlayer.frame;
    [self.viewHeaderPlayer addSubview:self.smallGestureView];
    self.tbView.alpha =  1.0;
}
-(void)expandViewFromHome:(UIView*)header
{
  
    isExpandedMode =  YES;
    
    UIWindow *window =     [UIApplication sharedApplication].keyWindow;
    
    [self.smallGestureView removeFromSuperview];
   
        //        self.view.transform=CGAffineTransformMakeScale(1.0, 1.0);
        //        self.view.alpha=1;
        self.view.frame=CGRectMake(window.frame.origin.x, window.frame.origin.y, window.frame.size.width, window.frame.size.height);
        self.viewHeaderPlayer.frame = CGRectMake(0, 0, self.view.frame.size.width, youtubeFrame.size.height);
        self.tbView.alpha =  1.0;
        self.tbView.frame =  CGRectMake(0, self.viewHeaderPlayer.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-self.viewHeaderPlayer.frame.size.height);
    [header addSubview:self.view];
    

}
-(void)updateExpandMode:(BOOL)isExpand
{
    isExpandedMode =  isExpand;
}
@end
