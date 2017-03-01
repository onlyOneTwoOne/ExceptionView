//
//  FMExceptionView.m
//  FormaxCopyMaster
//
//  Created by LIYINGPENG on 2017/1/19.
//  Copyright © 2017年 Formax. All rights reserved.
//

#import "FMExceptionView.h"
#import <Masonry/Masonry.h>
#import <objc/runtime.h>

@implementation FMExceptionView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)prepareForReuse {
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _imageView = nil;
    _titleLabel = nil;
    _detailLabel = nil;
    _button = nil;
    
    _customView = nil;
    
    [_bottomDetailLabel removeFromSuperview];
    _bottomDetailLabel = nil;
    
    [self removeAllConstraints];
}

- (void)removeAllConstraints {
    
    [self removeConstraints:self.constraints];
    [_contentView removeConstraints:_contentView.constraints];
}

#pragma mark -Layout
- (void)setupConstraints {
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.center.equalTo(self).centerOffset(CGPointMake(0, self.verticalOffset));
        make.width.equalTo(self);
    }];
    
    if (_customView) {
        
        [self.customView mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.edges.equalTo(self.contentView);
            if (!CGSizeEqualToSize(self.customViewSize, CGSizeZero)) {
                
                make.size.mas_equalTo(self.customViewSize);
            }
        }];
    } else {
        
        CGFloat width = CGRectGetWidth(self.frame) ?: CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat padding = 15;
        CGFloat verticalSpace = self.verticalSpace == 0 ?: 20;
        
        NSMutableArray<UIView*> *views = [NSMutableArray arrayWithCapacity:4];
        
        if ([self isNeedShowImage]) {
            
            [views addObject:_imageView];
        } else {
            
            [_imageView removeFromSuperview];
            _imageView = nil;
        }
        
        if ([self isNeedShowTitle]) {
            
            [views addObject:_titleLabel];
            _titleLabel.preferredMaxLayoutWidth = width - padding * 2;
        } else {
            
            [_titleLabel removeFromSuperview];
            _titleLabel = nil;
        }
        
        if ([self isNeedShowDetail]) {
            
            [views addObject:_detailLabel];
            _detailLabel.preferredMaxLayoutWidth = width - padding * 2;
        } else {
            
            [_detailLabel removeFromSuperview];
            _detailLabel = nil;
        }
        
        if ([self isNeedShowButton]) {
            
            [views addObject:_button];
            
            if (!CGSizeEqualToSize(CGSizeZero, self.buttonSize)) {
                
                [_button mas_updateConstraints:^(MASConstraintMaker *make) {
                   
                    make.size.mas_equalTo(self.buttonSize);
                }];
            } else {
                
                [_button mas_remakeConstraints:^(MASConstraintMaker *make) {//移除现有约束
                    
                }];
            }
        } else {
            
            [_button removeFromSuperview];
            _button = nil;
        }
        
        if (views.count != 0) {
            
            [views mas_makeConstraints:^(MASConstraintMaker *make) {
               
                make.centerX.equalTo(self.contentView);
                make.leading.greaterThanOrEqualTo(self.contentView).offset(padding);
            }];
            
            __block UIView *preView = nil;
            [views enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
               
                if (!preView) {
                    
                    [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                       
                        make.top.equalTo(self.contentView);
                    }];
                } else {
                    
                    [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                       
                        make.top.equalTo(preView.mas_bottom).offset(verticalSpace);
                    }];
                }
                
                preView = obj;
                
                if (idx == views.count - 1) {
                    
                    [obj mas_makeConstraints:^(MASConstraintMaker *make) {
                       
                        make.bottom.equalTo(self.contentView);
                    }];
                }
            }];
        }
    }
    
    if ([self isNeedShowBottomDetail]) {
        
        [_bottomDetailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.leading.equalTo(self).offset(30);
            make.trailing.equalTo(self).offset(-30);
            make.bottom.equalTo(self).offset(-50);
        }];
    } else {
        
        [_bottomDetailLabel removeFromSuperview];
        _bottomDetailLabel = nil;
    }
}

