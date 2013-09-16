//
//  CloudMusicPlayerViewController.m
//  NCMusicEngine Example
//
//  Created by Bruce on 13-9-4.
//  Copyright (c) 2013年 NC. All rights reserved.
//

#import "CloudMusicPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "NCMusicEngine.h"

#import "NSString+TimeToString.h"
#import "CloudMusicItem.h"

@interface CloudMusicPlayerViewController () <NCMusicEngineDelegate> {

    NCMusicEngine *_musicEngine;
    CGFloat _currentDownloadProgress;
    CGFloat _currentPlayProgress;
    NSArray *_musicItems;
    NSTimeInterval _totalDuration;
    NSUInteger _currentIndex;

}

@property (nonatomic, retain) IBOutlet UISlider *progressSlider;
@property (nonatomic, retain) IBOutlet UISlider *volumeView;
@property (nonatomic, retain) IBOutlet UIButton *playPauseButton;
@property (nonatomic, retain) IBOutlet UILabel  *playedTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel  *leftTimeLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, retain) IBOutlet UILabel  *songName;

@property (retain, nonatomic) UIImageView *bufferedView;

@property BOOL panningProgress;
@property BOOL panningVolume;

@end

@implementation CloudMusicPlayerViewController

@synthesize progressSlider = _progressSlider;
@synthesize volumeView = _volumeView;
@synthesize panningProgress = _panningProgress;
@synthesize panningVolume = _panningVolume;
@synthesize playPauseButton = _playPauseButton;
@synthesize playedTimeLabel = _playedTimeLabel;
@synthesize leftTimeLabel = _leftTimeLabel;
@synthesize bufferedView = _bufferedView;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize songName = _songName;

- (void)play:(NSURL *)url cacheKey:(NSString *)cacheKey {

    if (!_musicEngine) {
        
        NSLog(@"-----大哥：play:(NSURL *)url");
        
        _musicEngine = [[NCMusicEngine alloc] initWithSetBackgroundPlaying:YES];
        _musicEngine.delegate = self;
        
        /*
        _currentDownloadProgress = 0.0f;
        _currentPlayProgress = 0.0f;
        
        _musicEngine.delegate = nil;
        
        [_musicEngine.player stop];
        _musicEngine.player.delegate = nil;
        _musicEngine.player = nil;
        [_musicEngine stop];
        [_musicEngine release];
        _musicEngine = nil;
         */
    }
    
    _currentDownloadProgress = 0.0f;
    _currentPlayProgress = 0.0f;
    
    
    [_musicEngine stop];
    [_musicEngine playUrl:url withCacheKey:cacheKey];
    
    
    [_loadingIndicator setHidden:NO];
    [_loadingIndicator startAnimating];
    [_playedTimeLabel setHidden:YES];
}

- (void)playItems:(NSArray *)items atIndex:(NSUInteger)index {
    
    if (_musicItems) {
        
        [_musicItems release];
    }
    
    _musicItems = [items retain];
    
    [self playIndex:index];
}

- (void)playIndex:(NSUInteger)index {
    
    if (index >= [_musicItems count]) {
        
        NSLog(@"SB越界了, 改成最后一首了");
        index = [_musicItems count] - 1;
    }
    
    _currentIndex = index;
    
    //TODO: 设置歌名: [(CloudMusicItem *)items[index] name]
    
    _songName.text = [(CloudMusicItem *)_musicItems[index] name];
    
    [self play:[(CloudMusicItem *)_musicItems[index] url] cacheKey:[(CloudMusicItem *)_musicItems[index] cacheKey]];
}

- (void)prev {
    
    if (_currentIndex > 0) {
        
        _currentIndex--;
        [self playIndex:_currentIndex];
    }
}

