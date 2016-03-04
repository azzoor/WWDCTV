//
//  PlayerViewController.h
//  WWDC
//
//  Created by James Rossfeld on 3/3/16.
//  Copyright © 2016 Bronron Apps. All rights reserved.
//

#import <AVKit/AVKit.h>

@interface PlayerViewController : AVPlayerViewController

- (instancetype) initWithVideoURL:(NSString *)videoURL;
- (void)play;

@end
