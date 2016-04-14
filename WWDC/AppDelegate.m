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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self downloadJSONFile];
    
    //Setup the tabBarController
    self.tabBarController = [UITabBarController new];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)initializeRootViewControllerWith:(NSArray*)videoArray {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSMutableArray *conferenceViewArray = [NSMutableArray new];
    
    //Setup each tabBarItem. Note that there is a limit of 5 tabbar items.
    for (NSString *conferenceID in videoArray)
    {
        if ([conferenceViewArray count] >= 5) break;

        UISplitViewController *splitViewController = [storyboard instantiateViewControllerWithIdentifier:@"SplitViewController"];
        splitViewController.preferredPrimaryColumnWidthFraction = 0.43;
        splitViewController.tabBarItem.title = conferenceID;
        UINavigationController *navController = [splitViewController.viewControllers firstObject];
        VideoTableViewController *vc = (VideoTableViewController *)[navController.viewControllers firstObject];
        vc.conference_id = conferenceID;
        [conferenceViewArray addObject:splitViewController];
    }
    [self.tabBarController setViewControllers: conferenceViewArray animated:NO];
}

// JSON location = https://raw.githubusercontent.com/azzoor/WWDCTV/master/WWDC/videos.json
- (void)downloadJSONFile {
    NSURLSession* downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURL* url = [NSURL URLWithString:@"https://raw.githubusercontent.com/azzoor/WWDCTV/master/WWDC/videos.json"];
    [[downloadSession dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (((NSHTTPURLResponse*)response).statusCode == 200) {
            
        }
        NSArray* videoArray = [self parseJSONData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initializeRootViewControllerWith:videoArray];
        });
    }] resume];
}

- (NSArray *)parseJSONData:(NSData*)data
{
    //Get JSON
    NSMutableArray *videoArray = [NSMutableArray new];
    NSError *error = nil;
    self. allVideos = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    //Sorts the conferences by order_id this has been onfigured to ensure the newer conferences appear first.
    NSSortDescriptor *brandDescriptor = [[NSSortDescriptor alloc] initWithKey:kOrderIDKey ascending:true];
    self.allVideos = [self.allVideos sortedArrayUsingDescriptors:@[brandDescriptor]];
    
    //Get the conference ids which are to be used for the tabBarController
    for (NSDictionary *videoDictionary in self.allVideos)
    {
        if (![videoArray containsObject:[videoDictionary objectForKey:kConferenceKey]])
        {
            [videoArray addObject:[videoDictionary objectForKey:kConferenceKey]];
        }
    }
    
    return [videoArray copy];
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
