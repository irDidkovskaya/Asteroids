//
//  ASGameViewController.m
//  Asteroids
//
//  Created by Irina Didkovskaya on 12/13/13.
//  Copyright (c) 2013 Irina. All rights reserved.
//

#import "ASGameViewController.h"
#import "ASCAAsteroid.h"
#import "ASSpaceship.h"
#import "SACABullet.h"
#import "ASSpaceShipControllView.h"
#import "ASControllButton.h"
#import "JoyStickView.h"
#import "ASResultsManager.h"

@interface ASGameViewController () <UIAlertViewDelegate>
{
    CADisplayLink *timer;
    NSTimer *moveSpaceshipTimer;
    NSTimer *scoreTimer;
    NSTimer *addAsteroidsTimer;
    NSInteger score;
}
@property (nonatomic, strong) IBOutlet ASSpaceship *spaceship;
@property (nonatomic, strong) IBOutlet ASSpaceShipControllView *spaceShipControllView;
@property (nonatomic, strong) IBOutlet UIButton *attacButton;
@property (nonatomic, strong) IBOutlet UIButton *returnToGameBtn;
@property (nonatomic, strong) IBOutlet JoyStickView *joyStickView;
@property (nonatomic, strong) IBOutlet UILabel *scoreLabel;
@property (nonatomic, strong) IBOutlet UILabel *gameOverLabel;
@property (nonatomic, strong) IBOutlet UIView *gameOverView;

@property (nonatomic, strong) NSMutableArray *bullets;
@property (nonatomic, strong) NSMutableArray *asteroids;

- (IBAction)attacPressed:(id)sender;
- (IBAction)showMenu:(id)sender;
- (IBAction)returnToGameAction:(id)sender;
@end

@implementation ASGameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    score = 0;
    addAsteroidsTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(addAsteroidsTimer) userInfo:nil repeats:YES];
    
    timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(checkForCollisions)];
    timer.frameInterval = 2;
    [timer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self addAsteroids:1 fromPoint:CGPointMake(0, 0)];
    
    
    
    scoreTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateScore) userInfo:nil repeats:YES];
    
}

- (void)updateScore
{
    score += 10;
    self.scoreLabel.text = [NSString stringWithFormat:@"%d",score];
}

- (void)addAsteroidsTimer
{
    [self addAsteroids:1 fromPoint:CGPointMake(0, 0)];
}

- (void)gameOver:(BOOL)showGameOver
{
    self.attacButton.enabled = NO;
    self.joyStickView.userInteractionEnabled = NO;
    self.gameOverView.layer.opacity = 0;
    if (showGameOver)
    {
        self.gameOverLabel.hidden = NO;
    } else {
        self.gameOverLabel.hidden = YES;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.gameOverView.layer.opacity = 1;
        self.gameOverView.hidden = NO;
    } completion:^(BOOL finished) {
        
        for (id element in self.gameOverView.subviews) {
            if ([element isKindOfClass:[UIButton class]])
            {
                UIButton *btn = element;
                if (showGameOver && btn == self.returnToGameBtn)
                {
                    btn.hidden = YES;
                } else {
                    btn.hidden = NO;
                }
            }
        }
        
        if (showGameOver)
        {
            [self performSelector:@selector(addPlayerName) withObject:nil afterDelay:1];
        }
        
    }];
    
}
- (void)addPlayerName
{
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter your Name", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Done", nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
}

