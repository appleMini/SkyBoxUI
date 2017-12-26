//
//  SPHeaderView.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/26.
//

#import "SPHeaderView.h"

@interface SPHeaderView()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation SPHeaderView

- (instancetype)init
{
    self = [[[UINib nibWithNibName:@"SPHeaderView" bundle:[Commons resourceBundle]] instantiateWithOwner:nil options:nil] firstObject];
    if (self) {
        
    }
    return self;
}

- (IBAction)homeAction:(id)sender {
    NSLog(@"go home...");
}
- (IBAction)refreshAction:(id)sender {
    NSLog(@"refresh...");
}

@end
