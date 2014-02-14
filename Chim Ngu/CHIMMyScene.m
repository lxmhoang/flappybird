//
//  CHIMMyScene.m
//  Chim Ngu
//
//  Created by Tran Hoang Duong on 13/2/14.
//  Copyright (c) 2014 Tran Hoang Duong. All rights reserved.
//

#import "CHIMMyScene.h"

static const uint32_t chimCategory =  0x1 << 0;
static const uint32_t obstacleCategory =  0x1 << 1;

static const float BG_VELOCITY = 100.0;
static const float OBJECT_VELOCITY = 160.0;
static  float CHIM_VELOCITY =600;
static inline CGPoint CGPointAdd(const CGPoint a, const CGPoint b)
{
    return CGPointMake(a.x + b.x, a.y + b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}


@implementation CHIMMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        ;
        self.velocity = CGPointMake(0.0, 0.0);
        //init several sizes used in all scene
        screenRect = [[UIScreen mainScreen] bounds];
        screenHeight = screenRect.size.height;
        screenWidth = screenRect.size.width;
        ongs = [[NSMutableArray alloc]init];
        _gameStart = 0;
        
        started = NO;
        //adding the chim
        [self addChim];
        
        //static bg
        SKSpriteNode *bgStatic = [SKSpriteNode spriteNodeWithImageNamed:@"background.png"];
        bgStatic.scale = 1.2;
        bgStatic.position = CGPointMake(0, 0);
        bgStatic.anchorPoint = CGPointZero;
        bgStatic.name = @"bgStatic";
        
         [self addChild:bgStatic];
        //adding the background
        [self initalizingScrollingBackground];
        
        //score
        scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        scoreLabel.text = @"0";
        scoreLabel.fontSize = 20;
        scoreLabel.fontColor = [SKColor whiteColor];
        scoreLabel.position = CGPointMake(self.size.width/2, self.size.height-50);
        scoreLabel.name = @"score";
        scoreLabel.zPosition = 10;
        [self addChild:scoreLabel];
        
        SKLabelNode *hscoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        hscoreLabel.text = [NSString stringWithFormat:@"Hi : %d",[[NSUserDefaults standardUserDefaults] integerForKey:@"hs"]];
        hscoreLabel.fontSize = 20;
        hscoreLabel.fontColor = [SKColor whiteColor];
        hscoreLabel.position = CGPointMake(50, self.size.height-50);
        hscoreLabel.name = @"score";
        hscoreLabel.zPosition = 10;
        [self addChild:hscoreLabel];
        
        
        SKLabelNode *gameStart = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        gameStart.text = @"Speedy Bird";
        gameStart.fontSize = 30;
        gameStart.fontColor = [SKColor whiteColor];
        gameStart.position = CGPointMake(self.size.width/2, self.size.height/2);
        gameStart.zPosition = 10;
        [self addChild:gameStart];
        //Making self delegate of physics World
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
        
        frozen = NO;

    }
    return self;
}
-(void)addMissile
{
    //initalizing  node

    ong1 = [SKSpriteNode spriteNodeWithImageNamed:@"ong tren.png"];
    [ong1 setScale:1.5];
    
    //Adding SpriteKit physicsBody for collision detection
    ong1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ong1.size];
    ong1.physicsBody.categoryBitMask = obstacleCategory;
    ong1.physicsBody.dynamic = YES;
    ong1.physicsBody.contactTestBitMask = chimCategory;
    ong1.physicsBody.collisionBitMask = 0;
    ong1.physicsBody.usesPreciseCollisionDetection = YES;
  
    ong1.name = @"ong1";

    ong2 = [SKSpriteNode spriteNodeWithImageNamed:@"ong duoi.png"];
    [ong2 setScale:1.5];
    
    //Adding SpriteKit physicsBody for collision detection
    ong2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ong1.size];
    ong2.physicsBody.categoryBitMask = obstacleCategory;
    ong2.physicsBody.dynamic = YES;
    ong2.physicsBody.contactTestBitMask = chimCategory;
    ong2.physicsBody.collisionBitMask = 0;
    ong2.physicsBody.usesPreciseCollisionDetection = YES;
    ong2.name = @"ong2";

    //selecting random y position for missile
    int r = arc4random() % 130 + 320;

    float chieu_cao_den_tren = r ;
    ong1.size = CGSizeMake( 50, screenHeight- chieu_cao_den_tren);
    ong1.position = CGPointMake(self.frame.size.width + 20, (screenHeight-chieu_cao_den_tren)/2 +chieu_cao_den_tren );
    ong1.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ong1.size];
    
    float chieu_cao_den = r - 100;
    float chieu_cao_mat_dat = 113;
    ong2.size = CGSizeMake( 50, chieu_cao_den-chieu_cao_mat_dat);
     ong2.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ong2.size];
    ong2.position = CGPointMake(self.frame.size.width + 20,(chieu_cao_den-chieu_cao_mat_dat)/2 + chieu_cao_mat_dat);
    [self addChild:ong1];
    [self addChild:ong2];
    [ongs addObject:ong1];
}
-(void)addChim
{
    _chim = [SKSpriteNode spriteNodeWithImageNamed:@"chim1.png"];
    _chim.scale = 2;
    _chim.zPosition = 2;
    

    
    //Adding SpriteKit physicsBody for collision detection
    _chim.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_chim.size];
    _chim.physicsBody.categoryBitMask = chimCategory;
    _chim.physicsBody.dynamic = YES;
    _chim.physicsBody.contactTestBitMask = obstacleCategory;
    _chim.physicsBody.collisionBitMask = 0;
    _chim.physicsBody.usesPreciseCollisionDetection = YES;
    _chim.name = @"chim";
    _chim.position = CGPointMake(screenWidth/3,screenHeight/4*3);
    actionMoveUp = [SKAction moveByX:0 y:60 duration:.2];
    actionMoveDown = [SKAction moveByX:0 y:-30 duration:.2];
    
    SKTexture *propeller1 = [SKTexture textureWithImageNamed:@"chim1.png"];
    SKTexture *propeller2 = [SKTexture textureWithImageNamed:@"chim2.png"];
    
    SKAction *fap = [SKAction animateWithTextures:@[propeller1,propeller2] timePerFrame:0.1];
    SKAction *spinForever = [SKAction repeatActionForever:fap];
    
   // SKAction *rotation2 = [SKAction rotateByAngle: -M_PI/2.0 duration:0.2];
    //[_chim runAction: rotation2];
    [_chim runAction:spinForever withKey:@"flap"];
    

    
    [self addChild:_chim];
}
-(void)initalizingScrollingBackground
{
    for (int i = 0; i < 2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"dat.png"];
        bg.scale = 2;
        bg.position = CGPointMake( i* bg.size.width, 0);
        bg.anchorPoint = CGPointZero;

        //Adding SpriteKit physicsBody for collision detection
        bg.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(bg.size.width, bg.size.height *2)];
        bg.physicsBody.categoryBitMask = obstacleCategory;
        bg.physicsBody.dynamic = YES;
   
        bg.physicsBody.contactTestBitMask = chimCategory;
        bg.physicsBody.collisionBitMask = 0;
        bg.physicsBody.usesPreciseCollisionDetection = YES;

        bg.name = @"bg";
        
        [self addChild:bg];
    }
    
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    started = YES;
    if ([node.name isEqualToString:@"retry"]) {
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        
        CHIMMyScene * scene = [CHIMMyScene sceneWithSize:self.view.bounds.size];
        scene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:scene transition: reveal];
        
    }else if(!frozen){
        self.velocity = CGPointMake(0.0, 0.0);
        if(_chim.position.y < screenHeight){
            
            SKAction *rotation = [SKAction rotateByAngle: M_PI/2.0 duration:0.5];
            //and just run the action
            [_chim runAction: rotation];
            [_chim runAction:actionMoveUp completion:^{
                SKAction *rotation2 = [SKAction rotateByAngle: -M_PI/2.0 duration:0.3];
                [_chim runAction: rotation2];
            }];
        }
    }else if ([node.name isEqualToString:@"share"])
    {
        [self share];
    }
  

}

