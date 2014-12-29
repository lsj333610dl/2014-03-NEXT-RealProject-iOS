//
//  L3MainTableViewCell.m
//  snapshop
//
//  Created by 이상진 on 2014. 11. 21..
//  Copyright (c) 2014년 EntusApps. All rights reserved.
//

#import "L3MainTableViewCell.h"

@implementation L3MainTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    
    _shadowView.layer.masksToBounds = NO;
    _shadowView.layer.shadowColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
    _shadowView.layer.shadowOffset = CGSizeMake(0, 1);
    _shadowView.layer.shadowOpacity = 1.0f;
    _shadowView.layer.shadowRadius = 1.0f;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
    // Configure the view for the selected state
}


- (void)snaped{
    [_likeButton setTitle:@"Unsnap" forState:UIControlStateNormal];
}

- (void)unsnap{
    [_likeButton setTitle:@"snap" forState:UIControlStateNormal];
}

@end
