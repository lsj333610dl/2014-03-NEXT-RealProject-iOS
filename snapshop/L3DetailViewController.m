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


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define COLOR_MAIN UIColorFromRGB(0x4EC598)

@interface L3DetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *shadowView;
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

@property (nonatomic) SIAlertView *sialertView;
@property (nonatomic) L3TextField *titleTF;
@property (nonatomic) L3TextField *contentsTF;
@property (nonatomic) L3TextField *priceTF;
@property (nonatomic) L3TextField *urlTF;
@property (weak, nonatomic) IBOutlet UILabel *writerLabel;

@property (nonatomic) CGRect alertViewFrame;
@property (weak, nonatomic) IBOutlet UILabel *viewSnapCountLabel;
@property (weak, nonatomic) IBOutlet UIView *topBarView;

@end

@implementation L3DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    _delegate = [[UIApplication sharedApplication] delegate];
    [self reloadData];

    _manager = [AFHTTPRequestOperationManager manager];
    
    
//    [self addShadowToView:_topBarView];
    [self addShadowToView:_shadowView];
    
}

- (void)addShadowToView:(UIView*)view{
    
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 1.0f;
    view.layer.shadowRadius = 1.0f;
}


- (void)reloadData{
    _topTitleLabel.text = _data[@"title"];
    _titleLabel.text = _data[@"title"];
    _writerLabel.text = [NSString stringWithFormat:@"작성자 : %@",_data[@"writer"]];
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_data[@"imgUrl"]]];
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber *priceNumber = [formatter numberFromString:_data[@"price"] ];
    NSString *priceString = [formatter stringFromNumber:priceNumber];
    
    
    _priceLabel.text = [NSString stringWithFormat:@"%@원",priceString];
    _contentsLabel.text = _data[@"contents"];
    
    _viewSnapCountLabel.text = [NSString stringWithFormat:@"%zd명이 구경하고, %zd명이 Snap했습니다.",[_data[@"read"] integerValue],[_data[@"numLike"] integerValue]];
    
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
        _writerLabel.hidden = YES;
    }
    else {
        _deleteButton.hidden = YES;
        _editButton.hidden = YES;
        _writerLabel.hidden = NO;
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
    __block L3DetailViewController *selfCopy = self;
    SIAlertView *alert = [[SIAlertView alloc]initWithTitle:@"삭제" andMessage:@"정말 이 글을 삭제하시렵니까?"];
    [alert addButtonWithTitle:@"취소" type:SIAlertViewButtonTypeCancel handler:nil];
    [alert addButtonWithTitle:@"삭제" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alert){
        [selfCopy delete];
    }];
    
    [alert show];

    
    
}


- (void)delete{
    
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
    
    
    self.titleTF    = [[L3TextField alloc]initWithFrame:CGRectMake(10, 30, 250, 40)];
    self.contentsTF = [[L3TextField alloc]initWithFrame:CGRectMake(10, 100, 250, 40)];
    self.priceTF    = [[L3TextField alloc]initWithFrame:CGRectMake(10, 170, 250, 40)];
    self.urlTF    = [[L3TextField alloc]initWithFrame:CGRectMake(10, 240, 250, 40)];
    
    
    [_titleTF setDelegate:self];
    [_contentsTF setDelegate:self];
    [_priceTF setDelegate:self];
    [_urlTF setDelegate:self];
    
    UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 44)];
    toolbar.barTintColor = [UIColor whiteColor];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]initWithTitle:@"취소" style:UIBarButtonItemStylePlain target:self action:@selector(cancelEditPost)];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]initWithTitle:@"저장" style:UIBarButtonItemStylePlain target:self action:@selector(editPost)];
    
    cancelButton.tintColor = COLOR_MAIN;
    saveButton.tintColor = COLOR_MAIN;
    
    [toolbar setItems:@[cancelButton,flex,saveButton]];
    
    
    self.titleTF.inputAccessoryView = toolbar;
    self.contentsTF.inputAccessoryView = toolbar;
    self.priceTF.inputAccessoryView = toolbar;
    self.urlTF.inputAccessoryView = toolbar;
    
    self.titleTF.textColor = [UIColor whiteColor];
    self.contentsTF.textColor = [UIColor whiteColor];
    self.priceTF.textColor = [UIColor whiteColor];
    self.urlTF.textColor = [UIColor whiteColor];
    
    self.titleTF.text = _data[@"title"];
    self.priceTF.text = _data[@"price"];
    self.contentsTF.text = _data[@"contents"];
    self.urlTF.text = _data[@"shopUrl"];
    
    
    [editView addSubview:self.titleTF];
    [editView addSubview:self.contentsTF];
    [editView addSubview:self.priceTF];
    [editView addSubview:self.urlTF];
    
    _sialertView = [[SIAlertView alloc]initWithTitle:nil andMessage:nil andContentView:editView];
    
    [_sialertView addButtonWithTitle:@"취소" type:SIAlertViewButtonTypeCancel handler:nil];
    
    
    [_sialertView show];
    
    
    _alertViewFrame = _sialertView.frame;
}

- (void)editPost{
    
    NSString *editUrlString = [NSString stringWithFormat:@"http://125.209.199.221:8080/app/posts/edit/%zd",[_data[@"pid"] integerValue]];
    
    NSDictionary *parameters = @{@"title":_titleTF.text,
                                 @"contents":_contentsTF.text,
                                 @"price":_priceTF.text,
                                 @"shopUrl":_urlTF.text,
                                 @"id":@(_delegate.uid)
                                 };
    
    [_manager POST:editUrlString
        parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    [formData appendPartWithFileData:UIImageJPEGRepresentation(_imageView.image, 1) name:@"image" fileName:@"editImage.jpg" mimeType:@"image/jpeg"];
    NSLog(@"%@, %@",editUrlString,parameters);
}
           success:^(AFHTTPRequestOperation *op, id ro){
               NSLog(@"성공!, %@",ro);
               [_sialertView dismissAnimated:YES];
               _titleLabel.text = parameters[@"title"];
               _contentsLabel.text = parameters[@"contents"];
               _priceLabel.text = parameters[@"price"];
               
           }
           failure:^(AFHTTPRequestOperation *op, NSError *error){
               NSLog(@"에라! : %@",error);
           }];
    
}

- (void)cancelEditPost{
    [_sialertView dismissAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    [UIView beginAnimations:@"alertMove" context:nil];
    
    if (textField==_titleTF) {
        CGRect frame = _alertViewFrame;
        frame.origin.y -= 50;
        _sialertView.frame = frame;
    }
    
    else if (textField==_contentsTF) {
        
        CGRect frame = _alertViewFrame;
        frame.origin.y -= 100;
        _sialertView.frame = frame;
    }
    
    else if (textField==_priceTF) {
        
        CGRect frame = _alertViewFrame;
        frame.origin.y -= 150;
        _sialertView.frame = frame;
    }
    
    else if (textField==_urlTF) {
        
        CGRect frame = _alertViewFrame;
        frame.origin.y -= 200;
        _sialertView.frame = frame;
    }
    
    [UIView commitAnimations];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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
