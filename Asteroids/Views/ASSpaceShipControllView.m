//
//  ASSpaceShipControllView.m
//  Asteroids
//
//  Created by Irina Didkovskaya on 12/15/13.
//  Copyright (c) 2013 Irina. All rights reserved.
//

#import "ASSpaceShipControllView.h"
#import "ASControllButton.h"


#define BUTTON_WIDTH 30
@interface ASSpaceShipControllView()

@property (nonatomic, strong) ASControllButton *btnTop;
@property (nonatomic, strong) ASControllButton *btnRight;
@property (nonatomic, strong) ASControllButton *btnLeft;
@property (nonatomic, strong) ASControllButton *btnBottom;

@end

@implementation ASSpaceShipControllView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}


- (void)initialize
{
    
//    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 60;
    self.layer.masksToBounds = YES;
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    self.btnBottom = [ASControllButton buttonWithType:UIButtonTypeCustom];
    self.btnBottom.buttonDirection = kASButtonDirectionBottom;
    self.btnBottom.frame = CGRectMake(0, height/2, width, height/2);
    [self addSubview:self.btnBottom];
    
    
    self.btnRight = [ASControllButton buttonWithType:UIButtonTypeCustom];
    self.btnRight.buttonDirection = kASButtonDirectionRight;
    self.btnRight.frame = CGRectMake(width/2, 0, width/2, height);
    [self addSubview:self.btnRight];
    
    
    self.btnLeft = [ASControllButton buttonWithType:UIButtonTypeCustom];
    self.btnLeft.buttonDirection = kASButtonDirectionLeft;
    self.btnLeft.frame = CGRectMake(0, 0, width/2, height);
    [self addSubview:self.btnLeft];
    
    
    self.btnTop = [ASControllButton buttonWithType:UIButtonTypeCustom];
    self.btnTop.buttonDirection = kASButtonDirectionTop;
    self.btnTop.frame = CGRectMake(0, 0, width, height/2);
    [self addSubview:self.btnTop];

}

- (void)addTarget:(id)target withStartAction:(SEL)startAction andEndAaction:(SEL)endAction
{
    [self.btnTop addTarget:target action:startAction forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragOutside];
    [self.btnLeft addTarget:target action:startAction forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragOutside];
    [self.btnBottom addTarget:target action:startAction forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragOutside];
    [self.btnRight addTarget:target action:startAction forControlEvents:UIControlEventTouchDown|UIControlEventTouchDragOutside];
    
    
    [self.btnTop addTarget:target action:endAction forControlEvents:UIControlEventTouchUpInside];
    [self.btnLeft addTarget:target action:endAction forControlEvents:UIControlEventTouchUpInside];
    [self.btnBottom addTarget:target action:endAction forControlEvents:UIControlEventTouchUpInside];
    [self.btnRight addTarget:target action:endAction forControlEvents:UIControlEventTouchUpInside];

}

- (void)addStartTarget:(id)target withAction:(SEL)action
{
    
    
    
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
