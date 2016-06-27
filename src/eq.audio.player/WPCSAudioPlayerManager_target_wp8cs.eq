
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

public class WPCSAudioPlayer : AudioPlayer
{
	static int ACTION_PLAY = 1;
	static int ACTION_PAUSE = 2;
	static int ACTION_STOP = 3;
	static int ACTION_VOLUME = 4;
	static int ACTION_LOOP = 5;
	static int ACTION_SEEK = 6;

	embed {{{
		System.Windows.Controls.MediaElement element;

		void on_media_opened(object src, System.EventArgs re) {
			var e = src as System.Windows.Controls.MediaElement;
			if(e != null) {
				element = e;
			}
		}
	}}}

	public WPCSAudioPlayer initialize(String id) {
		if(id == null) {
			return(null);
		}
		var resfn = "Assets/%s.wav".printf().add(id).to_string();
		embed {{{
			System.Windows.Controls.MediaElement e = new System.Windows.Controls.MediaElement();
			e.Source = new System.Uri(resfn.to_strptr(), System.UriKind.RelativeOrAbsolute);
			e.AutoPlay = false;
			e.MediaOpened+=on_media_opened;
			if(eq.gui.sysdep.wpcs.GuiEngine.rootframe != null) {
				eq.gui.sysdep.wpcs.GuiEngine.rootframe.Children.Add(e);
			}
		}}}
		return(this);
	}

	public bool play() {
		return(playback(ACTION_PLAY));
	}

	public bool stop() {
		return(playback(ACTION_STOP));
	}

	public bool pause() {
		return(playback(ACTION_PAUSE));
	}

	public bool seek(int sec) {
		return(playback(ACTION_SEEK, Primitive.for_integer(sec)));
	}

	public bool set_loops(bool v) {
		return(playback(ACTION_LOOP, Primitive.for_boolean(v)));
	}

	public bool set_volume(double v) {
		return(playback(ACTION_VOLUME, Primitive.for_double(v)));
	}

	public int get_duration() {
		embed {{{
			if(element != null) {
				var ts = element.NaturalDuration.TimeSpan;
				if(ts != null) {
					return((int)ts.TotalSeconds);
				}
			}
		}}}
		return(0);
	}

	public int get_current_time() {
		embed {{{
			if(element != null) {
				var ts = element.Position;
				if(ts != null) {
					return((int)ts.TotalSeconds);
				}
			}
		}}}
		return(0);
	}

	embed {{{
		void on_media_ended(object src, System.EventArgs re) {
			var e = src as System.Windows.Controls.MediaElement;
			if(e != null) {
				e.Stop();
				e.Play();
			}
		}
	}}}

	bool playback(int action, Object obj = null) {
		embed {{{
			if(element == null) {
				return(false);
			}
			if(action == ACTION_PLAY) {
				element.Play();
			}
			else if(action == ACTION_PAUSE) {
				element.Pause();	
			}
			else if(action == ACTION_STOP) {
				element.Stop();
			}
			else if(action == ACTION_VOLUME) {
				double v = eq.api.DoubleStatic.eq_api_DoubleStatic_as_double(obj, 0.0);
				element.Volume = v;
			}
			else if(action == ACTION_LOOP) {
				var v = eq.api.BooleanStatic.eq_api_BooleanStatic_as_boolean(obj, false);
				if(v) {
					element.MediaEnded += on_media_ended;
				}
				else {
					element.MediaEnded -= on_media_ended;
				}
			}
			else if(action == ACTION_SEEK) {
				var ts = eq.api.IntegerStatic.eq_api_IntegerStatic_as_integer(obj, 0);
				if(element.CanSeek) {
					var ticks =  10000000 * ts;
					element.Position = new System.TimeSpan(ticks);
				}
				else {
					return(false);
				}
			}
		}}}
		return(true);
	}
}

class WPCSAudioPlayerManager : AudioPlayerManagerBackend
{
	public AudioPlayer create(String id) {
		return(new WPCSAudioPlayer().initialize(id));
	}

	public AudioPlayer create_for_file(File audiofile) {
		return(null);
	}
}
