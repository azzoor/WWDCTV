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

-(NSArray *) readJSON
{
    //Get JSON File
    NSError *error = nil;
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"videos" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSArray *allVideos = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];

    return allVideos;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.conference_id;
    
    NSArray *allVideos = [self readJSON];
    NSArray *videosForThisConference = [allVideos filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"conference CONTAINS[cd] %@", self.conference_id]];
    
    self.sectionArray = @[@{kConferenceKey: self.conference_id,
                            kVideosKey: videosForThisConference}];
    
    [self.tableView reloadData];
    
    //Selects the first item.
    if ([self.sectionArray count] > 0)
    {
        NSDictionary *sectionDictionary =  [self.sectionArray firstObject];
        NSArray *videoArray = sectionDictionary[kVideosKey];
        if ([videoArray count] > 0)
        {
            NSDictionary *videoObjectDictionary = [videoArray firstObject];
            
            VideoDetailViewController *viewTmp = [self.splitViewController.viewControllers objectAtIndex:1];
            [viewTmp setupVideoDictionaryObject:videoObjectDictionary];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionDictionary =  [self.sectionArray objectAtIndex:section];
    return [sectionDictionary[kVideosKey] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    NSDictionary *sectionDictionary = [self.sectionArray objectAtIndex:indexPath.section];
    NSArray *videoArray = sectionDictionary[kVideosKey];
    NSDictionary *videoObjectDictionary = [videoArray objectAtIndex:indexPath.row];

    cell.textLabel.text = videoObjectDictionary[kTitleKey];
    cell.textLabel.font = [UIFont systemFontOfSize:22];
    return cell;
}

//On changing the focus of the table view this will update the detail view of the SplitViewController
- (void)tableView:(UITableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
    NSIndexPath *nextIndexPath = [context nextFocusedIndexPath];
    if (nextIndexPath != nil)
    {
        NSDictionary *sectionDictionary = [self.sectionArray objectAtIndex:nextIndexPath.section];
        NSArray *videoArray = sectionDictionary[kVideosKey];
        NSDictionary *videoObjectDictionary = [videoArray objectAtIndex:nextIndexPath.row];
        
        VideoDetailViewController *viewTmp = [self.splitViewController.viewControllers objectAtIndex:1];
        [viewTmp setupVideoDictionaryObject:videoObjectDictionary];
    }
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSDictionary *sectionDictionary = [self.sectionArray objectAtIndex:section];
//    return [sectionDictionary objectForKey:kConferenceKey];
//}

@end
