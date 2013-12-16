//
//  SACABullet.m
//  Asteroids
//
//  Created by Irina Didkovskaya on 12/14/13.
//  Copyright (c) 2013 Irina. All rights reserved.
//

#import "SACABullet.h"

@implementation SACABullet

- (id)initWithLayer:(id)layer {
    self = [super initWithLayer:layer];
    
        self.bounds = CGRectMake(0, 0, 5, 5);
        self.cornerRadius = 2;
        self.backgroundColor = [UIColor whiteColor].CGColor;
    
    return self;
}


@end
