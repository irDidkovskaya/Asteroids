//
//  ASDBManager.h
//  Asteroids
//
//  Created by Irina Didkovskaya on 12/16/13.
//  Copyright (c) 2013 Irina. All rights reserved.
//

#import "ASResultsManager.h"
#import "ASDBManager.h"
#import "Result.h"


@interface ASResultsManager()
@property dispatch_queue_t coordinator_queue;
@end

@implementation ASResultsManager
+ (instancetype)sharedMaperManager
{
    static ASResultsManager *sharedObject_ = nil;
    static dispatch_once_t predicate;
    dispatch_once( &predicate, ^{
        sharedObject_ = [[self alloc] init];
        sharedObject_.coordinator_queue = dispatch_queue_create("com.hata.babbler.coordinator.queue", NULL);
    });
    return sharedObject_;
}

- (void)saveToCoreDataPlayerName:(NSString *)name result:(NSInteger)score
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Result"
                inManagedObjectContext:[ASDBManager sharedManager].mainManagedObjectContext];
    [request setEntity:entity];
    
    
    Result *result = [NSEntityDescription
                   insertNewObjectForEntityForName:@"Result"
                   inManagedObjectContext:[ASDBManager sharedManager].mainManagedObjectContext];
        result.playerName = name;
    result.score = [NSNumber numberWithInteger:score];
    [[ASDBManager sharedManager] saveContext];

}


- (NSArray *)getResultsFromCoreData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity =
    [NSEntityDescription entityForName:@"Result"
                inManagedObjectContext:[ASDBManager sharedManager].mainManagedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO selector:@selector(localizedCaseInsensitiveCompare:)];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    NSError *error;
    NSArray *array = [[ASDBManager sharedManager].mainManagedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    return array;
}



@end
