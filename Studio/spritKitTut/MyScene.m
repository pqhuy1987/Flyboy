//
//  MyScene.m
//  spritKitTut
//
//  Created by Ricky Brown on 6/2/14.
//  Copyright (c) 2014 15and50. All rights reserved.
//

#import "MyScene.h"

#import "BMGlyphFont.h"
#import "BMGlyphLabel.h"
#import "ViewController.h"
#import "Twitter/Twitter.h"
#import "AppDelegate.h"

int shareScore;

static const uint32_t wallCategory       =  0x1 << 2;
static const uint32_t rockCategory       =  0x1 << 1;
static const uint32_t playerCategory     =  0x1 << 0;

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size])
    {
        
        /* Setup scene */
        self.backgroundColor = [SKColor whiteColor];
        
        /* Collision */
        CGRect frame = CGRectMake(0, -20, self.size.width+30, self.size.height+70);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:frame];
        self.physicsBody.categoryBitMask = wallCategory;
        self.physicsWorld.contactDelegate = self;
        self.physicsBody.restitution = 0.0f;
        
        /* Set Varables */
        moveToX = -30;
        maxFuel = 40;
        lives = 3;
        fuel = maxFuel;
        halfFuel = maxFuel/2;
        almostDoneFuel = maxFuel/2/2;
        done = YES;
        gameOver = YES;
        hit = NO;
        NSInteger theHighScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
        highscore = theHighScore;
        
        /* Move Background */
        for (int i=0; i<2; i++)
        {
            
            SKSpriteNode *background = [SKSpriteNode spriteNodeWithImageNamed:@"Background"];
            //background.position = CGPointMake(self.size.width/2, self.size.height/2);
            background.position = CGPointMake((i*background.size.width)+background.size.width/2, background.size.height/2+20);
            //background.position = CGPointZero; //In a Mac machine makes the center of the image positioned at lower left corner. Untill and unless specified this is the default position
            background.name =@"background";
            [self addChild:background];
            
        }
        
        for (int i=0; i<2; i++)
        {
            
            SKSpriteNode *ground = [SKSpriteNode spriteNodeWithImageNamed:@"ground"];
            //background.position = CGPointMake(self.size.width/2, self.size.height/2);
            ground.position = CGPointMake((i*ground.size.width)+ground.size.width/2, ground.size.height/2+1);
            ground.size = CGSizeMake(ground.size.width, ground.size.height+2);
            //background.position = CGPointZero; //In a Mac machine makes the center of the image positioned at lower left corner. Untill and unless specified this is the default position
            ground.name =@"ground";
            [self addChild:ground];
            
        }
        
        /* Exacute */
        [self makeGameLabels];
        [self makePlayer];
    
    }
    
    return self;

}

#pragma mark Send them rocks in

-(void) addSpritesIn {
    
    rockSprite = [SKSpriteNode spriteNodeWithImageNamed:@"RockSprite"];
    rockSprite.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rockSprite.size];
    rockSprite.physicsBody.dynamic = YES;
    rockSprite.physicsBody.affectedByGravity = NO;
    rockSprite.physicsBody.categoryBitMask = rockCategory;
    rockSprite.physicsBody.contactTestBitMask = playerCategory;
    rockSprite.physicsBody.collisionBitMask = 0;
    rockSprite.physicsBody.usesPreciseCollisionDetection = YES;
    
    int randomSpeed = (arc4random()%(5-2))+2;
    float waitTime;
    int randomPosition;
    
    if (player.position.y > 15 && player.position.y < 18)
    {
        randomPosition = 18;
    }
    else
    {
        randomPosition = (arc4random()%(325)) + 0;
    }
    
    if (score > 50 && score < 100)
    {
        waitTime = 0.6;
    }
    else if (score > 100 && score < 200)
    {
        waitTime = 0.5;
    }
    else if (score > 200 && score < 300)
    {
        waitTime = 0.4;
    }
    else if (waitTime > 300)
    {
        waitTime = 0.3;
    }
    else
    {
        waitTime = 0.7;
    }
    
    [self sendInRockAtSpeed:randomSpeed waitTime:waitTime atY:randomPosition];
    
}

