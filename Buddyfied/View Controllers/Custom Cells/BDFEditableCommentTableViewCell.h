//
//  BDFEditableCommentTableViewCell.h
//  Buddyfied
//
//  Created by Tom Gilbert on 07/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLDynamicSizeView.h"
#import "BDFBuddyTableViewCell.h"
#import "BDFHasUITextViewDelegate.h"

@interface BDFEditableCommentTableViewCell : UITableViewCell  <TLDynamicSizeView, BDFBuddyTableViewCell, BDFHasUITextViewDelegate>

@end
