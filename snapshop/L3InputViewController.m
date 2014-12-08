//
//  L3InputViewController.m
//  snapshop
//
//  Created by 이상진 on 2014. 11. 20..
//  Copyright (c) 2014년 EntusApps. All rights reserved.
//

#import "L3InputViewController.h"

#import "AFNetworking.h"
#import "L3TextField.h"
#import "AppDelegate.h"

#define SUCCESS_STATUS @"10"

@interface L3InputViewController ()

@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottomContraint;
@property (nonatomic) CGRect keyboardBounds;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet L3TextField *titleTextfield;
@property (weak, nonatomic) IBOutlet L3TextField *urlTextfield;
@property (weak, nonatomic) IBOutlet L3TextField *contentsTextfield;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) AppDelegate *delegate;
@property (weak, nonatomic) IBOutlet L3TextField *priceTextfield;


@end

@implementation L3InputViewController

@synthesize keyboardBounds;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_image) {
        [self.imageView setImage:_image];
    }
    
    _delegate = [[UIApplication sharedApplication]delegate];
    
    self.titleTextfield.text = _titleString;
    self.urlTextfield.text = _urlString;
    self.priceTextfield.text = _priceString;

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [_titleTextfield becomeFirstResponder];
    
}


#pragma mark - keyboardAnimation

- (void)keyboardWillAnimate:(NSNotification *)notification
{
    
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    if( ([notification name] == UIKeyboardWillShowNotification)  )
    {
        self.inputViewBottomContraint.constant = keyboardBounds.size.height;
        [self.view layoutIfNeeded];
    }
    
    else if( ([notification name] == UIKeyboardWillHideNotification) )
    {
        self.inputViewBottomContraint.constant -= keyboardBounds.size.height;
        [self.view layoutIfNeeded];
    }
    
    [UIView commitAnimations];
}

- (void)removeKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - IBAction

- (IBAction)cancel:(id)sender{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)save:(id)sender{
    
    ///1. imageUrl로
//    [self savePostWithImageUrlString:@"http://cfile217.uf.daum.net/image/1505C9384DC8E7BF1FF9F2"];
    
    
    ///2. image파일로
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yy-MM-dd-hh:mm:ss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    
    NSData *imageData = UIImageJPEGRepresentation(_imageView.image, 0.5);
    [self savePostWithImageData:imageData imageName:[NSString stringWithFormat:@"%zd_%@_%@.jpeg",_delegate.uid,_titleTextfield.text,dateString]];
    
    
}

-(void)savePostWithImageUrlString:(NSString*)imageUrlString{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *imagePostUrl = @"http://125.209.199.221:8080/app/posts/newurl";
    
    NSDictionary *parameters = @{@"title":_titleTextfield.text,
                                 @"shopUrl":_urlTextfield.text,
                                 @"contents":_contentsTextfield.text,
                                 @"price":_priceTextfield.text,
                                 @"id":[NSNumber numberWithInteger:_delegate.uid],
                                 @"image":imagePostUrl};
    NSLog(@"uid : %zd",_delegate.uid);
    NSLog(@"파라미터 : %@",parameters);
    
    [manager POST:imagePostUrl
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              
              if ([responseObject[@"status"] isEqualToNumber:@10]) {
                  [self dismissViewControllerAnimated:YES completion:nil];
                  [[NSNotificationCenter defaultCenter]postNotificationName:@"SaveSuccess" object:nil];
              }
              
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"%@",[error localizedDescription]);
              NSLog(@"%@",operation);
              [[[UIAlertView alloc]initWithTitle:@"저장 실패" message:@"저장에 실패했습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil] show];
          }];
}

-(void)savePostWithImageData:(NSData*)imageData imageName:(NSString*)imageName{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *imagePostUrl = @"http://125.209.199.221:8080/app/posts/new";
    
    NSDictionary *parameters = @{@"title":_titleTextfield.text,
                                 @"shopUrl":_urlTextfield.text,
                                 @"contents":_contentsTextfield.text,
                                 @"price":_priceTextfield.text,
                                 @"id":[NSNumber numberWithInteger:_delegate.uid]};
    NSLog(@"파라미터 : %@",parameters);
    
    [manager POST:imagePostUrl
       parameters:parameters
constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:imageName mimeType:@"image/jpeg"];
    
        NSLog(@"imageName : %@",imageName);
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject[@"status"] isEqualToNumber:@10]) {
            NSLog(@"저장 성공");
            [self dismissViewControllerAnimated:YES completion:nil];
            
            [[NSNotificationCenter defaultCenter]postNotificationName:@"SavePost" object:nil];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
        NSLog(@"%@",operation);
        
        [[[UIAlertView alloc]initWithTitle:@"저장 실패" message:@"저장에 실패했습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil] show];
    }];
}


#pragma mark - etc

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
//     resignFirstResponder];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}


@end
