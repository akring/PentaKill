//
//  MyScene.m
//  spriteTestProject
//
//  Created by whkj on 14-3-28.
//  Copyright (c) 2014年 Akring. All rights reserved.
//

#import "MyScene.h"
#import "GameOverScene.h"
#import "AppDelegate.h"


//偏转向量计算方法
static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}
static inline CGPoint rwSub(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}
static inline CGPoint rwMult(CGPoint a, float b) {
    return CGPointMake(a.x * b, a.y * b);
}
static inline float rwLength(CGPoint a) {
    return sqrtf(a.x * a.x + a.y * a.y);
}
// 让向量的长度（模）等于1
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x / length, a.y / length);
}


/**
 *   为碰撞类型设置对应类
 */
static const uint32_t bulletCategory      = 0x1 << 0;
static const uint32_t enemyShipCategory   = 0x1 << 1;
static const uint32_t mySpaceShipCategory = 0x1 << 3;
static const uint32_t enemyBulletCategory = 0x1 << 4;
static const uint32_t myShelterCategory   = 0x1 << 5;

@interface MyScene()<SKPhysicsContactDelegate>{
    
    int shelterCount;
    
    int shipDestoryed;
    
    BOOL bulletReload;
}

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@property (nonatomic) SKSpriteNode *spaceShip;
@property (nonatomic) SKSpriteNode *enemyShip;
@property (nonatomic) SKSpriteNode *myShelter;
@property (nonatomic) SKSpriteNode *myBullet;

@property (nonatomic)SKEmitterNode *fire;
@property (nonatomic)SKEmitterNode *myShelterLight;

@property (nonatomic) SKLabelNode *scoreLabel;
@property (nonatomic) SKLabelNode *shelterLabel;

@end

@implementation MyScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        score = 0;
        
        shipDestoryed = 0;
        
        bulletReload = YES;
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        /**
         *   得分标签
         */
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        self.scoreLabel.text = [NSString stringWithFormat: @"Score:%d",score];
        self.scoreLabel.fontSize = 20;
        self.scoreLabel.position = CGPointMake(self.scoreLabel.frame.size.width/2,
                                               self.frame.size.height - self.scoreLabel.frame.size.height);
        
        [self addChild:self.scoreLabel];
        
        /**
         *   玩家标签
         */
        
        SKLabelNode *playerNameLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        playerNameLabel.text = playerName;
        playerNameLabel.fontSize = 18;
        playerNameLabel.fontColor = [UIColor greenColor];
        playerNameLabel.position = CGPointMake(self.frame.size.width/2,
                                               self.frame.size.height - playerNameLabel.frame.size.height);
        
        [self addChild:playerNameLabel];
        
        //自己的ship
        self.spaceShip = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        
        self.spaceShip.position = CGPointMake(self.frame.size.width/2, 40);
        
        [self addChild:self.spaceShip];
        
        //自己的ship的物理body
        self.spaceShip.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.spaceShip.size];
        self.spaceShip.physicsBody.dynamic = YES;
        self.spaceShip.physicsBody.categoryBitMask = mySpaceShipCategory;
        self.spaceShip.physicsBody.contactTestBitMask = enemyShipCategory;
        self.spaceShip.physicsBody.collisionBitMask = 0;//相互作用的效果掩码，0为无，其他诸如回弹等
        
        //配置重力体系
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        
        self.physicsWorld.contactDelegate = self;
        
        score = 0;
        
        manager = [[CMMotionManager alloc]init];
        
        manager.accelerometerUpdateInterval = 0.001;
        
        [manager startAccelerometerUpdates];
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
    
    
    
}

/*-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 
 
 for (UITouch *touch in touches) {
 CGPoint location = [touch locationInNode:self];
 
 SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
 
 sprite.position = location;
 
 //SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
 
 //[sprite runAction:[SKAction repeatActionForever:action]];
 
 [self addChild:sprite];
 }
 }*/

#pragma mark -
#pragma mark 添加精灵及动画

