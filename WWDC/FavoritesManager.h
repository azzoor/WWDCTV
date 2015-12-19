//
//  FavoritesManager.h
//  WWDC
//
//  Created by Julio Carrettoni on 12/19/15.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMarkAsFavoriteTitle @"Fav"
#define kUnMarkAsFavoriteTitle @"Fav"

@interface FavoritesManager : NSObject

+ (BOOL) isVideoAFavorite:(NSString*) videoURL;
+ (void) markVideoAsFavorite:(NSString*) videoURL;
+ (void) unMarkVideoAsFavorite:(NSString*) videoURL;

@end
