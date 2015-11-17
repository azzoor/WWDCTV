//
//  AppDelegate.m
//  WWDC
//
//  Created by Aaron Stephenson on 17/11/2015.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import "AppDelegate.h"
#import "Header.h"
#import "VideoTableViewController.h"

@interface AppDelegate ()
@property (nonatomic, strong) UITabBarController *tabBarController;
@end

@implementation AppDelegate

-(NSArray *) readJSON
{
    //Get JSON
    NSMutableArray *videoArray = [NSMutableArray new];
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"videos" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *allVideos = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    //Sorts the conferences by order_id this has been onfigured to ensure the newer conferences appear first.
    NSSortDescriptor *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:kOrderIDKey ascending:true];
    allVideos = [allVideos sortedArrayUsingDescriptors:@[brandDescriptor]];
    
    //Get the conference ids which are to be used for the tabBarController
    for (NSDictionary *videoDictionary in allVideos)
    {
        if (![videoArray containsObject:[videoDictionary objectForKey:kConferenceKey]])
        {
            [videoArray addObject:[videoDictionary objectForKey:kConferenceKey]];
        }
    }
    
    return [videoArray copy];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray *videoArray = [self readJSON];
    
    // Override point for customization after application launch.
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSMutableArray *conferenceViewArray = [NSMutableArray new];
    
    //Setup each tabBarItem. Note that there is a limit of 5 tabbar items.
    for (NSString *conferenceID in videoArray)
    {
        if ([conferenceViewArray count] >= 5) break;

        UISplitViewController *splitViewController = [storyboard instantiateViewControllerWithIdentifier:@"SplitViewController"];
        splitViewController.tabBarItem.title = conferenceID;
        UINavigationController *navController = [splitViewController.viewControllers firstObject];
        VideoTableViewController *vc = (VideoTableViewController *)[navController.viewControllers firstObject];
        vc.conference_id = conferenceID;
        [conferenceViewArray addObject:splitViewController];
    }

    //Setup the tabBarController
    self.tabBarController = [UITabBarController new];
    self.tabBarController.viewControllers = conferenceViewArray;
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
