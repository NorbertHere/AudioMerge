//
//  AudioMerger.m
//  ExtAudioFileDemo
//
//  Created by iCoder on 30/07/13.
//
//

#import <AudioToolbox/AudioToolbox.h>
#import "AudioMerger.h"

@implementation AudioMerger

+ (BOOL)mergeAudioFiles:(NSArray *)inputFiles outputURL:(NSURL *)outputURL;
{
    BOOL success                                            = YES;
    OSStatus                            err                 = noErr;
    AudioStreamBasicDescription         outputFileFormat;
    NSUInteger                          numberOfChannels    = 1;
    ExtAudioFileRef						outputAudioFileRef  = NULL;

    [self setDefaultAudioFormatFlags:&outputFileFormat numChannels:numberOfChannels];
    
    UInt32 flags = kAudioFileFlags_EraseFile;
	err = ExtAudioFileCreateWithURL((__bridge CFURLRef)outputURL, kAudioFileCAFType, &outputFileFormat, NULL, flags, &outputAudioFileRef);
    
    if (err)
	{
        success = NO;
        goto reterr;
	}
    
    for(NSURL *inputURL in inputFiles)
    {
        success =  [self writeAudioFileWithURL:inputURL
                         toAudioFileWithFormat:&outputFileFormat
                                 fileReference:outputAudioFileRef
                           andNumberOfChannels:numberOfChannels];
        if(!success)
        {
            break;
        }
    }
    
reterr:
    if (outputAudioFileRef)
    {
        ExtAudioFileDispose(outputAudioFileRef);
    }
    
    return success;
}

+ (BOOL)writeAudioFileWithURL:(NSURL *)inputURL
        toAudioFileWithFormat:(AudioStreamBasicDescription *)outputFileFormat
                fileReference:(ExtAudioFileRef)outputAudioFileRef
          andNumberOfChannels:(NSUInteger)numberOfChannels
{
    BOOL                                success             = YES;
    OSStatus                            err                 = noErr;
    AudioStreamBasicDescription			inputFileFormat;
    UInt32								thePropertySize     = sizeof(inputFileFormat);
    ExtAudioFileRef						inputAudioFileRef   = NULL;
    UInt8                               *buffer             = NULL;
    
    err = ExtAudioFileOpenURL((__bridge CFURLRef)inputURL, &inputAudioFileRef);
    if (err)
	{
        success = NO;
        goto reterr;
	}
    
    bzero(&inputFileFormat, sizeof(inputFileFormat));
    err = ExtAudioFileGetProperty(inputAudioFileRef, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &inputFileFormat);
    if (err)
	{
        success = NO;
		goto reterr;
	}
    
    err = ExtAudioFileSetProperty(inputAudioFileRef, kExtAudioFileProperty_ClientDataFormat, sizeof(*outputFileFormat), outputFileFormat);
    if (err)
	{
        success = NO;
		goto reterr;
	}
    
    size_t bufferSize = 4096;
    buffer = malloc(bufferSize);
	assert(buffer);
    
    AudioBufferList conversionBuffer;
	conversionBuffer.mNumberBuffers = 1;
	conversionBuffer.mBuffers[0].mNumberChannels = numberOfChannels;
	conversionBuffer.mBuffers[0].mData = buffer;
	conversionBuffer.mBuffers[0].mDataByteSize = bufferSize;
    
    while (TRUE)
    {
		conversionBuffer.mBuffers[0].mDataByteSize = bufferSize;
		UInt32 frameCount = INT_MAX;
        
		if (inputFileFormat.mBytesPerFrame > 0)
        {
			frameCount = (conversionBuffer.mBuffers[0].mDataByteSize / inputFileFormat.mBytesPerFrame);
		}
        
		err = ExtAudioFileRead(inputAudioFileRef, &frameCount, &conversionBuffer);
        
		if (err)
        {
            success = NO;
			goto reterr;
		}
        
		if (frameCount == 0)
        {
			break;
        }
        
		err = ExtAudioFileWrite(outputAudioFileRef, frameCount, &conversionBuffer);
        
		if (err)
        {
            success = NO;
			goto reterr;
		}
	}
    
reterr:
    if (buffer != NULL)
		free(buffer);
    
    if (inputAudioFileRef)
    {
        ExtAudioFileDispose(inputAudioFileRef);
    }
    
    return success;
}

+ (void)setDefaultAudioFormatFlags:(AudioStreamBasicDescription*)audioFormatPtr
                       numChannels:(NSUInteger)numChannels
{
	bzero(audioFormatPtr, sizeof(AudioStreamBasicDescription));
    
	audioFormatPtr->mFormatID = kAudioFormatLinearPCM;
	audioFormatPtr->mSampleRate = 44100.0;
	audioFormatPtr->mChannelsPerFrame = numChannels;
	audioFormatPtr->mBytesPerPacket = 2 * numChannels;
	audioFormatPtr->mFramesPerPacket = 1;
	audioFormatPtr->mBytesPerFrame = 2 * numChannels;
	audioFormatPtr->mBitsPerChannel = 16;
	audioFormatPtr->mFormatFlags = kAudioFormatFlagsNativeEndian |
    kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
}

@end
