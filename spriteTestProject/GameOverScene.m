//
//  GameOverScene.m
//  spriteTestProject
//
//  Created by whkj on 14-3-28.
//  Copyright (c) 2014年 Akring. All rights reserved.
//

#import "GameOverScene.h"
#import "GameStartScene.h"
#import "AppDelegate.h"

@interface GameOverScene()

@property (nonatomic) NSString *resultMessage;

@property (nonatomic,strong)NSMutableArray *highScoreNameArray;
@property (nonatomic,strong)NSMutableArray *highScoreScoreArray;

@property (nonatomic,strong)SKLabelNode *name1;
@property (nonatomic,strong)SKLabelNode *name2;
@property (nonatomic,strong)SKLabelNode *name3;

@property (nonatomic,strong)SKLabelNode *score1;
@property (nonatomic,strong)SKLabelNode *score2;
@property (nonatomic,strong)SKLabelNode *score3;

@end

@implementation GameOverScene

- (id)initWithSize:(CGSize)size won:(BOOL)won{
    
    _highScoreNameArray = [[NSMutableArray alloc]init];
    _highScoreScoreArray = [[NSMutableArray alloc]init];
    
    AVQuery *querry = [AVQuery queryWithClassName:@"finalGameScore"];
    
    [querry addDescendingOrder:@"gameScore"];
    
    //querry.limit = 3;
    
    [querry findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
            
            NSLog(@"error code:%d",[error code]);
            
        }else{
            
            for (AVObject *result in objects) {
                
                NSString *name = [result objectForKey:@"playerName"];
                int sc = [[result objectForKey:@"gameScore"] intValue];
                NSString *score = [NSString stringWithFormat:@"%d",sc];
                
                [_highScoreNameArray addObject:name];
                [_highScoreScoreArray addObject:score];
            }
        }
        
        [self refreshInterface];
    }];
    
    if (self = [super initWithSize:size]) {
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"score"];
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        if (won) {
            
            self.resultMessage = @"You Win !";
        }else{
            
            self.resultMessage = @"Game Over !";
        }
        
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = self.resultMessage;
        label.fontSize = 40;
        label.fontColor = [SKColor whiteColor];
        label.position = CGPointMake(self.size.width/2, self.size.height-80);
        [self addChild:label];
        
        SKLabelNode *detail = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        detail.text = [NSString stringWithFormat:@"得分：%d",score];
        detail.fontSize = 30;
        detail.fontColor = [SKColor whiteColor];
        detail.position = CGPointMake(label.position.x, label.position.y - detail.frame.size.height*2);
        [self addChild:detail];
        
        //排名标签1
        _name1 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        //_name1.text = [NSString stringWithFormat:@"1. %@",[_highScoreNameArray objectAtIndex:0]];
        _name1.fontSize = 20;
        _name1.fontColor = [SKColor whiteColor];
        _name1.position = CGPointMake(100, detail.position.y - label.frame.size.height*4);
        [self addChild:_name1];
        
        _score1 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        //_score1.text = [NSString stringWithFormat:@"%@",[_highScoreScoreArray objectAtIndex:0]];
        _score1.fontSize = 20;
        _score1.fontColor = [SKColor whiteColor];
        _score1.position = CGPointMake(220, _name1.position.y);
        [self addChild:_score1];
        
        //排名标签2
        
        _name2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        //_name2.text = playerName2;
        _name2.fontSize = 20;
        _name2.fontColor = [SKColor whiteColor];
        _name2.position = CGPointMake(100, 214);
        [self addChild:_name2];
        
        _score2 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        //_score2.text = playerScore2;
        _score2.fontSize = 20;
        _score2.fontColor = [SKColor whiteColor];
        _score2.position = CGPointMake(220, _name2.position.y);
        [self addChild:_score2];
        
        //排名标签1
        
        _name3 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        //_name3.text = playerName3;
        _name3.fontSize = 20;
        _name3.fontColor = [SKColor whiteColor];
        _name3.position = CGPointMake(100, 164);
        [self addChild:_name3];
        
        _score3 = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        //_score3.text = playerScore3;
        _score3.fontSize = 20;
        _score3.fontColor = [SKColor whiteColor];
        _score3.position = CGPointMake(220, _name3.position.y);
        [self addChild:_score3];
    }
    
    return self;
}

/**
 *  刷新界面
 */
- (void)refreshInterface{
    
    if (_highScoreNameArray.count == 1)
        
    {
        _name1.text = [NSString stringWithFormat:@"1. %@",[_highScoreNameArray objectAtIndex:0]];
        _score1.text = [NSString stringWithFormat:@"%@",[_highScoreScoreArray objectAtIndex:0]];
    }
    else if (_highScoreNameArray.count == 2)
        
    {
        _name1.text = [NSString stringWithFormat:@"1. %@",[_highScoreNameArray objectAtIndex:0]];
        _score1.text = [NSString stringWithFormat:@"%@",[_highScoreScoreArray objectAtIndex:0]];
        _name2.text = [NSString stringWithFormat:@"2. %@",[_highScoreNameArray objectAtIndex:1]];
        _score2.text = [NSString stringWithFormat:@"%@",[_highScoreScoreArray objectAtIndex:1]];
    }
    else if (_highScoreNameArray.count >= 3)
    {
        _name1.text = [NSString stringWithFormat:@"1. %@",[_highScoreNameArray objectAtIndex:0]];
        _score1.text = [NSString stringWithFormat:@"%@",[_highScoreScoreArray objectAtIndex:0]];
        _name2.text = [NSString stringWithFormat:@"2. %@",[_highScoreNameArray objectAtIndex:1]];
        _score2.text = [NSString stringWithFormat:@"%@",[_highScoreScoreArray objectAtIndex:1]];
        _name3.text = [NSString stringWithFormat:@"3. %@",[_highScoreNameArray objectAtIndex:2]];
        _score3.text = [NSString stringWithFormat:@"%@",[_highScoreScoreArray objectAtIndex:2]];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    SKAction *loseAction = [SKAction runBlock:^{
        
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        
        SKScene *gameOverScene = [[GameStartScene alloc] initWithSize:self.size];
        
        [self.view presentScene:gameOverScene transition:reveal];
        
    }];
    
    [self runAction:loseAction];
}

@end