- (void)checkForCollisions
{
    
    if (!self.attacButton.enabled) return;
    BOOL isStop = NO;
    for (ASCAAsteroid *asteroid in self.asteroids) {
        
        if ((self.spaceship.frame.origin.x >= [asteroid.presentationLayer frame].origin.x && self.spaceship.frame.origin.x <= [asteroid.presentationLayer frame].origin.x + [asteroid.presentationLayer frame].size.width) && (self.spaceship.frame.origin.y >= [asteroid.presentationLayer frame].origin.y && self.spaceship.frame.origin.y <= [asteroid.presentationLayer frame].origin.y + [asteroid.presentationLayer frame].size.height))
        {
            
            self.spaceship.hidden = YES;
            [self gameOver:YES];
            
        }
        
        for (SACABullet *bullet in self.bullets) {
            NSLog(@"bullet = %@", bullet);
            //            NSLog(@"bullet = %@", NSStringFromCGRect([bullet.presentationLayer frame]));
            if (([bullet.presentationLayer frame].origin.x > [asteroid.presentationLayer frame].origin.x && [bullet.presentationLayer frame].origin.x < [asteroid.presentationLayer frame].origin.x + [asteroid.presentationLayer frame].size.width) && ([bullet.presentationLayer frame].origin.y > [asteroid.presentationLayer frame].origin.y && [bullet.presentationLayer frame].origin.y < [asteroid.presentationLayer frame].origin.y + [asteroid.presentationLayer frame].size.height))
            {
                
                if (!asteroid.doubleSided) {
                    [self addAsteroids:(2 + arc4random() % (4 - 2 + 1)) fromPoint:[asteroid.presentationLayer frame].origin];
                    NSLog(@"COLLISION with asteroid CREATE SMALLS = %@", asteroid);
                }
                NSLog(@"COLLISION with asteroid = %@", asteroid);
                [asteroid removeFromSuperlayer];
                isStop = YES;
                break;
                
                
            }
            
        }
        
        if (isStop)
        {
            break;
        }
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.bullets = [NSMutableArray array];
    self.asteroids = [NSMutableArray array];
    
    NSLog(@"asteroid = %@", self.asteroids);
    
    self.attacButton.layer.cornerRadius = 33;
    
    
    //    [self.spaceShipControllView addTarget:self withStartAction:@selector(startMoveSpaceShip:) andEndAaction:@selector(endMoveSpaceShip:)];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver: self
                           selector: @selector (onStickChanged:)
                               name: @"DirectionChangedNotification"
                             object: nil];
    
    [notificationCenter addObserver: self
                           selector: @selector (onStickStopChanged:)
                               name: @"DirectionChangedStopNotification"
                             object: nil];
    
    
    
	// Do any additional setup after loading the view.
}





- (void)addAsteroids:(int)asteroidsNum fromPoint:(CGPoint)point
{
    if (point.y == 0 && point.x == 0)
    {
        point = CGPointMake(self.view.frame.size.height, arc4random()%(int)self.view.frame.size.width);
    }
    for (int i = 0; i < asteroidsNum; i++) {
        
        CGRect screenBounds = [[UIScreen mainScreen] applicationFrame];
        ASCAAsteroid *asteroid = [[ASCAAsteroid alloc] initWithLayer:[CALayer layer]];
        asteroid.position = CGPointMake(screenBounds.size.height+50, screenBounds.size.width+50);
        asteroid.corners = 4 + arc4random() % (8 - 4 + 1);
        asteroid.opacity = 0;
        asteroid.bounds = CGRectMake(0, 0, 40 + arc4random() % (60 - 40 + 1), 40 + arc4random() % (60 - 40 + 1));
        asteroid.doubleSided = NO;
        if (asteroidsNum > 1)
        {
            asteroid.bounds = CGRectMake(0, 0, 40/asteroidsNum + arc4random() % (60/asteroidsNum - 40/asteroidsNum + 1), 40/asteroidsNum + arc4random() % (60/asteroidsNum - 40/asteroidsNum + 1));
            asteroid.doubleSided = YES;
        }
        
        [asteroid rasterizationScale];
        asteroid.contentsScale = [UIScreen mainScreen].scale;
        [self.view.layer addSublayer:asteroid];
        [asteroid setNeedsDisplay];
        
        
        UIBezierPath *bubblePath = [UIBezierPath bezierPath];
        [bubblePath moveToPoint:point];
        
        [bubblePath addLineToPoint:CGPointMake(-50, arc4random()%(int)self.view.frame.size.width)];
        
        CAKeyframeAnimation *bubbleAnim = [CAKeyframeAnimation animationWithKeyPath:@"position"];
        bubbleAnim.path = bubblePath.CGPath;
        bubbleAnim.duration = 5;
        bubbleAnim.delegate = self;
        bubbleAnim.repeatCount = -1;
        [bubbleAnim setValue:@"asteroidAnumation" forKey:@"tag"];
        [bubbleAnim setValue:asteroid forKey:@"asteroidLayer"];
        [asteroid addAnimation:bubbleAnim forKey:@"asteroidBubble"];
        
        [self.asteroids addObject:asteroid];
        
    }
}

