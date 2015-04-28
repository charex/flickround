//
//  YRNFlickrPhoto.h
//  Flickround
//
//  Created by Marco on 26/04/15.
//  Copyright (c) 2015 Yron Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YRNFlickrPhoto : NSObject

@property (nonatomic, strong, readonly) NSString *accuracy;
@property (nonatomic, strong, readonly) NSNumber *farm;
@property (nonatomic, strong, readonly) NSString *photoId;
@property (nonatomic, strong, readonly) NSString *latitude;
@property (nonatomic, strong, readonly) NSString *longitude;
@property (nonatomic, strong, readonly) NSString *placeId;
@property (nonatomic, strong, readonly) NSString *secret;
@property (nonatomic, strong, readonly) NSString *server;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSURL *photoURL;
@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinates;

// Initialize a photo from a dictionary
- (instancetype)initFromDictionary:(NSDictionary *)photoInfo;

@end
