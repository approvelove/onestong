//
//  AppDelegate.m
//  onestong
//
//  Created by 王亮 on 14-4-18.
//  Copyright (c) 2014年 王亮. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "LocationHelper.h"
#import "TimeHelper.h"
#import "DeviceTraceService.h"
#import "DeviceTraceModel.h"

long long OST_WORKON_TIME;
long long OST_WORKEND_TIME;

static NSInteger AWAKETIMENUM = 10; //每隔60秒唤醒一次(10min 发送一次定位) //test begin in 16:37
static NSInteger STARTLOCATIONTIME = 10*60;
static NSInteger currentSeconds = 10;
static long long latestTimeRecord;
@implementation AppDelegate
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //取消所有本地推送
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    latestTimeRecord = [TimeHelper convertDateToSecondTime:[NSDate date]];
    LoginViewController *loginViewController = [[LoginViewController alloc]init];
    UINavigationController * controller = [[UINavigationController alloc]initWithRootViewController:loginViewController];
    [self.window setRootViewController:controller];
    [self.window makeKeyAndVisible];
    return YES;
}

//////////////////////////////////////////////
- (void)initLocationHelper
{
    locationHelper = [[LocationHelper alloc] init];
    [locationHelper initGPSLocation];
}

- (void)startLocationHelper
{
    NSDate *now = [NSDate date];
    if ([self isWeekEndDayWithDate:now]) {
        return;
    }
    if (![self isWorkOnTimeNow]) {
        return;
    }
    NSLog(@"哈哈好");
    [locationHelper startLocation];
    currentSeconds += AWAKETIMENUM;
}

- (BOOL)isWeekEndDayWithDate:(NSDate *)date
{
    NSString *weekDay = [TimeHelper getWeekDayInweekWithDate:date];
    if ([weekDay isEqualToString:@"星期六"] || [weekDay isEqualToString:@"星期日"]) {
        return YES;
    }
    return NO;
}

- (void)locationFail:(NSNotification *)notification
{
    NSLog(@"error");
    [locationHelper startLocation];
}

- (void)locationSuccess:(NSNotification *)notification
{
    NSLog(@"userinfo=%@",notification.userInfo);
    DeviceTraceService *service = [[DeviceTraceService alloc] init];
    DeviceTraceModel *deviceModel = [[DeviceTraceModel alloc] init];
    deviceModel.longtitude =[notification.userInfo[@"longitude"] doubleValue];
    deviceModel.latitude = [notification.userInfo[@"latitude"] doubleValue];
    deviceModel.location = notification.userInfo[@"address"];
    if (currentSeconds >= STARTLOCATIONTIME) {
        NSLog(@"发送定位点");
        currentSeconds = 0;
        [service addDeviceTraceInfoWithDeviceTraceModel:deviceModel];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    latestTimeRecord = [TimeHelper convertDateToSecondTime:[NSDate date]];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (BOOL)isWorkOnTimeNow
{
    NSDateComponents *comps = [TimeHelper getDateComponents];
    NSString *currentDate = [NSString stringWithFormat:@"%02ld:%02ld",(long)comps.hour,(long)comps.minute];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSDate *current = [dateFormatter dateFromString:currentDate];
    long long currentDateNum = [TimeHelper convertDateToSecondTime:current];
    if (currentDateNum<OST_WORKON_TIME||currentDateNum>OST_WORKEND_TIME) {
        //9点到18点之外为非工作时间，无需知道位置
        return NO;
    }
    return YES;
}

- (void)runThreadOnBackgroundWithStartTime:(long long)startTime endTime:(long long)endTime
{
    //    long long comps = [TimeHelper convertDateToSecondTime:[NSDate date]];
    OST_WORKON_TIME = startTime;
    OST_WORKEND_TIME = endTime;
    return;
    if (![self isWorkOnTimeNow]) {
        return;
    }
    
    [self registLocationNotification];
    [self initLocationHelper];
    NSLog(@"%@",NSStringFromSelector(_cmd));
    
    //得到当前应用程序的UIApplication对象
    UIApplication *app = [UIApplication sharedApplication];
    //一个后台任务标识符
    UIBackgroundTaskIdentifier taskID = UIBackgroundTaskInvalid;
    
    taskID =  [app beginBackgroundTaskWithExpirationHandler:^{
        
    }];
    //UIBackgroundTaskInvalid表示系统没有为我们提供额外的时候
    if (taskID == UIBackgroundTaskInvalid) {
        NSLog(@"Failed to start background task!");
        return;
    }
    NSLog(@"Starting background task with %f seconds remaining", app.backgroundTimeRemaining);
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:AWAKETIMENUM target:self selector:@selector(startLocationHelper) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [timer fire];
    NSLog(@"Finishing background task with %f seconds remaining",app.backgroundTimeRemaining);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    long long now = [TimeHelper convertDateToSecondTime:[NSDate date]];
    //    [[NSNotificationCenter defaultCenter] postNotificationName:VERSION_CHECK_NOTIFICATION object:nil userInfo:nil];
    
    if ((now - latestTimeRecord) / 1000 / 60 >=10) { //每隔10分钟校验
        [[NSNotificationCenter defaultCenter] postNotificationName:VERSION_CHECK_NOTIFICATION object:nil];
    }
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"onestong" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"onestong.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                                       NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES],
                                       NSInferMappingModelAutomaticallyOption, nil];
    
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:optionsDictionary error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark -
#pragma mark 通知管理

- (void)registLocationNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationSuccess:) name:NOTIFICATION_LOCATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationFail:) name:NOTIFICATION_LOCATION_ERROR object:nil];
}

- (void)freeLocationNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOCATION_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_LOCATION object:nil];
}

@end
