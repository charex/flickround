//
//  YRNDataStore.m
//  Flickround
//
//  Created by Marco on 26/04/15.
//  Copyright (c) 2015 Yron Lab. All rights reserved.
//

#import "YRNDataStore.h"

NSString *const kFlickrEndpoint = @"https://api.flickr.com/services/rest/";
NSString *const kFlickrPhotoSearch = @"flickr.photos.search";
NSUInteger const kNumberOfPhotosPerPage = 25;

@interface YRNDataStore ()

@property (nonatomic, strong) NSString *flickrApiKey;

@end

@implementation YRNDataStore

- (instancetype)initWithApiKey:(NSString *)apiKey
{
    self = [super init];
    
    if (self)
    {
        self.flickrApiKey = apiKey;
    }
    
    return self;
}

- (void)downloadPhotos:(MKMapRect)mapRect withCompletionHandler:(void (^)(NSArray *photos, NSError *error))completion
{
    NSString *flickrSearchUrlString = [NSString stringWithFormat:@"%@&has_geo=1&bbox=%@&extras=geo&per_page=%lu", [self baseURLStringForMethod:kFlickrPhotoSearch], [self boundingBoxForMapRect:mapRect], (unsigned long)kNumberOfPhotosPerPage];
    NSURL *flickrSearchUrl = [NSURL URLWithString:flickrSearchUrlString];
    
    [[[NSURLSession sharedSession] dataTaskWithURL:flickrSearchUrl completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
        {
            NSLog(@"Error downlaoding photos");
            completion(nil, error);
        }
        else
        {
            NSError *serializationError;
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&serializationError];
            if (serializationError)
            {
                completion(nil, serializationError);
            }
            else if ([result isKindOfClass:[NSDictionary class]])
            {
                NSArray *photosArray = result[@"photos"][@"photo"];
                completion(photosArray, nil);
            }
        }
    }] resume];
}

- (void)downloadPhoto:(YRNFlickrPhoto *)photo withCompletionHandler:(void (^)(UIImage *photo, NSError *error))completion
{
    [[[NSURLSession sharedSession] dataTaskWithURL:photo.photoURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error)
        {
            NSLog(@"Error downloading the photo: %@", photo.photoURL);
            completion(nil, error);
        }
        else
        {
            UIImage *photoImage = [UIImage imageWithData:data];
            if (photoImage)
            {
                completion(photoImage, nil);
            }
            else
            {
                NSLog(@"Cannot convert data to image");
                completion(nil, [NSError errorWithDomain:@"YRNErrorDomain" code:-42 userInfo:nil]);
            }
        }
    }] resume];
}


- (NSString *)baseURLStringForMethod:(NSString *)method
{
    return [NSString stringWithFormat:@"%@?method=%@&api_key=%@&format=json&nojsoncallback=1", kFlickrEndpoint, method, self.flickrApiKey];
}

- (NSString *)boundingBoxForMapRect:(MKMapRect)mapRect
{
    MKMapPoint northEastPoint = MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMinY(mapRect));
    CLLocationCoordinate2D northEastCoordinate = MKCoordinateForMapPoint(northEastPoint);
    
    MKMapPoint southWestPoint = MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMaxY(mapRect));
    CLLocationCoordinate2D southWestCoordinate = MKCoordinateForMapPoint(southWestPoint);
    
    NSString *boundingBoxString = [NSString stringWithFormat:@"%@, %@, %@, %@", @(southWestCoordinate.longitude), @(southWestCoordinate.latitude), @(northEastCoordinate.longitude), @(northEastCoordinate.latitude)];
    
    // encode commas 
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                              (__bridge CFTypeRef)boundingBoxString,
                                                              NULL,
                                                              CFSTR(","),
                                                              kCFStringEncodingUTF8));
    
    return result;
}

@end
