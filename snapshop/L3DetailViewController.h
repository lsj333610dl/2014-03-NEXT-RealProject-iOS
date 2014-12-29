//
//  L3DetailViewController.h
//  snapshop
//
//  Created by 이상진 on 2014. 12. 12..
//  Copyright (c) 2014년 EntusApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface L3DetailViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic) UIImage *mainImage;
@property (nonatomic) NSString *titleString;
@property (nonatomic) NSString *priceString;

@property (nonatomic) NSMutableDictionary *data;

- (void)reloadData;

@end
