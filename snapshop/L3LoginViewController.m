//
//  L3LoginViewController.m
//  snapshop
//
//  Created by 이상진 on 2014. 11. 20..
//  Copyright (c) 2014년 EntusApps. All rights reserved.
//

#import "L3LoginViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "SIAlertView/SIAlertView.h"
#import "ViewController.h"
#import "L3TextField.h"


#define SUCCESS_STATUS @"10"

@interface L3LoginViewController ()

@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet L3TextField *emailTextField;
@property (weak, nonatomic) IBOutlet L3TextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *findPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) UIStoryboard *storyBoard;

@end

@implementation L3LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _manager = [AFHTTPRequestOperationManager manager];
    
    self.storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    
    [_emailTextField becomeFirstResponder];
    
}




- (IBAction)login:(id)sender{
    
    if ([_emailTextField.text containsString:@"@"] && [_emailTextField.text containsString:@"."]) {
        
        if (_passwordTextField.text.length < 4) {
            SIAlertView *alert = [[SIAlertView alloc]initWithTitle:@"비밀번호 오류!" andMessage:@"비밀번호가 너무 짧습니다.\n다시 입력해주세요."];
            [alert addButtonWithTitle:@"확인" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
                [_passwordTextField becomeFirstResponder];
            }];
            [alert show];
            return;
        }
        
#warning 임시
        
        ViewController *mainViewController = [_storyBoard instantiateViewControllerWithIdentifier:@"mainViewController"];
        
        [self presentViewController:mainViewController animated:NO completion:nil];
        return;
        
        
        [_manager GET:@"http://125.209.199.221:8080/app/users/login"
           parameters:@{@"email":_emailTextField.text,@"password":_passwordTextField.text}
              success:^(AFHTTPRequestOperation *operation, id responseObject){
                  NSLog(@"%@",[responseObject objectForKey:@"status"]);
                  
                  if ([[responseObject objectForKey:@"status"] isEqualToString:SUCCESS_STATUS]) {
                      
                      ViewController *mainViewController = [_storyBoard instantiateViewControllerWithIdentifier:@"mainViewController"];
                      
                      [self presentViewController:mainViewController animated:NO completion:nil];
                  }
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error){
                  NSLog(@"%@",[error localizedDescription]);
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
