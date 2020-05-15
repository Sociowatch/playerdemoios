//
//  SlikePlayerErrorView.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 06/06/18.
//

#import "SlikePlayerErrorView.h"
#import "NSBundle+Slike.h"

@interface SlikePlayerErrorView ()

@end

@implementation SlikePlayerErrorView

- (void)awakeFromNib {
    [super awakeFromNib];
    _reloadButton.layer.cornerRadius = 4;
    _reloadButton.hidden=YES;
    _closeButton.hidden=YES;
    
    self.thumbImageView.image = [UIImage imageNamed:@"iconError" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil];
    self.thumbImageView.image = [UIImage imageNamed:@"iconError" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil];
    [self.closeButton setImage:[UIImage imageNamed:@"player_closebtn" inBundle:[NSBundle slikeImagesBundle] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    return self;
}

+ (instancetype )slikePlayerErrorView {
    
    SlikePlayerErrorView *errorView = [[[NSBundle slikeNibsBundle] loadNibNamed:@"SlikePlayerErrorView" owner:self options:nil] lastObject];
    return errorView;
}

- (void)setErrorMessage:(NSString *)errMessage withCloseEnable:(BOOL)isCloseEnable withReloadEnable:(BOOL)isReloadEnable {
    [self.reloadButton setTitle:[SlikePlayerSettings playerSettingsInstance].slikestrings.reloadButtonTitle forState:UIControlStateNormal];

    _messageLabel.text = errMessage;
    
    if (isCloseEnable) {
        _closeButton.hidden=NO;
    }
    if (isReloadEnable) {
        _reloadButton.hidden=NO;
    }
}


- (IBAction)closeButtonDidClicked:(id)sender {
    
    if (self.closeButtonBlock) {
        self.closeButtonBlock();
    }
}

- (IBAction)retryButtonDidClicked:(id)sender {
    if (self.reloadButtonBlock) {
        self.reloadButtonBlock();
    }
}

- (void)dealloc {
    SlikeDLog(@"dealloc- Cleaning up SlikePlayerErrorView");
}


@end
