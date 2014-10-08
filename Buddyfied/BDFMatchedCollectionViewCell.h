//
//  BDFMatchedCollectionViewCell.h
//  Buddyfied
//
//  Created by Tom Gilbert on 24/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BDFMatchedCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIImageView *buddyImageView;
@property (strong, nonatomic) NSString *unique;


@end
