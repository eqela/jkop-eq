
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

public class XamlAudioPlayer : AudioPlayer
{
	XamlSoundElement xsound;

	public static XamlAudioPlayer for_file(File file) {
		var v = new XamlAudioPlayer();
		v.xsound = XamlSoundElement.for_file(file);
		if(v.xsound == null) {
			return(null);
		}
		return(v);
	}

	public static XamlAudioPlayer for_id(String id) {
		var v = new XamlAudioPlayer();
		v.xsound = XamlSoundElement.for_id(id);
		if(v.xsound == null) {
			return(null);
		}
		return(v);
	}

	public bool play() {
		xsound.play();
		return(true);
	}

	public bool pause() {
		embed {{{
			var sound = xsound.get_media_element();
			sound.Pause();
		}}}
		return(true);
	}

	public bool stop() {
		embed {{{
			var sound = xsound.get_media_element();
			sound.Stop();
		}}}
		return(true);
	}

	public bool seek(int sec) {
		int hrs = 0, mins = 0, secs = sec;
		if(secs > 0) {
			hrs = secs / 1800;
			secs = secs % 1800;
		}
		if(secs > 0) {
			mins = secs / 60;
			secs = secs % 60;
		}
		embed {{{
			var sound = xsound.get_media_element();
			sound.Position = new System.TimeSpan(hrs, mins, secs);
		}}}
		return(true);
	}

	public int get_current_time() {
		embed {{{
			var sound = xsound.get_media_element();
			var ts = sound.Position;
			if(ts != null) {
				return((int)ts.TotalSeconds);
			}
		}}}
		return(0);
	}

	public int get_duration() {
		embed {{{
			var sound = xsound.get_media_element();
			var ts = sound.NaturalDuration.TimeSpan;
			if(ts != null) {
				return((int)ts.TotalSeconds);
			}
		}}}
		return(0);
	}

	public bool set_loops(bool v) {
		embed {{{
			var sound = xsound.get_media_element();
			sound.IsLooping = v;
		}}}
		return(true);
	}

	public bool set_volume(double v) {
		embed {{{
			var sound = xsound.get_media_element();
			sound.Volume = v;
		}}}
		return(true);
	}
}

class XamlAudioPlayerManagerBackend : AudioPlayerManagerBackend
{
	public AudioPlayer create(String id) {
		return(XamlAudioPlayer.for_id(id));
	}
	public AudioPlayer create_for_file(File audiofile) {
		return(XamlAudioPlayer.for_file(audiofile));
	}
}
