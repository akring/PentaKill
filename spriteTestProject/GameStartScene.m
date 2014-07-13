//
//  GameStartScene.m
//  spriteTestProject
//
//  Created by whkj on 14-3-28.
//  Copyright (c) 2014年 Akring. All rights reserved.
//

#import "GameStartScene.h"
#import "MyScene.h"
#import "AppDelegate.h"

@interface GameStartScene()

@property (nonatomic) SKLabelNode *startLabel;

@end

@implementation GameStartScene

-(id)initWithSize:(CGSize)size {
    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        self.startLabel = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        
        
        self.startLabel.text = @"Game Start";
        self.startLabel.fontSize = 40;
        self.startLabel.position = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
        
        [self addChild:self.startLabel];
        
        if (playerName.length == 0) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"请输入姓名"
                                                           message:@"姓名将用于排行"
                                                          delegate:self
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil, nil];
            
            alert.alertViewStyle = UIAlertViewStylePlainTextInput;
            
            [alert show];
        }
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    SKAction *loseAction = [SKAction runBlock:^{
        
        SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
        
        SKScene *gameOverScene = [[MyScene alloc] initWithSize:self.size];
        
        [self.view presentScene:gameOverScene transition:reveal];
    }];
    
    [self runAction:loseAction];
}

#pragma mark -
#pragma mark Alert代理

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        UITextField *tx = [alertView textFieldAtIndex:0];
        
        playerName = tx.text;
        
        if (tx.text.length == 0) {
            
            playerName = @"无名氏";
        }
    }
}

@end
