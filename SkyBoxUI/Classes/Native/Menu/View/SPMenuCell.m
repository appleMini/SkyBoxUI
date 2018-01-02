//
//  SPMenuCell.m
//  SkyBoxUI
//
//  Created by Shao shuqiang on 2017/12/12.
//

#import "SPMenuCell.h"
#import "SPCellSelectedView.h"

@interface SPMenuCell()

@property (nonatomic, strong)    UIImageView *iconV;
@property (nonatomic, strong)    UILabel     *label;
@property (nonatomic, strong)    UIImageView *accessV;
@end

@implementation SPMenuCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupView];
    }
    
    return self;
}

- (void)getFontNames
{
    NSArray *familyNames = [UIFont familyNames];
    
    for (NSString *familyName in familyNames) {
        printf("familyNames = %s\n",[familyName UTF8String]);
        
        NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
        
        for (NSString *fontName in fontNames) {
            printf("\tfontName = %s\n",[fontName UTF8String]);
        }
    }
}

- (void)setupView {
    [self getFontNames];
    UIImageView *iconV = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:iconV];
    [iconV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(22);
        make.height.mas_equalTo(22);
        make.leading.mas_equalTo(60);
        make.centerY.mas_equalTo(0);
    }];
    self.iconV = iconV;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont fontWithName:@"Calibri-Bold" size:18];
//    label.font = [UIFont boldSystemFontOfSize:30];
    label.textColor = [UIColor whiteColor];
    [self.contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(iconV.mas_trailing).mas_offset(20);
        make.centerY.mas_equalTo(0);
        make.height.mas_equalTo(20);
        make.trailing.mas_equalTo(-50);
    }];
    self.label = label;
    
    UIImageView *accessV = [[UIImageView alloc] initWithFrame:CGRectZero];
    accessV.image = [Commons getPdfImageFromResource:@"Channels_item_arrow"];
    [self.contentView addSubview:accessV];
    [accessV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(7);
        make.height.mas_equalTo(11);
        make.centerY.mas_equalTo(0);
        make.trailing.mas_equalTo(-60);
    }];
    self.accessV = accessV;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect frame = CGRectMake(40, (self.frame.size.height-60) / 2, self.frame.size.width-80, 60);
    self.selectedBackgroundView = [[SPCellSelectedView alloc] initWithFrame:frame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        self.label.textColor = [SPColorUtil getHexColor:@"#ffd570"];
        self.iconV.image = [Commons getPdfImageFromResource:self.highlightIconName];
        self.accessV.image = [Commons getPdfImageFromResource:@"Channels_item_arrow_active"];
    }else {
        self.label.textColor = [SPColorUtil getHexColor:@"#bcbcbd"];
        self.iconV.image = [Commons getPdfImageFromResource:self.iconName];
        self.accessV.image = [Commons getPdfImageFromResource:@"Channels_item_arrow"];
    }
}

- (void)setIconName:(NSString *)iconName {
    _iconName = iconName;
    self.iconV.image = [Commons getPdfImageFromResource:iconName];
}

- (void)setItemName:(NSString *)itemName {
    _itemName = itemName;
    self.label.text = itemName;
}
@end
