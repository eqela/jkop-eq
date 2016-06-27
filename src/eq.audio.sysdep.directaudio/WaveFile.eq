
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

public class WaveFile
{
	embed {{{
		#include <stdio.h>
	}}}

	public static WaveFile for_file(File path) {
		var v = new WaveFile();
		if(path.is_file() && path.has_extension("wav")) {
			if(v.initialize(path) == false) {
				return(null);
			}
		}
		return(v);
	}

	public int audio_format;
	public int chunk_size;
	public int sample_rate;
	public int num_channels;
	public int bytes_per_second;
	public int block_align;
	public int bits_per_sample;
	public Buffer data;

	public bool initialize(File f) {
		var strpath = f.get_native_path();
		if(String.is_empty(strpath)) {
			return(false);
		}
		var pp = strpath.to_strptr();
		embed {{{
			struct WaveHeaderType
			{
				char chunkId[4];
				unsigned long chunkSize;
				char format[4];
				char subChunkId[4];
				unsigned long subChunk1Size;
				unsigned short audioFormat;
				unsigned short numChannels;
				unsigned long sampleRate;
				unsigned long bytesPerSecond;
				unsigned short blockAlign;
				unsigned short bitsPerSample;
				char dataChunkId[4];
				unsigned long dataSize;
			};
			FILE* filePtr;
			WaveHeaderType waveFileHeader;
			// Open the wave file in binary.
			filePtr = fopen(pp, "rb");
			if(filePtr == NULL) {
				}}} return(false); embed {{{
			}
			// Read in the wave file header.
			int count = fread(&waveFileHeader, sizeof(waveFileHeader), 1, filePtr);
			if(count != 1) {
				}}} Log.error("Invalid WAVE file."); return(false); embed {{{
			}
			// Check that the chunk ID is the RIFF format.
			if((waveFileHeader.chunkId[0] != 'R') || (waveFileHeader.chunkId[1] != 'I') || 
			   (waveFileHeader.chunkId[2] != 'F') || (waveFileHeader.chunkId[3] != 'F')) {
				}}} Log.error("Invalid WAVE file. (1)"); return(false); embed {{{
			}
			// Check that the file format is the WAVE format.
			if((waveFileHeader.format[0] != 'W') || (waveFileHeader.format[1] != 'A') ||
			   (waveFileHeader.format[2] != 'V') || (waveFileHeader.format[3] != 'E')) {
				}}} Log.error("Invalid WAVE file. (2)"); return(false); embed {{{
			}
			// Check that the sub chunk ID is the fmt format.
			if((waveFileHeader.subChunkId[0] != 'f') || (waveFileHeader.subChunkId[1] != 'm') ||
			   (waveFileHeader.subChunkId[2] != 't') || (waveFileHeader.subChunkId[3] != ' ')) {
				}}} Log.error("Invalid WAVE file. (3)"); return(false); embed {{{
			}
			// Check for the data chunk header.
			if((waveFileHeader.dataChunkId[0] != 'd') || (waveFileHeader.dataChunkId[1] != 'a') ||
			   (waveFileHeader.dataChunkId[2] != 't') || (waveFileHeader.dataChunkId[3] != 'a')) {
				// Move to the beginning of the wave data which starts at the end of the data chunk header.
				fseek(filePtr, sizeof(WaveHeaderType)-8, SEEK_SET);
				int flag = 0;
				char ch = fgetc(filePtr);
				while(1) {
					if(feof(filePtr)) {
						break;
					}
					if(ch == 'd') {
						ch = fgetc(filePtr);
						if(ch == 'a') {
							ch = fgetc(filePtr);
							if(ch == 't') {
								ch = fgetc(filePtr);
								if(ch == 'a') {
									flag = 1;
									break;
								}
							}
						}
					}
					else {
						ch = fgetc(filePtr);
					}
					
				}
				if(flag == 0) {
					}}} Log.error("Invalid WAVE file. (4)"); return(false); embed {{{
				}
				unsigned long cbSize;
				fread(&cbSize, 4, 4, filePtr);
				waveFileHeader.dataSize = cbSize - 12;
			}
			else {
				// Move to the beginning of the wave data which starts at the end of the data chunk header.
				fseek(filePtr, sizeof(WaveHeaderType), SEEK_SET);

			}
		}}}
		int size, nc, af, sr, bps, bips, ba;
		embed {{{
			size = waveFileHeader.dataSize;
			af = waveFileHeader.audioFormat;
			nc = waveFileHeader.numChannels;
			sr = waveFileHeader.sampleRate;
			bps = waveFileHeader.bytesPerSecond;
			bips = waveFileHeader.bitsPerSample;
			ba = waveFileHeader.blockAlign;
		}}}
		data = DynamicBuffer.create(size);
		if(data == null) {
			return(false);
		}
		num_channels = nc;
		audio_format = af;
		sample_rate = sr;
		bytes_per_second = bps;
		bits_per_sample = bips;
		block_align = ba;
		ptr waveData = data.get_pointer().get_native_pointer();
		int cnt;
		embed {{{
			// Read in the wave file data into the newly created buffer.
			cnt = count = fread(waveData, 1, size, filePtr);
			if(count != size) {
				}}} Log.error("Unknown error loading WAV file.".printf().add(cnt).add(size)); return(false); embed {{{
			}
			// Close the file once done reading.
			int error = fclose(filePtr);
			if(error != 0) {
				}}} return(false); embed {{{
			}
		}}}
		String channel;
		if(nc == 1) {
			channel = "Mono";
		}
		else if(nc == 2) {
			channel = "Stereo";
		}
		Log.debug("Wave file loaded: `%s' (%d-bit %s, %d bit/s)".printf().add(strpath).add(bips).add(channel).add(sr));
		return(true);
	}
}
