//
//  YRNPhotoAnnotation.m
//  Flickround
//
//  Created by Marco on 26/04/15.
//  Copyright (c) 2015 Yron Lab. All rights reserved.
//

#import "YRNPhotoAnnotation.h"

@implementation YRNPhotoAnnotation

- (instancetype)initWithPhoto:(YRNFlickrPhoto *)photo
{
    self = [super init];
    
    if(self)
    {
        self.photo = photo;
        self.title = photo.title ? photo.title : @"Photo";
        self.coordinate = photo.coordinates;
    }
    
    return self;
}

@end
