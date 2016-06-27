
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

class IOSAudioClip : AudioClip
{
	embed {{{
		#include <AVFoundation/AVFoundation.h>
	}}}

	class IOSAudioClipPlayerThread : Runnable
	{
		property String clipid;

		public void run() {
			if(clipid == null) {
				return;
			}
			var ip = clipid.to_strptr();
			if(ip == null) {
				return;
			}
			ptr ap;
			embed {{{
				NSString* p1 = [[NSString alloc] initWithUTF8String:ip];
				NSURL* pp = [[NSBundle mainBundle] URLForResource:p1 withExtension:@"mp3"];
				NSError* err;
				AVAudioPlayer* avap = [[AVAudioPlayer alloc] initWithContentsOfURL:pp error:&err];
				ap = (__bridge void*)avap;
			}}}
			if(ap == null) {
				Log.debug("IOSAudioClip: Failed to play audio clip `%s'".printf().add(clipid));
			}
			embed {{{
				[avap play];
				[NSThread sleepForTimeInterval:[avap duration]];
				[avap stop];
			}}}
		}
	}

	String clipid;

	public AudioClip initialize(String id) {
		if(id == null) {
			return(null);
		}
		clipid = id;
		return(this);
	}

	public bool play() {
		if(clipid == null) {
			return(false);
		}
		Thread.start(new IOSAudioClipPlayerThread().set_clipid(clipid));
		return(true);
	}
}

class IOSAudioClipManager : AudioClipManagerBackend
{
	public AudioClip create(String id) {
		return(new IOSAudioClip().initialize(id));
	}
}
