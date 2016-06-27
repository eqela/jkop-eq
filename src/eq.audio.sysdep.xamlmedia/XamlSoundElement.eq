
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

public class XamlSoundElement
{
	embed {{{
		Windows.UI.Xaml.Controls.MediaElement sound;
	}}}

	public static XamlSoundElement for_id(String id, bool auto_play = false) {
		var v = new XamlSoundElement();
		if(v.load_id(id, auto_play) == false) {
			return(null);
		}
		return(v);
	}

	public static XamlSoundElement for_file(File f, bool auto_play = false) {
		var v = new XamlSoundElement();
		if(v.load(f, auto_play) == false) {
			return(null);
		}
		return(v);
	}

	bool load_id(String id, bool play) {
		var app = File.for_app_directory();
		File audio = null;
		if(app != null) {
			app = app.entry("Assets");
			audio = app.entry("%s.wav".printf().add(id).to_string());
			if(audio.is_file() == false) {
				audio = app.entry("%s.mp3".printf().add(id).to_string());
			}
		}
		return(load(audio, play));
	}

	bool load(File audio, bool play = false) {
		if(audio != null) {
			var apath = audio.get_native_path();
			embed {{{
				sound = new Windows.UI.Xaml.Controls.MediaElement();
				sound.AutoPlay = play;
				if(play) {
					sound.MediaEnded += (e, arg) => {
						unload();
					};
				}
				sound.Source = new System.Uri(apath.to_strptr());
				if(eq.gui.sysdep.xamlcs.GuiEngine.root_panel != null) {
					eq.gui.sysdep.xamlcs.GuiEngine.root_panel.Children.Add(sound);
				}
			}}}
		}
		return(true);
	}

	public void unload() {
		embed {{{
			var panel = sound.Parent as Windows.UI.Xaml.Controls.Panel;
			if(panel != null) {
				panel.Children.Remove(sound);
			}
		}}}
	}

	public void play() {
		embed {{{
			sound.Play();
		}}}
	}

	embed {{{
		public Windows.UI.Xaml.Controls.MediaElement get_media_element() {
			return(sound);
		}
	}}}
}