/**
 *   添加enemyShip
 */
- (void)addEnemyShip{
    
    _enemyShip = [SKSpriteNode spriteNodeWithImageNamed:@"enemyShip"];
    
    int minX = _enemyShip.size.width/2;
    int maxX = self.frame.size.width - _enemyShip.size.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    //enemyShip.position = CGPointMake(self.frame.size.height + enemyShip.size.height/2, actualX);
    _enemyShip.position = CGPointMake(actualX , self.frame.size.height + _enemyShip.size.height/2);
    
    [self addChild:_enemyShip];
    
    /**
     *   enemyShip物理外形
     */
    
    _enemyShip.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_enemyShip.size];
    _enemyShip.physicsBody.dynamic = YES;
    _enemyShip.physicsBody.categoryBitMask = enemyShipCategory;
    _enemyShip.physicsBody.contactTestBitMask = bulletCategory;
    _enemyShip.physicsBody.collisionBitMask = 0;//相互作用的效果掩码，0为无，其他诸如回弹等
    
    /**
     *   enemyShip动作
     */
    int minDuration = 2.0;
    int maxDuration = 4.0;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    SKAction *actionMove = [SKAction moveTo:CGPointMake(actualX , -_enemyShip.size.height/2) duration:actualDuration];
    
    SKAction *actionMoveDone = [SKAction removeFromParent];
    [_enemyShip runAction:[SKAction sequence:@[actionMove,actionMoveDone]]];
    
    /**
     *   发射子弹
     */
    
}

- (void)addBullet{
    
    SKSpriteNode *myBullet = [SKSpriteNode spriteNodeWithImageNamed:@"myBullet"];
    
    myBullet.position = self.spaceShip.position;
    
    
    [self addChild:myBullet];
    
    
    /**
     *   enemyShip物理外形
     */
    
    myBullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:myBullet.size];
    myBullet.physicsBody.dynamic = YES;
    myBullet.physicsBody.categoryBitMask = bulletCategory;
    myBullet.physicsBody.contactTestBitMask = enemyShipCategory;
    myBullet.physicsBody.collisionBitMask = 0;//相互作用的效果掩码，0为无，其他诸如回弹等
    myBullet.physicsBody.usesPreciseCollisionDetection = YES;//加强小而快的物体的检测效果，否则可能检测不到碰撞效果
    
    //动画效果
    CGPoint destination = CGPointMake(self.spaceShip.position.x, 1000);
    
    float bulletDuration = self.size.height / 480.0;
    
    SKAction *actionMove = [SKAction moveTo:destination duration:bulletDuration];
    
    SKAction *actionDone = [SKAction removeFromParent];
    
    [myBullet runAction:[SKAction sequence:@[actionMove,actionDone]]];
}

- (void)addEnemyBullet{
    
    SKSpriteNode *enemyBullet = [SKSpriteNode spriteNodeWithImageNamed:@"enemyBullet"];
    
    enemyBullet.position = self.enemyShip.position;
    
    [self addChild:enemyBullet];
    
    enemyBullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:enemyBullet.size];
    enemyBullet.physicsBody.dynamic = YES;
    enemyBullet.physicsBody.categoryBitMask = enemyBulletCategory;
    enemyBullet.physicsBody.contactTestBitMask = mySpaceShipCategory;
    enemyBullet.physicsBody.collisionBitMask = 0;//相互作用的效果掩码，0为无，其他诸如回弹等
    enemyBullet.physicsBody.usesPreciseCollisionDetection = YES;//加强小而快的物体的检测效果，否则可能检测不到碰撞效果
    
    //移动效果
    
    CGPoint offset = rwSub(self.spaceShip.position, self.enemyShip.position);
    
    CGPoint destination = rwAdd(offset, self.spaceShip.position);
    
    float bulletDuration = self.size.height / 480.0;
    
    SKAction *actionMove = [SKAction moveTo:destination duration:bulletDuration];
    
    SKAction *actionDone = [SKAction removeFromParent];
    
    [enemyBullet runAction:[SKAction sequence:@[actionMove,actionDone]]];
}