- (void)next {
    
    if (_currentIndex >= [_musicItems count] - 1) {
        
        return;
    }
    
    _currentIndex++;
    
    [self playIndex:_currentIndex];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
        // Listen for volume changes
        [[MPMusicPlayerController iPodMusicPlayer] beginGeneratingPlaybackNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handle_VolumeChanged:)
                                                     name:MPMusicPlayerControllerVolumeDidChangeNotification
                                                   object:[MPMusicPlayerController iPodMusicPlayer]];
    }
    
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    
    UIImage *knob = [UIImage imageNamed:@"CloudMusicPlayer.bundle/images/VolumeKnob"];
    [_progressSlider setThumbImage:knob forState:UIControlStateNormal];
    _progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    UIImage *minImg = [[UIImage imageNamed:@"CloudMusicPlayer.bundle/images/speakerSliderMinValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    UIImage *maxImg = [[UIImage imageNamed:@"CloudMusicPlayer.bundle/images/speakerSliderMaxValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 6, 0, 6)];
    [_progressSlider setMinimumTrackImage:minImg forState:UIControlStateNormal];
    [_progressSlider setMaximumTrackImage:maxImg forState:UIControlStateNormal];
    
    _progressSlider.maximumValue = 100;
    _progressSlider.minimumValue = 0;
    
    //UIImage *knobImg = [UIImage imageNamed:@"CloudMusicPlayer.bundle/images/mpSpeakerSliderKnob.png"];
    [self.volumeView setThumbImage:knob forState:UIControlStateNormal];
    //[self.volumeView setThumbImage:knob forState:UIControlStateHighlighted];
    [self.volumeView setMinimumTrackImage:minImg forState:UIControlStateNormal];
    [self.volumeView setMaximumTrackImage:maxImg forState:UIControlStateNormal];
    self.volumeView.value = [MPMusicPlayerController iPodMusicPlayer].volume;
    
    
    //loading image view
    UIImage *bufferedViewImage = [[UIImage imageNamed:@"CloudMusicPlayer.bundle/images/speakerSliderLightValue"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 6.0, 0.0, 6.0)];
    self.bufferedView = [[[UIImageView alloc] initWithImage:bufferedViewImage] autorelease];
    _bufferedView.image = bufferedViewImage;
    _bufferedView.contentMode = UIViewContentModeScaleToFill;
    
    CGRect sliderTrackFrame = [_progressSlider trackRectForBounds:_progressSlider.bounds];
    _bufferedView.frame = CGRectMake(sliderTrackFrame.origin.x, sliderTrackFrame.origin.y, 0, sliderTrackFrame.size.height);
    _bufferedView.contentMode = UIViewContentModeScaleToFill;
    
    [_progressSlider insertSubview:_bufferedView atIndex:1];
    _currentDownloadProgress = 0;
    
    // Make sure the system follows our playback status
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *sessionError = nil;
    
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    
    if (!success){
    
        NSLog(@"setCategory error %@", sessionError);
    }
    
    success = [audioSession setActive:YES error:&sessionError];
    
    if (!success){
    
        NSLog(@"setActive error %@", sessionError);
    }
    
    //[audioSession setDelegate:self];
    
    /*
    CloudMusicItem *item0 = [[[CloudMusicItem alloc] initWithName:@"ssdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfsdfssdfsdfsdfb" url:[NSURL URLWithString:@"http://download-vdisk.sina.com.cn/19902274/d61c10cba00cad41117aa172f8404faebd9650a9?ssig=44Hep1GwhJ&Expires=9999999999&KID=sae,l30zoo1wmz&fn=dsadsadsadsadsadas1"]] autorelease];
    CloudMusicItem *item1 = [[[CloudMusicItem alloc] initWithName:@"12908371209380129830192380127309817230918230912730712894y72398479128739817239187" url:[NSURL URLWithString:@"http://stackoverflow.com/questions/593234/how-to-use-activity-indicator-view-on-iphone"]] autorelease];
    
    [self playItems:@[item0, item1] atIndex:0];
     */
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [[MPMusicPlayerController iPodMusicPlayer] endGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMusicPlayerControllerVolumeDidChangeNotification
                                                  object:[MPMusicPlayerController iPodMusicPlayer]];
    
    
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];

    [_progressSlider release];
    [_volumeView release];
    [_playPauseButton release];
    
    //care
    
    /*
    _musicEngine.player.delegate = nil;
    [_musicEngine.player stop];
    _musicEngine.player = nil;
    */
     
    _musicEngine.delegate = nil;
    [_musicEngine stop];
    [_musicEngine release];
    
    [_bufferedView release];
    
    [_musicItems release];
    _musicItems = nil;
    
    [_loadingIndicator release];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    //return NO;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		return YES;
		
	} else {
		
		return NO;
	}
}

