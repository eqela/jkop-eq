
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

public class AudioClipManager
{
	static AudioClipManagerBackend backend;
	static HashTable clips;

	static void initialize() {
		if(backend == null) {
			IFDEF("target_html") {
				backend = new HTML5AudioClipManager();
			}
			ELSE IFDEF("target_osx") {
				backend = new OSXAudioClipManager();
			}
			ELSE IFDEF("target_android") {
				backend = new AndroidAudioClipManager();
			}
			ELSE IFDEF("target_j2me") {
				backend = new J2MEAudioClipManager();
			}
			ELSE IFDEF("target_win32") {
				backend = new Win32AudioClipManager();
			}
			ELSE IFDEF("target_wpcs") {
				backend = new WPCSAudioClipManager();
			}
			ELSE IFDEF("target_ios") {
				backend = new IOSAudioClipManager();
			}
			ELSE IFDEF("target_linux") {
				backend = new LinuxAudioClipManager();
			}
			ELSE IFDEF("target_uwpcs") {
				backend = new XamlAudioClipManager();
			}
			ELSE IFDEF("target_j2se") {
				backend = new J2SEAudioClipManager();
			}
		}
	}

	public static void prepare(String id) {
		get(id);
	}

	public static AudioClip get(String id) {
		AudioClip v;
		if(clips != null) {
			v = clips.get(id) as AudioClip;
		}
		if(v != null) {
			return(v);
		}
		if(backend == null) {
			initialize();
		}
		if(backend == null) {
			return(null);
		}
		v = backend.create(id);
		if(v == null) {
			return(null);
		}
		if(clips == null) {
			clips = HashTable.create();
		}
		clips.set(id, v);
		return(v);
	}

	public static bool play(String id) {
		var clip = get(id);
		if(clip == null) {
			return(false);
		}
		return(clip.play());
	}

	public static void clear() {
		IFDEF("target_wpcs") {
			foreach(WPCSAudioClip wac in clips) {
				wac.dispose();
			}
		}
		IFDEF("target_android") {
			embed {{{
				if(AndroidAudioClipManager.soundpool != null) {
					AndroidAudioClipManager.soundpool.release();
					AndroidAudioClipManager.soundpool = null;
				}
			}}}
		}
		clips = null;
	}
}
