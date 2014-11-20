//
//  ViewController.m
//  snapshop
//
//  Created by 이상진 on 2014. 11. 3..
//  Copyright (c) 2014년 EntusApps. All rights reserved.
//

#import "ViewController.h"
#import "SIAlertView/SIAlertView.h"
#import "L3InputViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define COLOR_MAIN UIColorFromRGB(0xE35A66)

@interface ViewController () <UIImagePickerControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (IBAction)add:(id)sender {

    UIImagePickerController *picker = [UIImagePickerController new];
    [picker setDelegate:(id)self];
    [picker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : COLOR_MAIN}];
    [picker setAllowsEditing:YES];
    
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"사진 추가하기", @"사진 추가하기") andMessage:NSLocalizedString(@"티켓에 사진을 추가할 방법을 선택하세요.", @"티켓에 사진을 추가할 방법을 선택하세요.")];
    
    
    [alertView addButtonWithTitle:NSLocalizedString(@"카메라로 사진 촬영", @"카메라로 사진 촬영")
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *siAlertView){
                              
                              [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
                              [self presentViewController:picker animated:NO completion:^{
                                  NSLog(@"사진촬영 띄우기 완료");
                              }];
                          }];
    
    [alertView addButtonWithTitle:NSLocalizedString(@"앨범에서 불러오기", @"앨범에서 불러오기")
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *siAlertView){
                              
                              [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                              [self presentViewController:picker animated:NO completion:nil];
                          }];
    
    [alertView addButtonWithTitle:NSLocalizedString(@"웹에서 이미지 검색", @"웹에서 이미지 검색")
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *siAlertView){
//                              
//                              SJWebSearchCollectionViewController *search = [[UIStoryboard storyboardWithName:@"Main" bundle: nil] instantiateViewControllerWithIdentifier:@"webImageSearchViewController"];
//                              [self presentViewController:search animated:YES completion:nil];
                              
                              
                          }];
    
    [alertView addButtonWithTitle:NSLocalizedString(@"취소", @"취소") type:SIAlertViewButtonTypeCancel handler:nil];
    
    [alertView show];


}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    
    [picker dismissViewControllerAnimated:NO completion:nil];
    [self showInputView:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)showInputView:(UIImage*)image{
    UIStoryboard *Main = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    L3InputViewController *inputViewController = [Main instantiateViewControllerWithIdentifier:@"inputViewController"];
    
    [inputViewController setImage:image];
    //    [contentsViewController.blurredImageView setImageToBlur:image blurRadius:20.0f completionBlock:^{
    //    }];
    [self presentViewController:inputViewController animated:YES completion:nil];
    
}

#pragma mark - etc

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end
