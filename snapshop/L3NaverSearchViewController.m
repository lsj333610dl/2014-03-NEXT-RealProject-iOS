//
//  L3NaverSearchViewController.m
//  snapshop
//
//  Created by 이상진 on 2014. 11. 20..
//  Copyright (c) 2014년 EntusApps. All rights reserved.
//

#import "L3NaverSearchViewController.h"
#import "AFNetworking/AFNetworking.h"
#import "SIAlertView.h"
#import "L3NaverSearchTableViewCell.h"
#import "L3InputViewController.h"

#import "UIImageView+WebCache.h"



#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define COLOR_MAIN UIColorFromRGB(0x4EC598)

@interface L3NaverSearchViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSMutableArray *resultArray;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortSeg;
@property (nonatomic) NSUInteger start;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) NSUInteger total;

@end

const NSInteger DISPLAY = 20;

@implementation L3NaverSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchBar.delegate = self;
    self.searchBar.tintColor = COLOR_MAIN;
    [_searchBar becomeFirstResponder];
    
    self.manager = [AFHTTPRequestOperationManager manager];
    self.resultArray = [NSMutableArray new];
    
    self.start = 1;
    self.isLoading = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(close:) name:@"SavePost" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    L3NaverSearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    [cell.itemImageView sd_setImageWithURL:_resultArray[indexPath.row][@"image"]];
    [cell.titleLabel setText:_resultArray[indexPath.row][@"title"]];
    [cell.mallNameLabel setText:_resultArray[indexPath.row][@"mallName"]];
    
    
    if ([_resultArray[indexPath.row][@"hprice"] integerValue] == 0) {
        
        NSNumber *lprice = [formatter numberFromString:[_resultArray[indexPath.row][@"lprice"] stringValue]];
        NSString *lpriceString = [formatter stringFromNumber:lprice];
        cell.priceLabel.text = [NSString stringWithFormat:@"%@원",lpriceString];
    }
    else {
        
        NSNumber *lprice = [formatter numberFromString:[_resultArray[indexPath.row][@"lprice"] stringValue]];
        NSString *lpriceString = [formatter stringFromNumber:lprice];
        
        NSNumber *hprice = [formatter numberFromString:[_resultArray[indexPath.row][@"hprice"] stringValue]];
        NSString *hpriceString = [formatter stringFromNumber:hprice];
        
        cell.priceLabel.text = [NSString stringWithFormat:@"%@원 ~ %@원",lpriceString,hpriceString];
    }
    
    
    if ( (indexPath.row == [_resultArray count]-1) && !_isLoading && _total>(_start+DISPLAY)) {
        _isLoading = YES;
        [self loadMore];
        NSLog(@"좀더");
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
//    NSURL *url = [NSURL URLWithString:_resultArray[indexPath.row][@"link"]];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    L3InputViewController *inputVC = [storyBoard instantiateViewControllerWithIdentifier:@"inputViewController"];
    
    inputVC.urlString = _resultArray[indexPath.row][@"link"];
    inputVC.titleString = _searchBar.text;
    inputVC.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_resultArray[indexPath.row][@"image"]]]];
//    inputVC.priceString = [_resultArray[indexPath.row][@"price"] stringValue];
    
    inputVC.priceString = [_resultArray[indexPath.row][@"lprice"] stringValue];
    
    
//    if ([_resultArray[indexPath.row][@"hprice"] integerValue] == 0) {
//        
//        NSNumber *lprice = [formatter numberFromString:[_resultArray[indexPath.row][@"lprice"] stringValue]];
//        NSString *lpriceString = [formatter stringFromNumber:lprice];
//        inputVC.priceString = [NSString stringWithFormat:@"%@원",lpriceString];
//    }
//    else {
//        
//        NSNumber *lprice = [formatter numberFromString:[_resultArray[indexPath.row][@"lprice"] stringValue]];
//        NSString *lpriceString = [formatter stringFromNumber:lprice];
//        
//        NSNumber *hprice = [formatter numberFromString:[_resultArray[indexPath.row][@"hprice"] stringValue]];
//        NSString *hpriceString = [formatter stringFromNumber:hprice];
//        
//        inputVC.priceString = [NSString stringWithFormat:@"%@원 ~ %@원",lpriceString,hpriceString];
//    }
//    
    [self presentViewController:inputVC animated:YES completion:^{
    }];
    
}



- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - IBAction
- (IBAction)close:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"SavePost" object:nil];
    NSLog(@"???");
}
- (IBAction)segValueChange:(id)sender {
    if ([_searchBar.text isEqualToString:@""]) {
        return;
    }
    
    [self searchBarSearchButtonClicked:_searchBar];
}

#pragma mark - SearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    [_tableView setContentOffset:CGPointMake(0, 0) animated:NO];
    
    NSString *sortKey;
    
    switch (_sortSeg.selectedSegmentIndex) {
        case 0:
            sortKey = @"sim";
            break;
        case 1:
            sortKey = @"date";
            break;
        case 2:
            sortKey = @"dsc";
            break;
        case 3:
            sortKey = @"asc";
            break;
            
        default:
            break;
    }
    
    _start = 1;
    
    [_manager GET:@"http://125.209.199.221:8080/search/shop"
       parameters:@{@"query":searchBar.text,
                    @"display":[NSNumber numberWithInteger:DISPLAY],
                    @"start":[NSNumber numberWithInteger:_start],
                    @"sort":sortKey}
          success:^(AFHTTPRequestOperation *operation, id responseObject){
              [self.view endEditing:YES];
              
              
              if ([responseObject[@"response"][@"data"] isEqual:[NSNull null]]) {
                  SIAlertView *alert = [[SIAlertView alloc]initWithTitle:@"검색 결과가 없습니다." andMessage:@"다른 검색어로 검색해 보세요."];
                  [alert addButtonWithTitle:@"오키" type:SIAlertViewButtonTypeCancel handler:nil];
                  [alert show];
                  return;
              }
              
              _total = [responseObject[@"response"][@"data"][@"total"] integerValue];
              self.resultArray = [responseObject[@"response"][@"data"][@"list"] mutableCopy];
              
              [_tableView reloadData];
              
              
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error){
              NSLog(@"%@",[error localizedDescription]);
          }];
    
}


- (void)loadMore{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(globalQueue, ^{
        
        dispatch_async(mainQueue, ^{
            [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
        });
        _isLoading = YES;
        [self searchMore];
        
    });
}

- (void)searchMore{
    //로딩이면
    if (_isLoading) {
        NSString *sortKey;
        
        switch (_sortSeg.selectedSegmentIndex) {
            case 0:
                sortKey = @"sim";
                break;
            case 1:
                sortKey = @"date";
                break;
            case 2:
                sortKey = @"dsc";
                break;
            case 3:
                sortKey = @"asc";
                break;
                
            default:
                break;
        }
        
        _start+=DISPLAY;
        NSLog(@"%zd",_start);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
            
            [_manager GET:@"http://125.209.199.221:8080/search/shop"
               parameters:@{@"query":_searchBar.text,
                            @"display":[NSNumber numberWithInteger:DISPLAY],
                            @"start":[NSNumber numberWithInteger:_start],
                            @"sort":sortKey}
                  success:^(AFHTTPRequestOperation *operation, id responseObject){
                      [self.view endEditing:YES];
                      
                      for (id object in responseObject[@"response"][@"data"][@"list"]) {
                          [self.resultArray addObject:object];
                          
                          [_tableView reloadData];
                      }
                      
                      
                      
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error){
                      NSLog(@"%@",[error localizedDescription]);
                  }];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"끝났다.");
                _isLoading = NO;
                
                [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
            });
        });
        
    }
    
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