#pragma mark -Getters
- (UIView*)contentView {
    
    if (!_contentView) {
        
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    
    return _contentView;
}

- (UIImageView*)imageView {
    
    if (!_imageView) {
        
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [_contentView addSubview:_imageView];
    }
    
    return _imageView;
}

- (UILabel*)titleLabel {
    
    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc] init];
        
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [ThemeManager colorTitleSub];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.numberOfLines = 0;
        
        [_contentView addSubview:_titleLabel];
    }
    
    return _titleLabel;
}

- (UILabel*)detailLabel {
    
    if (!_detailLabel) {
        
        _detailLabel = [[UILabel alloc] init];
        
        _detailLabel.font = [UIFont systemFontOfSize:14];
        _detailLabel.textColor = [ThemeManager colorTitleSub];
        _detailLabel.textAlignment = NSTextAlignmentCenter;
        _detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _detailLabel.numberOfLines = 0;
        
        [_contentView addSubview:_detailLabel];
    }
    
    return _detailLabel;
}

- (UIButton*)button {
    
    if (!_button) {
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        _button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        _button.layer.cornerRadius = 4;
        _button.layer.masksToBounds = YES;
        
        [_contentView addSubview:_button];
    }
    
    return _button;
}

- (UILabel*)bottomDetailLabel {
    
    if (!_bottomDetailLabel) {
        
        _bottomDetailLabel = [[UILabel alloc] init];
        
        _bottomDetailLabel.font = [UIFont systemFontOfSize:14];
        _bottomDetailLabel.textColor = [ThemeManager colorTitleSub];
        _bottomDetailLabel.textAlignment = NSTextAlignmentCenter;
        _bottomDetailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _bottomDetailLabel.numberOfLines = 0;
        
        [self addSubview:_bottomDetailLabel];
    }
    
    return _bottomDetailLabel;
}

- (BOOL)isNeedShowImage {
    
    return (_imageView && _imageView.image && _imageView.superview);
}

- (BOOL)isNeedShowTitle {
    
    return (_titleLabel && (_titleLabel.text.length > 0 || _titleLabel.attributedText.string.length > 0) && _titleLabel.superview);
}

- (BOOL)isNeedShowDetail {
    
    return (_detailLabel && (_detailLabel.text.length > 0 || _detailLabel.attributedText.string.length > 0) && _detailLabel.superview);
}

- (BOOL)isNeedShowButton {
    
    return (_button && ([_button titleForState:UIControlStateNormal].length > 0 || [_button attributedTitleForState:UIControlStateNormal].string.length > 0 || [_button imageForState:UIControlStateNormal]) && _button.superview);
}

- (BOOL)isNeedShowBottomDetail {
    
    return (_bottomDetailLabel && (_bottomDetailLabel.text.length > 0 || _bottomDetailLabel.attributedText.string.length > 0) && _bottomDetailLabel.superview);
}

#pragma mark -Setters
- (void)setCustomView:(UIView *)customView {
    
    if (_customView != customView) {
        
        if (_customView) {
            
            [_customView removeFromSuperview];
            _customView = nil;
        }
        
        _customView = customView;
        
        if (_customView) {
            
            [self.contentView addSubview:_customView];
        }
    }
}
@end

@implementation FMExceptionViewStyle
#pragma mark - Protocol
#pragma mark -NSCopying
- (id)copyWithZone:(NSZone *)zone {
    
    FMExceptionViewStyle *styleCopy = [[[self class] allocWithZone:zone] init];
    styleCopy.backgroundColor = self.backgroundColor;
    
    styleCopy.image = self.image;
    styleCopy.title = self.title;
    styleCopy.detail = self.detail;
    styleCopy.buttonTitle = self.buttonTitle;
    styleCopy.buttonImage = self.buttonImage;
    styleCopy.buttonBackgroundImage = self.buttonBackgroundImage;
    styleCopy.buttonBackgroundColor = self.buttonBackgroundColor;
    styleCopy.buttonSize = self.buttonSize;
    
    styleCopy.customViewBlock = self.customViewBlock;
    styleCopy.customViewSize = self.customViewSize;
    
    styleCopy.bottomDetail = self.bottomDetail;
    
    styleCopy.verticalOffset = self.verticalOffset;
    styleCopy.verticalSpace = self.verticalSpace;
    styleCopy.insets = self.insets;
    
    return styleCopy;
}
@end

