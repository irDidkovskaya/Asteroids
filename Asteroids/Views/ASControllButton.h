//
//  ASControllButton.h
//  Asteroids
//
//  Created by Irina Didkovskaya on 12/15/13.
//  Copyright (c) 2013 Irina. All rights reserved.
//

#import <UIKit/UIKit.h>

enum kASButtonDirection {
    kASButtonDirectionRight = 0,
    kASButtonDirectionLeft = 1,
    kASButtonDirectionTop = 2,
    kASButtonDirectionBottom = 3,
    };

@interface ASControllButton : UIButton
@property (nonatomic, assign) enum kASButtonDirection buttonDirection;
@end
