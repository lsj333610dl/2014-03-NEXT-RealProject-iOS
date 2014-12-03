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


#define SUCCESS_STATUS @"10"

@interface L3JoinViewController ()

@property (nonatomic) AFHTTPRequestOperationManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet L3TextField *emailTextField;
@property (weak, nonatomic) IBOutlet L3TextField *passwordTextField;
@property (weak, nonatomic) IBOutlet L3TextField *passwordCheckTextField;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (strong, nonatomic) UIStoryboard *storyBoard;

@end

@implementation L3JoinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _manager = [AFHTTPRequestOperationManager manager];
    
    self.storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    
    [_emailTextField becomeFirstResponder];
    
}


- (IBAction)join:(id)sender{
    
    if ([_emailTextField.text containsString:@"@"] && [_emailTextField.text containsString:@"."]) {
        
        if (_passwordTextField.text.length < 4) {
            SIAlertView *alert = [[SIAlertView alloc]initWithTitle:@"비밀번호 오류!" andMessage:@"비밀번호가 너무 짧습니다.\n다시 입력해주세요."];
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
        
        
        [_manager GET:@"http://125.209.199.221:8080/app/users/new"
           parameters:@{@"email":_emailTextField.text,@"password":_passwordTextField.text}
              success:^(AFHTTPRequestOperation *operation, id responseObject){
                  NSLog(@"%@",[responseObject objectForKey:@"status"]);
                  
                  if ([[[responseObject objectForKey:@"status"] stringValue] isEqualToString:SUCCESS_STATUS]) {
                      
                      ViewController *mainViewController = [_storyBoard instantiateViewControllerWithIdentifier:@"mainViewController"];
                      
                      [self presentViewController:mainViewController animated:NO completion:nil];
                  }
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error){
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