- (void)addShelter{
    
    shelterCount = 2;
    
    _myShelter = [SKSpriteNode spriteNodeWithImageNamed:@"mySheld"];
    
    _myShelter.position = CGPointMake(self.spaceShip.position.x, self.spaceShip.position.y + 20);
    
    [self addChild:_myShelter];
    
    _myShelter.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_myShelter.size];
    _myShelter.physicsBody.dynamic = YES;
    _myShelter.physicsBody.categoryBitMask = myShelterCategory;
    _myShelter.physicsBody.contactTestBitMask = enemyBulletCategory;
    _myShelter.physicsBody.collisionBitMask = 0;//相互作用的效果掩码，0为无，其他诸如回弹等
    
    self.myShelterLight = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"sheld" ofType:@"sks"]];
    
    self.myShelterLight.position = self.myShelter.position;
    
    [self addChild:self.myShelterLight];
    
    //护盾记数标签
    self.shelterLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    self.shelterLabel.text = [NSString stringWithFormat: @"护盾剩余:%d次",shelterCount];
    self.shelterLabel.fontSize = 20;
    self.shelterLabel.position = CGPointMake(self.frame.size.width - self.shelterLabel.frame.size.width/2,
                                             self.frame.size.height - self.shelterLabel.frame.size.height);
    
    [self addChild:self.shelterLabel];
}

- (void)removeShelter{
    
    if (self.myShelter) {
        
        [self.myShelter removeFromParent];
    }
}

#pragma mark -
#pragma mark 待调用方法

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast{
    
    self.lastSpawnTimeInterval += timeSinceLast;
    
    if (self.lastSpawnTimeInterval > 1) {
        
        self.lastSpawnTimeInterval = 0;
        
        [self addEnemyShip];
        
        [self addEnemyBullet];
        
        [_fire removeFromParent];//移除击毁敌机之后的火焰粒子效果
        
        bulletReload = YES;
        
    }
    //[self addBullet];
    
    if (shipDestoryed == 2) {
        
        [self addShelter];
        
        shipDestoryed = 0;
    }
}

/**
 *   当子弹击中时调用该方法消除子弹和对方飞船
 *
 *   @param myBullet  我的子弹
 *   @param enemyShip 敌方飞船
 */
- (void)whenBullet:(SKSpriteNode *)myBullet hitEnemyShip:(SKSpriteNode *)enemyShip{
    
    [myBullet removeFromParent];
    [enemyShip removeFromParent];
    
    
    //加分
    score = score + 50;
    
    if (shipDestoryed < 2&&shelterCount == 0) {
        
        shipDestoryed++;
    }
    
    self.scoreLabel.text = [NSString stringWithFormat: @"Score:%d",score];
    self.scoreLabel.position = CGPointMake(self.scoreLabel.frame.size.width/2,
                                           self.frame.size.height - self.scoreLabel.frame.size.height);
}

/**
 *   当相撞时调用该方法消除子弹和对方飞船
 *
 *   @param mySpaceShip  我的飞船
 *   @param enemyShip    敌方飞船
 */
- (void)whenEnemyShip:(SKSpriteNode *)enemyShip hitMyShip:(SKSpriteNode *)mySpaceShip{
    
    [enemyShip removeFromParent];
    
    [mySpaceShip removeFromParent];
    
    //存数据库
    [self saveFinalScore];
    
    //转入失败场景
    
    SKAction *loseAction = [SKAction runBlock:^{
        
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        
        SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
        
        //[gameOverScene setValue:resultScore forKey:@"resultScore"];
        
        [self.view presentScene:gameOverScene transition:reveal];
    }];
    
    [self runAction:loseAction];
    
}

/**
 *   当敌方子弹击中我的飞船时调用该方法
 *
 *   @param enemyBullet 敌方子弹
 *   @param mySpaceShip 我的飞车
 */
