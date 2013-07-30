//
//  AudioMerger.h
//  ExtAudioFileDemo
//
//  Created by iCoder on 30/07/13.
//
//

#import <Foundation/Foundation.h>

@interface AudioMerger : NSObject

// inputFiles - Array of NSURL objects.
// outputURL - URL where the merged audio file needs to be stored.
+ (BOOL)mergeAudioFiles:(NSArray *)inputFiles outputURL:(NSURL *)outputURL;

@end
