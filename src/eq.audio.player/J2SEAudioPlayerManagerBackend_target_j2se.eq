
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

public class J2SEAudioPlayer : AudioPlayer
{
	J2SESound jsound;
	bool loop;

	public static J2SEAudioPlayer for_file(File file) {
		var v = new J2SEAudioPlayer();
		v.jsound = J2SESound.load_by_file(file);
		if(v.jsound == null) {
			return(null);
		}
		return(v);
	}

	public static J2SEAudioPlayer for_id(String id) {
		var v = new J2SEAudioPlayer();
		v.jsound = J2SESound.load_by_id(id);
		if(v.jsound == null) {
			return(null);
		}
		return(v);
	}

	public bool play() {
		embed {{{
			javax.sound.sampled.Clip sound = jsound.get_sound_clip();
			if(loop) {
				sound.loop(javax.sound.sampled.Clip.LOOP_CONTINUOUSLY);
			}
			else {
				sound.start();
			}
		}}}
		return(true);
	}

	public bool pause() {
		embed {{{
			javax.sound.sampled.Clip sound = jsound.get_sound_clip();
			sound.stop();
		}}}
		return(true);
	}

	public bool stop() {
		embed {{{
			javax.sound.sampled.Clip sound = jsound.get_sound_clip();
			sound.stop();
			sound.setMicrosecondPosition(0);
		}}}
		return(true);
	}

	public bool seek(int sec) {
		embed {{{
			javax.sound.sampled.Clip sound = jsound.get_sound_clip();
			sound.setMicrosecondPosition(sec * 1000000);
		}}}
		return(true);
	}

	public int get_current_time() {
		int v = 0;
		embed {{{
			javax.sound.sampled.Clip sound = jsound.get_sound_clip();
			v = (int)(sound.getMicrosecondPosition()/1000000);
		}}}
		return(v);
	}

	public int get_duration() {
		int v = 0;
		embed {{{
			javax.sound.sampled.Clip sound = jsound.get_sound_clip();
			v = (int)(sound.getMicrosecondLength()/1000000);
		}}}
		return(v);
	}

	public bool set_loops(bool v) {
		embed {{{
			javax.sound.sampled.Clip sound = jsound.get_sound_clip();
			if(loop != v && sound.isRunning()) {
				sound.stop();
				if(v) {
					sound.loop(javax.sound.sampled.Clip.LOOP_CONTINUOUSLY);
				}
				else {
					sound.start();
				}
			}
		}}}
		loop = v;
		return(true);
	}

	public bool set_volume(double vol) {
		bool v = false;
		embed {{{
			javax.sound.sampled.Clip sound = jsound.get_sound_clip();
			javax.sound.sampled.FloatControl master_gain = (javax.sound.sampled.FloatControl)sound.getControl(javax.sound.sampled.FloatControl.Type.MASTER_GAIN);
			if(master_gain != null) {
				float max = master_gain.getMaximum(), min = master_gain.getMinimum();
				float avol = (float)vol * -min;
				avol = avol + min;
				if(avol >= min && avol <= max) {
					master_gain.setValue((float)avol);
					v = true;
				}
			}
		}}}
		return(v);
	}
}

class J2SEAudioPlayerManagerBackend : AudioPlayerManagerBackend
{
	public AudioPlayer create(String id) {
		return(J2SEAudioPlayer.for_id(id));
	}
	public AudioPlayer create_for_file(File audiofile) {
		return(J2SEAudioPlayer.for_file(audiofile));
	}
}
