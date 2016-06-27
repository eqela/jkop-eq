
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

class WPCSAudioClip : AudioClip
{
	class AudioClipRunnableThread : Runnable
	{
		embed "cs" {{{
			Microsoft.Xna.Framework.Audio.SoundEffect sound;
			
			public void set_audio(Microsoft.Xna.Framework.Audio.SoundEffect sound) {
				this.sound = sound;
			}
		}}}

		public void run() {
			embed "cs" {{{
				var sound = this.sound.CreateInstance();
				if(sound != null) {
					sound.Play();
					System.Threading.Thread.Sleep(this.sound.Duration);
					sound.Dispose();
				}
			}}}
		}

		public void dispose() {
			embed "cs" {{{
				if(sound != null && sound.IsDisposed == false) {
					sound.Dispose();
					sound = null;
				}
			}}}
		}
	}

	AudioClipRunnableThread audio_runnable;

	public AudioClip initialize(String id) {
		if(id != null) {
			var strid = "Assets/%s.wav".printf().add(id).to_string();
			audio_runnable = new AudioClipRunnableThread();
			embed "cs" {{{ 
				var uri = new System.Uri(strid.to_strptr(), System.UriKind.RelativeOrAbsolute);
				System.Windows.Resources.StreamResourceInfo srinfo = System.Windows.Application.GetResourceStream(uri);
				if(srinfo == null) {
					System.Diagnostics.Debug.WriteLine("Failed to initialize audio clip: " + strid.to_strptr());
					return(null);
				}
				var se = Microsoft.Xna.Framework.Audio.SoundEffect.FromStream(srinfo.Stream);
				if(se != null) {
					Microsoft.Xna.Framework.FrameworkDispatcher.Update();
					audio_runnable.set_audio(se);
				}
				else {
					audio_runnable = null;
				}
			}}}
		}
		return(this);
	}

	public bool play() {
		if(audio_runnable!=null) {
			Thread.start(audio_runnable);
			return(true);
		}
		return(false);
	}

	public void dispose() {
		if(audio_runnable != null) {
			audio_runnable.dispose();
		}
	}
}

class WPCSAudioClipManager : AudioClipManagerBackend
{
	public AudioClip create(String id) {
		return(new WPCSAudioClip().initialize(id));
	}
}
