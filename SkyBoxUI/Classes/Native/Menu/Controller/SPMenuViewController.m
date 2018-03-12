//
//  MenuViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPMenuViewController.h"
#import "SPMenuCell.h"

@interface SPMenuViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSArray *_dataArr;
}

@property (nonatomic, strong) UITableView *tableView;
@end

@implementation SPMenuViewController

static NSString *cellID = @"MenuCell";

- (void)selectMenuItem:(NSInteger)index jump:(BOOL)isScroll {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    isScroll ? [self tableView:self.tableView didSelectRowAtIndexPath:indexPath] : nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//@{@"iconName":@"Channels_icon_online" ,@"highlightIconName":@"Channels_icon_online_active", @"item": @"ONLINE STREAM", @"VC" : @"SPOnlineViewController"},
    _dataArr = @[@{@"iconName":@"Channels_icon_allfiles" , @"highlightIconName":@"Channels_icon_allfiles_active", @"item": @"LOCAL FILES", @"VC" :             @"SPHomeViewController"},
                 @{@"iconName":@"Channels_icon_VRvideos" ,@"highlightIconName":@"Channels_icon_VRvideos_active", @"item": @"VR VIDEOS", @"VC" : @"SPVRViewController"},
                 @{@"iconName":@"Channels_icon_network" ,@"highlightIconName":@"Channels_icon_network_active", @"item": @"LOCAL NETWORK", @"VC" : @"SPNetworkViewController"},
                 @{@"iconName":@"Channels_icon_airscreen" ,@"highlightIconName":@"Channels_icon_airscreen_active", @"item": @"AIRSCREEN", @"VC" : @"SPAirScreenViewController"},
                 
                 @{@"iconName":@"Channels_icon_favorites" ,@"highlightIconName":@"Channels_icon_favorites_active", @"item": @"FAVORITE", @"VC" : @"SPFavoriteViewController"}];
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        adjustsScrollViewInsets(_tableView);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.clipsToBounds = NO;
        [_tableView registerClass:[SPMenuCell class] forCellReuseIdentifier:cellID];
        
        CGFloat top = (SCREEN_HEIGHT - 20 - kWSCALE*94 + kHSCALE*8 - 5 * 80.0) / 2.0;
        _tableView.contentInset = UIEdgeInsetsMake(top, 0, kWSCALE*94 - kHSCALE*8, 0);
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
}

- (NSUInteger)menuCount {
    return _dataArr.count;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)showNavigatinBar {return NO;}
#pragma -mark tableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if(!cell){
        cell = [[SPMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.iconName = _dataArr[indexPath.row][@"iconName"];
    cell.itemName = _dataArr[indexPath.row][@"item"];
    cell.highlightIconName = _dataArr[indexPath.row][@"highlightIconName"];
    return  cell;
}

#pragma -mark tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(MenuViewController: jumpViewController:menuIndex:)]) {
        [self.delegate MenuViewController:self jumpViewController:_dataArr[indexPath.row][@"VC"] menuIndex:indexPath.row];
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
//    headerView.backgroundColor = [UIColor clearColor];
//    return headerView;
//}
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 44.0;
//}

@end
