
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

class OSXAudioClip : AudioClip
{
	embed {{{
		#import <AppKit/NSSound.h>
	}}}

    class OSXAudioClipThread : Runnable
    {
		property String audioid;

		public void run() {
			play(audioid);
		}

		void play(String id) {
			var ip = id.to_strptr();
			if(ip == null) {
				return;
			}
			ptr nss;
			embed {{{
				NSString* p1 = [[NSString alloc] initWithUTF8String:ip];
				NSString* pp = [[NSBundle mainBundle] pathForResource:p1 ofType:@"mp3"];
				NSSound *sound;
				if(pp != nil) {
					sound = [[NSSound alloc] initWithContentsOfFile:pp byReference:NO];
					nss = (__bridge void*)sound;
				}
			}}}
			if(nss == null) {
				Log.error("OSXAudioClip: Failed to play audio clip `%s'".printf().add(id));
				return;
			}
			embed {{{
				[sound play];
			}}}
		}
	}

	String audioid;

	bool check_for_validity(String id) {
		if(id == null) {
			return(false);
		}
		var ip = id.to_strptr();
		if(ip == null) {
			return(false);
		}
		ptr nss;
		embed {{{
			NSString* p1 = [[NSString alloc] initWithUTF8String:ip];
			NSString* pp = [[NSBundle mainBundle] pathForResource:p1 ofType:@"mp3"];
			NSSound *sound;
			if(pp != nil) {
				sound = [[NSSound alloc] initWithContentsOfFile:pp byReference:NO];
				nss = (__bridge void*)sound;
			}
		}}}
		if(nss != null) {
			return(true);
		}
		return(false);
	}

	public AudioClip initialize(String id) {
		if(check_for_validity(id) == false) {
			return(null);
		}
		Log.debug("OSXAudioClip: Initialized audio clip `%s'".printf().add(id));
		audioid = id;
		return(this);
	}

	public bool play() {
		if(audioid == null) {
			return(false);
		}
		Thread.start(new OSXAudioClipThread().set_audioid(audioid));
		return(true);
	}
}

class OSXAudioClipManager : AudioClipManagerBackend
{
	public AudioClip create(String id) {
		return(new OSXAudioClip().initialize(id));
	}
}
