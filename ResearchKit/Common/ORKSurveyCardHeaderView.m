/*
 Copyright (c) 2018, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */


#import "ORKSurveyCardHeaderView.h"
#import "ORKSkin.h"
#import "ORKLearnMoreView.h"

static const CGFloat HeadlineViewTitleLeftRightPadding = 10.0;

@implementation ORKSurveyCardHeaderView {
    UIView *_headlineView;
    NSString *_title;
    UILabel *_titleLabel;
    NSString *_detailText;
    UILabel *_detailTextLabel;
    ORKLearnMoreView *_learnMoreView;
    NSString *_progressText;
    UILabel *_progressLabel;
    CAShapeLayer *_headlineMaskLayer;
    UIStackView *_headlineStackView;
    NSArray<NSLayoutConstraint *> *_headerViewConstraints;
    NSArray<NSLayoutConstraint *> *_progressLabelConstraints;
}

- (instancetype)initWithTitle:(NSString *)title {
    
    self = [super init];
    if (self) {
        _title = title;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setupStackView];
        [self setupHeaderView];
        [self setupConstraints];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title detailText:(nullable NSString *)text learnMoreView:(nullable ORKLearnMoreView *)learnMoreView progressText:(nullable NSString *)progressText {
    
    self = [super init];
    if (self) {
        _title = title;
        _detailText = text;
        _learnMoreView = learnMoreView;
        _progressText = progressText;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setupStackView];
        [self setupHeaderView];
        [self setupConstraints];
    }
    return self;
}

- (void)setupStackView {
    _headlineStackView = [[UIStackView alloc] init];
    _headlineStackView.axis = UILayoutConstraintAxisVertical;
    _headlineStackView.distribution = UIStackViewDistributionEqualSpacing;
    _headlineStackView.alignment = UIStackViewAlignmentLeading;
    _headlineStackView.spacing = ORKCardTopBottomMargin;
}

- (void)setupHeaderView {
    [self setupHeadlineView];
    [self addSubview:_headlineView];
    
    [self setupTitleLabel];
    [_headlineStackView addArrangedSubview:_titleLabel];
    
    if (_detailText) {
        [self setUpDetailTextLabel];
        [_headlineStackView addArrangedSubview:_detailTextLabel];
    }
    
    if (_learnMoreView) {
        [_headlineStackView addArrangedSubview:_learnMoreView];
    }
    
    if (_progressText) {
        [self setUpProgressLabel];
        [_headlineView addSubview:_progressLabel];
    }
    
    [_headlineView addSubview:_headlineStackView];
}

- (void)setupHeadlineView {
    if (!_headlineView) {
        _headlineView = [UIView new];
    }
}

- (void)setupTitleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
    }
    _titleLabel.numberOfLines = 0;
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _titleLabel.text = _title;
    [_titleLabel setFont:[UIFont systemFontOfSize:ORKCardDefaultFontSize weight:UIFontWeightBold]];
}

- (void)setUpDetailTextLabel {
    if (!_detailTextLabel) {
        _detailTextLabel = [UILabel new];
    }
    
    _detailTextLabel.numberOfLines = 0;
    _detailTextLabel.textColor = [UIColor blackColor];
    _detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _detailTextLabel.text = _detailText;
    //ToDo: create constant for detail text font size
    [_detailTextLabel setFont:[UIFont systemFontOfSize:ORKCardDefaultFontSize weight:UIFontWeightThin]];
}

