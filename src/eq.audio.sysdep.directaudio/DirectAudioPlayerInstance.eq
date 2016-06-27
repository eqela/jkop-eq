
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

public class DirectAudioPlayerInstance
{
	embed "c" {{{
		#include <dsound.h>
	}}}

	static int ACTION_PLAY = 1;
	static int ACTION_PAUSE = 2;
	static int ACTION_STOP = 3;
	static int ACTION_VOLUME = 4;
	static int ACTION_LOOP = 5;
	static int ACTION_SEEK = 6;

	property ptr soundbuf;

	~DirectAudioPlayerInstance() {
		safe_release();
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

	public bool is_playing() {
		var sb = soundbuf;
		if(sb != null) {
			embed {{{
				DWORD stat;
				((IDirectSoundBuffer8*)sb)->GetStatus(&stat);
				return(stat & DSBSTATUS_PLAYING != 0);
			}}}
		}
		return(false);
	}

	public void safe_release() {
		var sb = soundbuf;
		if(sb!=null) {
			embed {{{
				((IDirectSoundBuffer8*)sb)->Release();
			}}}
		}
		soundbuf = null;
	}

	public virtual bool playback(int action, Object obj = null) {
		if(soundbuf == null || action == 0) {
			return(false);
		}
		ptr sb = soundbuf;
		embed {{{
			IDirectSoundBuffer8* m_secondaryBuffer1 = ((IDirectSoundBuffer8*)sb);
			HRESULT result;
		}}}
		if(action == ACTION_PLAY) {
			embed {{{
				result = m_secondaryBuffer1->Play(0, 0, 0);
			}}}
		}
		else if(action == ACTION_STOP) {
			embed {{{
				result = m_secondaryBuffer1->Stop();
				if(SUCCEEDED(result)) {
					result = m_secondaryBuffer1->SetCurrentPosition(0);
				}
			}}}
		}
		else if(action == ACTION_PAUSE) {
			embed {{{
				result = m_secondaryBuffer1->Stop();
			}}}
		}
		if(action == ACTION_LOOP) {
			var obj_boolean =  obj as Boolean;
			if(obj_boolean != null) {
				bool v = obj_boolean.to_boolean();
				if(v) {
					embed {{{
						result = m_secondaryBuffer1->Play(0, 0, DSBPLAY_LOOPING);
					}}}
				}
				else {
					embed {{{
						result = m_secondaryBuffer1->Play(0, 0, 0);
					}}}
				}
			}
		}
		if(action == ACTION_VOLUME) {
			//FIXME
		}
		if(action == ACTION_SEEK) {
			//FIXME
		}
		embed {{{
			if(FAILED(result)){
				}}} return(false); embed {{{
			}
		}}}
		return(true);
	}

	public int get_duration() {
		Log.error("FIXME: Implement DirectAudioPlayer.get_duration()");
		return(0);
	}

	public int get_current_time() {
		Log.error("FIXME: Implement DirectAudioPlayer.get_current_time()");
		return(0);
	}
}
