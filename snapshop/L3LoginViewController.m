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
#import "L3JoinViewController.h"
#import "AppDelegate.h"
#import "SVProgressHUD/SVProgressHUD.h"

#define SUCCESS_STATUS 10

@interface L3LoginViewController ()

@property (nonatomic) AFHTTPRequestOperationManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet L3TextField *emailTextField;
@property (weak, nonatomic) IBOutlet L3TextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (strong, nonatomic) UIStoryboard *storyBoard;
@property (weak, nonatomic) IBOutlet UIView *formView;

@end

@implementation L3LoginViewController

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




- (IBAction)login:(id)sender{
    
    NSString *emailid = _emailTextField.text;
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest =[NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL myStringMatchesRegEx=[emailTest evaluateWithObject:emailid];
    
    
    if (myStringMatchesRegEx) {
        
        if (_passwordTextField.text.length < 4) {
            SIAlertView *alert = [[SIAlertView alloc]initWithTitle:@"비밀번호 오류!" andMessage:@"비밀번호가 너무 짧습니다.\n다시 입력해주세요."];
            [alert addButtonWithTitle:@"확인" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
                [_passwordTextField becomeFirstResponder];
            }];
            [alert show];
            return;
        }
        
        
        
        [_manager GET:@"http://125.209.199.221:8080/app/users/login"
           parameters:@{@"email":_emailTextField.text,@"password":_passwordTextField.text}
              success:^(AFHTTPRequestOperation *operation, id responseObject){
                  
                  NSLog(@"로그인 코드 : %@",[responseObject objectForKey:@"status"]);
                  
                  if ([[responseObject objectForKey:@"status"] isEqualToNumber:@SUCCESS_STATUS]) {
                      
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
    
    else {
        SIAlertView *alert = [[SIAlertView alloc]initWithTitle:@"이메일 형식이 아닙니다." andMessage:@"이메일을 입력해주세요."];
        [alert addButtonWithTitle:@"확인" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView){
            [_emailTextField becomeFirstResponder];
        }];
        [alert show];
    }

}

- (IBAction)showJoinVC:(id)sender {
    L3JoinViewController *joinVC = [_storyBoard instantiateViewControllerWithIdentifier:@"joinViewController"];
    
    [self presentViewController:joinVC animated:NO completion:nil];
}

#pragma mark - etc

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
