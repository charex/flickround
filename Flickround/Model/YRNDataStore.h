//
//  YRNDataStore.h
//  Flickround
//
//  Created by Marco on 26/04/15.
//  Copyright (c) 2015 Yron Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YRNFlickrPhoto;

@interface YRNDataStore : NSObject

// Init data store for a specific API key
- (instancetype)initWithApiKey:(NSString *)apiKey;
// Download photos contained in a specific map rect
- (void)downloadPhotos:(MKMapRect)mapRect withCompletionHandler:(void (^)(NSArray *photos, NSError *error))completion;
// Download a single photo
- (void)downloadPhoto:(YRNFlickrPhoto *)photo withCompletionHandler:(void (^)(UIImage *photo, NSError *error))completion;

@end
