
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

class HTML5AudioPlayer : AudioPlayer
{
	ptr audioplayer;

	public AudioPlayer initialize(String id) {
		var fn = "%s".printf().add(id).to_string();
		var fnp = fn.to_strptr();
		ptr audio_element;
		embed {{{
			audio_element = document.createElement('audio');
			audio_element.setAttribute("preload", "auto");
			var src_mp3 = document.createElement('source');
			src_mp3.type = 'audio/mpeg';
			src_mp3.src = fnp + '.mp3';
			audio_element.appendChild(src_mp3);
			var src_ogg = document.createElement('source');
			src_ogg.type = 'audio/ogg';
			src_ogg.src = fnp + '.ogg';
			audio_element.appendChild(src_ogg);
			var src_m4a = document.createElement('source');
			src_m4a.type = 'audio/mp4';
			src_m4a.src = fnp + '.m4a';
			audio_element.appendChild(src_m4a);
			var src_wav = document.createElement('source');
			src_wav.type = 'audio/wav';
			src_wav.src = fnp + '.wav';
			audio_element.appendChild(src_wav);
			document.body.appendChild(audio_element);
			audio_element.load();
		}}}
		audioplayer = audio_element;
		return(this);
	}

	public bool play() {
		var audioplayer = this.audioplayer;
		if(audioplayer != null) {
			embed {{{
				audioplayer.play();
			}}}
			return(true);
		}
		return(false);
	}

	public bool stop() {
		var audioplayer = this.audioplayer;
		if(audioplayer != null) {
			embed {{{
				audioplayer.pause();
				audioplayer.currentTime = 0;
			}}}
			return(true);
		}
		return(false);
	}

	public bool pause() {
		var audioplayer = this.audioplayer;
		if(audioplayer != null) {
			embed {{{
				audioplayer.pause();
			}}}
			return(true);
		}
		return(false);
	}

	public bool seek(int sec) {
		var audioplayer = this.audioplayer;
		if(sec >= 0 && audioplayer != null) {
			embed {{{
				audioplayer.currentTime = sec;
			}}}
			return(true);
		}
		return(false);
	}

	public bool set_loops(bool v) {
		var audioplayer = this.audioplayer;
		if(v != null && audioplayer != null) {
			if(v) {
				embed {{{
					audioplayer.loop = true;
				}}}
			}
			else {
				embed {{{
					audioplayer.loop = false;
				}}}
			}
			return(true);
		}
		return(false);
	}

	public bool set_volume(double v) {
		var audioplayer = this.audioplayer;
		if(v != null && audioplayer != null) {
			if(v <= 0.0) {
				embed {{{
					audioplayer.volume = 0.0;
				}}}
			}
			else if(v >= 1.0) {
				embed {{{
					audioplayer.volume = 1.0;
				}}}
			}
			else {
				embed {{{
					audioplayer.volume = v;
				}}}
			}
			return(true);
		}
		return(false);
	}

	public int get_duration() {
		int d;
		var audioplayer = this.audioplayer;
		embed {{{
			d = audioplayer.duration;
		}}}
		return(d);
	}

	public int get_current_time() {
		int ct;
		var audioplayer = this.audioplayer;
		embed {{{
			ct = audioplayer.currentTime;
		}}}
		return(ct);
	}
}

class HTML5AudioPlayerManager : AudioPlayerManagerBackend
{
	public AudioPlayer create(String id) {
		return(new HTML5AudioPlayer().initialize(id));
	}

	public AudioPlayer create_for_file(File audiofile) {
		return(null);
	}
}
