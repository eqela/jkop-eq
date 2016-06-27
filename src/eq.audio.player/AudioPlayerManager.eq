
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

public class AudioPlayerManager
{
	static AudioPlayerManagerBackend backend;
	static HashTable clips;

	static void initialize() {
		if(backend == null) {
			IFDEF("target_osx") {
				backend = new OSXAudioPlayerManager();
			}
			ELSE IFDEF("target_ios") {
				backend = new IOSAudioPlayerManager();
			}
			ELSE IFDEF("target_android") {
				backend = new AndroidAudioPlayerManager();
			}
			ELSE IFDEF("target_win32") {
				backend = new Win32AudioPlayerManager();
			}
			ELSE IFDEF("target_wp8cs") {
				backend = new WPCSAudioPlayerManager();
			}
			ELSE IFDEF("target_html") {
				backend = new HTML5AudioPlayerManager();
			}
			ELSE IFDEF("target_linux") {
				backend = new LinuxAudioPlayerManager();
			}
			ELSE IFDEF("target_uwpcs") {
				backend = new XamlAudioPlayerManagerBackend();
			}
			ELSE IFDEF("target_j2se") {
				backend = new J2SEAudioPlayerManagerBackend();
			}
		}
	}

	public static void prepare(String id) {
		get(id);
	}

	public static void prepare_file(File f, String id = null) {
		if(f == null) {
			return;
		}
		var xid = id;
		if(String.is_empty(xid)) {
			xid = Path.strip_extension(f.basename());
		}
		if(String.is_empty(xid)) {
			return;
		}
		initialize();
		if(backend == null) {
			return;
		}
		var clip = backend.create_for_file(f);
		if(clip == null) {
			return;
		}
		if(clips == null) {
			clips = HashTable.create();
		}
		if(clips != null) {
			clips.set(xid, clip);
		}
	}

	public static AudioPlayer get(String id) {
		AudioPlayer v;
		if(clips != null) {
			v = clips.get(id) as AudioPlayer;
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

	public static void set_volume(double v) {
		if(clips == null) {
			return;
		}
		foreach(AudioPlayer player in clips.iterate_values()) {
			player.set_volume(v);
		}
	}

	public static bool play(String id) {
		var clip = get(id);
		if(clip == null) {
			return(false);
		}
		return(clip.play());
	}

	public static bool pause(String id) {
		var clip = get(id);
		if(clip == null) {
			return(false);
		}
		return(clip.pause());
	}

	public static bool stop(String id) {
		var clip = get(id);
		if(clip == null) {
			return(false);
		}
		return(clip.stop());
	}

	public static bool seek(String id, int sec) {
		var clip = get(id);
		if(clip == null) {
			return(false);
		}
		return(clip.seek(sec));
	}

	public static void clear() {
		clips = null;
	}
}

