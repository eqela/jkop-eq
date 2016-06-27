
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

class AndroidAudioPlayer : AudioPlayer
{
	embed "java" {{{
		android.media.MediaPlayer mp;
	}}}

	int resourceid;
	bool prepared = false;
	int milli = 1000;

	public AudioPlayer get_audio_player_resource(String id) {
		String appid = Application.get_name();
		var rid = "%s:raw/%s".printf().add(appid).add(id).to_string();
		Log.debug("Trying to load Android audio player resource `%s'.".printf().add(rid));
		embed "java" {{{
			android.content.res.Resources res = eq.api.Android.context.getResources();
			if(res != null) {
				int aid = res.getIdentifier(rid.to_strptr(), null, null);
				if(aid > 0) {
					mp = android.media.MediaPlayer.create(eq.api.Android.context, aid);
					resourceid = aid;
				}
			}
		}}}
		prepared = true;
		return(this);
	}

	public AudioPlayer prepare_audio_file(File audio) {
		if(audio == null) {
			return(null);
		}
		String path = audio.get_native_path();
		if(path == null) {
			return(null);
		}
		embed "java" {{{
			try {
				mp = new android.media.MediaPlayer();
				mp.setDataSource(path.to_strptr());
				mp.prepare();
			} catch(java.io.IOException e) {
			}
		}}}
		prepared = true;
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
		double volume = v;
		if(v > 1.0) {
			volume = 1.0;
		}
		else if(v < 0) {
			volume = 0.0;
		}
		return(playback("volume", Primitive.for_double(volume)));
	}

	bool playback(String action, Object obj = null) {
		embed "java" {{{
			if(mp == null) {
		}}}
				return(false);
		embed "java" {{{
			}
		}}}
		if("play".equals(action)) {
			if(!prepared) {
				embed "java" {{{
					try{
						mp.prepareAsync();
					}
					catch(java.lang.IllegalStateException e) {
						e.printStackTrace();
					}
				}}}
				prepared = true;
			}
			embed "java" {{{
				try{
					mp.start();
				}
				catch(java.lang.IllegalStateException e) {
					e.printStackTrace();
				}
			}}}
		}
		else if("pause".equals(action)) {
			embed "java" {{{
				try{
					if(mp.isPlaying()) {
						mp.pause();
					}
				}
				catch(java.lang.IllegalStateException e) {
					e.printStackTrace();
				}
			}}}
		}
		else if("stop".equals(action)) {
			embed "java" {{{
				try{
					if(mp.isPlaying()) {
						mp.seekTo(0); // stopping the player should reset the time to 0
					}
					mp.stop();
				}
				catch(java.lang.IllegalStateException e) {
					e.printStackTrace();
				}
			}}}
			prepared = false;
		}
		if("seek".equals(action)) {
			var obj_integer =  obj as Integer;
			if(obj_integer != null) {
				int sec = obj_integer.to_integer();
				embed {{{
					try{
						if(prepared) {
							mp.seekTo(sec * milli);
						}
					}
					catch(java.lang.IllegalStateException e) {
						e.printStackTrace();
					}
				}}}
			}
		}
		if("loop".equals(action)) {
			var obj_boolean =  obj as Boolean;
			if(obj_boolean != null) {
				bool v = obj_boolean.to_boolean();
				embed {{{
					mp.setLooping(v);
				}}}
			}
		}
		if("volume".equals(action)) {
			var obj_double =  obj as Double;
			if(obj_double != null) {
				double v = obj_double.to_double();
				if(v >= 0.0 && v <= 1.0) {
					embed {{{
						mp.setVolume((float)v, (float)v);
					}}}
				}
			}
		}
		return(true);
	}

	public int get_duration() {
		int n;
		embed "java" {{{
			if(mp != null) {
				n = (int)(mp.getDuration() / milli);
			}
		}}}
		return(n);
	}

	public int get_current_time() {
		int ct;
		embed "java" {{{
			if(mp != null) {
				ct = mp.getCurrentPosition() / milli;
			}
		}}}
		return(ct);
	}

	~AndroidAudioPlayer() {
		embed "java" {{{
			if(mp != null) {
				mp.release();
			}
		}}}
	}
}

class AndroidAudioPlayerManager : AudioPlayerManagerBackend
{
	public AudioPlayer create(String id) {
		return(new AndroidAudioPlayer().get_audio_player_resource(id));
	}

	public AudioPlayer create_for_file(File audio) {
		return(new AndroidAudioPlayer().prepare_audio_file(audio));
	}
}

