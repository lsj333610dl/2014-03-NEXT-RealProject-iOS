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
#import "L3NaverSearchViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "L3MainTableViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define COLOR_MAIN UIColorFromRGB(0xE35A66)

@interface ViewController () <UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControll;
@property (strong, nonatomic) UIStoryboard *storyBoard;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSMutableArray *resultArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) SIAlertView *alertView;
@property (strong, nonatomic) UIImagePickerController *imgPicker;

@end

@implementation ViewController

@synthesize alertView;
@synthesize imgPicker;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    
    _storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    _manager = [AFHTTPRequestOperationManager manager];
    _resultArray = [NSMutableArray new];
    
    [self reloadTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"SavePost" object:nil];



    imgPicker = [UIImagePickerController new];
    [imgPicker setDelegate:(id)self];
    [imgPicker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : COLOR_MAIN}];
    [imgPicker setAllowsEditing:YES];

    alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"사진 추가하기", @"사진 추가하기") andMessage:NSLocalizedString(@"사진을 추가할 방법을 선택하세요.", @"사진을 추가할 방법을 선택하세요.")];


    [alertView addButtonWithTitle:NSLocalizedString(@"카메라로 사진 촬영", @"카메라로 사진 촬영")
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *siAlertView){

                              [imgPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                              [self presentViewController:imgPicker animated:NO completion:^{
                                  NSLog(@"사진촬영 띄우기 완료");
                              }];
                          }];

    [alertView addButtonWithTitle:NSLocalizedString(@"앨범에서 불러오기", @"앨범에서 불러오기")
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *siAlertView){

                              [imgPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                              [self presentViewController:imgPicker animated:NO completion:nil];
                          }];

    [alertView addButtonWithTitle:NSLocalizedString(@"웹에서 이미지 검색", @"웹에서 이미지 검색")
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *siAlertView){
                              L3NaverSearchViewController *searchViewController = [_storyBoard instantiateViewControllerWithIdentifier:@"naverSearchViewController"];
                              [self presentViewController:searchViewController animated:YES completion:nil];
                          }];

    [alertView addButtonWithTitle:NSLocalizedString(@"취소", @"취소") type:SIAlertViewButtonTypeCancel handler:nil];

}

- (void)reloadTable{
    NSLog(@"로드로드!");
    [_manager GET:@"http://125.209.199.221:8080/app/posts/"
       parameters:@{@"sort":@1,@"start":@1}
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              NSLog(@"%@",responseObject[@"response"][@"data"]);
              _resultArray = responseObject[@"response"][@"data"];
              [_tableView reloadData];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              
          }];
    
}

- (IBAction)add:(id)sender {

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
    
    L3InputViewController *inputViewController = [_storyBoard instantiateViewControllerWithIdentifier:@"inputViewController"];
    
    [inputViewController setImage:image];
    //    [contentsViewController.blurredImageView setImageToBlur:image blurRadius:20.0f completionBlock:^{
    //    }];
    [self presentViewController:inputViewController animated:YES completion:nil];
    
}



#pragma mark - tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_resultArray count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    L3MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    
    [cell.bgImageView sd_setImageWithURL:_resultArray[indexPath.row][@"imgUrl"]];
    [cell.titleLabel setText:_resultArray[indexPath.row][@"title"]];
//    
//    if ([_resultArray[indexPath.row][@"hprice"] integerValue] == 0) {
//        
//        NSNumber *lprice = [formatter numberFromString:[_resultArray[indexPath.row][@"lprice"] stringValue]];
//        NSString *lpriceString = [formatter stringFromNumber:lprice];
//        cell.priceLabel.text = [NSString stringWithFormat:@"%@원",lpriceString];
//    }
//    else {
//        
//        NSNumber *lprice = [formatter numberFromString:[_resultArray[indexPath.row][@"lprice"] stringValue]];
//        NSString *lpriceString = [formatter stringFromNumber:lprice];
//        
//        NSNumber *hprice = [formatter numberFromString:[_resultArray[indexPath.row][@"hprice"] stringValue]];
//        NSString *hpriceString = [formatter stringFromNumber:hprice];
//        
//        cell.priceLabel.text = [NSString stringWithFormat:@"%@원 ~ %@원",lpriceString,hpriceString];
//    }
//    
//    
//    if ( (indexPath.row == [_resultArray count]-1) && !_isLoading && _total>(_start+DISPLAY)) {
//        _isLoading = YES;
//        [self loadMore];
//        NSLog(@"좀더");
//    }
    
    return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    
//    //    NSURL *url = [NSURL URLWithString:_resultArray[indexPath.row][@"link"]];
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    L3InputViewController *inputVC = [storyBoard instantiateViewControllerWithIdentifier:@"inputViewController"];
//    
//    inputVC.urlString = _resultArray[indexPath.row][@"link"];
//    inputVC.titleString = _searchBar.text;
//    inputVC.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_resultArray[indexPath.row][@"image"]]]];
//    
//    NSLog(@"%@",_resultArray[indexPath.row][@"image"]);
//    //    inputVC.priceString = _resultArray[indexPath.row][@"lprice"];
//    
//    [self presentViewController:inputVC animated:YES completion:^{
//        //        [self dismissViewControllerAnimated:NO completion:nil];
//    }];
//    
//}


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
