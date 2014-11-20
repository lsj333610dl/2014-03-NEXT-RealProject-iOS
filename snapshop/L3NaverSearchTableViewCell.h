//
//  L3NaverSearchTableViewCell.h
//  snapshop
//
//  Created by 이상진 on 2014. 11. 20..
//  Copyright (c) 2014년 EntusApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface L3NaverSearchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *mallNameLabel;

@end