- (void)setUpProgressLabel {
    if (!_progressLabel) {
        _progressLabel = [UILabel new];
    }
    _progressLabel.numberOfLines = 0;
    _progressLabel.textColor = [UIColor blackColor];
    _progressLabel.text = _progressText;
    _progressLabel.textAlignment = NSTextAlignmentRight;
    [_progressLabel setFont:[UIFont systemFontOfSize:ORKCardDefaultFontSize weight:UIFontWeightBold]];
    [_progressLabel sizeToFit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self setupConstraints];
    if (_headlineView) {
        if (!_headlineMaskLayer) {
            _headlineMaskLayer = [CAShapeLayer layer];
        }
        for (CALayer *sublayer in [_headlineMaskLayer.sublayers mutableCopy]) {
            [sublayer removeFromSuperlayer];
        }
        [_headlineMaskLayer removeFromSuperlayer];
        
        _headlineMaskLayer.path = [UIBezierPath bezierPathWithRoundedRect: _headlineView.bounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){ORKCardDefaultCornerRadii, ORKCardDefaultCornerRadii}].CGPath;
        
        CAShapeLayer *foreLayer = [CAShapeLayer layer];
        [foreLayer setFillColor:[[UIColor whiteColor] CGColor]];
        CGRect foreLayerBounds = CGRectMake(ORKCardDefaultBorderWidth, ORKCardDefaultBorderWidth, _headlineView.bounds.size.width - 2 * ORKCardDefaultBorderWidth, _headlineView.bounds.size.height - ORKCardDefaultBorderWidth);
        
        CGFloat foreLayerCornerRadii = ORKCardDefaultCornerRadii >= ORKCardDefaultBorderWidth ? ORKCardDefaultCornerRadii - ORKCardDefaultBorderWidth : ORKCardDefaultCornerRadii;
        
        foreLayer.path = [UIBezierPath bezierPathWithRoundedRect: foreLayerBounds byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){foreLayerCornerRadii, foreLayerCornerRadii}].CGPath;
        foreLayer.zPosition = 0.0f;
        
        [_headlineMaskLayer addSublayer:foreLayer];
        
        if (_titleLabel.text) {
            CAShapeLayer *lineLayer = [CAShapeLayer layer];
            CGRect lineBounds = CGRectMake(ORKCardLeftRightMargin, _headlineView.bounds.size.height - 1.0, _headlineView.bounds.size.width - 2 * ORKCardLeftRightMargin, 0.5);
            lineLayer.path = [UIBezierPath bezierPathWithRect:lineBounds].CGPath;
            lineLayer.zPosition = 0.0f;
            [lineLayer setFillColor:[[UIColor ork_midGrayTintColor] CGColor]];
            
            [_headlineMaskLayer addSublayer:lineLayer];
        }
        
        [_headlineMaskLayer setFillColor:[[UIColor ork_borderGrayColor] CGColor]];
        [_headlineView.layer insertSublayer:_headlineMaskLayer atIndex:0];
    }
}

- (void)setupConstraints {
    if (_headerViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:_headerViewConstraints];
    }
    _headlineView.translatesAutoresizingMaskIntoConstraints = NO;
    _headlineStackView.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (_detailTextLabel) {
        _detailTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    if (_learnMoreView) {
        _learnMoreView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    if (_progressLabel) {
        [self setupProgressLabelConstraints];
    }
    
    _headerViewConstraints = @[
                               [NSLayoutConstraint constraintWithItem:_headlineView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0 constant:0.0],
                               [NSLayoutConstraint constraintWithItem:_headlineView
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:ORKCardLeftRightMargin],
                               [NSLayoutConstraint constraintWithItem:_headlineView
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant: -ORKCardLeftRightMargin],
                               
                               [NSLayoutConstraint constraintWithItem:_headlineStackView
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_headlineView
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:ORKCardTopBottomMargin],
                               [NSLayoutConstraint constraintWithItem:_headlineStackView
                                                            attribute:NSLayoutAttributeLeft
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_headlineView
                                                            attribute:NSLayoutAttributeLeft
                                                           multiplier:1.0
                                                             constant:HeadlineViewTitleLeftRightPadding],
                               [NSLayoutConstraint constraintWithItem:_headlineStackView
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem: _progressText ? _progressLabel : _headlineView
                                                            attribute:_progressText ? NSLayoutAttributeLeft : NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:-HeadlineViewTitleLeftRightPadding],
                               
                               [NSLayoutConstraint constraintWithItem:_headlineView
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_headlineStackView
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0 constant:ORKCardTopBottomMargin],
                               [NSLayoutConstraint constraintWithItem:self
                                                            attribute:NSLayoutAttributeBottom
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_headlineView
                                                            attribute:NSLayoutAttributeBottom
                                                           multiplier:1.0 constant:0.0]
                               ];
    [NSLayoutConstraint activateConstraints:_headerViewConstraints];
}

- (void) setupProgressLabelConstraints {
    if (_progressLabelConstraints) {
        [NSLayoutConstraint deactivateConstraints:_progressLabelConstraints];
    }
    _progressLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    _progressLabelConstraints = @[
                               [NSLayoutConstraint constraintWithItem:_progressLabel
                                                            attribute:NSLayoutAttributeTop
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:_headlineView
                                                            attribute:NSLayoutAttributeTop
                                                           multiplier:1.0
                                                             constant:ORKCardTopBottomMargin],
                               [NSLayoutConstraint constraintWithItem:_progressLabel
                                                            attribute:NSLayoutAttributeRight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem: _headlineView
                                                            attribute:NSLayoutAttributeRight
                                                           multiplier:1.0
                                                             constant:-HeadlineViewTitleLeftRightPadding],
                               [NSLayoutConstraint constraintWithItem:_progressLabel
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem: nil
                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                           multiplier:1.0
                                                             constant:_progressLabel.frame.size.width]
                               ];
    [NSLayoutConstraint activateConstraints:_progressLabelConstraints];
}

@end
