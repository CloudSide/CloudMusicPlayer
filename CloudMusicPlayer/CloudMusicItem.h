//
//  CloudMusicItem.h
//  CloudMusicPlayer
//
//  Created by Bruce on 13-9-5.
//  Copyright (c) 2013年 Bruce. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CloudMusicItem : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *cacheKey;
@property (nonatomic, readonly) NSURL *url;

- (id)initWithName:(NSString *)name url:(NSURL *)url cacheKey:(NSString *)cacheKey;

@end
