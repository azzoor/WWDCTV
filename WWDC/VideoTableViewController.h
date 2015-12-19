//
//  VideoTableViewController.h
//  WWDC
//
//  Created by Aaron Stephenson on 17/11/2015.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoDetailViewController.h"

@interface VideoTableViewController : UITableViewController <VideoDetailViewControllerDelegate>
@property (nonatomic, strong) NSString *conference_id;
@end
