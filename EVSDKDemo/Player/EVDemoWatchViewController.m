//
//  EVDemoWatchViewController.m
//  EVSDKDemo
//
//  Created by mashuaiwei on 16/8/12.
//  Copyright © 2016年 cloudfocous. All rights reserved.
//

#import "EVDemoWatchViewController.h"
//#import "EVPlayer.h"
//#import "EVPlayerConfig.h"
//#import "EVStreamer.h"
#import <EVMediaFramework/EVPlayer.h>
#import <EVMediaFramework/EVPlayerConfig.h>
#import <EVMediaFramework/EVStreamer.h>
#import "CCAlertManager.h"

static NSString * const kAgoraId = @"";

@interface EVDemoWatchViewController ()<EVPlayerDelegate, EVStreamerDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (nonatomic, strong) EVPlayer *player; /**< 播放器 */
@property (nonatomic, strong) EVStreamer *streamer; /**< 推流端 */

@end

@implementation EVDemoWatchViewController

#pragma mark - life circle

- (void)viewDidLoad{
    [super viewDidLoad];
    
//    self.vid = @"1471314937295531";
    [self setUpPlayer];
}


#pragma mark - UIAction

- (IBAction)close:(UIButton *)sender {
    [self.player shutDown];
    _player = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)interactiveLiveButtonClicked:(UIButton *)sender {
    if (self.streamer && !self.streamer.agoraAppid) {
        [[CCAlertManager shareInstance] performComfirmTitle:nil message:@"请先设置agoraAppid" comfirmTitle:@"确定" WithComfirm:nil];
        return;
    }
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.player pause];
        if (!self.streamer) {
            self.streamer = [[EVStreamer alloc] init];
            self.streamer.delegate = self;
            self.streamer.frontCamera = YES;
//            self.streamer.presentView = self.containerView;
            [self.containerView addSubview:self.streamer.preview];
            self.streamer.preview.frame = self.containerView.bounds;
            self.streamer.agoraAppid = kAgoraId;
            [self.streamer livePrepareComplete:nil];
            [self.streamer startPreview];
        }
//        [self.streamer startInteractiveLiveAsAnchor:NO channel:@"evtest002"];
        [self.streamer joinChannel:@"evtest002"];
    } else {
//        [self.player play];
//        [self.streamer endInteractiveLive];
        [self.streamer leaveChannel];
    }
}

#pragma mark - EVPlayerDelegate
- (void)EVPlayerDidFinishPlay:(EVPlayer *)player reason:(MPMovieFinishReason)reason {
    NSLog(@"视频播放结束");
}

#pragma mark - EVStreamerDelegate
- (void)EVStreamerUpdateVideoChatState:(EVVideoChatState)chatState{
    NSLog(@"连麦状态：%lu", chatState);
    if (chatState == EVVideoChatStateChannelLeaved) {
        [self.streamer stopPreview];
        [self.streamer.preview removeFromSuperview];
        _streamer = nil;
        [self.player play];
    }
}


#pragma mark - private methods

- (void)setUpPlayer{
    self.player = [[EVPlayer alloc] init];
    self.player.playerContainerView = self.containerView;
    self.player.live = YES;
    self.player.lid = self.vid;
    self.player.delegate = self;
    
    __weak typeof(self) wSelf = self;
    [self.player playPrepareComplete:^(EVPlayerResponseCode responseCode, NSDictionary *result, NSError *err) {
        __strong typeof(wSelf) sSelf = wSelf;
        if (responseCode == EVPlayerResponse_Okay) {
            [sSelf.player play];
        } else {
            NSLog(@"获取直播地址失败：%@", err);
        }
    }];
}

@end
