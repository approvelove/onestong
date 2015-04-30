//
//  AppDelegate.h
//  onestong
//
//  Created by 王亮 on 14-4-18.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LocationHelper;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    LocationHelper *locationHelper;
}

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void)runThreadOnBackgroundWithStartTime:(long long)startTime endTime:(long long)endTime;
@end