-(void) sendInRockAtSpeed:(int)speed waitTime:(float)wait atY:(int)y {
    
    SKAction *moveObstacle = [SKAction moveToX:moveToX duration:speed];
    
    //rockSprite = [SKSpriteNode spriteNodeWithImageNamed:@"RockSprite"];
    rockSprite.size = CGSizeMake(40*3/2-5, 25*3/2-5);
    rockSprite.position = CGPointMake(568, y);

    [self addChild:rockSprite];
    
    [rockSprite runAction:moveObstacle withKey:@"moveing"];
    
    [rockSprite runAction:moveObstacle completion:^(void){
       
        score++;
        scoreLabel.text = [NSString stringWithFormat:@"%li", (long)score];
        
    }];
    
    if (!gameOver && !hit)
    {
        
        [self performSelector:@selector(addSpritesIn) withObject:self afterDelay:wait];
    
    }
    
}

#pragma mark Play, play again

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"share"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shareIt" object:nil];
    }
    
    else if (!playing && done)
    {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
        
        fuel = maxFuel;
        score = 0;
        lives = 3;
        scoreLabel.text = [NSString stringWithFormat:@"%li", (long)score];
        playing = YES;
        gameOver = NO;
        hit = NO;
        player.physicsBody.affectedByGravity = YES;
        player.physicsBody.dynamic = YES;
        
        [GameOverLabel removeFromParent];
        [YourScoreWasLabel removeFromParent];
        [tapToPlayLabel removeFromParent];
        [YourHighScoreWasLabel removeFromParent];
        [gameOverBoard removeFromParent];
        [tapToPlayFirstLabel removeFromParent];
        [player removeAllActions];
        [newHighScore removeFromParent];
        [shareSprite removeFromParent];
        
        SKAction *blinkSequence = [SKAction sequence:@[[SKAction fadeAlphaTo:1.0 duration:0],[SKAction fadeAlphaTo:0.0 duration:0],[SKAction fadeAlphaTo:1.0 duration:0]]];
        
        [lifeONE runAction:[SKAction repeatAction:blinkSequence count:5] completion:^{}];
        [lifeTWO runAction:[SKAction repeatAction:blinkSequence count:5] completion:^{}];
        [lifeTHREE runAction:[SKAction repeatAction:blinkSequence count:5] completion:^{}];
        
        [self addChild:scoreLabel];
        [self performSelector:@selector(addSpritesIn) withObject:self afterDelay:1];
        
    }
    else if (playing && !hit)
    {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideAd" object:nil];
        
        [player.physicsBody applyImpulse:CGVectorMake(0.0f, 90.0f)];
        
        [player setTexture:[SKTexture textureWithImageNamed:@"jetPackGuyFly"]];
        
    }
    
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [player setTexture:[SKTexture textureWithImageNamed:@"jetPackGuy"]];
    
}

#pragma mark Game over

-(void) gameOver {

    shareScore = (int)score;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showAd" object:nil];
    
    YourScoreWasLabel.text = [NSString stringWithFormat:@"SCORE: %li", (long)score];
    
    NSLog(@"score = %li", (long)score);
    
    NSInteger theHighScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
    highscore = theHighScore;
    
    if (score > theHighScore)
    {
        
        highscore = score;
        YourHighScoreWasLabel.text = [NSString stringWithFormat:@"BEST: %li", (long)highscore];
        [[NSUserDefaults standardUserDefaults] setInteger:highscore forKey:@"HighScore"];
        
        [self addChild:newHighScore];
        
    }
    
    [scoreLabel removeFromParent];
    [rockSprite removeFromParent];
    
    [self addChild:gameOverBoard];
    [self addChild:GameOverLabel];
    [self addChild:YourScoreWasLabel];
    [self addChild:YourHighScoreWasLabel];
    //[self addChild:[self shareScoreButton]];
    
    gameOver = NO;
    playing = NO;
    done = NO;
    
    [self performSelector:@selector(setPlayer) withObject:self afterDelay:2];
    
}

