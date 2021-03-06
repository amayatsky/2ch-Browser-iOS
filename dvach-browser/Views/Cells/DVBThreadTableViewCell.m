//
//  DVBThreadTableViewCell.m
//  dvach-browser
//
//  Created by Andy on 05/10/14.
//  Copyright (c) 2014 8of. All rights reserved.
//

#import <UIImageView+AFNetworking.h>

#import "DVBConstants.h"
#import "DVBCommon.h"
#import "UIImage+DVBOpaqueImage.h"

#import "DVBThreadTableViewCell.h"

static UIImage *kPlaceholderImage;
static CGFloat const kMargin = 10;
static CGFloat const kTopMargin = 8;

@interface DVBThreadTableViewCell ()

@property (nonatomic, weak) IBOutlet UITextView *commentTextView;
@property (nonatomic, weak) IBOutlet UILabel *postsCountLabel;
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UIView *postsCountContainerView;
/// Image for showing OP thumbnail image
@property (nonatomic, weak) IBOutlet UIImageView *threadThumb;

@end

@implementation DVBThreadTableViewCell

+ (BOOL)goodFitWithViewWidth:(CGFloat)viewWidth andString:(NSString *)string
{
    CGFloat widthLeftForText = viewWidth - 4 * kMargin - (IS_IPAD ? PREVIEW_IMAGE_SIZE_IPAD : PREVIEW_IMAGE_SIZE) - 70; // 70 - time label size
    CGFloat heightLeftForText = (IS_IPAD ? PREVIEW_ROW_DEFAULT_HEIGHT_IPAD : PREVIEW_ROW_DEFAULT_HEIGHT) - kMargin - kTopMargin;

    NSMutableDictionary *commentAttributes = [@
    {
        NSFontAttributeName : [UIFont preferredFontForTextStyle:UIFontTextStyleBody]
    } mutableCopy];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_ENABLE_LITTLE_BODY_FONT]) {
        commentAttributes[NSFontAttributeName] = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    }

    // Rectangle need for comment
    CGRect rect = [string boundingRectWithSize:CGSizeMake(widthLeftForText, CGFLOAT_MAX)
                                       options:NSStringDrawingUsesLineFragmentOrigin
                                    attributes:commentAttributes
                                       context:nil];
    if (heightLeftForText > rect.size.height) {
        return YES;
    }

    return NO;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.contentView.opaque = YES;
    self.backgroundView.opaque = YES;

    for (UIView *view in self.contentView.subviews) {
        view.layer.drawsAsynchronously = YES;
    }

    self.contentView.layer.shouldRasterize = YES;
    self.contentView.layer.rasterizationScale = [UIScreen mainScreen].scale;

    if (!kPlaceholderImage) {
        kPlaceholderImage = [UIImage optimizedImageFromImage:[UIImage imageNamed:FILENAME_THUMB_IMAGE_PLACEHOLDER]];
    }

    _threadThumb.opaque = YES;
    _threadThumb.contentMode = UIViewContentModeScaleAspectFill;
    _threadThumb.clipsToBounds = YES;
    _threadThumb.image = kPlaceholderImage;

    _commentTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _commentTextView.layer.masksToBounds = NO;
    _commentTextView.opaque = YES;
    _commentTextView.backgroundColor = [UIColor whiteColor];
    // It'll not become truly opaque otherwise
    for (UIView *subview in _commentTextView.subviews) {
        subview.opaque = YES;
        subview.backgroundColor = [UIColor whiteColor];
    }
    // Delete insets
    _commentTextView.textContainer.lineFragmentPadding = 0;
    _commentTextView.textContainerInset = UIEdgeInsetsZero;

    _dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    _dateLabel.layer.masksToBounds = NO;
    _dateLabel.opaque = YES;
    _dateLabel.backgroundColor = [UIColor whiteColor];

    _postsCountLabel.opaque = YES;
    _postsCountLabel.layer.opaque = YES;
    _postsCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    _postsCountLabel.layer.masksToBounds = NO;

    _postsCountContainerView.layer.cornerRadius = 6.0f;
    _postsCountContainerView.layer.borderColor = THUMBNAIL_GREY_BORDER;
    _postsCountContainerView.layer.borderWidth = 1.0;
    _postsCountContainerView.layer.masksToBounds = NO;
    _postsCountContainerView.layer.shouldRasterize = YES;
    _postsCountContainerView.layer.rasterizationScale = [UIScreen mainScreen].scale;

    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_ENABLE_LITTLE_BODY_FONT]) {
        _commentTextView.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _dateLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        _postsCountLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption1];
    }

    if ([[NSUserDefaults standardUserDefaults] boolForKey:SETTING_ENABLE_DARK_THEME]) {
        self.backgroundColor = CELL_BACKGROUND_COLOR;
        _commentTextView.textColor = CELL_TEXT_COLOR;
        _commentTextView.backgroundColor = CELL_BACKGROUND_COLOR;
        // Hack to make it truly opaque
        for (UIView *subview in _commentTextView.subviews) {
            subview.backgroundColor = CELL_BACKGROUND_COLOR;
        }
        _postsCountLabel.textColor = CELL_TEXT_COLOR;
        _postsCountLabel.backgroundColor = CELL_BACKGROUND_COLOR;
        _dateLabel.textColor = CELL_TEXT_COLOR;
        _dateLabel.backgroundColor = CELL_BACKGROUND_COLOR;
        _postsCountContainerView.backgroundColor = CELL_BACKGROUND_COLOR;
        _postsCountContainerView.layer.borderColor = CELL_TEXT_COLOR.CGColor;
    }
}

- (void)prepareCellWithComment:(NSString *)comment andThumbnailUrlString:(NSString *)thumbnailUrlString andPostsCount:(NSString *)postsCount andTimeSinceFirstPost:(NSString *)timeSinceFirstPost
{
    _commentTextView.text = comment;

    if (thumbnailUrlString) {
        NSURL *thumbnailUrl = [NSURL URLWithString:thumbnailUrlString];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:thumbnailUrl];
        NSString *userAgent = [[NSUserDefaults standardUserDefaults] objectForKey:DEFAULTS_USERAGENT_KEY];

        [request setValue:userAgent forHTTPHeaderField:NETWORK_HEADER_USERAGENT_KEY];

        [_threadThumb setImageWithURLRequest:[request copy]
                            placeholderImage:nil
                                     success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, UIImage * _Nonnull image)
        {
            _threadThumb.image = image;
        } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nonnull response, NSError * _Nonnull error) { }];
    }

    _postsCountLabel.text = postsCount;
    _dateLabel.text = timeSinceFirstPost;
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    _commentTextView.text = nil;
    _dateLabel.text = nil;
    _postsCountLabel.text = nil;
    _threadThumb.image = kPlaceholderImage;
}

@end
