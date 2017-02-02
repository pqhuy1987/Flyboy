//
//  MyScene.h
//  spritKitTut
//

//  Copyright (c) 2014 15and50. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "BMGlyphFont.h"
#import "BMGlyphLabel.h"

extern int shareScore;

@interface MyScene : SKScene <SKPhysicsContactDelegate> {
    
    SKSpriteNode *player;
    SKSpriteNode *rockSprite;
    SKSpriteNode *timesTwoSprite;
    
    SKSpriteNode *gameOverBoard;
    SKSpriteNode *lifeONE;
    SKSpriteNode *lifeTWO;
    SKSpriteNode *lifeTHREE;
    SKSpriteNode *lifeEXTRA;
    
    SKSpriteNode *shareSprite;
    
    BMGlyphLabel *scoreLabel;
    BMGlyphLabel *GameOverLabel;
    BMGlyphLabel *YourScoreWasLabel;
    BMGlyphLabel *YourHighScoreWasLabel;
    BMGlyphLabel *tapToPlayFirstLabel;
    BMGlyphLabel *tapToPlayLabel;
    BMGlyphLabel *newHighScore;
    
    int moveToX;
    int fuel;
    int maxFuel;
    int halfFuel;
    int almostDoneFuel;
    int lives;
    
    NSInteger score;
    NSInteger highscore;

    NSTimeInterval _lastUpdateTime;
    NSTimeInterval _dt;
    CGPoint _velocity;
    
    BOOL gameOver;
    BOOL playing;
    BOOL done;
    BOOL hit;
    
}

typedef enum : uint8_t {
    JCColliderTypeRectangle = 1,
    JCColliderTypeObstacle  = 2
} JCColliderType;

@end





