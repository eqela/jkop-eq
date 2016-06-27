
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

public class AlsaAudioPlayer
{
	class AudioPlayerRunnableThread : Runnable
	{
		embed "c" {{{
			#include <alsa/asoundlib.h>
			#include <stdio.h>
			#include <stdlib.h>
			#include <sndfile.h>
			#define PCM_DEVICE "default"
		}}}

		Mutex mutex;
		bool is_loop = false;
		ptr pcm_handle;
		ptr params;
		int duration;
		int num_rate;
		String filename;

		public AudioPlayerRunnableThread() {
			mutex = Mutex.create();
		}

		public AudioPlayerRunnableThread set_is_loop(bool v) {
			mutex.lock(); {
				this.is_loop = v;
			}
			mutex.unlock();
			return(this);
		}

		public AudioPlayerRunnableThread initialize(File audio) {
			if(audio.is_file()) {
				filename = audio.get_native_path();
				if(String.is_empty(filename)) {
					return(null);
				}
			}
			var cstr = filename.to_strptr();
			int duration;
			int num_rate;
			embed "c" {{{
				SNDFILE *sf;
				SF_INFO info;
				int no_of_frames;
				info.format = 0;
				sf = sf_open(cstr, SFM_READ, &info);
				if(sf == NULL) {
					}}} Log.error("Failed to read file"); embed "c" {{{
				}
				no_of_frames = info.frames;
				num_rate = info.samplerate;
				duration = ((float)no_of_frames / num_rate);
				sf_close(sf);
			}}}
			this.duration = duration;
			this.num_rate = num_rate;
			return(this);
		}

		public void run() {
			if(String.is_empty(filename)) {
				return;
			}
			var cstr = filename.to_strptr();
			ptr pcm_handle;
			ptr params;
			var now = SystemClock.timeval();
			embed "c" {{{
				unsigned int pcm, tmp, forward;
				snd_pcm_uframes_t frames;
				char *buff;
				int buff_size;
				SNDFILE *sf;
				SF_INFO info;
				int num, num_items, format;
				int no_of_frames, rate, channels;
				info.format = 0;
				sf = sf_open(cstr, SFM_READ, &info);
				if(sf == NULL) {
					}}} Log.error("Failed to open the file."); embed "c" {{{
				}
				no_of_frames = info.frames;
				rate = info.samplerate;
				channels = info.channels;
				num_items = no_of_frames * channels;
				format = info.format;
				sf_close(sf);
				if(pcm = snd_pcm_open((snd_pcm_t**)&pcm_handle, PCM_DEVICE, SND_PCM_STREAM_PLAYBACK, 0) < 0) {
					}}} Log.error("Failed to open PCM device"); embed "c" {{{
				}
				snd_pcm_hw_params_alloca((snd_pcm_hw_params_t**)&params);
				snd_pcm_hw_params_any((snd_pcm_t*)pcm_handle, (snd_pcm_hw_params_t*)params);
				if(pcm = snd_pcm_hw_params_set_access((snd_pcm_t*)pcm_handle, (snd_pcm_hw_params_t*)params, SND_PCM_ACCESS_RW_INTERLEAVED) < 0) {
					}}} Log.error("Failed to set audio device in interleaved mode.");
					return; embed "c" {{{
				}
				if(pcm = snd_pcm_hw_params_set_format((snd_pcm_t*)pcm_handle, (snd_pcm_hw_params_t*)params, SND_PCM_FORMAT_S16_LE) < 0) {
					}}} Log.error("Failed to set audio format");
					return; embed "c" {{{
				}
				if(pcm = snd_pcm_hw_params_set_channels((snd_pcm_t*)pcm_handle, (snd_pcm_hw_params_t*)params, channels) < 0) {
					}}} Log.error("Failed to set channel number");
					return; embed "c" {{{
			 	}
				if(pcm = snd_pcm_hw_params_set_rate_near((snd_pcm_t*)pcm_handle, (snd_pcm_hw_params_t*)params, &rate, 0) < 0) {
					}}} Log.error("Failed to set audio sampling rate");
					return; embed "c" {{{
				}
				if(pcm = snd_pcm_hw_params((snd_pcm_t*)pcm_handle, (snd_pcm_hw_params_t*)params) < 0) {
					}}} Log.error("Failed to set audio playback hardware parameters");
					return; embed "c" {{{
				}
				snd_pcm_hw_params_get_channels((snd_pcm_hw_params_t*)params, &tmp);
				snd_pcm_hw_params_get_rate((snd_pcm_hw_params_t*)params, &tmp, 0);
				snd_pcm_hw_params_get_period_size((snd_pcm_hw_params_t*)params, &frames, 0);
				buff_size = frames * channels * 2;
				buff = (char*)malloc(buff_size);
				}}}
				this.pcm_handle = pcm_handle;
				this.params = params;
				embed "c" {{{
				if(format == 65538) {
					int fd = open(cstr, O_RDONLY);
					while(1) {
						if(pcm = read(fd, buff, buff_size) == 0) {
							break;
						}
						if(pcm = snd_pcm_writei((snd_pcm_t*)pcm_handle, buff, frames) == -EPIPE) {
							}}} Log.error("XRUN error occurred!"); embed "c" {{{
							snd_pcm_prepare(pcm_handle);
						}
						else if(pcm == -32) {
							int errb;
							errb = snd_pcm_recover((snd_pcm_t*)pcm_handle, pcm, 0);
							if(errb < 0) {
								}}} Log.debug("Failed to recover from XRUN!"); embed "c" {{{
							}
							else {
								}}} Log.debug("Recovered from XRUN!"); embed "c" {{{
							}
						}
						else if(pcm < 0) {
							}}} Log.error("ERROR. Can't write to PCM device"); embed "c" {{{
						}
					}
				}
				else {
					}}} Log.debug("Invalid audio format");
					return; embed "c" {{{
				}
				snd_pcm_drain((snd_pcm_t*)pcm_handle);
				snd_pcm_close((snd_pcm_t*)pcm_handle);
				free(buff);
			}}}
			if(is_loop) {
				run();
			}
		}

