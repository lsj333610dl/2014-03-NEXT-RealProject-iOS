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
#import "AppDelegate.h"
#import "ODRefreshControl.h"
#import "TOWebViewController/TOWebViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define COLOR_MAIN UIColorFromRGB(0x4EC598)

@interface ViewController () <UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate>{
    AppDelegate *delegate;
    ODRefreshControl *refreshControl;
}

@property (strong, nonatomic) UIStoryboard *storyBoard;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSMutableArray *resultArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) SIAlertView *alertView;
@property (strong, nonatomic) UIImagePickerController *imgPicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSeg;

@property (nonatomic) NSUInteger start;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) NSUInteger total;

@end

@implementation ViewController


@synthesize alertView;
@synthesize imgPicker;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
    
    delegate = [[UIApplication sharedApplication]delegate];
    _storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    _manager = [AFHTTPRequestOperationManager manager];
    _resultArray = [NSMutableArray new];
    
    _start = 1;
    
    [self reloadTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"SavePost" object:nil];


    imgPicker = [UIImagePickerController new];
    [imgPicker setDelegate:(id)self];
    [imgPicker.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : COLOR_MAIN}];
    [imgPicker setAllowsEditing:YES];

    alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"사진 추가하기", @"사진 추가하기") andMessage:NSLocalizedString(@"사진을 추가할 방법을 선택하세요.", @"사진을 추가할 방법을 선택하세요.")];

    UIImagePickerController __block *blockPicker = imgPicker;
    ViewController __block *blockSelf = self;
    UIStoryboard __block *blockStoryboard = _storyBoard;
    
    [alertView addButtonWithTitle:NSLocalizedString(@"카메라로 사진 촬영", @"카메라로 사진 촬영")
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *siAlertView){

                              [blockPicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                              [blockSelf presentViewController:blockPicker animated:NO completion:^{
                                  NSLog(@"사진촬영 띄우기 완료");
                              }];
                          }];

    [alertView addButtonWithTitle:NSLocalizedString(@"앨범에서 불러오기", @"앨범에서 불러오기")
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *siAlertView){

                              [blockPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                              [blockSelf presentViewController:blockPicker animated:NO completion:nil];
                          }];

    [alertView addButtonWithTitle:NSLocalizedString(@"웹에서 이미지 검색", @"웹에서 이미지 검색")
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *siAlertView){
                              L3NaverSearchViewController *searchViewController = [blockStoryboard instantiateViewControllerWithIdentifier:@"naverSearchViewController"];
                              [blockSelf presentViewController:searchViewController animated:YES completion:nil];
                          }];

    [alertView addButtonWithTitle:NSLocalizedString(@"취소", @"취소") type:SIAlertViewButtonTypeCancel handler:nil];

    //refresh
    refreshControl = [[ODRefreshControl alloc] initInScrollView:_tableView];
//    [refreshControl setFrame:CGRectOffset(refreshControl.frame, 0, 64)];
    [refreshControl addTarget:self action:@selector(reloadTable) forControlEvents:UIControlEventValueChanged];
    [refreshControl setTintColor:COLOR_MAIN];
    
    
//    [_manager DELETE:@"http://125.209.199.221:8080/app/posts/delete/31" parameters:@{@"uid":@6} success:nil failure:nil];
    
}

- (void)reloadTable{
    NSLog(@"로드로드!");
    [_tableView setContentOffset:CGPointZero animated:NO];
    
    _start = 1;
    
    [_manager GET:@"http://125.209.199.221:8080/app/posts/"
       parameters:@{@"sort":[NSNumber numberWithInteger:_sortSeg.selectedSegmentIndex],
                    @"start":[NSNumber numberWithUnsignedInteger:_start],
                    @"id":[NSNumber numberWithInteger:delegate.uid]}
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              _total = [responseObject[@"response"][@"total"] unsignedIntegerValue];
              
              [_resultArray removeAllObjects];
              
              for (id object in responseObject[@"response"][@"data"]) {
                  [_resultArray addObject:object];
              }
              
              NSLog(@"%@",_resultArray);
              [_tableView reloadData];
              [refreshControl endRefreshing];
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              NSLog(@"에러 : %@",error);
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
    
    inputViewController.image = image;
//    [inputViewController setImage:image];
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
    
    NSNumber *priceNumber = [formatter numberFromString:_resultArray[indexPath.row][@"price"] ];
    NSString *priceString = [formatter stringFromNumber:priceNumber];
    
    
    [cell.bgImageView sd_setImageWithURL:_resultArray[indexPath.row][@"imgUrl"]];
    [cell.titleLabel setText:_resultArray[indexPath.row][@"title"]];
    [cell.writerLabel setText:_resultArray[indexPath.row][@"writer"]];
    [cell.priceLabel setText:[NSString stringWithFormat:@"%@원",priceString]];
    
    
    if ( (indexPath.row == [_resultArray count]-1) && !_isLoading ) {
        _isLoading = YES;
        [self loadMore];
        NSLog(@"좀더");
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    if ([_resultArray[indexPath.row][@"shopUrl"] isEqualToString:@""]) {
        return;
    }
    
    NSString *readUrlString = [NSString stringWithFormat:@"http://125.209.199.221:8080/app/posts/%zd/read",[_resultArray[indexPath.row][@"pid"] integerValue]];
    
    [_manager POST:readUrlString
        parameters:@{@"pid":_resultArray[indexPath.row][@"pid"]}
           success:^(AFHTTPRequestOperation *op, id ro){
               NSLog(@"%@",ro);
    }
           failure:^(AFHTTPRequestOperation *op, NSError *error){
               NSLog(@"%@",error);
           }];
    
    NSURL *url = [NSURL URLWithString:_resultArray[indexPath.row][@"shopUrl"]];
    TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:url];
    
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:webViewController] animated:YES completion:nil];
    
}


- (void)loadMore{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(globalQueue, ^{
        
        dispatch_async(mainQueue, ^{
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        });
        _isLoading = YES;
        
        
        if (_isLoading) {
            
            _start+=1;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                
                [_manager GET:@"http://125.209.199.221:8080/app/posts/"
                   parameters:@{@"sort":[NSNumber numberWithInteger:_sortSeg.selectedSegmentIndex],
                                @"start":[NSNumber numberWithUnsignedInteger:_start],
                                @"id":[NSNumber numberWithInteger:delegate.uid]}
                 
                      success:^(AFHTTPRequestOperation *operation, id responseObject){
                          NSLog(@"성공 %@",responseObject);
                          for (id object in responseObject[@"response"][@"data"]) {
                              [_resultArray addObject:object];
                              [_tableView reloadData];
                          }
                          
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error){
                          NSLog(@"에러 : %@",error);
                      }];

                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"끝났다.");
                    _isLoading = NO;
                    
                    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                });
            });
            
        }
        
    });
}


- (IBAction)segValueChang:(id)sender {
    
    [self reloadTable];
    
}

- (IBAction)logout:(id)sender {
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    [appDelegate.window setRootViewController:[_storyBoard instantiateViewControllerWithIdentifier:@"loginViewController"]];
    
    
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
