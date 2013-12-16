//
//  ASDBManager.h
//  Asteroids
//
//  Created by Irina Didkovskaya on 12/16/13.
//  Copyright (c) 2013 Irina. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASDBManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *mainManagedObjectContext;
+ (instancetype)sharedManager;

- (void)saveContext;

@end
