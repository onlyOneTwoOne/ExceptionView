//
//  FMExceptionView.h
//  FormaxCopyMaster
//
//  Created by LIYINGPENG on 2017/1/19.
//  Copyright © 2017年 Formax. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FMExceptionView : UIView
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *bottomDetailLabel;

@property (nonatomic, strong) UIView *customView;

@property (nonatomic, assign) CGSize buttonSize;
@property (nonatomic, assign) CGSize customViewSize;

@property (nonatomic, assign) CGFloat verticalOffset;///< default: 0
@property (nonatomic, assign) CGFloat verticalSpace;///< default: 20

- (void)prepareForReuse;
@end

@interface FMExceptionViewStyle : NSObject<NSCopying>
@property (nonatomic, strong) UIColor *backgroundColor;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSAttributedString *title;
@property (nonatomic, strong) NSAttributedString *detail;
@property (nonatomic, strong) NSAttributedString *buttonTitle;
@property (nonatomic, strong) UIImage *buttonImage;
@property (nonatomic, strong) UIImage *buttonBackgroundImage;
@property (nonatomic, strong) UIColor *buttonBackgroundColor;
@property (nonatomic, assign) CGSize buttonSize;

@property (nonatomic, strong) UIView* (^customViewBlock)();
@property (nonatomic, assign) CGSize customViewSize;

@property (nonatomic, strong) NSAttributedString *bottomDetail;

@property (nonatomic, assign) CGFloat verticalOffset;
@property (nonatomic, assign) CGFloat verticalSpace;
@property (nonatomic, assign) UIEdgeInsets insets;
@end

@protocol FMExceptionViewDataSource;
@protocol FMExceptionViewDelegate;

typedef NS_ENUM(NSUInteger, FMRefreshState) {
    FMRefreshStateNormal,
    FMRefreshStateLoading,
    FMRefreshStateEmpty,
    FMRefreshStateFailure,
};

static const NSInteger kFMRefreshSubStateForNormal = 0;

@interface FMExceptionStatusDisplayKit : NSObject

@property (nonatomic, weak, readonly) UIView *containerView;

@property (nonatomic, weak, nullable) id<FMExceptionViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id<FMExceptionViewDelegate> delegate;

@property (nonatomic, assign) FMRefreshState state;
/**
 *  子状态，比如
 *  state == FMRefreshStateFailure，可能的错误类型有很多（没有网络、服务器不稳定、没有权限等等），这种情况可以借助subState要自定义各种具体的错误类型，从而做出不同的处理
 *  
 *  subState置为`kFMRefreshSubStateForNormal`表示无子状态
 **/
@property (nonatomic, assign) NSInteger subState;

@property (nonatomic, getter=isVisible) BOOL visible;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithContainerView:(nonnull UIView*) containerView NS_DESIGNATED_INITIALIZER;

- (void)reloadExceptionView;

+ (void)setDefaultStyle:(nullable FMExceptionViewStyle*) style forState:(FMRefreshState) state;
/**
 *  @Note
 *  为了防止默认的style被修改，所以这里返回的对象为[defaultStyle copy]
 **/
+ (nullable FMExceptionViewStyle*)defaultStyleForState:(FMRefreshState) state;

- (void)setStyle:(nullable FMExceptionViewStyle*) style forState:(FMRefreshState) state;
/**
 *  @Note
 *  当没有设置state对应的自定义style时，为了防止defaultStyle被修改，所以这里返回的对象为[defaultStyle copy]
 *  @Note
 *  当已经设置state对应的自定义style时，返回的对象则为customStyle自身
 **/
- (nullable FMExceptionViewStyle*)styleForState:(FMRefreshState) state;
@end

#define FMSizeNull CGSizeMake(-MAXFLOAT, -MAXFLOAT)
#define FMEdgeInsetsNull UIEdgeInsetsMake(-MAXFLOAT, -MAXFLOAT, -MAXFLOAT, -MAXFLOAT)
#define FMCGFloatNull -MAXFLOAT

/**
 *  @Note
 *  1、返回值为NSObject类型，如果返回[NSNull null]时，则会默认处理成使用当前style的数据，返回nil，则处理成忽略此数据
 *  @Note
 *  2、返回值为其它基本类型时，如果返回FM***Null时，则会默认处理成使用当前style的数据，返回nil，则处理成忽略此数据
 **/
@protocol FMExceptionViewDataSource <NSObject>

@optional
- (nullable UIImage*)imageForExceptionView:(UIView*) view;

- (nullable NSAttributedString*)titleForExceptionView:(UIView*) view;

- (nullable NSAttributedString*)descriptionForExceptionView:(UIView*) view;

- (nullable NSAttributedString*)buttonTitleForExceptionView:(UIView*) view forState:(UIControlState) state;

- (nullable UIImage*)buttonImageForExceptionView:(UIView*) view forState:(UIControlState) state;

- (nullable UIImage*)buttonBackgroundImageForExceptionView:(UIView*) view forState:(UIControlState) state;

- (nullable UIColor*)buttonBackgroundColorForExceptionView:(UIView*) view;

- (CGSize)buttonSizeForExceptionView:(UIView*) view;

- (nullable NSAttributedString*)bottomDescriptionForExceptionView:(UIView*) view;

- (nullable UIColor*)backgroundColorForExceptionView:(UIView*) view;

- (nullable UIView*)customViewForExceptionView:(UIView*) view;

- (CGSize)customViewSizeForExceptionView:(UIView*) view;

- (CGFloat)verticalOffsetForExceptionView:(UIView*) view;

- (CGFloat)verticalSpaceHeightForExceptionView:(UIView*) view;

- (UIEdgeInsets)edgeInsetsForExceptionView:(UIView*) view;

@end

@protocol FMExceptionViewDelegate <NSObject>

@optional

- (void)exceptionView:(UIView*) view didTapView:(UIView*) contentView;

- (void)exceptionView:(UIView*) view didTapButton:(UIButton*) button;
@end
NS_ASSUME_NONNULL_END