-(void) setPlayer {
    
    player.physicsBody.affectedByGravity = NO;
    player.physicsBody.dynamic = NO;
    SKAction *moveEm = [SKAction moveToY:self.size.height/2 duration:1];
    [player runAction:moveEm];
    
    [player runAction:moveEm completion:^(void){
        
        SKAction *rotation = [SKAction rotateByAngle: M_PI/-4.0 duration:0.4];
        [player runAction:rotation];
        
        [player runAction:rotation completion:^(void){
            
            done = YES;
            gameOver = NO;
            playing = NO;
            
            float y = player.position.y;
            SKAction *a = [SKAction moveToY:(y+5) duration:0.5];
            SKAction *b = [SKAction moveToY:y duration:0.5];
            SKAction *sequence = [SKAction sequence:@[a,b]];
            [player runAction:[SKAction repeatActionForever:sequence] withKey:@"flouting"];
            
            [self addChild:tapToPlayLabel];
            
        }];
    
    }];
    
}

#pragma mark Collision

-(void) didBeginContact:(SKPhysicsContact *)contact {
    
    SKPhysicsBody *firstBody, *secondBody, *thirdBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
        thirdBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
        thirdBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & playerCategory) != 0 && (secondBody.categoryBitMask & rockCategory) != 0)
    {
        [self collision1:(SKSpriteNode *) firstBody.node didCollideWithRock:(SKSpriteNode *) secondBody.node];
    }
    
    if ((firstBody.categoryBitMask & playerCategory) != 0 && (thirdBody.categoryBitMask & wallCategory) != 0)
    {
        [self collision2:(SKSpriteNode *) firstBody.node didCollideWithRock:(SKSpriteNode *) thirdBody.node];
    }
    
}

-(void) anyCollision
{
    
    if (lives > 0)
    {
        
        player.alpha = 0.0;
        SKAction *blinkPlayer = [SKAction sequence:@[[SKAction fadeAlphaTo:1.0 duration:0],[SKAction fadeAlphaTo:0.0 duration:0],[SKAction fadeAlphaTo:1.0 duration:0]]];
        SKAction *blinkHeart = [SKAction sequence:@[[SKAction fadeAlphaTo:0.0 duration:0],[SKAction fadeAlphaTo:1.0 duration:0],[SKAction fadeAlphaTo:0.0 duration:0]]];
        
        if (lives == 3)
        {
            [lifeTHREE runAction:[SKAction repeatAction:blinkHeart count:5] completion:^{}];
        }
        if (lives == 2)
        {
            [lifeTWO runAction:[SKAction repeatAction:blinkHeart count:5] completion:^{}];
        }
        if (lives == 1)
        {
            [lifeONE runAction:[SKAction repeatAction:blinkHeart count:5] completion:^{}];
        }
        
        lives--;
        
        [player runAction:[SKAction repeatAction:blinkPlayer count:5] completion:^{}];
        
    }
    
    if (!hit && lives < 1)
    {
        
        hit = YES;
        
        SKAction *rotation = [SKAction rotateByAngle: M_PI/2.0 duration:1];
        [player runAction:rotation];
        
        [self performSelector:@selector(yourDone) withObject:self afterDelay:0.2];
        
    }
    
}

-(void) yourDone {
    
    gameOver = NO;
    [self gameOver];
    
}

#pragma mark Collision between player and wall

-(void) collision2:(SKSpriteNode *)playerS didCollideWithRock:(SKSpriteNode *)wallS {
    
    
}

#pragma mark Collision between player and rock

-(void) collision1:(SKSpriteNode *)playerS didCollideWithRock:(SKSpriteNode *)rockS {
    
    [self anyCollision];
    
}

#pragma mark Make button