- (void)whenEnemyBullet:(SKSpriteNode *)enemyBullet hitMyShip:(SKSpriteNode *)mySpaceShip{
    
    [mySpaceShip removeFromParent];
    
    //存数据库
    [self saveFinalScore];
    
    SKAction *loseAction = [SKAction runBlock:^{
        
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        
        SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size won:NO];
        
        //[gameOverScene setValue:resultScore forKey:@"resultScore"];
        
        [self.view presentScene:gameOverScene transition:reveal];
    }];
    
    [self runAction:loseAction];
}

- (void)whenEnemyBullet:(SKSpriteNode *)enemyBullet hitMyShelter:(SKEmitterNode *)mySpaceShip{
    
    [enemyBullet removeFromParent];
}

#pragma mark -
#pragma mark 保存分数
/**
 *  结束后保存分数
 */
- (void)saveFinalScore{
    
    //NSString *ps             = [NSString stringWithFormat:@"%d",score];
    
    AVObject *result = [AVObject objectWithClassName:@"finalGameScore"];
    
    [result setObject:playerName forKey:@"playerName"];
    [result setObject:[NSNumber numberWithInt:score] forKey:@"gameScore"];
    
    [result saveInBackground];
}

#pragma mark -
#pragma mark 控制移动

/**
 *   触摸控制移动
 *
 *   @param  通过触摸点移动飞船（传统方式）
 *
 *   @return nil
 */
/*- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
 
 UITouch * touch = [touches anyObject];
 
 CGPoint touchLocation = [touch locationInNode:self];
 
 CGPoint offset = rwSub(touchLocation, self.spaceShip.position);
 
 CGPoint destination = rwAdd(offset, self.spaceShip.position);
 
 float moveDuration = 0.0;
 
 SKAction *actionMove = [SKAction moveTo:destination duration:moveDuration];
 
 [self.spaceShip runAction:actionMove];
 
 
 //同步移动护盾位置
 _myShelter.position = CGPointMake(self.spaceShip.position.x, self.spaceShip.position.y + 20);
 
 _myShelterLight.position = _myShelter.position;
 }*/

/**
 *   朝点击方向发射子弹
 *
 *   @param touches 触摸点
 *   @param event   事件
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (!bulletReload) {
        
        return;
    }
    
    _myBullet = [SKSpriteNode spriteNodeWithImageNamed:@"myBullet"];
    
    _myBullet.position = self.spaceShip.position;
    
    [self addChild:_myBullet];
    
    [_fire removeFromParent];
    
    /**
     *   enemyShip物理外形
     */
    
    _myBullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_myBullet.size];
    _myBullet.physicsBody.dynamic = YES;
    _myBullet.physicsBody.categoryBitMask = bulletCategory;
    _myBullet.physicsBody.contactTestBitMask = enemyShipCategory;
    _myBullet.physicsBody.collisionBitMask = 0;//相互作用的效果掩码，0为无，其他诸如回弹等
    _myBullet.physicsBody.usesPreciseCollisionDetection = YES;//加强小而快的物体的检测效果，否则可能检测不到碰撞效果
    
    //动画效果
    UITouch *touch = [touches anyObject];
    
    CGPoint touchLocation = [touch locationInNode:self];
    
    CGPoint offset = rwSub(touchLocation, self.spaceShip.position);
    
    CGPoint direction = rwNormalize(offset);
    
    CGPoint shootAmount = rwMult(direction, 1000);
    
    CGPoint destination = rwAdd(shootAmount, self.spaceShip.position);
    
    float bulletDuration = self.size.height / 480.0;
    
    SKAction *actionMove = [SKAction moveTo:destination duration:bulletDuration];
    
    SKAction * actionMoveDone = [SKAction removeFromParent];
    
    [_myBullet runAction:[SKAction sequence:@[actionMove,actionMoveDone]]];
    
    bulletReload = NO;
}

/**
 *   利用重力感应移动飞船
 */
