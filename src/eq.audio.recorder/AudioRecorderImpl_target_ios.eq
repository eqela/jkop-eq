
/*
 * This file is part of Jkop
 * Copyright (c) 2016 Job and Esther Technologies, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

class AudioRecorderImpl : AudioRecorder
{
	embed {{{
		#import <AVFoundation/AVFoundation.h>
		#import <UIKit/UIKit.h>
	}}}

	public static AudioRecorder create(File file, EventReceiver listener) {
		var audiorecorder = new AudioRecorderImpl();
		audiorecorder.file = file;
		audiorecorder.listener = listener;
		return(audiorecorder.initialize());
	}

	ptr myrecorder;
	ptr mysession;
	ptr myplayer;
	EventReceiver listener;
	File file;

	public AudioRecorder initialize() {
		ptr avrec;
		ptr avsess;
		if(file.exists()) {
			return(null);
		}
		String path = file.get_native_path();
		var fp = path.to_strptr();
		bool success;
		embed {{{
			NSString *fpath = [NSString stringWithUTF8String:fp];
			NSURL *outputFileURL = [NSURL fileURLWithPath:fpath];
			NSError *err;
			AVAudioSession *session = [AVAudioSession sharedInstance];
			[session setCategory:AVAudioSessionCategoryPlayAndRecord error:&err];
			NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
			[recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
			[recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
			[recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
			AVAudioRecorder *recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:&err];
			recorder.meteringEnabled = YES;
			success = [recorder prepareToRecord];
			avsess = (__bridge_retained void*)session;
			avrec = (__bridge_retained void*)recorder;
		}}}
		if(!success) {
			return(null);
		}
		myrecorder = avrec;
		mysession = avsess;
		return(this);
	}

	public void record() {
		ptr mc = myrecorder;
		ptr sess = mysession;
		embed {{{
			AVAudioSession *session = (__bridge AVAudioSession*)sess;
			[session setActive:YES error:nil];
			AVAudioRecorder* avr = (__bridge AVAudioRecorder*)mc;
			[avr record];
		}}}
	}

	public void pause() {
		ptr mc = myrecorder;
		embed {{{
			AVAudioRecorder *avr = (__bridge AVAudioRecorder*)mc;
			[avr pause];
		}}}
	}

	public void resume() {
		ptr mc = myrecorder;
		embed {{{
			AVAudioRecorder *avr = (__bridge AVAudioRecorder*)mc;
			[avr record];
		}}}
	}

	public void stop() {
		ptr mc = myrecorder;
		ptr sess = mysession;
		embed {{{
			AVAudioRecorder* avr = (__bridge AVAudioRecorder*)mc;
			if([avr isRecording]) {
				[avr stop];
				AVAudioSession *session = (__bridge AVAudioSession*)sess;
				[session setActive:NO error:nil];
			}
		}}}
		if(file.is_file()) {
			var result = new AudioRecorderResult();
			result.set_file(file);
			EventReceiver.event(listener, result);
		}
	}
}
