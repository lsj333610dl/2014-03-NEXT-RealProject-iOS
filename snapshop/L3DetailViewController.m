//
//  L3DetailViewController.m
//  snapshop
//
//  Created by 이상진 on 2014. 12. 12..
//  Copyright (c) 2014년 EntusApps. All rights reserved.
//

#import "L3DetailViewController.h"
#import "UIImageView+WebCache.h"
#import "AFNetworking.h"
#import "TOWebViewController.h"
#import "AppDelegate.h"
#import "SIAlertView.h"
#import "L3TextField.h"

@interface L3DetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *snapButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentsLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (nonatomic) AFHTTPRequestOperationManager *manager;
@property (nonatomic) AppDelegate *delegate;
@end

@implementation L3DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _delegate = [[UIApplication sharedApplication] delegate];
    [self reloadData];

    _manager = [AFHTTPRequestOperationManager manager];

}


- (void)reloadData{
    _topTitleLabel.text = _data[@"title"];
    _titleLabel.text = _data[@"title"];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_data[@"imgUrl"]]];
    _priceLabel.text = _data[@"price"];
    _contentsLabel.text = _data[@"contents"];
    
    if ([_data[@"shopUrl"] isEqualToString:@""]) {
        [_buyButton setHighlighted:YES];
        [_buyButton setEnabled:NO];
    }
    else {

        [_buyButton setHighlighted:NO];
        [_buyButton setEnabled:YES];
    }

    if ([_data[@"like"] isEqualToNumber:@1]) {
        [_snapButton setTitle:@"Unsnap" forState:UIControlStateNormal];
    }
    else {
        [_snapButton setTitle:@"Snap" forState:UIControlStateNormal];
    }
    
    if ([_delegate.emailString isEqualToString:_data[@"writer"]]) {
        _deleteButton.hidden = NO;
        _editButton.hidden = NO;
    }
    else {
        _deleteButton.hidden = YES;
        _editButton.hidden = YES;
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - IBAction
- (IBAction)buy:(id)sender {
    
    if ([_data[@"shopUrl"] isEqualToString:@""]) {
        return;
    }
    
    NSString *readUrlString = [NSString stringWithFormat:@"http://125.209.199.221:8080/app/posts/%zd/read",[_data[@"pid"] integerValue]];
    
    [_manager POST:readUrlString
        parameters:@{@"pid":_data[@"pid"]}
           success:^(AFHTTPRequestOperation *op, id ro){
               NSLog(@"%@",ro);
           }
           failure:^(AFHTTPRequestOperation *op, NSError *error){
               NSLog(@"%@",error);
           }];
    
    NSURL *url = [NSURL URLWithString:_data[@"shopUrl"]];
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:url];
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:webViewController] animated:YES completion:nil];
    
}
- (IBAction)snap:(UIButton *)sender {


    NSString *urlString = [NSString stringWithFormat:@"http://125.209.199.221:8080/app/posts/like?pid=%@&uid=%@", _data[@"pid"], @(_delegate.uid)];

    //snap 추가
    if ([_snapButton.titleLabel.text isEqualToString:@"Snap"]) {
        [_manager POST:urlString
            parameters:@{@"pid":_data[@"pid"],@"uid": @(_delegate.uid)} success:^(AFHTTPRequestOperation *op,id ro){

                    NSLog(@"스냅 성공 : %@",ro);
                    [_snapButton setTitle:@"Unsnap" forState:UIControlStateNormal];
                }

               failure:^(AFHTTPRequestOperation *op, NSError *error){
                   NSLog(@"에라이 추가 에라다: %@",error);
               }];
    }

        //snap 취소
    else {

        NSLog(@"ss");
        [_manager DELETE:urlString
              parameters:@{@"pid":_data[@"pid"],@"uid":@(_delegate.uid)} success:^(AFHTTPRequestOperation *op,id ro){

                    NSLog(@"스냅 취소성공 : %@",ro);
                    [_snapButton setTitle:@"Snap" forState:UIControlStateNormal];
                }

                 failure:^(AFHTTPRequestOperation *op, NSError *error){
                     NSLog(@"에라이 취소 에라다 : %@",error);
                 }];
    }

}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)delete:(id)sender {
    
    //    [_manager DELETE:@"http://125.209.199.221:8080/app/posts/delete/31" parameters:@{@"uid":@6} success:nil failure:nil];
    NSString *deleteUrlString = [NSString stringWithFormat:@"http://125.209.199.221:8080/app/posts/delete/%zd",[_data[@"pid"] integerValue]];
    
    [_manager DELETE:deleteUrlString
          parameters:@{@"uid":@(_delegate.uid)}
             success:^(AFHTTPRequestOperation *op, id ro){
                 NSLog(@"지움 : %@",ro);
                 [[NSNotificationCenter defaultCenter]postNotificationName:@"ReloadData" object:nil];
                 [self back:nil];
             }
             failure:^(AFHTTPRequestOperation *op, NSError *error){
                 NSLog(@"실패");
             }];
    
    
}
- (IBAction)edit:(id)sender {
    UIView *editView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 250, 300)];
    [editView setBackgroundColor:[UIColor colorWithWhite:0.17f alpha:1.0f]];
    
    UILabel *titleLabel     = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 250, 20)];
    UILabel *contentsLabel  = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 250, 20)];
    UILabel *priceLabel     = [[UILabel alloc]initWithFrame:CGRectMake(10, 150, 250, 20)];
    UILabel *urlLabel     = [[UILabel alloc]initWithFrame:CGRectMake(10, 220, 250, 20)];
    
    titleLabel.text = @"제목";
    contentsLabel.text = @"내용";
    priceLabel.text = @"가격";
    urlLabel.text = @"URL";
    
    titleLabel.textColor = [UIColor whiteColor];
    contentsLabel.textColor = [UIColor whiteColor];
    priceLabel.textColor = [UIColor whiteColor];
    urlLabel.textColor = [UIColor whiteColor];
    
    [editView addSubview:titleLabel];
    [editView addSubview:contentsLabel];
    [editView addSubview:priceLabel];
    [editView addSubview:urlLabel];
    
    
    L3TextField *titleTF    = [[L3TextField alloc]initWithFrame:CGRectMake(10, 30, 250, 40)];
    L3TextField *contentsTF = [[L3TextField alloc]initWithFrame:CGRectMake(10, 100, 250, 40)];
    L3TextField *priceTF    = [[L3TextField alloc]initWithFrame:CGRectMake(10, 170, 250, 40)];
    L3TextField *urlTF    = [[L3TextField alloc]initWithFrame:CGRectMake(10, 240, 250, 40)];
    
    titleTF.textColor = [UIColor whiteColor];
    contentsTF.textColor = [UIColor whiteColor];
    priceTF.textColor = [UIColor whiteColor];
    urlTF.textColor = [UIColor whiteColor];
    
    titleTF.text = _data[@"title"];
    priceTF.text = _data[@"price"];
    contentsTF.text = _data[@"contents"];
    urlTF.text = _data[@"shopUrl"];
    
    
    [editView addSubview:titleTF];
    [editView addSubview:contentsTF];
    [editView addSubview:priceTF];
    [editView addSubview:urlTF];
    
    SIAlertView *alert = [[SIAlertView alloc]initWithTitle:@"수정" andMessage:nil andContentView:editView];
    
    [alert addButtonWithTitle:@"취소" type:SIAlertViewButtonTypeCancel handler:nil];
    [alert addButtonWithTitle:@"저장" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView* alertView){
        
        NSString *editUrlString = [NSString stringWithFormat:@"http://125.209.199.221:8080/app/posts/edit/%zd",[_data[@"pid"] integerValue]];
        [_manager POST:editUrlString
            parameters:@{@"title":titleTF.text,
                         @"contents":contentsTF.text,
                         @"price":priceTF.text,
                         @"shopUrl":priceTF.text
                         }
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                             [formData appendPartWithFileData:UIImageJPEGRepresentation(_imageView.image, 1) name:@"image" fileName:@"editImage" mimeType:@"image/jpeg"];
    
                         }
               success:^(AFHTTPRequestOperation *op, id ro){
                   NSLog(@"성공!, %@",ro);
                   
               }
               failure:^(AFHTTPRequestOperation *op, NSError *error){
                   NSLog(@"에라! : %@",error);
               }];
    }];
    
    [alert show];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
