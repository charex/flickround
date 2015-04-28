//
//  YRNPhotoAnnotation.h
//  Flickround
//
//  Created by Marco on 26/04/15.
//  Copyright (c) 2015 Yron Lab. All rights reserved.
//

@interface YRNPhotoAnnotation : MKPointAnnotation

@property (nonatomic, strong) YRNFlickrPhoto *photo;

// Initialize an annotation from a Flickr photo
- (instancetype)initWithPhoto:(YRNFlickrPhoto *)photo;

@end
