
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

class Win32AudioPlayer : AudioPlayer
{
	DirectAudioPlayer daplayer;
	DirectAudioEngine dae;

	public AudioPlayer initialize(String id) {
		return(initialize_for_file(
			File.for_eqela_path("/app/%s.wav".printf().add(id).to_string())));
	}

	public AudioPlayer initialize_for_file(File a) {
		if(a == null) {
			return(null);
		}
		if(a.exists() == false) {
			Log.warning("Win32AudioPlayerManager: `%s' was not found.".printf().add(a));
			return(null);
		}
		dae = DirectAudioEngine.load_file(a);
		return(this);
	}

	public void prepare() {
		if(daplayer == null) {
			if(dae != null) {
				daplayer = dae.create_player();
			}
		}
	}

	public bool play() {
		prepare();
		if(daplayer != null) {
			return(daplayer.playback(DirectAudioPlayer.ACTION_PLAY));
		}
		return(false);
	}

	public bool stop() {
		if(daplayer != null) {
			return(daplayer.playback(DirectAudioPlayer.ACTION_STOP));
		}
		return(false);
	}

	public bool pause() {
		if(daplayer != null) {
			return(daplayer.playback(DirectAudioPlayer.ACTION_PAUSE));
		}
		return(false);
	}

	public bool seek(int sec) {
		prepare();
		if(daplayer != null) {
			return(daplayer.playback(DirectAudioPlayer.ACTION_SEEK, sec));
		}
		return(false);
	}

	public bool set_loops(bool v) {
		prepare();
		if(daplayer != null) {
			return(daplayer.playback(DirectAudioPlayer.ACTION_LOOP, v));
		}
		return(false);
	}

	public bool set_volume(double v) {
		prepare();
		if(daplayer != null) {
			return(daplayer.playback(DirectAudioPlayer.ACTION_VOLUME, v));
		}
		return(false);
	}

	public int get_current_time() {
		if(daplayer != null) {
			return(daplayer.get_current_time());
		}
		return(0);
	}

	public int get_duration() {
		if(dae != null) {
			return(dae.get_seconds());
		}
		return(0);
	}
}

class Win32AudioPlayerManager : AudioPlayerManagerBackend
{
	public AudioPlayer create(String id) {
		return(new Win32AudioPlayer().initialize(id));
	}

	public AudioPlayer create_for_file(File audiofile) {
		return(new Win32AudioPlayer().initialize_for_file(audiofile));
	}
}
