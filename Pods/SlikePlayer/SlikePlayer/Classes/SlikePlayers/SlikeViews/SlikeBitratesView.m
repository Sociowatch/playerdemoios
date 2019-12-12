//
//  SlikeBitratesView.m
//  Pods
//
//  Created by Sanjay Singh Rathor on 23/07/18.
//

#import "SlikeBitratesView.h"
#import "NSBundle+Slike.h"
#import "SlikeCoreShared.h"
#import "SlikeSharedDataCache.h"
#import "SlikeBitratesModel.h"
#import "SlikeConfig.h"

#define btnCorner 16.0
#define SLIKE_BTN_SLECTED_RGBA(r, g, b, a)    [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface SlikeBitratesView() {
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *autoBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lowBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mediumBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *highBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet UIStackView *stackvVew;
@property (weak, nonatomic) IBOutlet UIButton *autoBtn;
@property (weak, nonatomic) IBOutlet UIButton *lowBtn;
@property (weak, nonatomic) IBOutlet UIButton *mediumBtn;
@property (weak, nonatomic) IBOutlet UIButton *hightBtn;

@end

@implementation SlikeBitratesView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self _configureControlsState];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    [self _configureControlsState];
    return self;
}

+ (instancetype )slikeBitratesView {
    SlikeBitratesView *errorView = [[[NSBundle slikeNibsBundle] loadNibNamed:@"SlikeBitratesView" owner:self options:nil] lastObject];
    return errorView;
}

/**
 Configure Controls State
 */