- (void)moveMySpaceShip{
    
    int acceleration  = 50;
    
    float offsetX = manager.accelerometerData.acceleration.x * acceleration;
    
    float offsetY = manager.accelerometerData.acceleration.y * acceleration;
    
    
    CGPoint moveLocation = CGPointMake(self.spaceShip.position.x + offsetX, self.spaceShip.position.y + offsetY);
    
    /**
     *   检测防止超出屏幕X边界
     */
    if (moveLocation.x >= self.view.frame.size.width) {
        
        moveLocation = CGPointMake(self.view.frame.size.width, moveLocation.y);
        
    }else if (moveLocation.x < 0){
        
        moveLocation = CGPointMake(self.spaceShip.size.width/2, moveLocation.y);
    }
    
    /**
     *   检测防止超出屏幕Y边界
     */
    if (moveLocation.y >= self.view.frame.size.height) {
        
        moveLocation = CGPointMake(moveLocation.x,self.view.frame.size.height);
        
    }else if (moveLocation.y < 0){
        
        moveLocation = CGPointMake(moveLocation.x,self.spaceShip.size.height/2);
    }
    
    CGPoint offset = rwSub(moveLocation, self.spaceShip.position);
    
    CGPoint destination = rwAdd(offset, self.spaceShip.position);
    
    float moveDuration = 0.05;
    
    SKAction *actionMove = [SKAction moveTo:destination duration:moveDuration];
    
    [self.spaceShip runAction:actionMove];
    
    
    //同步移动护盾位置
    _myShelter.position = CGPointMake(self.spaceShip.position.x, self.spaceShip.position.y + 20);
    
    _myShelterLight.position = _myShelter.position;
}

#pragma mark -
#pragma mark 代理

/**
 *   在显示每帧时都会调用update:方法。
 *
 *   @param currentTime 当前时间
 */
- (void)update:(NSTimeInterval)currentTime{
    
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    
    self.lastUpdateTimeInterval = currentTime;
    
    if (timeSinceLast >1) {
        
        timeSinceLast = 1.0/60.0;
        
        self.lastUpdateTimeInterval = currentTime;
        
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
    [self moveMySpaceShip];
    
    
}

/**
 *   碰撞代理
 *
 *   @param contact 碰撞对象
 */
- (void)didBeginContact:(SKPhysicsContact *)contact{
    
    SKPhysicsBody *firstBody,* secondBody;
    
    //判断并排序两个碰撞体
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }else{
        
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & bulletCategory) != 0 && (secondBody.categoryBitMask & enemyShipCategory)){
        
        _fire = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"MyParticle" ofType:@"sks"]];
        _fire.position = secondBody.node.position;
        [self addChild:_fire];
        
        
        [self whenBullet:(SKSpriteNode *)firstBody.node hitEnemyShip:(SKSpriteNode *)secondBody.node];
        
    }else if ((firstBody.categoryBitMask & enemyShipCategory) != 0 && (secondBody.categoryBitMask & mySpaceShipCategory)){
        
        [self whenEnemyShip:(SKSpriteNode *)firstBody.node hitMyShip:(SKSpriteNode *)secondBody.node];
        
    }else if ((firstBody.categoryBitMask & mySpaceShipCategory) != 0 && (secondBody.categoryBitMask & enemyBulletCategory)){
        
        [self whenEnemyBullet:(SKSpriteNode *)firstBody.node hitMyShip:(SKSpriteNode *)secondBody.node];
    }else if ((firstBody.categoryBitMask & enemyBulletCategory) != 0 && (secondBody.categoryBitMask & myShelterCategory)){
        
        [self whenEnemyBullet:(SKSpriteNode *)firstBody.node hitMyShelter:(SKEmitterNode *)secondBody.node];
        
        shelterCount --;
        
        self.shelterLabel.text = [NSString stringWithFormat: @"护盾剩余:%d次",shelterCount];
        
        if (shelterCount <= 0) {
            
            [self.myShelterLight removeFromParent];
            
            [self.myShelter removeFromParent];
            
            [self.shelterLabel removeFromParent];
        }
    }
}

@end