@interface FMExceptionStatusDisplayKit ()
@property (nonatomic, strong) FMExceptionView *exceptionView;

@property (nonatomic, strong) NSMutableDictionary<NSNumber*, FMExceptionViewStyle*> *styleDictionary;
@end

@implementation FMExceptionStatusDisplayKit
#pragma mark -LifeCycle
- (instancetype)initWithContainerView:(UIView *)containerView {
    
    self = [super init];
    
    if (self) {
        
        _containerView = containerView;
        _state = FMRefreshStateNormal;
        _subState = kFMRefreshSubStateForNormal;
    }
    return self;
}

#pragma mark -Public Methods
- (void)reloadExceptionView {
    
    NSParameterAssert(self.containerView);
    if (!self.containerView) return;
    
    if (self.state == FMRefreshStateNormal) {
        
        [self dismissExceptionView];
    } else {
        
        [self showExceptionView];
    }
}

+ (void)setDefaultStyle:(FMExceptionViewStyle *)style forState:(FMRefreshState)state {
    
    if (!style) {
        
        [[self defaultStyleDictionary] removeObjectForKey:@(state)];
    } else {
        
        [[self defaultStyleDictionary] setObject:style forKey:@(state)];
    }
}

+ (FMExceptionViewStyle*)defaultStyleForState:(FMRefreshState)state {
    
    return [[self defaultStyleDictionary][@(state)] copy];
}

- (void)setStyle:(FMExceptionViewStyle *)style forState:(FMRefreshState)state {
    
    if (!style) {
        
        [self.styleDictionary removeObjectForKey:@(state)];
    } else {
        
        [self.styleDictionary setObject:style forKey:@(state)];
    }
}

- (FMExceptionViewStyle*)styleForState:(FMRefreshState)state {
    
    FMExceptionViewStyle *style = self.styleDictionary[@(state)];
    if (!style) {
        
        style = [[self class] defaultStyleForState:state];
    }
    
    return style;
}

