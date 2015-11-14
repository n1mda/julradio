//
//  ViewController.m
//  julradio
//
//  Created by Axel Möller on 07/11/15.
//  Copyright © 2015 Appreviation AB. All rights reserved.
//

#import "ViewController.h"
#import "FSAudioController.h"
#import <YLGIFImage/YLGIFImage.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
{
    FSAudioController *audioController;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _backgroundImage.image = [YLGIFImage imageNamed:@"snow.gif"];

    audioController = [[FSAudioController alloc] init];
    audioController.url = [NSURL URLWithString:@"http://www.julradio.se/ios.pls"];
    
    __weak typeof(self) weakSelf = self;
    
    [audioController setOnStateChange:^(FSAudioStreamState state) {
        switch (state) {
            case kFsAudioStreamRetrievingURL:
            case kFsAudioStreamSeeking:
            case kFsAudioStreamBuffering:
                [weakSelf.playButton setImage:[UIImage imageNamed:@"Loading"] forState:UIControlStateNormal];
                break;
            case kFsAudioStreamPlaying:
                [weakSelf.playButton setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
                break;
            case kFsAudioStreamPaused:
            case kFsAudioStreamStopped:
            case kFSAudioStreamEndOfFile:
            case kFsAudioStreamPlaybackCompleted:
                [weakSelf.playButton setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
                break;
            default:
                break;
        }
    }];
    
    [audioController setOnFailure:^(FSAudioStreamError error, NSString *message) {
        [weakSelf.trackTitleLabel setText:message];
    }];
    
    [audioController setOnMetaDataAvailable:^(NSDictionary *metaData) {
        
        NSString *title = [metaData valueForKey:@"StreamTitle"];
        if(!title) title = @"Julradio";
        
        [weakSelf.trackTitleLabel setText:title];
        
        Class playingInfoCenter = NSClassFromString(@"MPNowPlayingInfoCenter");
        
        if (playingInfoCenter) {
            NSMutableDictionary *songInfo = [[NSMutableDictionary alloc] init];
            [songInfo setObject:title forKey:MPMediaItemPropertyTitle];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songInfo];
        }
        
    }];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:_volumeSlider.bounds];
        [_volumeSlider addSubview:volumeView];
        [volumeView sizeToFit];
    });
}

- (void)viewDidUnload {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    if(event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPause:
                [audioController stop];
                break;
            case UIEventSubtypeRemoteControlPlay:
                [audioController play];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self togglePlayback:nil];
                break;
                
            default:
                break;
        }
    }
}

- (IBAction)togglePlayback:(id)sender {
    if(![audioController isPlaying]) {
        [audioController play];
    } else {
        [audioController stop];
    }
}

@end
