
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

public class J2SESound
{
	embed {{{
		javax.sound.sampled.Clip sound_clip;
	}}}

	embed {{{
		public javax.sound.sampled.Clip get_sound_clip() {
			return(sound_clip);
		}
	
		static javax.sound.sampled.AudioInputStream get_stream_by_id(java.lang.String id, java.lang.String ext) {
			java.io.InputStream ins = J2SESound.class.getResourceAsStream("/" + id + "." + ext);
			if(ins == null) {
				return(null);
			}
			javax.sound.sampled.AudioInputStream ais = null;
			try {
				ais = javax.sound.sampled.AudioSystem.getAudioInputStream(new java.io.BufferedInputStream(ins));
			}
			catch(java.lang.Exception e) {
				System.out.println("Failed to initialize audio resource stream: " + e);
				return(null);
			}
			return(ais);
		}

		static javax.sound.sampled.AudioInputStream get_stream_by_file(eq.os.File file) {
			eq.api.String str = file.get_native_path();
			if(str == null || str.get_length() < 1) {
				return(null);
			}
			javax.sound.sampled.AudioInputStream ais = null;
			try {
				ais = javax.sound.sampled.AudioSystem.getAudioInputStream(new java.io.File(str.to_strptr()));
			}
			catch(java.lang.Exception e) {
				System.out.println("Failed to initialize audio resource stream: " + e);
				return(null);
			}
			return(ais);
		}

		boolean initialize(javax.sound.sampled.AudioInputStream stream) {
			if(stream == null) {
				return(false);
			}
			try {
				sound_clip = javax.sound.sampled.AudioSystem.getClip();
			}
			catch(java.lang.Exception e) {
				System.out.println("Failed to initialize audio file (2): " + e);
				return(false);
			}
			try {
				sound_clip.open(stream);
			}
			catch(java.lang.Exception e) {
				System.out.println("Failed to initialize audio file (3): " + e);
				return(false);
			}
			return(true);
		}
	}}}

	public static J2SESound load_by_id(String id) {
		if(String.is_empty(id)) {
			return(null);
		}
		var v = new J2SESound();
		embed {{{
			if(v.initialize(get_stream_by_id(id.to_strptr(), "wav")) == false) {
				return(null);
			}
		}}}
		return(v);
	}

	public static J2SESound load_by_file(File file) {
		if(file == null || file.is_file() == false) {
			return(null);
		}
		var v = new J2SESound();
		embed {{{
			if(v.initialize(get_stream_by_file(file)) == false) {
				return(null);
			}
		}}}
		return(v);
	}
}
