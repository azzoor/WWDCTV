//
//  VideoDetailViewController.h
//  WWDC
//
//  Created by Aaron Stephenson on 17/11/2015.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VideoDetailViewControllerDelegate <NSObject>
- (void) videoInformationHasChanged;
@end

@interface VideoDetailViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIButton *playButton;
@property (nonatomic, weak) IBOutlet UIButton *favButton;
@property (nonatomic, weak) id <VideoDetailViewControllerDelegate> delegate;
- (void)setupVideoDictionaryObject:(NSDictionary *)videoDictionary;
- (void)toggleFavorite;
@end
