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
#import "SVProgressHUD.h"
#import "L3DetailViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define COLOR_MAIN UIColorFromRGB(0x4EC598)

typedef enum : NSUInteger {
    ContentsModeFeed=1,
    ContentsModeSnaps=2,
    ContentsModePosts=3,
} ContentsMode;

@interface ViewController () <UIImagePickerControllerDelegate,UITableViewDataSource,UITableViewDelegate>{
    AppDelegate *delegate;
    ODRefreshControl *refreshControl;
    ContentsMode contentsMode;
}

@property (strong, nonatomic) UIStoryboard *storyBoard;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSMutableArray *resultArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) SIAlertView *alertView;
@property (strong, nonatomic) UIImagePickerController *imgPicker;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSeg;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (nonatomic) L3DetailViewController *detailVC;

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
    contentsMode = ContentsModeFeed;
    _start = 1;
    
    [self reloadTable];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"SavePost" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTable) name:@"ReloadData" object:nil];


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
    
    
    _detailVC = [_storyBoard instantiateViewControllerWithIdentifier:@"detailViewController"];
    
}

- (void)reloadTable{
    NSLog(@"로드로드!");
    [_tableView setContentOffset:CGPointZero animated:NO];
    
    _start = 1;
    
    switch (contentsMode) {
        case ContentsModeFeed:{
            [_manager GET:@"http://125.209.199.221:8080/app/posts/"
               parameters:@{@"sort":[NSNumber numberWithInteger:_sortSeg.selectedSegmentIndex],
                            @"start":[NSNumber numberWithUnsignedInteger:_start],
                            @"id":[NSNumber numberWithInteger:delegate.uid]}
                  success:^(AFHTTPRequestOperation *operation, id responseObject){
                      _total = [responseObject[@"total"] unsignedIntegerValue];
                      
                      [_resultArray removeAllObjects];
                      
                      for (id object in responseObject[@"data"]) {
                          [_resultArray addObject:object];
                      }
                      
                      NSLog(@"%@",responseObject);
                      [_tableView reloadData];
                      [refreshControl endRefreshing];
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error){
                      NSLog(@"에러 : %@",error);
                  }];
        }
            break;
            
        case ContentsModePosts:
            [self showPosts:nil];
            break;
            
        case ContentsModeSnaps:
            [self showSnaps:nil];
            break;
            
        default:
            break;
    }
    
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
    [self presentViewController:inputViewController animated:YES completion:^{
//        NSLog(@"ed:%@, ing:%@",[self presentedViewController],[self presentingViewController]);
    }];
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
    [cell.snapCountLabel setText:[NSString stringWithFormat:@"%zd snaps",[_resultArray[indexPath.row][@"numLike"] integerValue]]];
    
    if ([(NSNumber*)_resultArray[indexPath.row][@"like"] isEqualToNumber:@1]) {
        NSLog(@"좋아연,%@",_resultArray[indexPath.row][@"like"]);
        cell.likeButton.tag = 1;
        [cell snaped];
    }
    
    else{
        cell.likeButton.tag = 0;
        [cell unsnap];
    }
    
    
    
    if ( (indexPath.row == [_resultArray count]-1) && !_isLoading && _total>_resultArray.count) {
        
        NSLog(@"%zd,%zd",_total,_resultArray.count);
        
        _isLoading = YES;
        [self loadMore];
        NSLog(@"좀더");
    }

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
 
    [SVProgressHUD showWithStatus:@"Loading..."];
    
    _detailVC.data = _resultArray[indexPath.row];
    [_detailVC reloadData];
    [self presentViewController:_detailVC animated:YES completion:^{
        [SVProgressHUD dismiss];
    }];
    
    return;
    
}


