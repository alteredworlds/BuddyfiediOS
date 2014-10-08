//
//  BDFPlayerAttribute.h
//  Buddyfied
//
//  Created by Tom Gilbert on 10/07/2014.
//  Copyright (c) 2014 Tom Gilbert. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BDFPlayerAttribute : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sectionName;

@end