- (void)pauseAnimation {
    
    for (CALayer *layer in self.view.layer.sublayers) {
        if ([layer isKindOfClass:[SACABullet class]] || [layer isKindOfClass:[ASCAAsteroid class]])
        {
        CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
        layer.speed = 0.0;
        layer.timeOffset = pausedTime;
        }
        
    }
    
    
}

- (void)resumeAnimation {
    for (CALayer *layer in self.view.layer.sublayers) {
        if ([layer isKindOfClass:[SACABullet class]] || [layer isKindOfClass:[ASCAAsteroid class]])
        {
        CFTimeInterval pausedTime = [layer timeOffset];
        if (pausedTime != 0) {
            layer.speed = 1.0;
            layer.timeOffset = 0.0;
            layer.beginTime = 0.0;
            
            CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
            layer.beginTime = timeSincePause;
        }
        }
    }
}


#pragma mark Actions

- (IBAction)attacPressed:(id)sender
{
    SACABullet *bullet = [[SACABullet alloc] initWithLayer:[CALayer layer]];
    
    bullet.position = CGPointMake(self.spaceship.frame.size.width+self.spaceship.frame.origin.x, self.spaceship.frame.size.height/2+self.spaceship.frame.origin.y);
    bullet.opacity = 0;
    [self.view.layer addSublayer:bullet];
    
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setValue:@"bulletAnumation" forKey:@"tag"];
    animation.delegate = self;
    animation.duration = 2;
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(500,bullet.position.y)];
    [animation setValue:bullet forKey:@"animationLayer"];
    [bullet addAnimation:animation forKey:@"bulletAnumation"];
    [self.bullets addObject:bullet];
}


//- (void)startMoveSpaceShip:(id)sender
//{
//    moveSpaceshipTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(startTimer:) userInfo:sender repeats:YES];
//    [self moveSpaceship:sender];
//
//}
//
//- (void)moveSpaceship:(ASControllButton *)btn
//{
//    CGRect rectSpaceship = self.spaceship.frame;
//
//    switch (btn.buttonDirection) {
//        case kASButtonDirectionTop:
//        {
//            if (rectSpaceship.origin.y > 0)
//            {
//                rectSpaceship.origin.y -=10;
//            }
//
//        }
//            break;
//        case kASButtonDirectionBottom:
//        {
//            if (rectSpaceship.origin.y < self.view.frame.size.width-self.spaceship.frame.size.height)
//            {
//                rectSpaceship.origin.y +=10;
//            }
//        }
//            break;
//        case kASButtonDirectionLeft:
//        {
//            if (rectSpaceship.origin.x > 0)
//            {
//                rectSpaceship.origin.x -=10;
//            }
//        }
//
//            break;
//        case kASButtonDirectionRight:
//        {
//            if (rectSpaceship.origin.x < self.view.frame.size.height - self.spaceship.frame.size.width)
//            {
//                rectSpaceship.origin.x +=10;
//            }
//        }
//
//            break;
//
//        default:
//            break;
//    }
//
//    self.spaceship.frame = rectSpaceship;
//}
//
//- (void)startTimer:(NSTimer *)spaceshipTimer
//{
//    ASControllButton *btn = [spaceshipTimer userInfo];
//
//    [self moveSpaceship:btn];
//
//}


