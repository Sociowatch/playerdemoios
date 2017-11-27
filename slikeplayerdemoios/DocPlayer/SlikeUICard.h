//
//  SlikeUICardWhiteOptionFirst.h
//  SlikeUI
//
//  Created by Aravind kumar on 4/17/17.
//  Copyright © 2017 Aravind kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlikeUICard : UITableViewCell
{
    
}
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIImageView *separatorImgViewTop;
@property (weak, nonatomic) IBOutlet UIImageView *separatorImgViewBottom;

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UILabel *moreInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *tiLbl;
@property (weak, nonatomic) IBOutlet UILabel *despcriptionLbl;
@property (weak, nonatomic) IBOutlet UIButton *infoBtn;
@property (weak, nonatomic) IBOutlet UIImageView *thumbImageView;
@end
