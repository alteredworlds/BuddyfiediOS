//
//  BDFSupportsShowAppMenu.h
//  Buddyfied
//
//  Created by Tom Gilbert on 13/03/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//
#import "BDFMasterDetailController.h"

@protocol BDFHasMasterDetailController <NSObject>

@property (strong, nonatomic) id <BDFMasterDetailController> masterDetailController;

@end
