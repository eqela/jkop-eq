
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

class J2MEAudioClip : AudioClip
{
	class AudioClipRunnableThread : Runnable
	{
		embed "java" {{{
			javax.microedition.media.Player audio;
			
			public void set_audio(javax.microedition.media.Player audio) {
				this.audio = audio;
			}
		}}}

		public void run() {
			embed "java" {{{
				try {
					audio.start();
				}
				catch(Exception e) {
					System.err.println("Failed to play media: " + e);
				}
			}}}
		}
	}

	AudioClipRunnableThread audio_runnable;

	public AudioClip initialize(String id) {
		if(id == null) {
			return(this);
		}
		audio_runnable = new AudioClipRunnableThread();
		String strid = "/%s.wav".printf().add(id).to_string();
		embed "java" {{{
			try {
				java.io.InputStream ais = getClass().getResourceAsStream(strid.to_strptr());
				javax.microedition.media.Player audio = javax.microedition.media.Manager.createPlayer(ais, "audio/X-wav");
				audio_runnable.set_audio(audio);
			}
			catch(Exception e) {
				audio_runnable = null;
				System.err.println("Failed to prepare media: " + id.to_strptr());
			}
		}}}
		return(this);
	}

	public bool play() {
		if(audio_runnable != null) {
			Thread.start(audio_runnable);
			return(true);
		}
		return(false);
	}
}

class J2MEAudioClipManager : AudioClipManagerBackend
{
	public AudioClip create(String id) {
		return(new J2MEAudioClip().initialize(id));
	}
}
