
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

class Win32AudioClip : AudioClip
{
	class ThreadPlayer : Runnable
	{
		property DirectAudioPlayer daplayer;
		public void run() {
			var dap = daplayer;
			if(daplayer!=null) {
				dap.playback(DirectAudioPlayer.ACTION_PLAY);
				while(dap.is_playing()) {
					SystemEnvironment.usleep(1000);
				}
				dap.safe_release();
			}
		}
	}

	DirectAudioEngine daengine;

	public AudioClip initialize(String id) {
		var a = File.for_eqela_path("/app/%s.wav".printf().add(id).to_string());
		if(a.exists() == false) {
			Log.warning("Win32AudioClipManager: `%s' was not found.".printf().add(a));
			return(null);
		}
		daengine = DirectAudioEngine.load_file(a);
		return(this);
	}

	public bool play() {
		Thread.start(new ThreadPlayer().set_daplayer(daengine.create_player()));
		return(true);
	}
}

class Win32AudioClipManager : AudioClipManagerBackend
{
	public AudioClip create(String id) {
		return(new Win32AudioClip().initialize(id));
	}
}