- (void)endMoveSpaceShip:(id)sender
{
    [moveSpaceshipTimer invalidate];
}

#pragma mark AlertViewDelegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[ASResultsManager sharedMaperManager] saveToCoreDataPlayerName:[alertView textFieldAtIndex:0].text result:score];
}

#pragma mark Delegates

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSString *tag = [anim valueForKey:@"tag"];
    
    if ([tag isEqualToString:@"bulletAnumation"]) {
        
        CALayer *layer1 = [anim valueForKey:@"animationLayer"];
        
        [self.bullets removeObject:layer1];
        [layer1 removeFromSuperlayer];
        
        //        [ball removeAnimationForKey:@"drop"];
    } else if ([tag isEqualToString:@"asteroidAnumation"]){
        CALayer *layer1 = [anim valueForKey:@"asteroidLayer"];
        
        [self.asteroids removeObject:layer1];
        [layer1 removeFromSuperlayer];
    }
    
}


- (void)animationDidStart:(CAAnimation *)anim {
    NSString *tag = [anim valueForKey:@"tag"];
    
    if ([tag isEqualToString:@"bulletAnumation"]) {
        
        CALayer *layer1 = [anim valueForKey:@"animationLayer"];
        layer1.opacity = 1;
        
        //        [ball removeAnimationForKey:@"drop"];
    } else if ([tag isEqualToString:@"asteroidAnumation"]){
        CALayer *layer1 = [anim valueForKey:@"asteroidLayer"];
        layer1.opacity = 1;
    }
    
}

- (void)onStickChanged:(id)notification
{
    [moveSpaceshipTimer invalidate];
    NSDictionary *dict = [notification userInfo];
    NSValue *vdir = [dict valueForKey:@"dir"];
    CGPoint dir = [vdir CGPointValue];
    
    [self changePosition:dir];
    moveSpaceshipTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(startTimerChanges:) userInfo:vdir repeats:YES];
}

- (void)startTimerChanges:(NSTimer *)timer_
{
    NSValue *vdir = [timer_ userInfo];
    CGPoint dir = [vdir CGPointValue];
    [self changePosition:dir];
}

- (void)changePosition:(CGPoint)point
{
    
    UIView *viewSpaceshipArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height - self.spaceship.frame.size.width, self.view.frame.size.width - self.spaceship.frame.size.height)];
    
    
    CGPoint newpos = self.spaceship.frame.origin;
    newpos.x = point.x + newpos.x;
    newpos.y = point.y + newpos.y;
    if (![viewSpaceshipArea pointInside:newpos withEvent:nil]) return;
    
    NSLog(@"pointInside = %@", NSStringFromCGPoint(newpos));
    CGRect fr = self.spaceship.frame;
    fr.origin = newpos;
    self.spaceship.frame = fr;
}

- (void)onStickStopChanged:(id)notification
{
    [moveSpaceshipTimer invalidate];
}


- (IBAction)startNewGame:(id)sender
{
    score = 0;
    self.scoreLabel.text = @"0.0";
    self.gameOverView.hidden = YES;
    self.joyStickView.userInteractionEnabled = YES;
    self.attacButton.enabled = YES;
    self.spaceship.hidden = NO;
    self.spaceship.frame = CGRectMake(20, self.view.center.x, 51, 48);
    //    [self.view addSubview:self.spaceship];
    [self.spaceship updateConstraints];
    [self.view updateConstraints];
    scoreTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateScore) userInfo:nil repeats:YES];
    
}

- (IBAction)returnToGameAction:(id)sender
{
    self.gameOverView.hidden = YES;
    self.joyStickView.userInteractionEnabled = YES;
    self.attacButton.enabled = YES;
    [self resumeAnimation];
    addAsteroidsTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(addAsteroidsTimer) userInfo:nil repeats:YES];
}

- (IBAction)showMenu:(id)sender
{
    [addAsteroidsTimer invalidate];
    [self gameOver:NO];
    [self pauseAnimation];
    
}

- (IBAction)backToMainScreen:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
