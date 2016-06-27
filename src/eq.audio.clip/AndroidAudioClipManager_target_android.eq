
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

class AndroidAudioClip : AudioClip
{
	class AudioClipPlayThread : Runnable {
		property int sid;
		public void run() {
			embed "java" {{{
				AndroidAudioClipManager.soundpool.play(sid, 1, 1, 0, 0, 1);
			}}}
		}
	}

	int soundid;

	public bool play() {
		Thread.start(new AudioClipPlayThread().set_sid(soundid));
		return(true);
	}

	public AudioClip get_audio_clip_resource(String id) {
		String appid = Application.get_name();
		var rid = "%s:raw/%s".printf().add(appid).add(id).to_string();
		Log.debug("Trying to load Android audio clip resource `%s'.".printf().add(rid));
		embed "java" {{{
			android.content.res.Resources res = eq.api.Android.context.getResources();
			if(res != null) {
				int aid = res.getIdentifier(rid.to_strptr(), null, null);
				if(aid > 0) {
					soundid = AndroidAudioClipManager.soundpool.load(eq.api.Android.context, aid, 1);
				}
			}
		}}}
		return(this);
	}
}

class AndroidAudioClipManager : AudioClipManagerBackend
{
	embed "java" {{{
		public static android.media.SoundPool soundpool;
	}}}

	public AudioClip create(String id) {
		embed {{{
			if(soundpool == null) {
				soundpool = new android.media.SoundPool(128, android.media.AudioManager.STREAM_MUSIC, 0);
			}
		}}}
		return(new AndroidAudioClip().get_audio_clip_resource(id));
	}
}

