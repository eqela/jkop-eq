
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

public class DirectAudioEngine
{
	embed "c" {{{
		#include <windows.h>
		#include <mmsystem.h>
		#include <stdio.h>
		#include <dsound.h>
		#define IDIRECTSOUND8 {0x6825A449,0x7524,0x4D82,{0x92,0x0F,0x50,0xE3,0x6A,0xB3,0xAB,0x1E}}
	}}}

	ptr directsound = null;
	WaveFile wave;

	public static DirectAudioEngine load_file(File file) {
		var v = new DirectAudioEngine();
		if(v.initialize(file) == false) {
			v = null;
		}
		return(v);
	}

	public bool initialize(File file) {
		if(file == null || (file != null && file.exists() == false)) {
			Log.error("DirectAudioEngine failed to load: `%s' was not found.".printf().add(file));
			return(false);
		}
		wave = WaveFile.for_file(file);
		if(wave == null) {
			Log.error("Failed to load WAV file");
			return(false);
		}
		int sample_rate = wave.sample_rate;
		int bits_per_sample = wave.bits_per_sample;
		int num_channels = wave.num_channels;
		var wavebuffer = wave.data;
		if(wavebuffer == null) {
			return(false);
		}
		ptr ds = DirectSoundFactory.get_instance();
		if(ds == null) {
			return(false);
		}
		directsound = ds;
		return(true);
	}

	public DirectAudioPlayer create_player() {
		var ds = directsound;
		int sample_rate = wave.sample_rate;
		int bits_per_sample = wave.bits_per_sample;
		int num_channels = wave.num_channels;
		int audio_format = wave.audio_format;
		int block_align = wave.block_align;
		int bytes_per_second = wave.bytes_per_second;
		int size;
		if(ds != null && wave.data != null) {
			ptr dsb = null;
			size = wave.data.get_size();
			ptr waveData = wave.data.get_pointer().get_native_pointer();
			embed {{{
				HWND hwnd = GetActiveWindow();
				if(hwnd == NULL) {
					}}} return(null); embed {{{
				}
				((IDirectSound8*)ds)->SetCooperativeLevel(hwnd, DSSCL_PRIORITY);
				WAVEFORMATEX waveFormat;
				waveFormat.wFormatTag = audio_format;
				waveFormat.nSamplesPerSec = sample_rate;
				waveFormat.wBitsPerSample = bits_per_sample;
				waveFormat.nChannels = num_channels;
				waveFormat.nBlockAlign = block_align;
				waveFormat.nAvgBytesPerSec = bytes_per_second;
				waveFormat.cbSize = 0;
				DSBUFFERDESC bufferdsc;
				bufferdsc.dwSize = sizeof(DSBUFFERDESC);
				bufferdsc.dwFlags = DSBCAPS_CTRLVOLUME | DSBCAPS_GLOBALFOCUS;
				bufferdsc.dwBufferBytes = size;
				bufferdsc.dwReserved = 0;
				bufferdsc.lpwfxFormat = &waveFormat;
				IDirectSoundBuffer* tmp;
				HRESULT result = ((IDirectSound8*)ds)->CreateSoundBuffer(&bufferdsc, &tmp, NULL);
				if(FAILED(result)) {
					}}} return(null); embed {{{
				}
				result = tmp->QueryInterface(IDIRECTSOUND8, &dsb);
				if(FAILED(result)) {
					}}} return(null); embed {{{
				}
				tmp->Release();
				tmp = NULL;
				unsigned char *bufferPtr;
				int sz;
				result = ((IDirectSoundBuffer8*)dsb)->Lock(0,size,(void**)&bufferPtr,(DWORD*)&sz, NULL, 0, 0);
				if(FAILED(result)) {
					}}} return(null); embed {{{
				}
				memcpy(bufferPtr, waveData, sz);
				result = ((IDirectSoundBuffer8*)dsb)->Unlock((void*)bufferPtr, sz, NULL, 0);
				if(FAILED(result)) {
					}}} return(null); embed {{{
				}
			}}}
			if(dsb != null) {
				var v = new DirectAudioPlayer();
				v.set_soundbuf(dsb);
				v.set_seconds(get_seconds());
				v.set_bitrate(get_bitrate());
				return(v);
			}
		}
		return(null);
	}

	public int get_seconds() {
		if(wave == null) {
			return(0);
		}
		int bitrate = get_bitrate();
		return(wave.data.get_size() / bitrate);
	}

	public int get_bitrate() {
		if(wave == null) {
			return(0);
		}
		int bitrate = wave.bytes_per_second;
		if(bitrate < 1) {
			int bips = wave.bits_per_sample, sr = wave.sample_rate, nc = wave.num_channels;
			bitrate = (sr * ((bips / 8))) / nc;
		}
		return(bitrate);
	}
}
