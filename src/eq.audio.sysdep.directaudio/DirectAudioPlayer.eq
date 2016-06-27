
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

public class DirectAudioPlayer
{
	embed "c" {{{
		#include <dsound.h>
	}}}
	public static int ACTION_PLAY = 1;
	public static int ACTION_PAUSE = 2;
	public static int ACTION_STOP = 3;
	public static int ACTION_VOLUME = 4;
	public static int ACTION_LOOP = 5;
	public static int ACTION_SEEK = 6;

	property ptr soundbuf;
	property double bitrate;
	property int seconds;
	int play_opt;

	~DirectAudioPlayer() {
		safe_release();
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

	public bool playback(int action, Object obj = null) {
		if(soundbuf == null || action == 0) {
			return(false);
		}
		ptr sb = soundbuf;
		embed {{{
			IDirectSoundBuffer8* m_secondaryBuffer1 = ((IDirectSoundBuffer8*)sb);
			HRESULT result;
		}}}
		if(action == ACTION_PLAY) {
			int opt = play_opt;
			embed {{{
				result = m_secondaryBuffer1->Play(0, 0, opt);
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
			bool v = Boolean.as_boolean(obj);
			int opt = 0;
			if(v) {
				embed {{{
					opt = DSBPLAY_LOOPING;
				}}}
			}
			play_opt = opt;
		}
		if(action == ACTION_VOLUME) {
			double v = Double.as_double(obj);
			embed {{{
				LONG min = DSBVOLUME_MIN, max = DSBVOLUME_MAX;
				LONG volume = (LONG)((max - min) * v);
				result = m_secondaryBuffer1->SetVolume(volume);
			}}}
		}
		if(action == ACTION_SEEK) {
			int val = Integer.as_integer(obj) * bitrate;
			embed {{{
				result = ((IDirectSoundBuffer*)sb)->SetCurrentPosition(val);
			}}}
		}
		embed {{{
			if(FAILED(result)){
				}}} return(false); embed {{{
			}
		}}}
		return(true);
	}

	public int get_duration() {
		return(seconds);
	}

	public int get_current_time() {
		if(soundbuf == null) {
			return(0);
		}
		var sb = soundbuf;
		int pos;
		embed {{{
			((IDirectSoundBuffer*)sb)->GetCurrentPosition(&pos, NULL);
		}}}
		return(pos / bitrate);
	}
}
