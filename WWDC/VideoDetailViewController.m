//
//  VideoDetailViewController.m
//  WWDC
//
//  Created by Aaron Stephenson on 17/11/2015.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import "VideoDetailViewController.h"
#import "Header.h"
#import "FavoritesManager.h"

@import AVKit;

@interface VideoDetailViewController ()
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *platformLabel;
@property (nonatomic, weak) IBOutlet UILabel *sessionIDLabel;
@property (nonatomic, weak) IBOutlet UILabel *speakerLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) NSDictionary *videoDictionary;

@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerViewController *playerViewController;
@property (nonatomic, assign) BOOL isVideoPlaying;


@end

@implementation VideoDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isVideoPlaying = NO;
    
    // When setupVideoDictionary is called from the TableView Controller, this VC has not yet loaded from NIB.
    // This causes a bug where the labels show their default NIB contents.
    // Calling this method in viewDidLoad should cause the Labels to populate after loading from NIB.
    [self setupVideoDictionaryObject:self.videoDictionary];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.isVideoPlaying) {
        self.isVideoPlaying = NO;
        [self.playerItem removeObserver:self forKeyPath:@"status"];
    }
}

//Setup detail labels
- (void)setupVideoDictionaryObject:(NSDictionary *)videoDictionary
{
    if (videoDictionary)
    {
        self.view.alpha = 1.0;//Animating the alpha generates some weird glitches
        [UIView animateWithDuration:0.3 animations: ^{
            self.videoDictionary = videoDictionary;
            self.titleLabel.text = [self.videoDictionary objectForKey:kTitleKey];
            self.platformLabel.text = [self.videoDictionary objectForKey:kPlatformKey];
            self.sessionIDLabel.text = [self.videoDictionary objectForKey:kSessionIDKey];
            
            self.speakerLabel.text = [self.videoDictionary objectForKey:kSpeakerKey];
            self.descriptionLabel.text = [self.videoDictionary objectForKey:kDescriptionKey];
            [self.view layoutIfNeeded];
        }];
        [self setupFavButton];
    }
    else
    {
        self.view.alpha = 0.0;//Animating the alpha generates some weird glitches
    }
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
    if (context.nextFocusedView == self.favButton)
    {
        // Favourite button is about to be selected
        
        //Change background colour of button and tint colour of button image.
        self.favButton.backgroundColor = [UIColor colorWithRed:0.576 green:0.580 blue:0.600 alpha:1];
        self.favButton.tintColor = [UIColor whiteColor];

        //Add Shadow
        context.nextFocusedView.layer.shadowOffset = CGSizeMake(0, 10);
        context.nextFocusedView.layer.shadowOpacity = 0.6;
        context.nextFocusedView.layer.shadowRadius = 15;
        context.nextFocusedView.layer.shadowColor = [UIColor blackColor].CGColor;
        context.previouslyFocusedView.layer.shadowOpacity = 0;
        
        //Scale button to indicate it has been focused
        [UIView beginAnimations:@"button" context:nil];
        [UIView setAnimationDuration:0.3];
        self.favButton.transform = CGAffineTransformMakeScale(1.15, 1.15);
        [UIView commitAnimations];
    }
    else if (context.previouslyFocusedView == self.favButton)
    {
        // Favourite button is no longer selected
        
        //Background colour is removed and tint of button image returned to normal
        self.favButton.backgroundColor = [UIColor clearColor];
        self.favButton.tintColor = [UIColor colorWithRed:0.576 green:0.580 blue:0.600 alpha:1];
        
        //Remove Shadow
        context.previouslyFocusedView.layer.shadowOpacity = 0;

        //Remove Scale
        [UIView beginAnimations:@"button" context:nil];
        [UIView setAnimationDuration:0.3];
        self.favButton.transform = CGAffineTransformMakeScale(1, 1);
        [UIView commitAnimations];
    }
}

- (void)setupFavButton
{
    NSString *videoURL = [self.videoDictionary objectForKey:kVideoURLKey];
    if ([FavoritesManager isVideoAFavorite:videoURL])
    {
        [self.favButton setImage:[[UIImage imageNamed:@"heart_selected"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.favButton.accessibilityLabel = NSLocalizedString(@"Remove from Favourites", nil);
    }
    else
    {
        [self.favButton setImage:[[UIImage imageNamed:@"heart_unselected"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.favButton.accessibilityLabel = NSLocalizedString(@"Add to Favourites", nil);
    }
    self.favButton.tintColor = [UIColor colorWithRed:0.576 green:0.580 blue:0.600 alpha:1];
    self.favButton.layer.cornerRadius = 8;
}

//Plays the video on selecting the Play Video button
- (IBAction)playVideo:(id)sender
{
    NSURL *url = [NSURL URLWithString:self.videoDictionary[kVideoURLKey]];
    AVAsset *asset = [AVAsset assetWithURL:url];
    
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [self.playerItem addObserver:self
                      forKeyPath:@"status"
                         options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial)
                         context:NULL];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    self.playerViewController = [AVPlayerViewController new];
    self.playerViewController.player = self.player;
    
    [self presentViewController:self.playerViewController animated:true completion:^{
        self.isVideoPlaying = YES;
        [self.player play];
    }];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.playerItem && [keyPath isEqualToString:@"status"]) {

        // Handle video load failures.
        if (self.playerItem.status == AVPlayerStatusFailed) {
            UIAlertController * alert=  [UIAlertController
                                          alertControllerWithTitle:@"Video Error"
                                          message:@"There was an error loading the content."
                                          preferredStyle:UIAlertControllerStyleAlert];
            
            [self.playerViewController presentViewController:alert animated:YES completion:NULL];
        }
        //NSLog(@"Status: %ld\n\n", (long)self.playerItem.status);
    }
}


//Toggle favorite session state
- (IBAction)onFavButtonTUI:(UIButton *)sender
{
	[self toggleFavorite];
   
    if ([self.delegate respondsToSelector:@selector(videoInformationHasChanged)])
    {
        [self.delegate videoInformationHasChanged];
    }
}


- (void)toggleFavorite
{
    NSString *videoURL = [self.videoDictionary objectForKey:kVideoURLKey];
    if ([FavoritesManager isVideoAFavorite:videoURL])
    {
        [FavoritesManager unMarkVideoAsFavorite:videoURL];
        [self.favButton setImage:[[UIImage imageNamed:@"heart_unselected"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.favButton.accessibilityLabel = NSLocalizedString(@"Add to Favourites", nil);
    }
    else
    {
        [FavoritesManager markVideoAsFavorite:videoURL];
        [self.favButton setImage:[[UIImage imageNamed:@"heart_selected"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        self.favButton.accessibilityLabel = NSLocalizedString(@"Remove from Favourites", nil);
    }
    self.favButton.tintColor = [UIColor whiteColor];
}

@end
