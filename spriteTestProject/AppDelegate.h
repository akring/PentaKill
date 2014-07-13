//
//  AppDelegate.h
//  spriteTestProject
//
//  Created by whkj on 14-3-28.
//  Copyright (c) 2014年 Akring. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

int score;

NSString *playerName;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 *   coredata对象
 */
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;

@end
