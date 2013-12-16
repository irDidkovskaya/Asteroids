//
//  ASDBManager.h
//  Asteroids
//
//  Created by Irina Didkovskaya on 12/16/13.
//  Copyright (c) 2013 Irina. All rights reserved.

#import <Foundation/Foundation.h>

@interface ASResultsManager : NSObject
+ (instancetype)sharedMaperManager;

- (void)saveToCoreDataPlayerName:(NSString *)name result:(int)score;
- (NSArray *)getResultsFromCoreData;

@end