- (void)loadMore{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(globalQueue, ^{
        
        dispatch_async(mainQueue, ^{
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
            [SVProgressHUD show];
        });
        _isLoading = YES;
        
        
        if (_isLoading) {
            
            _start+=1;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                switch (contentsMode) {
                    case ContentsModeFeed:{
                        [_manager GET:@"http://125.209.199.221:8080/app/posts/"
                           parameters:@{@"sort":[NSNumber numberWithInteger:_sortSeg.selectedSegmentIndex],
                                        @"start":[NSNumber numberWithUnsignedInteger:_start],
                                        @"id":[NSNumber numberWithInteger:delegate.uid]}
                         
                              success:^(AFHTTPRequestOperation *operation, id responseObject){
                                  NSLog(@"성공 %@",responseObject);
                                  for (id object in responseObject[@"data"]) {
                                      [_resultArray addObject:object];
                                      [_tableView reloadData];
                                  }
                                  
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                  NSLog(@"에러 : %@",error);
                              }];

                    }
                        break;
                    case ContentsModeSnaps:{
                        NSString *mySnapsUrlString = [NSString stringWithFormat:@"http://125.209.199.221:8080/app/posts/%zd/likes",delegate.uid];
                        
                        [_manager GET:mySnapsUrlString
                           parameters:@{@"start":[NSNumber numberWithUnsignedInteger:_start]}
                              success:^(AFHTTPRequestOperation *operation, id responseObject){
                                  _total = [responseObject[@"total"] unsignedIntegerValue];
                                  
                                  for (id object in responseObject[@"data"]) {
                                      [_resultArray addObject:object];
                                      [_tableView reloadData];
                                  }
                                  
                                  [refreshControl endRefreshing];
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                  NSLog(@"에러 : %@",error);
                              }];
                    }
                        break;
                    case ContentsModePosts:{
                        
                        NSString *myPostsUrlString = [NSString stringWithFormat:@"http://125.209.199.221:8080/app/posts/%zd/posts",delegate.uid];
                        
                        [_manager GET:myPostsUrlString
                           parameters:@{@"start":[NSNumber numberWithUnsignedInteger:_start]}
                              success:^(AFHTTPRequestOperation *operation, id responseObject){
                                  _total = [responseObject[@"total"] unsignedIntegerValue];
                                  
                                  for (id object in responseObject[@"data"]) {
                                      [_resultArray addObject:object];
                                      [_tableView reloadData];
                                  }
                                  
                                  [refreshControl endRefreshing];
                              }
                              failure:^(AFHTTPRequestOperation *operation, NSError *error){
                                  NSLog(@"에러 : %@",error);
                              }];
                    }
                        break;
                        
                    default:
                        break;
                }
                
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"끝났다.");
                    _isLoading = NO;
                    
                    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
                    [SVProgressHUD dismiss];
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


- (IBAction)snap:(UIButton*)sender {
    NSLog(@"snap");
    L3MainTableViewCell *clickedCell = (L3MainTableViewCell *)[[[sender superview] superview] superview];
    NSIndexPath *clickedButtonPath = [self.tableView indexPathForCell:clickedCell];
    
    NSLog(@"%@",@{@"pid":_resultArray[clickedButtonPath.row][@"pid"],@"uid":[NSNumber numberWithInteger:delegate.uid]});
    
    NSString *urlString = [NSString stringWithFormat:@"http://125.209.199.221:8080/app/posts/like?pid=%@&uid=%@",_resultArray[clickedButtonPath.row][@"pid"],[NSNumber numberWithInteger:delegate.uid]];
    
    //snap 추가
    if (sender.tag == 0) {
        [_manager POST:urlString
            parameters:@{@"pid":_resultArray[clickedButtonPath.row][@"pid"],@"uid":[NSNumber numberWithInteger:delegate.uid]} success:^(AFHTTPRequestOperation *op,id ro){
             
                NSLog(@"스냅 성공 : %@",ro);
                sender.tag=1;
                [clickedCell snaped];
            }
         
               failure:^(AFHTTPRequestOperation *op, NSError *error){
                   NSLog(@"에라이 추가 에라다: %@",error);
               }];
    }
    
    //snap 취소
    else if(sender.tag == 1){
        [_manager DELETE:urlString
            parameters:@{@"pid":[NSNumber numberWithInteger:clickedButtonPath.row],@"uid":[NSNumber numberWithInteger:delegate.uid]} success:^(AFHTTPRequestOperation *op,id ro){
                
                NSLog(@"스냅 취소성공 : %@",ro);
                sender.tag=0;
                [clickedCell unsnap];
            }
         
               failure:^(AFHTTPRequestOperation *op, NSError *error){
                   NSLog(@"에라이 취소 에라다 : %@",error);
               }];
    }
    
}

#pragma mark - IBAction
- (IBAction)showFeed:(id)sender {
    
    _topViewHeight.constant = 64;
    [self.view layoutIfNeeded];
    
    _sortSeg.hidden = NO;
    contentsMode = ContentsModeFeed;
    [self reloadTable];
}


- (IBAction)showSnaps:(id)sender {
    
    _topViewHeight.constant = 20;
    [self.view layoutIfNeeded];
    
    contentsMode = ContentsModeSnaps;
    _sortSeg.hidden = YES;
    [_tableView setContentOffset:CGPointZero animated:NO];
    
    _start = 1;
    
    NSString *mySnapsUrlString = [NSString stringWithFormat:@"http://125.209.199.221:8080/app/posts/%zd/likes",delegate.uid];
    
    [_manager GET:mySnapsUrlString
       parameters:@{@"start":[NSNumber numberWithUnsignedInteger:_start]}
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              _total = [responseObject[@"total"] unsignedIntegerValue];
              
              [_resultArray removeAllObjects];
              
              for (id object in responseObject[@"data"]) {
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


- (IBAction)showPosts:(id)sender {
    
    
    _topViewHeight.constant = 20;
    [self.view layoutIfNeeded];
    
    contentsMode = ContentsModePosts;
    _sortSeg.hidden = YES;
    [_tableView setContentOffset:CGPointZero animated:NO];
    _start = 1;
    
    NSString *myPostsUrlString = [NSString stringWithFormat:@"http://125.209.199.221:8080/app/posts/%zd/posts",delegate.uid];
    
    [_manager GET:myPostsUrlString
       parameters:@{@"start":[NSNumber numberWithUnsignedInteger:_start]}
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              _total = [responseObject[@"total"] unsignedIntegerValue];
              
              [_resultArray removeAllObjects];
              
              for (id object in responseObject[@"data"]) {
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
