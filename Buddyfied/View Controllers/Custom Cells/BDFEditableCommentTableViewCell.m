//
//  BDFEditableCommentTableViewCell.m
//  Buddyfied
//
//  Created by Tom Gilbert on 07/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFEditableCommentTableViewCell.h"

@interface BDFEditableCommentTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *valueTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;

@property (nonatomic) CGSize originalSize;
@property (nonatomic) CGSize originalValueLabelSize;

@end

@implementation BDFEditableCommentTableViewCell

-(NSString*) name
{
    return self.nameLabel.text;
}

- (void) setName:(NSString *)name
{
    self.nameLabel.text = name;
}

- (NSString*) value
{
    return self.valueTextView.text;
}

-(void) setValue:(NSString*)value
{
    self.valueTextView.text = value;
}

-(id<UITextViewDelegate>)delegate
{
    return self.valueTextView.delegate;
}

-(void) setDelegate:(id<UITextViewDelegate>)delegate
{
    self.valueTextView.delegate = delegate;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self layoutIfNeeded];
    self.originalSize = self.bounds.size;
    self.originalValueLabelSize = self.valueTextView.bounds.size;
    self.valueTextView.scrollEnabled = NO;
    // textContainerInsert required to make UITextView match UILabel that it
    // 'replaces' in the view when Edit pressed.
    self.valueTextView.textContainerInset = UIEdgeInsetsMake(0, -3, 0, 0);
    self.valueTextView.textContainer.heightTracksTextView = YES;
}

- (void)configureWithText:(NSString *)text
{
    self.valueTextView.text = text;
}


// here we size the UITableViewCell HEIGHT.
// Then the contained UITextView is sized vertically via autolayout
- (CGSize)sizeWithData:(id)data
{
    [self configureWithText:data];
    
    CGSize commentsLabelSize = [self.valueTextView sizeThatFits:CGSizeMake(self.valueTextView.frame.size.width, FLT_MAX)];
    CGSize size = self.originalSize;
    size.width += commentsLabelSize.width - self.originalValueLabelSize.width;
    size.height += commentsLabelSize.height - self.originalValueLabelSize.height + 1;
    
    return size;
}

@end
