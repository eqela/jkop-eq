
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

class AudioRecorderImpl : AudioRecorder
{
	class AudioRecorderThread : Runnable
	{
		embed {{{
			android.media.AudioRecord audiorecorder;
			java.io.DataOutputStream dos;
			java.io.FileOutputStream fo;
			java.io.File tmpfile;
			java.io.File outputfile;
			boolean isRecording = false;
			boolean isResumable = false;
			boolean stop_recording = false;
			int total_size = 0;

			public AudioRecorderThread(android.media.AudioRecord ar, java.io.File file) {
				audiorecorder = ar;
				outputfile = file;
			}
		}}}

		public void run() {
			embed "java" {{{
				try {
					if(isResumable == false) {
						tmpfile = java.io.File.createTempFile("tmpwavefile", ".pcm", tmpfile);
						audiorecorder.startRecording();
						fo = new java.io.FileOutputStream(tmpfile);
						dos = new java.io.DataOutputStream(fo);
					}				
					isRecording = true;
					isResumable = false;
					int bufferSize = android.media.AudioRecord.getMinBufferSize(44100,
						android.media.AudioFormat.CHANNEL_IN_MONO,
						android.media.AudioFormat.ENCODING_PCM_16BIT);
					byte buffer[] = new byte[bufferSize];
					while(isRecording) {
						int bufferReadResult = audiorecorder.read(buffer, 0, buffer.length);
						if(bufferReadResult < 0) {
							break;
						}
						try {
							dos.write(buffer, 0, bufferReadResult);
						} catch(java.io.IOException e) {
						}
						total_size += bufferReadResult;
					}
					if(stop_recording) {
						dos.flush();
						dos.close();
						fo.close();
						audiorecorder.stop();
						on_recording_has_stopped();
					}
				} catch(java.lang.Throwable t) {
				}
			}}}
		}

		public void resume() {
			embed {{{
				if(isRecording) {
					return;
				}
				isRecording = true;
			}}}
			Thread.start(this);
		}

		public void pause() {
			embed {{{
				isResumable = true;
				isRecording = false;
			}}}
		}

		public void stop() {
			embed {{{
				isRecording = false;
				stop_recording = true;
				if(isResumable) {
					on_recording_has_stopped();
				}
				isResumable = false;
			}}}

		}

		public bool on_recording_has_stopped() {
			embed {{{
				long totalaudiolength = total_size;
				long totaldatalength = totalaudiolength + 36;
				long samplerate = 44100;
				int channels = 1;
				long byteRate = 16 * 44100 * channels / 8;
				try {
					dos.flush();
					dos.close();
					fo.close();
					audiorecorder.stop();
					java.io.FileOutputStream output = new java.io.FileOutputStream(outputfile);
					java.io.FileInputStream input = new java.io.FileInputStream(tmpfile);     
					byte[] data = new byte[1024];
					write_headers_to_file(output, totalaudiolength, totaldatalength, samplerate, channels, byteRate);
					int length;
					while((length = input.read(data)) != -1) {
						output.write(data, 0, length);
					}
					input.close();
					output.close();
				} catch(java.io.IOException e) {
				}
			}}}
			return(true);
		}

		embed {{{
			private void write_headers_to_file(java.io.FileOutputStream out, long audio_length, long data_length, long sample_rate, int channels, long byteRate) throws java.io.IOException {
				byte[] header = new byte[44];
				header[0] = 'R';
				header[1] = 'I';
				header[2] = 'F';
				header[3] = 'F';
				header[4] = (byte)(data_length & 0xff);
				header[5] = (byte)((data_length >> 8) & 0xff);
				header[6] = (byte)((data_length >> 16) & 0xff);
				header[7] = (byte)((data_length >> 24) & 0xff);
				header[8] = 'W';
				header[9] = 'A';
				header[10] = 'V';
				header[11] = 'E';
				header[12] = 'f';
				header[13] = 'm';
				header[14] = 't';
				header[15] = ' ';
				header[16] = 16;
				header[17] = 0;
				header[18] = 0;
				header[19] = 0;
				header[20] = 1;
				header[21] = 0;
				header[22] = (byte)channels;
				header[23] = 0;
				header[24] = (byte)(sample_rate & 0xff);
				header[25] = (byte)((sample_rate >> 8) & 0xff);
				header[26] = (byte)((sample_rate >> 16) & 0xff);
				header[27] = (byte)((sample_rate >> 24) & 0xff);
				header[28] = (byte)(byteRate & 0xff);
				header[29] = (byte)((byteRate >> 8) & 0xff);
				header[30] = (byte)((byteRate >> 16) & 0xff);
				header[31] = (byte)((byteRate >> 24) & 0xff);
				header[32] = (byte)(1 * 16 / 8);
				header[33] = 0;
				header[34] = 16;
				header[35] = 0;
				header[36] = 'd';
				header[37] = 'a';
				header[38] = 't';
				header[39] = 'a';
				header[40] = (byte)(audio_length & 0xff);
				header[41] = (byte)((audio_length >> 8) & 0xff);
				header[42] = (byte)((audio_length >> 16) & 0xff);
				header[43] = (byte)((audio_length >> 24) & 0xff);
				out.write(header, 0, 44);
			}
		}}}
	}

	embed {{{
		android.media.AudioRecord audiorecorder;
		java.io.File outputfile;
	}}}

	AudioRecorderThread myrecorderthread;
	EventReceiver listener;
	File file;

	public static AudioRecorder create(File file, EventReceiver listener) {
		var audiorecorder = new AudioRecorderImpl();
		audiorecorder.file = file;
		audiorecorder.listener = listener;
		return(audiorecorder.initialize());
	}

	public AudioRecorder initialize() {
		if(file.exists()) {
			return(null);
		}
		String path = file.get_native_path();
		if(prepare_recorder(path) == false) {
			return(null);
		}
		return(this);
	}

	public bool prepare_recorder(String path) {
		embed {{{
			outputfile = new java.io.File(path.to_strptr());
			int bufferSize = android.media.AudioRecord.getMinBufferSize(44100, android.media.AudioFormat.CHANNEL_IN_MONO, android.media.AudioFormat.ENCODING_PCM_16BIT);
			try {
				audiorecorder = new android.media.AudioRecord(android.media.MediaRecorder.AudioSource.MIC,
					44100,
					android.media.AudioFormat.CHANNEL_IN_MONO,
					android.media.AudioFormat.ENCODING_PCM_16BIT,
					bufferSize);
			} catch(java.lang.Throwable e) {
				return(false);
			}
		}}}
		return(true);
	}

	public void record() {
		embed {{{
			myrecorderthread = new AudioRecorderThread(audiorecorder, outputfile);
		}}}
		Thread.start(myrecorderthread);
	}

	public void pause() {
		embed {{{
			myrecorderthread.pause();
		}}}
	}

	public void resume() {
		embed {{{
			myrecorderthread.resume();
		}}}
	}

	public void stop() {
		myrecorderthread.stop();
		if(file.is_file()) {
			var result = new AudioRecorderResult();
			result.set_file(file);
			EventReceiver.event(listener, result);
		}
	}
}