- (BOOL)shouldAutorotate {
    
    //return NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		
		return YES;
		
	} else {
		
		return NO;
	}
}

- (void)resetAll {
    
    _currentDownloadProgress = 0.0f;
    _currentPlayProgress = 0.0f;
    
    [_loadingIndicator setHidden:YES];
    [_loadingIndicator stopAnimating];
    
    _leftTimeLabel.text = @"00:00";
    _playedTimeLabel.text = @"00:00";
    [_playedTimeLabel setHidden:NO];
    
    CGRect rect = _bufferedView.frame;
    _bufferedView.frame = CGRectMake(rect.origin.x, rect.origin.y, 0, rect.size.height);
    
    _progressSlider.value = 0;
    _totalDuration = 0;
}

- (void)handle_VolumeChanged:(NSNotification *)notification {
    
    if (!self.panningVolume) {
        
        self.volumeView.value = [MPMusicPlayerController iPodMusicPlayer].volume;
    }
}



#pragma mark - IBActions

- (IBAction)playButtonPressed {
    
    if (_musicEngine.playState == NCMusicEnginePlayStatePlaying) {
        
        [_musicEngine pause];
    
    } else {
        
        [_musicEngine resume];
    }
}

- (IBAction)prevButtonPressed {
    
    //TODO: 上一首
    [self prev];
}

- (IBAction)nextButtonPressed {
    
    //TODO: 下一首
    [self next];
}

- (IBAction)volumeChanged:(UISlider *)sender {
    
    self.panningVolume = YES;
    [MPMusicPlayerController iPodMusicPlayer].volume = sender.value;
}

- (IBAction)volumeEnd {
    
    self.panningVolume = NO;
}


- (IBAction)progressChanged:(UISlider *)sender {
    
    // While dragging the progress slider around, we change the time label,
    // but we're not actually changing the playback time yet.
    self.panningProgress = YES;
    
    CGFloat maxAllowValue = _currentDownloadProgress * 100 - 5;
    
    if (sender.value >= maxAllowValue && _musicEngine.downloadState != NCMusicEngineDownloadStateDownloaded) {
        
        [sender setValue:maxAllowValue];
    
    }else if (sender.value >= 99 && _musicEngine.downloadState == NCMusicEngineDownloadStateDownloaded) {
        
        [sender setValue:99];
    }
    
    _playedTimeLabel.text = [NSString stringFromTime:sender.value/100 * _totalDuration];
    
    NSTimeInterval leftTimePercent = 1 - sender.value/100;
    if (leftTimePercent < 0) {
        leftTimePercent = 0;
    }
    
    _leftTimeLabel.text = [NSString stringWithFormat:@"-%@", [NSString stringFromTime:_totalDuration * leftTimePercent]];
    
    //TODO: 改左右两侧label的值
}

- (IBAction)progressEnd {
    
    // Only when dragging is done, we change the playback time.
    
    //TODO: 设置: [_musicEngine.player setCurrentTime:self.progressSlider.value / 当前下载进度 * _musicEngine.player.duration];
    
    [_musicEngine.player setCurrentTime:self.progressSlider.value / 100 * _totalDuration];
    
//    if ([_musicEngine playState] == NCMusicEnginePlayStatePaused && self.progressSlider.value == 100) {
//        
//        [_musicEngine stop];
//    }
    
    self.panningProgress = NO;
}

