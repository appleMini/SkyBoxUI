//
//  SPDLANCell.h
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/26.
//

#import <UIKit/UIKit.h>

@interface SPDLANView : UIView
@property (nonatomic, strong) SPCmdAddDevice *device;
@end

@interface SPDLANCell : UITableViewCell
@property (nonatomic, strong) SPDLANView *dlanView;
@end

@interface SPDLANCollectionCell : UICollectionViewCell
@property (nonatomic, strong) SPDLANView *dlanView;
@end
