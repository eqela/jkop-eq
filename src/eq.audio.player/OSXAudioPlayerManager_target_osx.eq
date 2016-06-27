
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

class OSXAudioPlayer : AudioPlayer
{
	embed {{{
		#import <AppKit/NSSound.h>
	}}}

	ptr nssound;

	public AudioPlayer initialize(String id) {
		if(id == null) {
			return(null);
		}
		var ip = id.to_strptr();
		if(ip == null) {
			return(null);
		}
		ptr nss;
		int d;
		embed {{{
			NSString* p1 = [[NSString alloc] initWithUTF8String:ip];
			NSString* pp = [[NSBundle mainBundle] pathForResource:p1 ofType:@"mp3"];
			if(pp != nil) {
				NSSound *sound = [[NSSound alloc] initWithContentsOfFile:pp byReference:NO];
				nss = (__bridge_retained void*)sound;
			}
		}}}
		this.nssound = nss;
		if(nss != null) {
			Log.debug("OSXAudioPlayer: Initialized audio Player `%s'".printf().add(id));
		}
		else {
			Log.debug("OSXAudioPlayer: Failed to initialize audio Player `%s'".printf().add(id));
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
		if(nssound == null || action == null) {
			return(false);
		}
		var ac = action.to_strptr();
		var nss = nssound;
		embed {{{
			NSSound* s = (__bridge NSSound*)nss;
			if(ac == "play") {
				if(s.isPlaying) {
					[s resume];
				}
				else {
					[s play];
				}
			}
			else if(ac == "pause") {
				[s pause];
			}
			else if(ac == "stop") {
				[s stop];
			}
		}}}
		if("seek".equals(action)) {
			var obj_integer =  obj as Integer;
			if(obj_integer != null) {
				int sec = obj_integer.to_integer();
				embed {{{
					[s setCurrentTime:sec];
				}}}
			}
		}
		else if("loop".equals(action)) {
			var obj_boolean =  obj as Boolean;
			if(obj_boolean != null) {
				bool v = obj_boolean.to_boolean();
				if(v) {
					embed {{{
						[s setLoops:YES];
					}}}
				}
				else {
					embed {{{
						[s setLoops:NO];
					}}}
				}
			}
		}
		if("volume".equals(action)) {
			var obj_double = obj as Double;
			if(obj_double != null) {
				double v = obj_double.to_double();
				if(v >= 0.0 && v <= 1.0) {
					embed {{{
						[s setVolume:v];
					}}}
				}
			}
		}
		return(true);
	}

	public int get_duration() {
		if(nssound == null) {
			return(-1);
		}
		var nss = nssound;
		int d;
		embed {{{
			NSSound* s = (__bridge NSSound*)nss;
			d = [s duration];
		}}}
		return(d);
	}

	public int get_current_time() {
		if(nssound == null) {
			return(-1);
		}
		var nss = nssound;
		int ct;
		embed {{{
			NSSound* s = (__bridge NSSound*)nss;
			ct = [s currentTime];
		}}}
		return(ct);
	}

	public void destroy() {
		if(nssound == null) {
			return;
		}
		var nss = nssound;
		embed {{{
			NSSound* s = (__bridge_transfer NSSound*)nss;
		}}}
		nssound = null;
	}
}

class OSXAudioPlayerManager : AudioPlayerManagerBackend
{
	public AudioPlayer create(String id) {
		return(new OSXAudioPlayer().initialize(id));
	}

	public AudioPlayer create_for_file(File audiofile) {
		return(null);
	}
}

