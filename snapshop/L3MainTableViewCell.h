//
//  L3MainTableViewCell.h
//  snapshop
//
//  Created by 이상진 on 2014. 11. 21..
//  Copyright (c) 2014년 EntusApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface L3MainTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *writerLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *snapCountLabel;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

- (void)snaped;
- (void)unsnap;

@end