		public void audio_stop() {
			is_loop = false;
			ptr pcm_handle = this.pcm_handle;
			embed "c" {{{
				int pcm;
				if(pcm_handle != NULL) {
					snd_pcm_drop((snd_pcm_t*)pcm_handle);
				}
			}}}
		}

		public void audio_pause() {
			ptr params = this.params;
			ptr pcm_handle = this.pcm_handle;
			embed "c" {{{
				int pcm;
				if(pcm = snd_pcm_hw_params_can_pause((snd_pcm_hw_params_t*)params) == 1) {
					}}} Log.debug("Hardware support pause"); embed {{{
					snd_pcm_pause((snd_pcm_t*)pcm_handle, 1);
				}
				else {
					}}} Log.debug("Hardware does not support pause"); embed {{{
				}
			}}}
		}

		public void audio_resume() {
			ptr pcm_handle = this.pcm_handle;
			ptr params = this.params;
			embed "c" {{{
				int pcm;
				if(pcm = snd_pcm_hw_params_can_resume((snd_pcm_hw_params_t*)params) == 0) {
					}}} Log.debug("Hardware support resume"); embed {{{
					snd_pcm_pause((snd_pcm_t*)pcm_handle, 0);
				}
				else {
					}}} Log.debug("Hardware does not support resume"); embed {{{
				}
			}}}
		}

		public int audio_duration() {
			return(duration);
		}
	}

	AudioPlayerRunnableThread player;
	File file;

	public AlsaAudioPlayer initialize(File f) {
		if(f != null) {
			file = f;
		}
		player = new AudioPlayerRunnableThread().initialize(file);
		return(this);
	}

	public bool play() {
		if(player != null) {
			Thread.start(player);
		}
		return(true);
	}

	public bool stop() {
		player.audio_stop();
		return(true);
	}

	public bool pause() {
		player.audio_pause();
		return(true);
	}

	public bool resume() {
		player.audio_resume();
		return(true);
	}

	public bool seek(int sec) {
		return(false);
	}

	public int get_current_time() {
		return(0);
	}

	public int get_duration() {
		return(player.audio_duration());
	}

	public bool set_loops(bool v) {
		if(v) {
			if(player != null) {
				player.set_is_loop(v);
			}
			return(true);
		}
		return(false);
	}

	public bool set_volume(double v) {
		return(false);
	}
}