#pragma mark -Private Methods
- (void)showExceptionView {
    
    if (self.isVisible) [self dismissExceptionView];
    self.visible = YES;
    
    FMExceptionView *view = self.exceptionView;
    UIEdgeInsets insets = [self exceptionViewEdgeInsets];
    self.exceptionView.frame = CGRectMake(insets.left, insets.top, CGRectGetWidth(self.containerView.bounds) - (insets.left + insets.right), CGRectGetHeight(self.containerView.bounds) - (insets.top + insets.bottom));
    
    if (!view.superview) {
        
        [self.containerView addSubview:view];
    }
    
    [view prepareForReuse];
    
    UIView *customView = [self exceptionCustomView];
    
    if (customView) {
        
        view.customView = customView;
    } else {
        
        UIImage *image = [self exceptionImage];
        
        NSAttributedString *title = [self exceptionTitle];
        NSAttributedString *detail = [self exceptionDetail];
        
        UIImage *buttonImage = [self exceptionButtonImageForState:UIControlStateNormal];
        NSAttributedString *buttonTitle = [self exceptionButtonTitleForState:UIControlStateNormal];
        
        view.verticalSpace = [self exceptionVerticalSpaceHeight];
        
        if (image) {
            
            view.imageView.image = image;
        }
        
        if (title) {
            
            view.titleLabel.attributedText = title;
        }
        
        if (detail) {
            
            view.detailLabel.attributedText = detail;
        }
        
        if (buttonImage) {
            
            [view.button setImage:buttonImage forState:UIControlStateNormal];
            [view.button setImage:[self exceptionButtonImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            [view.button addTarget:self action:@selector(didTapExceptionButton) forControlEvents:UIControlEventTouchUpInside];
        } else if (buttonTitle) {
            
            [view.button setAttributedTitle:buttonTitle forState:UIControlStateNormal];
            [view.button setAttributedTitle:[self exceptionButtonTitleForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            [view.button addTarget:self action:@selector(didTapExceptionButton) forControlEvents:UIControlEventTouchUpInside];
            
            UIImage *bgImage = [self exceptionButtonBackgroundImageForState:UIControlStateNormal];
            if (bgImage) {
                
                [view.button setBackgroundImage:bgImage forState:UIControlStateNormal];
                [view.button setBackgroundImage:[self exceptionButtonBackgroundImageForState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
            }
            
            UIColor *bgColor = [self exceptionButtonBackgroundColor];
            if (bgColor) {
                
                view.button.backgroundColor = bgColor;
            }
        }
    }
    
    NSAttributedString *bottomDetail = [self exceptionBottomDetail];
    if (bottomDetail) {
        
        view.bottomDetailLabel.attributedText = bottomDetail;
    }
    
    view.verticalOffset = [self exceptionVerticalOffset];
    view.buttonSize = [self exceptionButtonSize];
    view.customViewSize = [self exceptionCustomViewSize];
    
    view.backgroundColor = [self exceptionBackgroundColor];
    view.hidden = NO;
    view.clipsToBounds = YES;
    
    [view setupConstraints];
    
    [UIView performWithoutAnimation:^{
        
        [view layoutIfNeeded];
    }];
}

- (void)dismissExceptionView {
    
    if (self.exceptionView) {
        [self.exceptionView prepareForReuse];
        [self.exceptionView removeFromSuperview];
        
        self.exceptionView = nil;
    }
    
    self.visible = NO;
}

#pragma mark -DataSource Getters
- (UIImage*)exceptionImage {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(imageForExceptionView:)]) {
        
        UIImage* image = [self.dataSource imageForExceptionView:self.containerView];
        if (image != (id)[NSNull null]) {
            
            return image;
        }
    }
    
    return [self styleForState:self.state].image;
}

- (NSAttributedString*)exceptionTitle {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(titleForExceptionView:)]) {
        
        NSAttributedString *title = [self.dataSource titleForExceptionView:self.containerView];
        if (title != (id)[NSNull null]) {
            
            return title;
        }
    }
    
    return [self styleForState:self.state].title;
}

- (NSAttributedString*)exceptionDetail {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(descriptionForExceptionView:)]) {
        
        NSAttributedString *detail = [self.dataSource descriptionForExceptionView:self.containerView];
        if (detail != (id)[NSNull null]) {
            
            return detail;
        }
    }
    
    return [self styleForState:self.state].detail;
}

- (NSAttributedString*)exceptionButtonTitleForState:(UIControlState) state {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(buttonTitleForExceptionView:forState:)]) {
        
        NSAttributedString *buttonTitle = [self.dataSource buttonTitleForExceptionView:self.containerView forState:state];
        if (buttonTitle != (id)[NSNull null]) {
            
            return buttonTitle;
        }
    }
    
    return [self styleForState:self.state].buttonTitle;
}

- (UIImage*)exceptionButtonImageForState:(UIControlState) state {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(buttonImageForExceptionView:forState:)]) {
        
        UIImage *buttonImage = [self.dataSource buttonImageForExceptionView:self.containerView forState:state];
        if (buttonImage != (id)[NSNull null]) {
            
            return buttonImage;
        }
    }
    
    return [self styleForState:self.state].buttonImage;
}

- (UIImage*)exceptionButtonBackgroundImageForState:(UIControlState) state {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(buttonBackgroundImageForExceptionView:forState:)]) {
        
        UIImage *backgroundImage = [self.dataSource buttonBackgroundImageForExceptionView:self.containerView forState:state];
        if (backgroundImage != (id)[NSNull null]) {
            
            return backgroundImage;
        }
    }
    
    return [self styleForState:self.state].buttonBackgroundImage;
}

- (UIColor*)exceptionButtonBackgroundColor {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(buttonBackgroundColorForExceptionView:)]) {
        
        UIColor *backgorundColor = [self.dataSource buttonBackgroundColorForExceptionView:self.containerView];
        if (backgorundColor != (id)[NSNull null]) {
            
            return backgorundColor;
        }
    }
    
    return [self styleForState:self.state].buttonBackgroundColor;
}

- (CGSize)exceptionButtonSize {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(buttonSizeForExceptionView:)]) {
        
        CGSize buttonSize = [self.dataSource buttonSizeForExceptionView:self.containerView];
        if (!CGSizeEqualToSize(buttonSize, FMSizeNull)) {
            
            return buttonSize;
        }
    }
    
    return [self styleForState:self.state].buttonSize;
}

