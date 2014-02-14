//
//  CHIMMyScene.h
//  Chim Ngu
//

//  Copyright (c) 2014 Tran Hoang Duong. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface CHIMMyScene : SKScene<SKPhysicsContactDelegate>
{
    CGRect screenRect;
    CGFloat screenHeight;
    CGFloat screenWidth;
    SKAction *actionMoveUp;
    SKAction *actionMoveDown;
    
    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    NSTimeInterval _lastTimeFAP;
    NSTimeInterval _gameStart;
    bool frozen;
    bool birdDie;
    
    SKSpriteNode *ong1;
    
    SKSpriteNode *ong2;
    NSMutableArray *ongs;
    int score;
    SKLabelNode *scoreLabel;
    bool started;
}
@property SKSpriteNode *chim;
@property (nonatomic, assign) CGPoint velocity;
@end
