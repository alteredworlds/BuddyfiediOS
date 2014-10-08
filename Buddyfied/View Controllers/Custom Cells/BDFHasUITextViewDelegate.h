//
//  BDFHasEditableTextView.h
//  Buddyfied
//
//  Created by Tom Gilbert on 08/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BDFHasUITextViewDelegate <NSObject>

@property (nonatomic, weak) id<UITextViewDelegate> delegate;

@end
