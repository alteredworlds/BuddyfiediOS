//
//  BDFBuddyAttributeTableViewCell.m
//  Buddyfied
//
//  Created by Tom Gilbert on 24/04/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFBuddyAttributeTableViewCell.h"

@interface BDFBuddyAttributeTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;

@property (nonatomic) CGSize originalSize;
@property (nonatomic) CGSize originalValueLabelSize;

@end

@implementation BDFBuddyAttributeTableViewCell

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
    return self.valueLabel.text;
}

-(void) setValue:(NSString*)value
{
    self.valueLabel.text = value;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self layoutIfNeeded];
    self.originalSize = self.bounds.size;
    self.originalValueLabelSize = self.valueLabel.bounds.size;
}

- (void)configureWithText:(NSString *)text
{
    self.valueLabel.text = text;
    [self.valueLabel sizeToFit];
}

- (CGSize)sizeWithData:(id)data
{
    [self configureWithText:data];
    // the dynamic size is calculated by taking the original size and incrementing
    // by the change in the label's size after configuring. Here, we're using the
    // intrinsic size because this project uses Auto Layout and the label's size
    // after calling `sizeToFit` does not match the intrinsic size. I don't completely
    // understand why this is yet, but using the intrinsic size works just fine.
    CGSize attributeValuesTextViewSize = self.valueLabel.intrinsicContentSize;
    CGSize size = self.originalSize;
    size.width += attributeValuesTextViewSize.width - self.originalValueLabelSize.width;
    size.height += attributeValuesTextViewSize.height - self.originalValueLabelSize.height;
    
    return size;
}

@end
