//
//  CloudMusicItem.m
//  CloudMusicPlayer
//
//  Created by Bruce on 13-9-5.
//  Copyright (c) 2013年 Bruce. All rights reserved.
//

#import "CloudMusicItem.h"

@implementation CloudMusicItem

@synthesize name = _name;
@synthesize url = _url;
@synthesize cacheKey = _cacheKey;

- (id)initWithName:(NSString *)name url:(NSURL *)url cacheKey:(NSString *)cacheKey {

    if (self = [super init]) {
        
        _name = [name copy];
        _url = [url copy];
        _cacheKey = [cacheKey copy];
    }
    
    return self;
}

- (void)dealloc {

    [_name release], _name = nil;
    [_url release], _url = nil;
    [_cacheKey release], _cacheKey = nil;
    
    [super dealloc];
}

@end
