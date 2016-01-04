//
//  VideoTableViewController.m
//  WWDC
//
//  Created by Aaron Stephenson on 17/11/2015.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import "VideoTableViewController.h"
#import "Header.h"
#import "FavoritesManager.h"

@interface VideoTableViewController ()
@property (nonatomic, strong) NSArray *sectionArray;
@property (nonatomic, strong) NSArray *visibleArray;
@property BOOL selectedCellMatchesFocusedCell; // this property is to help the focus engine

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
    self.visibleArray = self.sectionArray;

    [self.tableView reloadData];
    
    //Select the first item.
    [self selectTheFirstItem];
}

- (void)selectTheFirstItem
{
    NSDictionary *sectionDictionary = [self.visibleArray firstObject];
    NSArray *videoArray = sectionDictionary[kVideosKey];
    NSDictionary *videoObjectDictionary = [videoArray firstObject];
    [self setupDetailViewWithVideo:videoObjectDictionary];
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
    return self.visibleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sectionDictionary = self.visibleArray[section];
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
    
    NSDictionary *sectionDictionary = self.visibleArray[indexPath.section];
    NSArray *videoArray = sectionDictionary[kVideosKey];
    NSDictionary *videoObjectDictionary = videoArray[indexPath.row];

    cell.textLabel.text = videoObjectDictionary[kTitleKey];
    cell.detailTextLabel.text = videoObjectDictionary[kSessionIDKey];
    
    NSString* videoURL = [videoObjectDictionary objectForKey:kVideoURLKey];
    if ([FavoritesManager isVideoAFavorite:videoURL]) {
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart_selected"]];
    }
    else
    {
        cell.accessoryView = nil;
    }
    return cell;
}

- (UIView *)preferredFocusedView
{
    // this method override is necessary to focus the PlayButton
    // when tableView:didSelectRowAtIndexPath: is called
    if (self.selectedCellMatchesFocusedCell)
    {
        UINavigationController *childNavVC = self.splitViewController.viewControllers[1];
        VideoDetailViewController *childVC = [childNavVC.viewControllers firstObject];
        return childVC.playButton;
    }
    else
    {
        return [super preferredFocusedView];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    // this is kind of hacky but I see no way around it
    // You can't change focus programatically when the cell is selected
    // Instead, setting a boolean property and then asking the focus engine to update
    // then in preferredFocusedView I check for the bool and either call super or give it the view of the play button
    //
    self.selectedCellMatchesFocusedCell = YES;
    [self setNeedsFocusUpdate];
}

//On changing the focus of the table view this will update the detail view of the SplitViewController
- (void)tableView:(UITableView *)tableView didUpdateFocusInContext:(UITableViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
    // this property is to help the focus engine
    self.selectedCellMatchesFocusedCell = NO;
    //
    
    NSIndexPath *nextIndexPath = [context nextFocusedIndexPath];
    if (nextIndexPath == nil) return;

    NSDictionary *sectionDictionary = self.visibleArray[nextIndexPath.section];
    NSArray *videoArray = sectionDictionary[kVideosKey];
    NSDictionary *videoObjectDictionary = videoArray[nextIndexPath.row];
    [self setupDetailViewWithVideo:videoObjectDictionary];
}

- (void)setupDetailViewWithVideo:(NSDictionary *)videoObjectDictionary
{
    UINavigationController *childNavVC = self.splitViewController.viewControllers[1];
    VideoDetailViewController *childVC = [childNavVC.viewControllers firstObject];
    childVC.delegate = self;
    [childVC setupVideoDictionaryObject:videoObjectDictionary];
}

//VideoDetailViewController Delegate
- (void)videoInformationHasChanged
{
    [self.tableView reloadData];
}

//Change the filter of the shown sessions, either all sessions or only the favourited one.
- (IBAction)onSessionFilterVC:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        //Show All
        self.visibleArray = self.sectionArray;
    }
    else
    {
        //Show only favourites
        NSDictionary *sectionDictionary = [self.sectionArray firstObject];
        NSArray *videoArray = sectionDictionary[kVideosKey];
        
        NSMutableArray* filteredVideos = [NSMutableArray arrayWithCapacity:videoArray.count];
        NSArray* favorites = [FavoritesManager arrayOfFavorites];
        for (NSDictionary* session in videoArray)
        {
            if ([favorites containsObject:session[kVideoURLKey]])
            {
                [filteredVideos addObject:session];
            }
        }
        self.visibleArray = @[@{kConferenceKey: self.conference_id,
                                kVideosKey: filteredVideos}];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.visibleArray.count)] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self selectTheFirstItem];
}


@end
