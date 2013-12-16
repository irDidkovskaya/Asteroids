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
#import "JoyStickView.h"
#import "ASResultsManager.h"

@interface ASGameViewController () <UIAlertViewDelegate>
{
    NSTimer *moveSpaceshipTimer;
    NSTimer *scoreTimer;
    NSTimer *addAsteroidsTimer;
    NSTimer *colisionChecker;
    NSInteger score;
}
@property (nonatomic, strong) IBOutlet ASSpaceship *spaceship;
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

#pragma mark viewLoad
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    score = 0;
    colisionChecker = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(checkForCollisions) userInfo:nil repeats:YES];
    
    [self addAsteroids:1 fromPoint:CGPointMake(0, 0)];
    
    [self runTimers];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.bullets = [NSMutableArray array];
    self.asteroids = [NSMutableArray array];
    
    self.attacButton.layer.cornerRadius = 33;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver: self
                           selector: @selector (directionChanged:)
                               name: @"DirectionChangedNotification"
                             object: nil];
    
    [notificationCenter addObserver: self
                           selector: @selector (directionStopChanged:)
                               name: @"DirectionChangedStopNotification"
                             object: nil];
}

- (void)runTimers
{
    addAsteroidsTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(addAsteroidsTimer) userInfo:nil repeats:YES];
    scoreTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateScore) userInfo:nil repeats:YES];
}

- (void)updateScore
{
    score += 1;
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld",(long)score];
}

- (void)addAsteroidsTimer
{
    [self addAsteroids:1 fromPoint:CGPointMake(0, 0)];
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
            
            
            if (([bullet.presentationLayer frame].origin.x >= [asteroid.presentationLayer frame].origin.x && [bullet.presentationLayer frame].origin.x <= [asteroid.presentationLayer frame].origin.x + [asteroid.presentationLayer frame].size.width) && ([bullet.presentationLayer frame].origin.y >= [asteroid.presentationLayer frame].origin.y && [bullet.presentationLayer frame].origin.y <= [asteroid.presentationLayer frame].origin.y + [asteroid.presentationLayer frame].size.height))
            {
                 NSLog(@"!!!!Collision");
                NSLog(@"Collision");
                if (!asteroid.doubleSided) {
                    [self addAsteroids:(2 + arc4random() % (4 - 2 + 1)) fromPoint:[asteroid.presentationLayer frame].origin];
                }
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
        [self.view.layer insertSublayer:asteroid below:self.gameOverView.layer];
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


#pragma mark Animation Delegates

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSString *tag = [anim valueForKey:@"tag"];
    
    if ([tag isEqualToString:@"bulletAnumation"]) {
        
        CALayer *layer1 = [anim valueForKey:@"animationLayer"];
        layer1.hidden = YES;
        [self.bullets removeObject:layer1];
        [layer1 removeFromSuperlayer];
        
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
        layer1.hidden = NO;
        
    } else if ([tag isEqualToString:@"asteroidAnumation"]){
        CALayer *layer1 = [anim valueForKey:@"asteroidLayer"];
        layer1.opacity = 1;
    }
    
}

#pragma mark pause/resume animation
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

#pragma mark Notifications
- (void)directionChanged:(id)notification
{
    [moveSpaceshipTimer invalidate];
    NSDictionary *dict = [notification userInfo];
    NSValue *vdir = [dict valueForKey:@"dir"];
    CGPoint dir = [vdir CGPointValue];
    
    [self changePosition:dir];
    moveSpaceshipTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(startTimerChanges:) userInfo:vdir repeats:YES];
}

- (void)directionStopChanged:(id)notification
{
    [moveSpaceshipTimer invalidate];
}

#pragma  mark spaceShip position changes
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
    
    CGRect fr = self.spaceship.frame;
    fr.origin = newpos;
    self.spaceship.frame = fr;
}


#pragma mark Actions
- (IBAction)attacPressed:(id)sender
{
    SACABullet *bullet = [[SACABullet alloc] initWithLayer:[CALayer layer]];
    
    bullet.position = CGPointMake(-10, -10);
    bullet.opacity = 0;
    bullet.hidden = NO;
    [self.view.layer insertSublayer:bullet below:self.gameOverView.layer];
    
    
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setValue:@"bulletAnumation" forKey:@"tag"];
    animation.delegate = self;
    animation.duration = 2;
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.spaceship.frame.size.width+self.spaceship.frame.origin.x, self.spaceship.frame.size.height/2+self.spaceship.frame.origin.y)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(500,self.spaceship.frame.size.height/2+self.spaceship.frame.origin.y)];
    [animation setValue:bullet forKey:@"animationLayer"];
    [bullet addAnimation:animation forKey:@"bulletAnumation"];
    [self.bullets addObject:bullet];
}


- (IBAction)startNewGame:(id)sender
{
    score = 0;
    self.scoreLabel.text = @"0";
    self.gameOverView.hidden = YES;
    self.joyStickView.userInteractionEnabled = YES;
    self.attacButton.enabled = YES;
    self.spaceship.hidden = NO;
    self.spaceship.frame = CGRectMake(20, self.view.center.x, 51, 48);
    //    [self.view addSubview:self.spaceship];
    [self.spaceship updateConstraints];
    [self.view updateConstraints];
    scoreTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateScore) userInfo:nil repeats:YES];
}

- (IBAction)returnToGameAction:(id)sender
{
    self.gameOverView.hidden = YES;
    self.joyStickView.userInteractionEnabled = YES;
    self.attacButton.enabled = YES;
    [self resumeAnimation];
    [self runTimers];
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

#pragma mark Game Over
- (void)gameOver:(BOOL)showGameOver
{
    [scoreTimer invalidate];
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
            [self performSelector:@selector(addPlayerName) withObject:nil afterDelay:0.5];
        }
        
    }];
    
}
- (void)addPlayerName
{
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Enter your Name", nil) message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Done", nil), nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
}

#pragma mark AlertViewDelegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[ASResultsManager sharedMaperManager] saveToCoreDataPlayerName:[alertView textFieldAtIndex:0].text result:score];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
