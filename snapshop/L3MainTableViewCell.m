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
