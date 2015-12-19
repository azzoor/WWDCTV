//
//  FavoritesManager.m
//  WWDC
//
//  Created by Julio Carrettoni on 12/19/15.
//  Copyright © 2015 Bronron Apps. All rights reserved.
//

#import "FavoritesManager.h"

#define kArrayOfFavorites @"array_of_favorites"

@implementation FavoritesManager

//Private methods
+ (NSArray*) arrayOfFavorites {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kArrayOfFavorites]?:[NSArray array];
}

+ (NSMutableArray*) mutableArrayOfFavorites {
    return [NSMutableArray arrayWithArray:[self arrayOfFavorites]];
}

+ (void) saveArrayOfFavorites:(NSArray*) arrayOfFavorites {
    [[NSUserDefaults standardUserDefaults] setObject:arrayOfFavorites forKey:kArrayOfFavorites];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//Public methods
+ (BOOL) isVideoAFavorite:(NSString*) videoURL {
    return [[self arrayOfFavorites] containsObject:videoURL];
}

+ (void) markVideoAsFavorite:(NSString*) videoURL {
    NSMutableArray* mutableArrayOfFavorites = [self mutableArrayOfFavorites];
    if (![mutableArrayOfFavorites containsObject:videoURL]) {
        [mutableArrayOfFavorites addObject:videoURL];
        [self saveArrayOfFavorites:mutableArrayOfFavorites];
    }
}

+ (void) unMarkVideoAsFavorite:(NSString*) videoURL {
    NSMutableArray* mutableArrayOfFavorites = [self mutableArrayOfFavorites];
    if ([mutableArrayOfFavorites containsObject:videoURL]) {
        [mutableArrayOfFavorites removeObject:videoURL];
        [self saveArrayOfFavorites:mutableArrayOfFavorites];
    }
}


@end
