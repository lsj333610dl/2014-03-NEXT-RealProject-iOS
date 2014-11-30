//
//  L3TextField.m
//  snapshop
//
//  Created by 이상진 on 2014. 12. 1..
//  Copyright (c) 2014년 EntusApps. All rights reserved.
//

#import "L3TextField.h"

@implementation L3TextField




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = 10.0f;

    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 50)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;


    [self setValue:[UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [self setTintColor:[UIColor colorWithRed:78/255.0f green:197/255.0f blue:152/255.0f alpha:1.0f]];

}


@end
