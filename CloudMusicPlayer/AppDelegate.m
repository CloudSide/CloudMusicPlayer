//
//  AppDelegate.m
//  CloudMusicPlayer
//
//  Created by Bruce on 13-9-16.
//  Copyright (c) 2013年 Bruce. All rights reserved.
//

#import "AppDelegate.h"
#import "CloudMusicItem.h"
#import "CloudMusicPlayerViewController.h"

@implementation AppDelegate

- (void)dealloc {
    
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    NSString *urlString0 = @"http://download-vdisk.sina.com.cn/245157/6d38ee69b79c155d2b448bf750d404615786fe33?ssig=JTdEuvjutu&Expires=9999999999&KID=sae,l30zoo1wmz&fn=Intro.mp3";
    NSString *urlString1 = @"http://download-vdisk.sina.com.cn/245157/ad6dab14d778777b068d8506fe392cea72a535ec?ssig=TXHVGxE4vX&Expires=9999999999&KID=sae,l30zoo1wmz&fn=%E9%83%AD%E5%BE%B7%E7%BA%B2+%E4%BA%8E%E8%B0%A6.mp3";
    
    CloudMusicItem *song0 = [[[CloudMusicItem alloc] initWithName:@"Intro.mp3" url:[NSURL URLWithString:urlString0] cacheKey:[NSString stringWithFormat:@"%lu", (unsigned long)[urlString0 hash]]] autorelease];
    CloudMusicItem *song1 = [[[CloudMusicItem alloc] initWithName:@"郭德纲.mp3" url:[NSURL URLWithString:urlString1] cacheKey:[NSString stringWithFormat:@"%lu", (unsigned long)[urlString1 hash]]] autorelease];
    
    CloudMusicPlayerViewController *moviePlayerViewController = [[CloudMusicPlayerViewController alloc] initWithNibName:@"CloudMusicPlayerViewController" bundle:nil];
    [moviePlayerViewController playItems:@[song0, song1] atIndex:0];
    
    self.window.rootViewController = [moviePlayerViewController autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
