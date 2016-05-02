//
//  PlayerViewController.m
//  WWDC
//
//  Created by James Rossfeld on 3/3/16.
//  Copyright © 2016 Bronron Apps. All rights reserved.
//

#import "PlayerViewController.h"

@import AVKit;

@interface PlayerViewController ()

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) NSString *videoURL;
@property (nonatomic, assign) BOOL isVideoPlaying;

@end

@implementation PlayerViewController

- (instancetype) initWithVideoURL:(NSString *)videoURL {
    if (self = [super init]) {
        self.videoURL = videoURL;
        [self prepareVideo];
    }
    
    return self;
}

- (void)dealloc {
    if (self.isVideoPlaying) {
        self.isVideoPlaying = NO;
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)prepareVideo {
    NSURL *url = [NSURL URLWithString:self.videoURL];
    if (url == nil) return;
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.isVideoPlaying = YES;
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
                         context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemFinishedPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
}

//Plays the video on selecting the Play Video button
- (void)play
{
    [self.player play];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {
        
        // Handle video load failures.
        if (self.playerItem.status == AVPlayerStatusFailed) {
            UIAlertController * alert=  [UIAlertController
                                         alertControllerWithTitle:@"Video Error"
                                         message:@"There was an error loading the content."
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            [self presentViewController:alert animated:YES completion:NULL];
        }
        //NSLog(@"Status: %ld\n\n", (long)self.playerItem.status);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)itemFinishedPlaying:(NSNotification*)notification {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
