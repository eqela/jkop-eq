
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

class HTML5AudioClip : AudioClip
{
	String id;

	public AudioClip initialize(String id) {
		this.id = id;
		return(this);
	}

	public bool play() {
		var fn = "%s".printf().add(id).to_string();
		var fnp = fn.to_strptr();
		ptr audio_element;
		bool r = false;
		embed {{{
 			audio_element = document.createElement('audio');
			audio_element.setAttribute("preload", "auto");
			var src_mp3 = document.createElement('source');
			src_mp3.type = 'audio/mpeg';
			src_mp3.src = fnp + '.mp3';
			audio_element.appendChild(src_mp3);
			var src_ogg = document.createElement('source');
			src_ogg.type = 'audio/ogg';
			src_ogg.src = fnp + '.ogg';
			audio_element.appendChild(src_ogg);
			var src_m4a = document.createElement('source');
			src_m4a.type = 'audio/mp4';
			src_m4a.src = fnp + '.m4a';
			audio_element.appendChild(src_m4a);
			var src_wav = document.createElement('source');
			src_wav.type = 'audio/wav';
			src_wav.src = fnp + '.wav';
			audio_element.appendChild(src_wav);
			document.body.appendChild(audio_element);
			audio_element.load();
			try {
				audio_element.play();
				audio_element.addEventListener('ended', function() {
					audio_element.parentNode.removeChild(audio_element);
					audio_element = null;
				});
				r = true;
			}
			catch(e) {}
		}}}
		return(r);
	}
}

class HTML5AudioClipManager : AudioClipManagerBackend
{
	public AudioClip create(String id) {
		return(new HTML5AudioClip().initialize(id));
	}
}