-(SKSpriteNode *) shareScoreButton
{
    
    shareSprite = [SKSpriteNode spriteNodeWithImageNamed:@"shareButton"];
    
    if ((APP).screenIsSmall)
    {
        shareSprite.position = CGPointMake(self.size.width/2+188, self.size.height/2-80);
    }
    else
    {
        shareSprite.position = CGPointMake(self.size.width/2+230, self.size.height/2-135);
    }
    
    shareSprite.name = @"share";
    return shareSprite;
    
}

#pragma mark Make labels

-(void) makeGameLabels {
    
    int y = 135;
    int x;
    int s = 3;
    
    BMGlyphFont *font2 = [BMGlyphFont fontWithName:@"FontForFlyGuy2"];
    
    /* Make Score Label */
    score = 0;
    scoreLabel = [BMGlyphLabel labelWithText:[NSString stringWithFormat:@"%li", (long)score] font:font2];
    scoreLabel.horizontalAlignment = BMGlyphHorizontalAlignmentLeft;
    
    /* Make Game Over Label */
    GameOverLabel = [BMGlyphLabel labelWithText:@"GAME OVER!" font:font2];
    GameOverLabel.position = CGPointMake(self.size.width/2, self.size.height/2+75);
    
    /* Make After Score Label */
    YourScoreWasLabel = [BMGlyphLabel labelWithText:[NSString stringWithFormat:@"SCORE: %li", (long)score] font:font2];
    YourScoreWasLabel.position = CGPointMake(self.size.width/2-110, self.size.height/2+30);
    YourScoreWasLabel.horizontalAlignment = BMGlyphHorizontalAlignmentLeft;
    
    /* Make After Highscore Label */
    YourHighScoreWasLabel = [BMGlyphLabel labelWithText:[NSString stringWithFormat:@"BEST: %li", (long)highscore] font:font2];
    YourHighScoreWasLabel.position = CGPointMake(self.size.width/2-86, self.size.height/2-7);
    YourHighScoreWasLabel.horizontalAlignment = BMGlyphHorizontalAlignmentLeft;
    
    /* Make Tap Play Again Label */
    BMGlyphFont *font3 = [BMGlyphFont fontWithName:@"FontForFlyGuy3"];
    tapToPlayLabel = [BMGlyphLabel labelWithText:@"TAP TO PLAY!" font:font3];
    tapToPlayLabel.position = CGPointMake(self.size.width/2, self.size.height/2-60);
    
    /* Make Tap Play First Label */
    BMGlyphFont *font = [BMGlyphFont fontWithName:@"FontForFlyGuy"];
    tapToPlayFirstLabel = [BMGlyphLabel labelWithText:@"TAP TO PLAY!" font:font];
    tapToPlayFirstLabel.position = CGPointMake(self.size.width/2, self.size.height/2);
    [self addChild:tapToPlayFirstLabel];
    
    /* Make New High Score Label */
    newHighScore = [BMGlyphLabel labelWithText:@"NEW BEST!" font:font2];
    newHighScore.position = CGPointMake(self.size.width/2+200, self.size.height/2+100);
    newHighScore.horizontalAlignment = BMGlyphHorizontalAlignmentCentered;
    
    SKAction *rotation = [SKAction rotateByAngle: M_PI/-6.0 duration:0];
    [newHighScore runAction:rotation];
    
    /* Make Game Over Board */
    gameOverBoard = [SKSpriteNode spriteNodeWithImageNamed:@"GameOverBoard"];
    gameOverBoard.position = CGPointMake(self.size.width/2, self.size.height/2+14);
    gameOverBoard.size = CGSizeMake(140*2, 120*2);
    
    if ((APP).screenIsSmall)
    {
        x = 220;
        scoreLabel.position = CGPointMake(self.size.width/2-230, self.size.height/2-137);
    }
    else
    {
        x = 260;
        scoreLabel.position = CGPointMake(self.size.width/2-275, self.size.height/2-137);
    }
    
    /* Make Lives */
    lifeONE = [SKSpriteNode spriteNodeWithImageNamed:@"heartLifeSprite"];
    lifeONE.position = CGPointMake(self.size.width/2-x, self.size.height/2+y);
    lifeONE.size = CGSizeMake(lifeONE.size.width-s, lifeONE.size.height-s);
    lifeONE.alpha = 0;
    [self addChild:lifeONE];
    
    lifeTWO = [SKSpriteNode spriteNodeWithImageNamed:@"heartLifeSprite"];
    lifeTWO.size = CGSizeMake(lifeTWO.size.width-s, lifeTWO.size.height-s);
    lifeTWO.position = CGPointMake(self.size.width/2-x+40, self.size.height/2+y);
    lifeTWO.alpha = 0;
    [self addChild:lifeTWO];
    
    lifeTHREE = [SKSpriteNode spriteNodeWithImageNamed:@"heartLifeSprite"];
    lifeTHREE.size = CGSizeMake(lifeTHREE.size.width-s, lifeTHREE.size.height-s);
    lifeTHREE.position = CGPointMake(self.size.width/2-x+80, self.size.height/2+y);
    lifeTHREE.alpha = 0;
    [self addChild:lifeTHREE];

}

