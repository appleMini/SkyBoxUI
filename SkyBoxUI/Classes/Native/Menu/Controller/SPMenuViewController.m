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

- (void)selectMenuItem:(NSInteger)index {
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _dataArr = @[@{@"iconName":@"" , @"item": @"LOCAL FILES", @"VC" : @"SPHomeViewController"}, @{@"iconName":@"" , @"item": @"VR VIDEOS", @"VC" : @"SPVRViewController"},
                 @{@"iconName":@"" , @"item": @"LOCAL NETWORK", @"VC" : @"SPNetworkViewController"}, @{@"iconName":@"" , @"item": @"AIRSCREEN", @"VC" : @"SPAirScreenViewController"},
                 @{@"iconName":@"" , @"item": @"ONLINE STREAM", @"VC" : @"SPOnlineViewController"}, @{@"iconName":@"" , @"item": @"FAVORITE", @"VC" : @"SPFavoriteViewController"}];
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        adjustsScrollViewInsets(_tableView);
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[SPMenuCell class] forCellReuseIdentifier:cellID];
        
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            CGFloat top = 0;
            if (@available(iOS 11.0, *)) {
                top = self.view.safeAreaInsets.top;
            } else {
                top = 0;
            }
            make.leading.mas_equalTo(0);
            make.trailing.mas_equalTo(0);
            make.top.mas_equalTo(top);
            make.bottom.mas_equalTo(-(kWSCALE*49));
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
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
    return  cell;
}

#pragma -mark tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(MenuViewController: jumpViewController:)]) {
        [self.delegate MenuViewController:self jumpViewController:_dataArr[indexPath.row][@"VC"]];
    }
}

@end
