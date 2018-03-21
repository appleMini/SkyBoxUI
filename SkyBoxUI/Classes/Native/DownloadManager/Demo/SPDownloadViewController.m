//
//  SPDownloadViewController.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/1.
//

#import "SPDownloadViewController.h"
#import "SPTaskModel.h"
#import "HYBVideoCell.h"
#import "SPDownloadManager.h"
#import "SPDBTool.h"

#define kBaseURL @"http://192.168.7.87:8080/REST/resources"

static NSString *kCellIdentifier = @"HYBVideoCell";
@interface SPDownloadViewController ()<UITableViewDelegate, UITableViewDataSource> {
    NSArray *_videoModels;
}

@property (nonatomic, strong) UITableView *tableView;
@end

@implementation SPDownloadViewController

- (NSString *)titleOfLabelView {
    return @"主页";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ////     NSLog(@"SCREEN_WIDTH == %f, SCREEN_HEIGHT == %f", SCREEN_WIDTH, SCREEN_HEIGHT);
    NSArray *urls = @[@"abc.mp4", @"2017.mp4", @"EasyMovieTexture.mp4", @"ed_1024_512kb.mp4", @"abcd.zip"];
    NSMutableArray *videoModels = [[NSMutableArray alloc] init];
    for (NSString *uid in urls) {
        SPTaskModel *model = [[SPTaskModel alloc] init];
        model.downloadUrl = [NSString stringWithFormat:@"%@/%@",
                          kBaseURL, uid];
        [videoModels addObject:model];
    }
    
    _videoModels = videoModels;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[HYBVideoCell class] forCellReuseIdentifier:kCellIdentifier];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _videoModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HYBVideoCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier
                                                         forIndexPath:indexPath];
    
    SPTaskModel *model = _videoModels[indexPath.row];
    SPMovieModel *dbModel = [SPDBTool fetchWithRemoteUrl:model.downloadUrl];

    model.status = dbModel.isFinished ? SPDownloadStatusCompleted : SPDownloadStatusNone;
    model.progress = dbModel.isFinished ? 1.0 : [dbModel progress];
    cell.model = model;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SPTaskModel *model = _videoModels[indexPath.row];
    switch (model.status) {
        case SPDownloadStatusNone: {
            [[SPDownloadManager shareInstance] addTaskModel:model];
            break;
        }
        case SPDownloadStatusRunning: {
            [[SPDownloadManager shareInstance] suspendOperation:model.downloadUrl];
            break;
        }
        case SPDownloadStatusSuspended: {
            [[SPDownloadManager shareInstance] resumeOperation:model.downloadUrl];
            break;
        }
        case SPDownloadStatusCompleted: {
            //     NSLog(@"已下载完成，可以播放了，播放路径：%@", model.localPath);
            break;
        }
        case SPDownloadStatusFailed: {
            [[SPDownloadManager shareInstance] addTaskModel:model];
            break;
        }
        case SPDownloadStatusWaiting: {
            break;
        }
        default:
            break;
    }
}

@end
