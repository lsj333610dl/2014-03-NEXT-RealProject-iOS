//
//  L3InputViewController.m
//  snapshop
//
//  Created by 이상진 on 2014. 11. 20..
//  Copyright (c) 2014년 EntusApps. All rights reserved.
//

#import "L3InputViewController.h"

#import "AFNetworking.h"

@interface L3InputViewController ()

@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewBottomContraint;
@property (nonatomic) CGRect keyboardBounds;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *titleTextfield;
@property (weak, nonatomic) IBOutlet UITextField *urlTextfield;
@property (weak, nonatomic) IBOutlet UITextField *contentsTextfield;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;


@end

@implementation L3InputViewController

@synthesize keyboardBounds;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_image) {
        [self.imageView setImage:_image];
    }
    
//    if (_titleString) {
//        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[_titleString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//        _titleTextfield.attributedText = attributedString;
//    }
    
    _titleTextfield.text = _titleString;
    self.urlTextfield.text = _urlString;
    
    [self.cancelButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.cancelButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.cancelButton.layer setShadowOpacity:0.5f];
    
    [self.saveButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [self.saveButton.layer setShadowOffset:CGSizeMake(1, 1)];
    [self.saveButton.layer setShadowOpacity:0.5f];
    
    [self setupTextfield:self.titleTextfield];
    [self setupTextfield:self.urlTextfield];
    [self setupTextfield:self.contentsTextfield];

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

- (void)setupTextfield:(UITextField*)tf{
    [tf.layer setShadowOpacity:1.0f];
    [tf.layer setShadowOffset:CGSizeMake(1, 1)];
    [tf.layer setShadowColor:[UIColor blackColor].CGColor];
    
    [tf setValue:[UIColor colorWithRed:220.0/255.0 green:220.0/255.0 blue:220.0/255.0 alpha:1.0] forKeyPath:@"_placeholderLabel.textColor"];
    [tf setTintColor:[UIColor colorWithRed:227/255.0f green:90/255.0f blue:102/255.0f alpha:1.0f]];
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
    
    
    
    
    NSData *imageData = UIImageJPEGRepresentation(_imageView.image, 0.5);
    [self saveImage:imageData forImageName:@"testImage.jpg"];
    
    
}


-(void) saveImage: (NSData *)imageData forImageName:(NSString*)imageName{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *imagePostUrl = @"http://10.73.45.133:8080/app/posts/new";
    
    NSDictionary *parameters = @{@"title":_titleTextfield.text,
                                 @"shopUrl":_urlTextfield.text,
                                 @"contents":_contentsTextfield.text,
                                 @"price":@"123123",
                                 @"id":@"test@example.com"};
    
    [manager POST:imagePostUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:imageName mimeType:@"image/jpeg"];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@,%@",operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[error localizedDescription]);
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
