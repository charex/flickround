//
//  YRNFlickrPhoto.m
//  Flickround
//
//  Created by Marco on 26/04/15.
//  Copyright (c) 2015 Yron Lab. All rights reserved.
//

#import "YRNFlickrPhoto.h"

@interface YRNFlickrPhoto ()

@property (nonatomic, strong) NSString *accuracy;
@property (nonatomic, strong) NSNumber *farm;
@property (nonatomic, strong) NSString *photoId;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *placeId;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, strong) NSString *server;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *photoURL;
@property (nonatomic, assign) CLLocationCoordinate2D coordinates;

@end

@implementation YRNFlickrPhoto

- (instancetype)initFromDictionary:(NSDictionary *)photoInfo
{
    self = [super init];
    
    if (self)
    {
        self.accuracy = photoInfo[@"accuracy"];
        self.farm = photoInfo[@"farm"];
        self.photoId = photoInfo[@"id"];
        self.latitude = photoInfo[@"latitude"];
        self.longitude = photoInfo[@"longitude"];
        self.placeId = photoInfo[@"placeId"];
        self.secret = photoInfo[@"secret"];
        self.server = photoInfo[@"server"];
        self.title = photoInfo[@"title"];
    }
    
    return self;
}

- (NSURL *)photoURL
{
    if (!_photoURL)
    {
        //    https://farm{farm-id}.staticflickr.com/{server-id}/{id}_{secret}_[mstzb].jpg
        NSString *urlString = [NSString stringWithFormat:@"https://farm%@.staticflickr.com/%@/%@_%@_s.jpg", self.farm, self.server, self.photoId, self.secret];
        _photoURL = [NSURL URLWithString:urlString];
    }
    
    return _photoURL;
}

- (CLLocationCoordinate2D)coordinates
{
    _coordinates = CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
    
    return _coordinates;
}

@end