- (void)_configureControlsState {
    
    if([UIScreen mainScreen].bounds.size.width != 320) {
        self.autoBtnWidthConstraint.constant =  75;
        self.lowBtnWidthConstraint.constant =  70;
        self.mediumBtnWidthConstraint.constant =  110;
        self.highBtnWidthConstraint.constant =  75;
    }
    
    self.autoBtn.layer.cornerRadius =  btnCorner;
    self.lowBtn.layer.cornerRadius =  btnCorner;
    self.mediumBtn.layer.cornerRadius =  btnCorner;
    self.hightBtn.layer.cornerRadius =  btnCorner;
    self.autoBtn.layer.borderWidth =  1.0;
    self.lowBtn.layer.borderWidth =  1.0;
    self.mediumBtn.layer.borderWidth =  1.0;
    self.hightBtn.layer.borderWidth =  1.0;
    self.autoBtn.layer.borderColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0).CGColor;
    self.lowBtn.layer.borderColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0).CGColor;
    self.mediumBtn.layer.borderColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0).CGColor;
    self.hightBtn.layer.borderColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0).CGColor;
    
    self.autoBtn.backgroundColor =  UIColor.clearColor;
    self.lowBtn.backgroundColor =  UIColor.clearColor;
    self.mediumBtn.backgroundColor =  UIColor.clearColor;
    self.hightBtn.backgroundColor =  UIColor.clearColor;
    self.autoBtn.tag =  121;
    self.lowBtn.tag =  122;
    self.mediumBtn.tag =  123;
    self.hightBtn.tag =  124;
    
    [self.autoBtn addTarget:self action:@selector(bitRateDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.lowBtn addTarget:self action:@selector(bitRateDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.mediumBtn addTarget:self action:@selector(bitRateDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.hightBtn addTarget:self action:@selector(bitRateDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.autoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.lowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.mediumBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.hightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.autoBtn.hidden =  YES;
    self.lowBtn.hidden =  YES;
    self.mediumBtn.hidden =  YES;
    self.hightBtn.hidden =  YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if([UIScreen mainScreen].bounds.size.width <= 320) {
        
        self.autoBtnWidthConstraint.constant =  65;
        self.lowBtnWidthConstraint.constant =  60;
        self.mediumBtnWidthConstraint.constant =  85;
        self.highBtnWidthConstraint.constant =  65;
        
    } else {
        
        self.autoBtnWidthConstraint.constant =  75;
        self.lowBtnWidthConstraint.constant =  70;
        self.mediumBtnWidthConstraint.constant =  110;
        self.highBtnWidthConstraint.constant =  75;
    }
    
}

/**
 Present the UI with the Available Bitrates for the Streams
 */
- (void)presentAvailableBitratesForStream {
    
    if([SlikeSharedDataCache sharedCacheManager].isEncrypted)
    {
        if([SlikeSharedDataCache sharedCacheManager].currentStreamBitrate == SlikeMediaBitrateAuto)
        {
            self.autoBtn.backgroundColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0);
            [self.autoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }else  if([SlikeSharedDataCache sharedCacheManager].currentStreamBitrate == SlikeMediaBitrateLow)
        {
            self.lowBtn.backgroundColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0);
            [self.lowBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        else  if([SlikeSharedDataCache sharedCacheManager].currentStreamBitrate == SlikeMediaBitrateMedium)
        {
            self.mediumBtn.backgroundColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0);
            [self.mediumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        else  if([SlikeSharedDataCache sharedCacheManager].currentStreamBitrate == SlikeMediaBitrateHigh)
        {
            self.hightBtn.backgroundColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0);
            [self.hightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        else
        {
            self.autoBtn.backgroundColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0);
            [self.autoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        
    [self.autoBtn setTitle:[self.configModel.qualityName[0] uppercaseString] forState:UIControlStateNormal];
    [self.lowBtn setTitle:[self.configModel.qualityName[1] uppercaseString] forState:UIControlStateNormal];
    [self.mediumBtn setTitle:[self.configModel.qualityName[2] uppercaseString] forState:UIControlStateNormal];
    [self.hightBtn setTitle:[self.configModel.qualityName[3] uppercaseString] forState:UIControlStateNormal];
        if([SlikeSharedDataCache sharedCacheManager].xStreamList.bitrateObjets.count >2)
        {
            self.autoBtn.hidden=  NO;
            self.lowBtn.hidden=  NO;
            self.mediumBtn.hidden=  NO;
            self.hightBtn.hidden=  NO;
        }
        else if([SlikeSharedDataCache sharedCacheManager].xStreamList.bitrateObjets.count >1)
        {
            self.autoBtn.hidden=  NO;
            self.lowBtn.hidden=  NO;
            self.mediumBtn.hidden=  NO;
        }
        else if([SlikeSharedDataCache sharedCacheManager].xStreamList.bitrateObjets.count >1)
        {
            self.autoBtn.hidden=  NO;
            self.lowBtn.hidden=  NO;
        }
    }
    else
    {
    NSArray *bitRateArray = [[SlikeSharedDataCache sharedCacheManager] cachedBitratesModels];
    SlikeMediaBitrate currentBitRateType = [SlikeSharedDataCache sharedCacheManager].currentStreamBitrate;
    
    for(SlikeBitratesModel *model in bitRateArray) {
        
        if([model.bitrateUrl isValidString]) {
            
            if(model.bitrateType == SlikeMediaBitrateAuto) {
                self.autoBtn.hidden =  NO;
                
                if ([self.configModel.qualityName count] == 4) {
                    [self.autoBtn setTitle:[self.configModel.qualityName[0] uppercaseString] forState:UIControlStateNormal];
                } else {
                    [self.autoBtn setTitle:[model.bitrateName uppercaseString] forState:UIControlStateNormal];
                }
                
                if(currentBitRateType == model.bitrateType) {
                    
                    self.autoBtn.backgroundColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0);
                    [self.autoBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                
            } else if(model.bitrateType == SlikeMediaBitrateLow) {
                self.lowBtn.hidden =  NO;
                
                if ([self.configModel.qualityName count] == 4) {
                    [self.lowBtn setTitle:[self.configModel.qualityName[1] uppercaseString] forState:UIControlStateNormal];
                } else {
                    [self.lowBtn setTitle:[model.bitrateName uppercaseString] forState:UIControlStateNormal];
                }
                
                if(currentBitRateType  == model.bitrateType) {
                    self.lowBtn.backgroundColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0);
                    [self.lowBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                
            } else if(model.bitrateType == SlikeMediaBitrateMedium) {
                self.mediumBtn.hidden =  NO;
                
                if ([self.configModel.qualityName count] == 4) {
                    [self.mediumBtn setTitle:[self.configModel.qualityName[2] uppercaseString] forState:UIControlStateNormal];
                } else {
                    [self.mediumBtn setTitle:[model.bitrateName uppercaseString] forState:UIControlStateNormal];
                }
            
                if(currentBitRateType  == model.bitrateType) {
                    self.mediumBtn.backgroundColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0);
                    [self.mediumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
                
            } else if(model.bitrateType == SlikeMediaBitrateHigh) {
                self.hightBtn.hidden =  NO;
                
                if ([self.configModel.qualityName count] == 4) {
                    [self.hightBtn setTitle:[self.configModel.qualityName[3] uppercaseString] forState:UIControlStateNormal];
                } else {
                    [self.hightBtn setTitle:[model.bitrateName uppercaseString] forState:UIControlStateNormal];
                }
                
                if(currentBitRateType  == model.bitrateType) {
                    self.hightBtn.backgroundColor = SLIKE_BTN_SLECTED_RGBA(216.0, 216.0, 216.0, 1.0);
                    [self.hightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                }
            }
        }
    }
    }
}


/**
 User has selected the Particular Bitrate
 @param sender -
 */
- (void)bitRateDidClicked:(UIButton *)sender {
    
    
    NSInteger tag =  sender.tag;
    SlikeMediaBitrate selectedBitrate = SlikeMediaBitrateNone;
    if(tag == 121) {
        selectedBitrate = SlikeMediaBitrateAuto;
        
    } else if(tag ==  122){
        selectedBitrate = SlikeMediaBitrateLow;
        
    } else if(tag ==  123) {
        selectedBitrate = SlikeMediaBitrateMedium;
        
    } else if(tag ==  124) {
        selectedBitrate = SlikeMediaBitrateHigh;
    }
    
    SlikeMediaBitrate currentBitRateType = [SlikeSharedDataCache sharedCacheManager].currentStreamBitrate;
    
    if (currentBitRateType == selectedBitrate ) {
        [self closeButtonDidClicked:nil];
    } else {
        if (self.selectedBirateBlock) {
            self.selectedBirateBlock(@(selectedBitrate));
        }
    }
}

- (IBAction)closeButtonDidClicked:(id)sender {
    if (self.closeButtonBlock) {
        self.closeButtonBlock();
    }
}

- (void)dealloc {
    SlikeDLog(@"dealloc- Cleaning up SlikeBitratesView");
}


@end
