//
//  ViewController.m
//  Flickround
//
//  Created by Marco on 26/04/15.
//  Copyright (c) 2015 Yron Lab. All rights reserved.
//

#import "YRNMapViewController.h"

#import "YRNPhotoAnnotation.h"

@interface YRNMapViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *photosMapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign, getter=isFirstLoad) BOOL firstLoad;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) YRNDataStore *dataStore;

@end

@implementation YRNMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.firstLoad = NO;
    self.photos = [NSMutableArray array];
    self.dataStore = [[YRNDataStore alloc] initWithApiKey:@"ad4f5854688239ed4a8b5e310ff6c70c"];

    [self initLocationManager];
}

- (void)initLocationManager
{
    if (!self.locationManager)
    {
        if (![CLLocationManager locationServicesEnabled])
        {
            //You need to enable Location Services
            NSLog(@"Location services are disabled");
        }
        else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        {
            // User has explicitly denied authorization for this application, or location services are disabled in Settings.
            NSLog(@"The app is not authorized to use Location Services");
        }
        else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
        {
            //This application is not authorized to use location services due to active restrictions on location services
            NSLog(@"The app is not authorized to use Location Services");
        }
        else
        {
            self.firstLoad = YES;
            self.locationManager = [[CLLocationManager alloc] init];
            // iOS 8 new authorization procedure
            if ([[self locationManager] respondsToSelector:@selector(requestWhenInUseAuthorization)])
            {
                [[self locationManager] requestWhenInUseAuthorization];
            }
            self.photosMapView.showsUserLocation = YES;
        }
    }
}

#pragma mark - Map management

- (void)addPhotosToMap
{
    // Remove previous annotations
    for (id<MKAnnotation> annotation in self.photosMapView.annotations)
    {
        [self.photosMapView removeAnnotation:annotation];
    }
    
    // Create and add an annotation for each photo
    for (YRNFlickrPhoto *photo in self.photos)
    {
        YRNPhotoAnnotation *annotation = [[YRNPhotoAnnotation alloc] initWithPhoto:photo];
        [self.photosMapView addAnnotation:annotation];
    }
}

#pragma mark - MKMapViewDelegate methods

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    CLLocationCoordinate2D userCoordinates = userLocation.location.coordinate;
    // Center the map on the user on the first load
    if (self.firstLoad)
    {
        self.firstLoad = NO;
        MKCoordinateRegion mapRegion = MKCoordinateRegionMakeWithDistance(userCoordinates, 500, 500);
        [self.photosMapView setRegion:mapRegion animated:YES];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{    
    __weak typeof(self) weakSelf = self;
    // Map has been scrolled, download new photos
    [self.dataStore downloadPhotos:mapView.visibleMapRect withCompletionHandler:^(NSArray *photos, NSError *error) {
        if (!error)
        {
            [weakSelf.photos removeAllObjects];
            for (NSDictionary *photoDictionary in photos)
            {
                [weakSelf.photos addObject:[[YRNFlickrPhoto alloc] initFromDictionary:photoDictionary]];
            }
            NSLog(@"Found %lu photos", (unsigned long)weakSelf.photos.count);
            // Update the map on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf addPhotosToMap];
            });
        }
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[YRNPhotoAnnotation class]])
    {
        static NSString *myAnnotationId = @"YRNPhotoAnnotation";
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:myAnnotationId];
        if(annotationView)
        {
            annotationView.annotation = annotation;
        }
        else
        {
            // Create and configure a new annotation view
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:myAnnotationId];
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"placeholder"];
        }
        
        [self.dataStore downloadPhoto:((YRNPhotoAnnotation *)annotation).photo withCompletionHandler:^(UIImage *photo, NSError *error) {
            if (!error)
            {
                // Update the map on the main thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    annotationView.image = photo;
                });
            }
        }];
        
        return annotationView;
    }
    
    return nil;
}

@end
