CloudMusicPlayer
================

A simple and easy-to-use music player support playing-while-downloading feature.


[![](http://service.t.sina.com.cn/widget/qmd/1656360925/02781ba4/4.png)](http://weibo.com/smcz)


-----
Usage
=====

```objective-c

NSString *urlString0 = @"http://download-vdisk.sina.com.cn/245157/6d38ee69b79c155d2b448bf750d404615786fe33?ssig=JTdEuvjutu&Expires=9999999999&KID=sae,l30zoo1wmz&fn=Intro.mp3";
NSString *urlString1 = @"http://download-vdisk.sina.com.cn/245157/ad6dab14d778777b068d8506fe392cea72a535ec?ssig=TXHVGxE4vX&Expires=9999999999&KID=sae,l30zoo1wmz&fn=%E9%83%AD%E5%BE%B7%E7%BA%B2+%E4%BA%8E%E8%B0%A6.mp3";
    
CloudMusicItem *song0 = [[[CloudMusicItem alloc] initWithName:@"Intro.mp3" url:[NSURL URLWithString:urlString0] cacheKey:[NSString stringWithFormat:@"%lu", (unsigned long)[urlString0 hash]]] autorelease];
CloudMusicItem *song1 = [[[CloudMusicItem alloc] initWithName:@"郭德纲.mp3" url:[NSURL URLWithString:urlString1] cacheKey:[NSString stringWithFormat:@"%lu", (unsigned long)[urlString1 hash]]] autorelease];
    
CloudMusicPlayerViewController *playerViewController = [[CloudMusicPlayerViewController alloc] initWithNibName:@"CloudMusicPlayerViewController" bundle:nil];
[playerViewController playItems:@[song0, song1] atIndex:0];

[aViewController presentModalViewController:playerViewController animated:YES];
/*
or:
[aNavigationController pushViewController:playerViewController animated:YES];
*/

[playerViewController release];
    
```
