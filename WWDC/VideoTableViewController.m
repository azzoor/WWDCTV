//
//  VideoTableViewController.m
//  WWDC
//
//  Created by Aaron Stephenson on 17/11/2015.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import "VideoTableViewController.h"
#import "VideoDetailViewController.h"
#import "Header.h"

@interface VideoTableViewController ()
@property (nonatomic, strong) NSArray *sectionArray;
@end

@implementation VideoTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.conference_id;
    
    NSArray *allVideos = [self readJSONFile];
    NSArray *videosForThisConference = [allVideos filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"conference CONTAINS[cd] %@", self.conference_id]];
    self.sectionArray = @[@{kConferenceKey: self.conference_id,
                            kVideosKey: videosForThisConference}];

    [self.tableView reloadData];
    
    //Select the first item.
    NSDictionary *sectionDictionary = [self.sectionArray firstObject];
    NSArray *videoArray = sectionDictionary[kVideosKey];
    NSDictionary *videoObjectDictionary = [videoArray firstObject];
    if (videoObjectDictionary == nil) return;
    
    UINavigationController *childNavVC = self.splitViewController.viewControllers[1];
    VideoDetailViewController *childVC = [childNavVC.viewControllers firstObject];
    [childVC setupVideoDictionaryObject:videoObjectDictionary];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)readJSONFile
{
    //Get JSON File
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"videos" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *allVideos = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    return allVideos;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionDictionary = self.sectionArray[section];
    return [sectionDictionary[kVideosKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:simpleTableIdentifier];
    }
    
    NSDictionary *sectionDictionary = self.sectionArray[indexPath.section];
    NSArray *videoArray = sectionDictionary[kVideosKey];
    NSDictionary *videoObjectDictionary = videoArray[indexPath.row];

    cell.textLabel.text = videoObjectDictionary[kTitleKey];
    cell.detailTextLabel.text = videoObjectDictionary[kSessionIDKey];
    return cell;
}

//On changing the focus of the table view this will update the detail view of the SplitViewController
- (void)tableView:(UITableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
    NSIndexPath *nextIndexPath = [context nextFocusedIndexPath];
    if (nextIndexPath == nil) return;

    NSDictionary *sectionDictionary = self.sectionArray[nextIndexPath.section];
    NSArray *videoArray = sectionDictionary[kVideosKey];
    NSDictionary *videoObjectDictionary = videoArray[nextIndexPath.row];
    
    UINavigationController *childNavVC = self.splitViewController.viewControllers[1];
    VideoDetailViewController *childVC = [childNavVC.viewControllers firstObject];
    [childVC setupVideoDictionaryObject:videoObjectDictionary];
}

@end
