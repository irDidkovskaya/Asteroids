//
//  ASSpaceShipControllView.h
//  Asteroids
//
//  Created by Irina Didkovskaya on 12/15/13.
//  Copyright (c) 2013 Irina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASSpaceShipControllView : UIView

- (void)addTarget:(id)target withStartAction:(SEL)startAction andEndAaction:(SEL)endAction;

@end
