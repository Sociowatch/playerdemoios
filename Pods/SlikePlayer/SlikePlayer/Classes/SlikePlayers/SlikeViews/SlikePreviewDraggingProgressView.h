//
//  SlikePreviewDraggingProgressView.h
//  Pods
//
//  Created by Sanjay Singh Rathor on 26/07/18.
//

#import <UIKit/UIKit.h>

@interface SlikePreviewDraggingProgressView : UIView
+ (instancetype )slikePreviewDraggingProgressView;

@property (unsafe_unretained, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *previewThumnail;
@property (weak, nonatomic) IBOutlet UILabel *screenShotTimeLabel;

@end
