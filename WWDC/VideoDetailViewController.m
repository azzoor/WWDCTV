//
//  VideoDetailViewController.m
//  WWDC
//
//  Created by Aaron Stephenson on 17/11/2015.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "Header.h"

@import AVKit;

@interface VideoDetailViewController ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *platformLabel;
@property (nonatomic, weak) IBOutlet UILabel *sessionIDLabel;
@property (nonatomic, weak) IBOutlet UITextView *descriptionLabel;
@property (nonatomic, strong) NSDictionary *videoDictionary;
@end

@implementation VideoDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//Setup detail labels
- (void)setupVideoDictionaryObject:(NSDictionary *)videoDictionary
{
    self.videoDictionary = videoDictionary;
    self.titleLabel.text = [self.videoDictionary objectForKey:kTitleKey];
    self.platformLabel.text = [self.videoDictionary objectForKey:kPlatformKey];
    self.sessionIDLabel.text = [self.videoDictionary objectForKey:kSessionIDKey];
    self.descriptionLabel.text = [self.videoDictionary objectForKey:kDescriptionKey];
}

//Plays the video on selecting the Play Video button
- (IBAction)playVideo:(id)sender
{
    AVPlayerViewController *viewTmp = [[AVPlayerViewController alloc]init];
    AVPlayer *player = [[AVPlayer alloc]initWithURL:[NSURL URLWithString:[self.videoDictionary objectForKey:kVideoURLKey]]];
    viewTmp.player = player;
    [self presentViewController:viewTmp animated:true completion:^{
        [player play];
    }];
}

@end