#pragma mark Make player

-(void) makePlayer {
    
    player = [SKSpriteNode spriteNodeWithImageNamed:@"jetPackGuy"];
    player.position = CGPointMake(60, self.size.height/2);
    player.size = CGSizeMake(player.size.width*2, player.size.height*2);

    player.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:player.size];
    player.physicsBody.affectedByGravity = NO;
    player.physicsBody.dynamic = YES;
    player.physicsBody.categoryBitMask = playerCategory;
    player.physicsBody.contactTestBitMask = rockCategory | wallCategory;
    player.physicsBody.allowsRotation = NO;
    player.physicsBody.collisionBitMask = wallCategory;
    player.physicsBody.restitution = 0.0f;
    
    [self addChild:player];
    
    float y = player.position.y;
    SKAction *a = [SKAction moveToY:(y+5) duration:0.5];
    SKAction *b = [SKAction moveToY:y duration:0.5];
    SKAction *sequence = [SKAction sequence:@[a,b]];
    [player runAction:[SKAction repeatActionForever:sequence] withKey:@"flouting"];
    
}

#pragma mark Moving backround

-(void) moveBackground {
    
    [self enumerateChildNodesWithName:@"background" usingBlock:^(SKNode *node, BOOL *stop) {
        
        SKSpriteNode *bg  = (SKSpriteNode *)node;
        CGPoint bgVelocity = CGPointMake(-10.0, 0);
        CGPoint amountToMove = CGPointMultiplyScalar (bgVelocity,_dt);
        bg.position = CGPointAdd(bg.position,amountToMove);
        
        if (bg.position.x <= -bg.size.width/2)
        {
            bg.position = CGPointMake(bg.position.x + (bg.size.width)*2, bg.position.y);
        }
    
    }];
    
    [self enumerateChildNodesWithName:@"ground" usingBlock:^(SKNode *node, BOOL *stop) {
        
        SKSpriteNode *bg  = (SKSpriteNode *)node;
        CGPoint bgVelocity = CGPointMake(-70.0, 0);
        CGPoint amountToMove = CGPointMultiplyScalar (bgVelocity,_dt);
        bg.position = CGPointAdd(bg.position,amountToMove);
        
        if (bg.position.x <= -bg.size.width/2)
        {
            bg.position = CGPointMake(bg.position.x + (bg.size.width)*2, bg.position.y);
        }
        
    }];
    
}

CGPoint CGPointAdd(CGPoint p1, CGPoint p2) {
    return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

CGPoint CGPointMultiplyScalar(CGPoint p1, CGFloat p2) {
    return CGPointMake(p1.x *p2, p1.y*p2);
}

-(void) update:(NSTimeInterval)currentTime {
    
    if(_lastUpdateTime)
    {
        _dt = currentTime - _lastUpdateTime;
    }
    else
    {
        _dt=0;
    }
    
    _lastUpdateTime = currentTime;
    [self moveBackground];
    
}

#pragma mark Other

-(void) didMoveToView:(SKView *)view {
    
}

@end








