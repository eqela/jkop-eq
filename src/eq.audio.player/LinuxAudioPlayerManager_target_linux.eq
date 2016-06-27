
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

public class LinuxAudioPlayer : AudioPlayer
{
	AlsaAudioPlayer alsaaudio;
	File file;

	public AudioPlayer initialize(String id) {
		if(id == null) {
			return(null);
		}
		var audioclip = File.for_eqela_path("/app/%s.wav".printf().add(id).to_string());
		if(audioclip.is_file()) {
			file = audioclip;
		}
		alsaaudio = new AlsaAudioPlayer().initialize(file);
		return(this);
	}

	public bool play() {
		if(alsaaudio != null) {
			alsaaudio.play();
		}
		return(true);
	}

	public bool stop() {
		alsaaudio.stop();
		return(true);
	}

	public bool pause() {
		alsaaudio.pause();
		return(true);
	}

	public bool resume() {
		alsaaudio.resume();
		return(true);
	}

	public bool seek(int sec) {
		return(false);
	}

	public int get_current_time() {
		return(0);
	}

	public int get_duration() {
		return(alsaaudio.get_duration());
	}

	public bool set_loops(bool v) {
		if(v) {
			if(alsaaudio != null) {
				alsaaudio.set_loops(v);
			}
			return(true);
		}
		return(false);
	}

	public bool set_volume(double v) {
		return(false);
	}
}

class LinuxAudioPlayerManager : AudioPlayerManagerBackend
{
	public AudioPlayer create(String id) {
		return(new LinuxAudioPlayer().initialize(id));
	}

	public AudioPlayer create_for_file(File audiofile) {
		return(null);
	}
}
