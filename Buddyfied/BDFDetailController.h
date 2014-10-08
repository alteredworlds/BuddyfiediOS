//
//  BDFDetailViewControllerDelegate.h
//  Buddyfied
//
//  Created by Tom Gilbert on 14/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import "BDFHasMasterDetailController.h"

@protocol BDFDetailController <BDFHasMasterDetailController>

- (void)enableToggleOnTouch:(BOOL)enable;

@end