- (void)share
{
    APActivityProvider *ActivityProvider = [[APActivityProvider alloc] init];
    NSArray *Items = @[ActivityProvider];
    
    
    UIActivityViewController *aVC = [[UIActivityViewController alloc] initWithActivityItems:Items applicationActivities:nil];
    NSMutableArray *listDisableItems = [[NSMutableArray alloc] initWithObjects:UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll, UIActivityTypePostToWeibo, nil];
    
    [aVC setExcludedActivityTypes:listDisableItems];
    
    [aVC setCompletionHandler:^(NSString *activityType, BOOL completed){
        NSLog(@"activity Type : %@", activityType);
          }];
    
    [self.view.window.rootViewController presentViewController:aVC animated:YES completion:nil];
}

-(void)update:(CFTimeInterval)currentTime {
 
    
    if (_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
      //  _dt = 0;
    }

    if (_dt > 0.02) {
        _dt = 0.02;
    }
    _lastUpdateTime = currentTime;
    _gameStart += _dt;
  //  _chim.position = CGPointMake(_chim.position.x,_chim.position.y - 4);
    if(started){
        if(!frozen)
        {
            if(_gameStart > 2){
                if( currentTime - _lastTimeFAP > 0.5)
                {
                    _lastTimeFAP = currentTime + 0.5;
                    [self addMissile];
                    
                }
            }
            [self moveBird];
            [self moveBg];
            [self moveObstacle];
            if([ongs count] >0)
            {
                if([ongs objectAtIndex:0])
                {
                    SKSpriteNode *ong = [ongs  objectAtIndex:0];
                    if(ong.position.x < _chim.position.x){
                        score ++;
                        scoreLabel.text = [NSString stringWithFormat:@"%d",score];
                        [ongs removeObjectAtIndex:0];
                    }
                }
            }
        }else {
            if(!birdDie)
            {
                [self birdDown];
            }
        }
 
    }
    
}
-(void) birdDown
{
    SKAction *rotation2 = [SKAction rotateByAngle: -M_PI/2.0 duration:0.3];
    [_chim runAction: rotation2];
    SKAction *birdDown = [SKAction moveByX:0 y: 110 -_chim.position.y duration:1];
    [_chim runAction:birdDown];
    birdDie = YES;
}
-(void) moveBird
{

    
    //3
    CGPoint gravity = CGPointMake(0.0, -CHIM_VELOCITY);
    //4
    CGPoint gravityStep = CGPointMultiplyScalar(gravity, _dt);
    //5
    self.velocity = CGPointAdd(self.velocity, gravityStep);
    CGPoint velocityStep = CGPointMultiplyScalar(self.velocity, _dt);

    
    _chim.position = CGPointAdd(_chim.position, velocityStep);
}
- (void)moveBg
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
     }];
}
- (void)moveObstacle
{
    NSArray *nodes = self.children;//1
    
    for(SKNode * node in nodes){
        if (![node.name  isEqual: @"bg"] && ![node.name  isEqual: @"chim"] && ![node.name  isEqual: @"bgStatic"] && ![node.name  isEqual: @"score"]) {
            SKSpriteNode *ob = (SKSpriteNode *) node;
            CGPoint obVelocity = CGPointMake(-OBJECT_VELOCITY, 0);
            CGPoint amtToMove = CGPointMultiplyScalar(obVelocity,_dt);
            
            ob.position = CGPointAdd(ob.position, amtToMove);
            if(ob.position.x < -100)
            {
                [ob removeFromParent];
            }
        }
    }
}
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & chimCategory) != 0 &&
        (secondBody.categoryBitMask & obstacleCategory) != 0)
    {
        // 2
        
        frozen = true;
        [_chim removeActionForKey:@"flap"];
        NSString * message;
        message = @"You die";
        // 3
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, 400);
        [self addChild:label];
        
        
        NSString * retrymessage;
        retrymessage = @"Replay";
        SKLabelNode *retryButton = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        retryButton.text = retrymessage;
        retryButton.fontSize = 40;
        retryButton.fontColor = [SKColor blackColor];
        retryButton.position = CGPointMake(self.size.width/2, 350);
        retryButton.name = @"retry";
        [retryButton setScale:.5];
        
        [self addChild:retryButton];
        if([[NSUserDefaults standardUserDefaults] integerForKey:@"hs"] < score)
        {
            [[NSUserDefaults standardUserDefaults]setObject: [NSNumber numberWithInt: score] forKey:@"hs"];
            NSString * highscore;
            highscore = @"New High Score";
            SKLabelNode *hscore = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
            hscore.text = highscore;
            hscore.fontSize = 20;
            hscore.fontColor = [SKColor redColor];
            hscore.position = CGPointMake(self.size.width/2, self.size.height/2 -40);
            [self addChild:hscore];

        }
        //SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        //SKScene * gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
        //[self.view presentScene:gameOverScene transition: reveal];
        
        
        SKLabelNode *shareButton = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
        shareButton.text = @"Share";
        shareButton.fontSize = 40;
        shareButton.fontColor = [SKColor blackColor];
        shareButton.position = CGPointMake(self.size.width/2, 300);
        shareButton.name = @"share";
        [shareButton setScale:.5];
        
        [self addChild:shareButton];
        
    }
}

@end
