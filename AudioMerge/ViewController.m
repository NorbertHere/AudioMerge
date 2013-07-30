//
//  ViewController.m
//  AudioMerge
//
//  Created by iCoder on 30/07/13.
//  Copyright (c) 2013 iCoder. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"
#import "AudioMerger.h"

@interface ViewController ()

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Input files.
    NSString *file1 = @"Yamaha-SY-35-Clarinet-C5";
    NSString *file2= @"whack";
    NSString *file3 = @"sound";
    
    // Url for the above input files.
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:file1 withExtension:@"wav"];
    NSURL *url2 = [[NSBundle mainBundle] URLForResource:file2 withExtension:@"caf"];
    NSURL *url3 = [[NSBundle mainBundle] URLForResource:file3 withExtension:@"caf"];
    
    // Output URL.
    NSString *outPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"test.caf"];
    NSURL *outputURL = [NSURL fileURLWithPath:outPath];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        BOOL success = [AudioMerger mergeAudioFiles:@[url1, url2, url3]
                                          outputURL:outputURL];
        NSLog(@"success : %d",success);
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:outputURL error:nil];
        [self.audioPlayer play];
    });
}

@end
