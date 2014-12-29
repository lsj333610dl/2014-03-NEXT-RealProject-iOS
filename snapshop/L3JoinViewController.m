//
//  L3JoinViewController.m
//  snapshop
//
//  Created by 이상진 on 2014. 12. 3..
//  Copyright (c) 2014년 EntusApps. All rights reserved.
//

#import "L3JoinViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "SIAlertView/SIAlertView.h"
#import "L3TextField.h"
#import "ViewController.h"
#import "SVProgressHUD.h"
#import "AppDelegate.h"

#define SUCCESS_STATUS @"10"

@interface L3JoinViewController ()

@property (weak, nonatomic) IBOutlet UIView *formView;
@property (nonatomic) AFHTTPRequestOperationManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet L3TextField *emailTextField;
@property (weak, nonatomic) IBOutlet L3TextField *passwordTextField;
@property (weak, nonatomic) IBOutlet L3TextField *passwordCheckTextField;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (strong, nonatomic) UIStoryboard *storyBoard;

@property (nonatomic) CGRect keyboardBounds;

@end

@implementation L3JoinViewController

@synthesize keyboardBounds;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _manager = [AFHTTPRequestOperationManager manager];
    
    self.storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    [_emailTextField becomeFirstResponder];
    
    
    _formView.layer.masksToBounds = NO;
    _formView.layer.shadowColor = [UIColor colorWithWhite:0.5f alpha:1.0f].CGColor;
    _formView.layer.shadowOffset = CGSizeMake(0, 1);
    _formView.layer.shadowOpacity = 1.0f;
    _formView.layer.shadowRadius = 1.0f;
    
}


- (IBAction)join:(id)sender{
    
    if ([_emailTextField.text containsString:@"@"] && [_emailTextField.text containsString:@"."]) {
        
        if (_passwordTextField.text.length < 4) {
            SIAlertView *alert = [[SIAlertView alloc]initWithTitle:@"비밀번호 오류!" andMessage:@"비밀번호가 너무 짧습니다.\n4자 이상으로 입력해주세요."];
            [alert addButtonWithTitle:@"확인" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
                [_passwordTextField becomeFirstResponder];
            }];
            [alert show];
            return;
        }
        
        else if (![_passwordTextField.text isEqualToString:_passwordCheckTextField.text]) {
            SIAlertView *alert = [[SIAlertView alloc]initWithTitle:@"비밀번호 오류!" andMessage:@"비밀번호가 다릅니다.\n다시 입력해주세요."];
            [alert addButtonWithTitle:@"확인" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
                [_passwordTextField becomeFirstResponder];
            }];
            [alert show];
            return;
        }
        
        
        [_manager POST:@"http://125.209.199.221:8080/app/users/new"
           parameters:@{@"email":_emailTextField.text,@"password":_passwordTextField.text}
              success:^(AFHTTPRequestOperation *operation, id responseObject){
                  NSLog(@"%@",[responseObject objectForKey:@"status"]);
                  
                  if ([[[responseObject objectForKey:@"status"] stringValue] isEqualToString:SUCCESS_STATUS]) {
                      
                      
                      [_manager GET:@"http://125.209.199.221:8080/app/users/login"
                         parameters:@{@"email":_emailTextField.text,@"password":_passwordTextField.text}
                            success:^(AFHTTPRequestOperation *operation, id responseObject){
                                NSLog(@"%@",[responseObject objectForKey:@"status"]);
                                
                                if ([[[responseObject objectForKey:@"status"] stringValue] isEqualToString:SUCCESS_STATUS]) {
                                    
                                    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
                                    [delegate setUid:[[responseObject objectForKey:@"id"]integerValue]];
                                    [delegate setEmailString:_emailTextField.text];
                                    
                                    [self.view endEditing:YES];
                                    
                                    ViewController *mainViewController = [_storyBoard instantiateViewControllerWithIdentifier:@"mainViewController"];
                                    
                                    delegate.window.rootViewController = mainViewController;
                                }
                                
                                else {
                                    [SVProgressHUD showErrorWithStatus:@"로그인 실패!\n이메일&비밀번호를 확인해보세요."];
                                }
                                
                            }
                            failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                [SVProgressHUD showErrorWithStatus:@"네트워크 에러!"];
                                NSLog(@"%@",[error localizedDescription]);
                            }];
                      
                      
                      
                      
                  }
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error){
                  [SVProgressHUD showErrorWithStatus:@"네트워크 에러!"];
                  NSLog(@"에러 : %@",[error localizedDescription]);
              }];
    }
    
    else {
        SIAlertView *alert = [[SIAlertView alloc]initWithTitle:@"이메일 형식이 아닙니다." andMessage:@"이메일을 입력해주세요."];
        [alert addButtonWithTitle:@"확인" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
            [_emailTextField becomeFirstResponder];
        }];
        [alert show];
    }
}

- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}





#pragma mark - etc

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


@end
