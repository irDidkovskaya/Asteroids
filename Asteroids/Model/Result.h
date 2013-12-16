//
//  Result.h
//  Asteroids
//
//  Created by Irina Didkovskaya on 12/16/13.
//  Copyright (c) 2013 Irina. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Result : NSManagedObject

@property (nonatomic, retain) NSString * playerName;
@property (nonatomic, retain) NSNumber * score;

@end