- (NSAttributedString*)exceptionBottomDetail {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(bottomDescriptionForExceptionView:)]) {
        
        NSAttributedString *bottomDetail = [self.dataSource bottomDescriptionForExceptionView:self.containerView];
        if (bottomDetail != (id)[NSNull null]) {
            
            return bottomDetail;
        }
    }
    
    return [self styleForState:self.state].bottomDetail;
}

- (UIColor*)exceptionBackgroundColor {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(backgroundColorForExceptionView:)]) {
        
        UIColor *backgroundColor = [self.dataSource backgroundColorForExceptionView:self.containerView];
        if (backgroundColor != (id)[NSNull null]) {
            
            return backgroundColor;
        }
    }
    
    return [self styleForState:self.state].backgroundColor;
}

- (UIView*)exceptionCustomView {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(customViewForExceptionView:)]) {
        
        UIView *customView = [self.dataSource customViewForExceptionView:self.containerView];
        if (customView != (id)[NSNull null]) {
            
            return customView;
        }
    }
    
    FMExceptionViewStyle *style = [self styleForState:self.state];
    if (style &&
        style.customViewBlock) {
        
        return style.customViewBlock();
    }
    
    return nil;
}

- (CGSize)exceptionCustomViewSize {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(customViewSizeForExceptionView:)]) {
        
        CGSize customViewSize = [self.dataSource customViewSizeForExceptionView:self.containerView];
        if (!CGSizeEqualToSize(customViewSize, FMSizeNull)) {
            
            return customViewSize;
        }
    }
    
    return [self styleForState:self.state].customViewSize;
}

- (CGFloat)exceptionVerticalOffset {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(verticalOffsetForExceptionView:)]) {
        
        CGFloat offset = [self.dataSource verticalOffsetForExceptionView:self.containerView];
        if (offset != FMCGFloatNull) {
            
            return offset;
        }
    }
    
    return [self styleForState:self.state].verticalOffset;
}

- (CGFloat)exceptionVerticalSpaceHeight {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(verticalSpaceHeightForExceptionView:)]) {
        
        CGFloat space = [self.dataSource verticalSpaceHeightForExceptionView:self.containerView];
        if (space != FMCGFloatNull) {
            
            return space;
        }
    }
    
    return [self styleForState:self.state].verticalSpace;
}

- (UIEdgeInsets)exceptionViewEdgeInsets {
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(edgeInsetsForExceptionView:)]) {
        
        UIEdgeInsets insets = [self.dataSource edgeInsetsForExceptionView:self.containerView];
        if (!UIEdgeInsetsEqualToEdgeInsets(insets, FMEdgeInsetsNull)) {
            
            return insets;
        }
    }
    
    return [self styleForState:self.state].insets;
}

#pragma mark -Delegate Getters & Events (Private)
- (void)didTapExceptionView {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(exceptionView:didTapView:)]) {
        
        [self.delegate exceptionView:self.containerView didTapView:self.exceptionView];
    }
}

- (void)didTapExceptionButton {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(exceptionView:didTapButton:)]) {
        
        [self.delegate exceptionView:self.containerView didTapButton:self.exceptionView.button];
    }
}

#pragma mark -Getters (Private)
- (FMExceptionView*)exceptionView {
    
    if (!_exceptionView) {
        
        _exceptionView = [[FMExceptionView alloc] init];
        _exceptionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _exceptionView.hidden = YES;
        
        [_exceptionView addGestureRecognizer:({
            
            UITapGestureRecognizer *gesTure = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapExceptionView)];
            
            gesTure;
        })];
    }
    
    return _exceptionView;
}

- (NSMutableDictionary<NSNumber*, FMExceptionViewStyle*>*)styleDictionary {
    
    if (!_styleDictionary) {
        
        _styleDictionary = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    
    return _styleDictionary;
}

+ (NSMutableDictionary<NSNumber*, FMExceptionViewStyle*>*)defaultStyleDictionary {
    
    static NSMutableDictionary *styleDic = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        styleDic = [NSMutableDictionary dictionaryWithCapacity:4];
    });
    
    return styleDic;
}
@end
