
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

class IOSAudioPlayer : AudioPlayer
{
	embed {{{
		#import <UIKit/UIKit.h>
		#include <AVFoundation/AVFoundation.h>
	}}}

	ptr audioplayer;

	public AudioPlayer initialize(String path) {
		if(path == null) {
			return(null);
		}
		var ip = path.to_strptr();
		if(ip == null) {
			return(null);
		}
		embed {{{
			NSString* p1 = [[NSString alloc] initWithUTF8String:ip];
			NSURL* pp = nil;
		}}}
		if(path.has_prefix("/")) {
			embed {{{
				pp = [NSURL URLWithString:p1];
			}}}
		}
		else {
			embed {{{
				pp = [[NSBundle mainBundle] URLForResource:p1 withExtension:@"mp3"];
			}}}
		}
		ptr ap;
		embed {{{
			NSError* err;
			AVAudioPlayer* avap = [[AVAudioPlayer alloc] initWithContentsOfURL: pp error:&err];
			if(err)
			{
				NSLog(@"Error in AudioPlayer: %@", [err localizedDescription]);
			} else {
				[avap prepareToPlay];
				ap = (__bridge_retained void*)avap;
			}
		}}}
		this.audioplayer = ap;
		if(ap != null) {
			Log.debug("IOSAudioPlayer: Initialized audio Player `%s'".printf().add(path));
		}
		else {
			Log.debug("IOSAudioPlayer: Failed to initialize audio Player `%s'".printf().add(path));
		}
		return(this);
	}

	public bool play() {
		return(playback("play"));
	}

	public bool stop() {
		return(playback("stop"));
	}

	public bool pause() {
		return(playback("pause"));
	}

	public bool seek(int sec) {
		return(playback("seek", Primitive.for_integer(sec)));
	}

	public bool set_loops(bool v) {
		return(playback("loop", Primitive.for_boolean(v)));
	}

	public bool set_volume(double v) {
		return(playback("volume", Primitive.for_double(v)));
	}

	bool playback(String action, Object obj = null) {
		if(audioplayer == null || action == null) {
			return(false);
		}
		var ac = action.to_strptr();
		ptr ap = audioplayer;
		embed {{{
			AVAudioPlayer* avap = (__bridge AVAudioPlayer*)ap;
			if(ac == "play") {
				[avap play];
			}
			else if(ac == "pause") {
				[avap pause];
			}
			else if(ac == "stop") {
				[avap stop];
			}
		}}}
		if("seek".equals(action)) {
			var obj_integer =  obj as Integer;
			if(obj_integer != null) {
				int sec = obj_integer.to_integer();
				embed {{{
					[avap setCurrentTime:sec];
				}}}
			}
		}
		if("loop".equals(action)) {
			var obj_boolean =  obj as Boolean;
			if(obj_boolean != null) {
				bool v = obj_boolean.to_boolean();
				if(v) {
					embed {{{
						[avap setNumberOfLoops:-1];
					}}}
				}
				else {
					embed {{{
						[avap setNumberOfLoops:0];
					}}}
				}
			}
		}
		if("volume".equals(action)) {
			var obj_double =  obj as Double;
			if(obj_double != null) {
				double v = obj_double.to_double();
				Log.message("volume: %f".printf().add(v).to_string());
				if(v >= 0.0 && v <= 1.0) {
					embed {{{
						[avap setVolume:v];
					}}}
				}
			}
		}

		return(true);
	}

	public int get_duration() {
		if(audioplayer == null) {
			return(-1);
		}
		int d;
		ptr ap = audioplayer;
		embed {{{
			AVAudioPlayer* avap = (__bridge AVAudioPlayer*)ap;
			d = [avap duration];
		}}}
		return(d);
	}

	public int get_current_time() {
		if(audioplayer == null) {
			return(-1);
		}
		int ct;
		ptr ap = audioplayer;
		embed {{{
			AVAudioPlayer* avap = (__bridge AVAudioPlayer*)ap;
			ct = [avap currentTime];
		}}}
		return(ct);
	}

	public void dealloc() {
		if(audioplayer == null) {
			return;
		}
		ptr ap = audioplayer;
		embed {{{
			AVAudioPlayer* avap = (__bridge_transfer AVAudioPlayer*)ap;
		}}}
		audioplayer == null;
	}
}

class IOSAudioPlayerManager : AudioPlayerManagerBackend
{
	public AudioPlayer create(String id) {
		return(new IOSAudioPlayer().initialize(id));
	}

	public AudioPlayer create_for_file(File audiofile) {
		return(new IOSAudioPlayer().initialize(audiofile.get_native_path()));
	}
}

