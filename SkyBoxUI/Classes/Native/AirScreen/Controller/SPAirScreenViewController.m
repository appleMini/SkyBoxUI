//
//  SPAirScreenViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/1.
//

#import "SPAirScreenViewController.h"
#import "SPAirScreenHelpViewController.h"

typedef enum : NSUInteger {
    StartupStatus,
    SearchStatus,
    ResultStatus,
} AirScreenStatus;

@interface SPAirScreenViewController () <UITableViewDelegate, UITableViewDataSource> {
    NSArray *_dataArr;
}
@property (nonatomic, assign) AirScreenStatus status;
@property (nonatomic, strong) UIBarButtonItem *helpItem;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pcImgVTopConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *pcImgV;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *refreshView;
@property (weak, nonatomic) IBOutlet UIView *refreshImgv;

@property (weak, nonatomic) IBOutlet UIView *num1View;
@property (weak, nonatomic) IBOutlet UIView *num2View;
@property (weak, nonatomic) IBOutlet UILabel *instruction1Label;
@property (weak, nonatomic) IBOutlet UILabel *instruction2Label;

@property (nonatomic, strong) UIView *resultView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UILabel *devicesLabel;
@property (nonatomic, strong) UIView *topView;

@end

@implementation SPAirScreenViewController

- (instancetype)initWithSomething {
    self = [super initWithNibName:@"SPAirScreenViewController" bundle:[Commons resourceBundle]];
    if (self) {
        self.status = StartupStatus;
        [self.searchButton setTitle:@"SEARCH DEVICE" forState:UIControlStateNormal];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self updateViewConstraints];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    [self resetViewsAndConstraints];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSString *)titleOfLabelView {
    return @"AIRSCREEN";
}

- (NSArray *)rightNaviItem {
    return @[self.helpItem];
}

- (UIBarButtonItem *)helpItem {
    if (!_helpItem) {
        UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [helpBtn setImage:nil forState:UIControlStateNormal];
        helpBtn.backgroundColor = [UIColor blueColor];
        helpBtn.frame = CGRectMake(0, 0, 40, 40);
        [helpBtn addTarget:self action:@selector(helpItemClick:) forControlEvents:UIControlEventTouchUpInside];
        _helpItem = [[UIBarButtonItem alloc] initWithCustomView:helpBtn];
    }
    return _helpItem;
}

- (void)helpItemClick:(UIButton *)sender {
    SPAirScreenHelpViewController *airScreenHelp = [[SPAirScreenHelpViewController alloc] initWithNibName:@"SPAirScreenHelpViewController" bundle:[Commons resourceBundle]];
    [self presentViewController:airScreenHelp animated:YES completion:nil];
}

- (void)showOrHiddenInstructionViews:(BOOL)hidden {
    _num1View.hidden = hidden;
    _num2View.hidden = hidden;
    
    _instruction1Label.hidden = hidden;
    _instruction2Label.hidden = hidden;
}
- (void)resetViewsAndConstraints {
    switch (_status) {
        case StartupStatus:
        {
            [self.resultView removeFromSuperview];
            _pcImgVTopConstraint.constant = 80*kWSCALE;
            _contentViewHeightConstraint.constant = 80*kWSCALE;
            _refreshView.hidden = YES;
            [self showOrHiddenInstructionViews:NO];
        }
            break;
        case SearchStatus:
        {
            _pcImgVTopConstraint.constant = 80*kWSCALE;
            _contentViewHeightConstraint.constant = 80*kWSCALE;
            [self showOrHiddenInstructionViews:YES];
            _refreshView.hidden = NO;
        }
            break;
        case ResultStatus:
        {
            _pcImgVTopConstraint.constant = [SPDeviceUtil isiPhoneX] ? 40 : 20*kWSCALE;
            _contentViewHeightConstraint.constant = 190*kWSCALE;
            [self showOrHiddenInstructionViews:YES];
            _refreshView.hidden = YES;
            [self.contentView addSubview:self.resultView];
            [self.resultView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0 ));
            }];
        }
            break;
        default:
            break;
    }
}

- (IBAction)searchClick:(id)sender {
    if (_status == StartupStatus) {
        [self.searchButton setTitle:@"CANCEL" forState:UIControlStateNormal];
    }else{
        [self.searchButton setTitle:@"SEARCH DEVICE" forState:UIControlStateNormal];
    }
    
    switch (_status) {
        case StartupStatus:
        {
            _status = SearchStatus;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _dataArr = @[@"AndyAW", @"GQ", @"DESTOP", @"ABCD", @"scaasda", @"fdgdfdfd", @"vdddgd", @"dvdfddfg"];
                
                _status = ResultStatus;
                [self updateViewConstraints];
                [self.tableView reloadData];
            });
        }
            break;
        case SearchStatus:
        {
            _status = StartupStatus;
        }
            break;
        case ResultStatus:
        {
            _status = StartupStatus;
        }
            break;
        default:
            break;
    }
    
    [self updateViewConstraints];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [UIColor darkGrayColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.layer.cornerRadius = 15;
        _tableView.layer.masksToBounds = YES;
    }
    
    return _tableView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        
        _devicesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _devicesLabel.text = @"4 DEVICES FOUND";
        _devicesLabel.font = [UIFont systemFontOfSize:13];
        _devicesLabel.textAlignment = NSTextAlignmentCenter;
        [_devicesLabel sizeToFit];
        [_topView addSubview:_devicesLabel];
        [_devicesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
        }];
        
        //line
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectZero];
        line1.backgroundColor = [UIColor whiteColor];
        [_topView addSubview:line1];
        
        [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(2);
            make.centerY.mas_equalTo(0);
            make.leading.mas_equalTo(5);
            make.trailing.equalTo(_devicesLabel.mas_leading).mas_equalTo(-8);
        }];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectZero];
        line2.backgroundColor = [UIColor whiteColor];
        [_topView addSubview:line2];
        [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(2);
            make.centerY.mas_equalTo(0);
            make.trailing.mas_equalTo(-5);
            make.leading.equalTo(_devicesLabel.mas_trailing).mas_equalTo(8);
        }];
        
    }
    
    return _topView;
}
- (UIView *)resultView {
    if (!_resultView) {
        UIView *reultV = [[UIView alloc] initWithFrame:CGRectZero];
        reultV.backgroundColor = [UIColor blueColor];
        _resultView = reultV;
        
        [_resultView addSubview:self.topView];
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(30*kWSCALE);
            make.leading.mas_equalTo(0);
            make.top.mas_equalTo(0);
            make.trailing.mas_equalTo(0);
        }];
        
        [_resultView addSubview:self.tableView];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topView.mas_bottom).mas_equalTo(5);
            make.leading.mas_equalTo(0);
            make.trailing.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
        }];
    }
    
    return _resultView;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArr.count;
}

static NSString *cellID = @"AIRSCREEN_CELLID";
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _dataArr[indexPath.row];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath");
}
@end