- (IBAction)closeButtonPressed:(id)sender {
    
    /*
    _musicEngine.player.delegate = nil;
    [_musicEngine.player stop];
    _musicEngine.player = nil;
    _musicEngine.delegate = nil;
    [_musicEngine stop];
    
    [_musicEngine release];
    _musicEngine = nil;
     */
    
    [self dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - NCEngineDelegate

- (void)engine:(NCMusicEngine *)engine didChangePlayState:(NCMusicEnginePlayState)playState {
    
    
    //TODO: 状态, 按钮显示等
    
    /*
     NCMusicEnginePlayStateStopped,
     NCMusicEnginePlayStatePlaying,
     NCMusicEnginePlayStatePaused,
     NCMusicEnginePlayStateEnded,
     NCMusicEnginePlayStateError
     */
    
    if (playState == NCMusicEnginePlayStatePlaying) {
        
        [_playPauseButton setImage:[UIImage imageNamed:@"CloudMusicPlayer.bundle/images/Controls_Pause"] forState:UIControlStateNormal];
        NSLog(@"playing");
        
    }else if (playState == NCMusicEnginePlayStateStopped) {
        
        [_playPauseButton setImage:[UIImage imageNamed:@"CloudMusicPlayer.bundle/images/Controls_Play"] forState:UIControlStateNormal];
        NSLog(@"stopped");
        _totalDuration = 0.f;
        
    }else if (playState == NCMusicEnginePlayStatePaused) {
        
        [_playPauseButton setImage:[UIImage imageNamed:@"CloudMusicPlayer.bundle/images/Controls_Play"] forState:UIControlStateNormal];
        NSLog(@"paused");
        
    }else if (playState == NCMusicEnginePlayStateEnded) {
        
        [_playPauseButton setImage:[UIImage imageNamed:@"CloudMusicPlayer.bundle/images/Controls_Play"] forState:UIControlStateNormal];
        NSLog(@"ended");
        
        if (_currentIndex >= [_musicItems count] - 1) {
            
            if (_musicEngine.downloadState == NCMusicEngineDownloadStateDownloaded) {
                
                [self closeButtonPressed:nil];
            }
            
        } else {
            
            [self next];
        }
        
    }else if (playState == NCMusicEnginePlayStateError) {
        
        if (_musicEngine.downloadState != NCMusicEngineDownloadStateError) {
            
            [_playPauseButton setImage:[UIImage imageNamed:@"CloudMusicPlayer.bundle/images/Controls_Play"] forState:UIControlStateNormal];
            NSLog(@"play: error");
            
            //[self resetAll];
            
            if (_musicEngine.downloadState == NCMusicEngineDownloadStateDownloaded) {
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"文件已损坏" message:@"不是有效的音频文件" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
                [alertView release];
                
                [self closeButtonPressed:nil];
            }
            
        }
    }
}


- (void)engine:(NCMusicEngine *)engine didChangeDownloadState:(NCMusicEngineDownloadState)downloadState {
    
    
    //TODO: 状态, 按钮显示、loading等
    
    /*
     
     NCMusicEngineDownloadStateNotDownloaded,
     NCMusicEngineDownloadStateDownloading,
     NCMusicEngineDownloadStateDownloaded,
     NCMusicEngineDownloadStateError
     
     */
    
    if (downloadState == NCMusicEngineDownloadStateNotDownloaded) {
        
    }else if (downloadState == NCMusicEngineDownloadStateDownloading) {
        
    }else if (downloadState == NCMusicEngineDownloadStateDownloaded) {
        
    }else if (downloadState == NCMusicEngineDownloadStateError) {
        
        NSLog(@"download: error");
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"网络中断" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        [alertView release];
        
        //[self resetAll];
    }
    
}

- (void)engine:(NCMusicEngine *)engine downloadProgress:(CGFloat)progress {
    
    _currentDownloadProgress = progress;
    
    //TODO: 更细缓冲的进度条
    
    CGRect rect = self.bufferedView.frame;
    CGRect sliderTrackFrame = [_progressSlider trackRectForBounds:_progressSlider.bounds];
    self.bufferedView.frame = CGRectMake(rect.origin.x, rect.origin.y, sliderTrackFrame.size.width * progress, rect.size.height);
    
    
    _totalDuration = _musicEngine.player.duration / _currentDownloadProgress;
}

- (void)engine:(NCMusicEngine *)engine playProgress:(CGFloat)progress {
    
    if (_musicEngine.downloadState == NCMusicEngineDownloadStateDownloaded) {
        
        _totalDuration = _musicEngine.player.duration / _currentDownloadProgress;
        
        CGRect rect = self.bufferedView.frame;
        CGRect sliderTrackFrame = [_progressSlider trackRectForBounds:_progressSlider.bounds];
        self.bufferedView.frame = CGRectMake(rect.origin.x, rect.origin.y, sliderTrackFrame.size.width, rect.size.height);
        
//        if (progress == 1) {
//            [self closeButtonPressed:nil];
//        }
    }
    
    if (_musicEngine.player.duration > 0) {
        [_loadingIndicator stopAnimating];
        [_playedTimeLabel setHidden:NO];
        [_loadingIndicator setHidden:YES];
    }
    
    _currentPlayProgress = progress;
    
    if (!self.panningProgress) {
        
        
        //TODO: 更新播放的进度条, 最终的进度 = 下载进度 * 播放进度
    
        _progressSlider.value = progress * _currentDownloadProgress * 100;
        
        NSTimeInterval leftTimePercent = 1 - progress * _currentDownloadProgress;
        if (leftTimePercent < 0) {
            leftTimePercent = 0;
        }
        
        _playedTimeLabel.text = [NSString stringFromTime:progress * _currentDownloadProgress * _totalDuration];
        _leftTimeLabel.text = [NSString stringWithFormat:@"-%@", [NSString stringFromTime:_totalDuration * leftTimePercent]];
    }
}


#pragma mark - Catch remote control events, forward to the music player


- (BOOL)canBecomeFirstResponder {

    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    
    if (receivedEvent.type != UIEventTypeRemoteControl) {
        
        return;
    }
    
    switch (receivedEvent.subtype) {
        
        case UIEventSubtypeRemoteControlTogglePlayPause: {
            
            //TODO: 如果当前是播放状态则pause, 否则play
            
            if (_musicEngine.playState == NCMusicEnginePlayStatePlaying) {
                
                [_musicEngine pause];
                
            } else {
            
                [_musicEngine resume];
            }
            
            break;
        }
            
        case UIEventSubtypeRemoteControlNextTrack:
            //TODO: 下一首
            [self next];
            break;
            
        case UIEventSubtypeRemoteControlPreviousTrack:
            //TODO: 上一首
            [self prev];
            break;
            
        case UIEventSubtypeRemoteControlPlay:
            //TODO: play
            [_musicEngine resume];
            break;
            
        case UIEventSubtypeRemoteControlPause:
            //TODO: pause
            [_musicEngine pause];
            break;
            
        case UIEventSubtypeRemoteControlStop:
            //TODO: stop
            [_musicEngine stop];
            break;
            
        case UIEventSubtypeRemoteControlBeginSeekingBackward:
            //TODO: beginSeekingBackward 先不实现
            break;
            
        case UIEventSubtypeRemoteControlBeginSeekingForward:
            //TODO: beginSeekingForward 先不实现
            break;
            
        case UIEventSubtypeRemoteControlEndSeekingBackward:
        case UIEventSubtypeRemoteControlEndSeekingForward:
            //TODO: endSeeking 先不实现
            break;
            
        default:
            break;
    }
}

@end
