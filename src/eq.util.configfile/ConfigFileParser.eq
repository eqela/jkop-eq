
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

public class ConfigFileParser
{
	public static bool parse(File file, ConfigFileParserListener listener, Logger logger = null) {
		if(file == null || listener == null) {
			return(false);
		}
		String block;
		int linen = 0;
		var ins = InputStream.create(file.read());
		if(ins == null) {
			return(false);
		}
		String line;
		while((line = ins.readline()) != null) {
			linen++;
			line = line.strip();
			if(String.is_empty(line) || line.has_prefix("#")) {
				continue;
			}
			if(line.has_suffix("{")) {
				if(block != null) {
					Log.error("%s:%d: Duplicate block: `%s'".printf().add(file).add(linen).add(line), logger);
					return(false);
				}
				block = line.substring(0, line.get_length()-1);
				if(block != null) {
					block = block.strip();
				}
				continue;
			}
			if("}".equals(line)) {
				if(block == null) {
					Log.error("%s:%d: Closing a non-opened block".printf().add(file).add(linen), logger);
					return(false);
				}
				block = null;
				continue;
			}
			var sp = StringSplitter.split(line, (int)':', 2);
			if(sp == null) {
				continue;
			}
			var key = sp.next() as String;
			var val = sp.next() as String;
			if(key != null) {
				key = key.strip();
			}
			if(val != null) {
				val = val.strip();
			}
			if(val != null && val.has_prefix("\"") && val.has_suffix("\"")) {
				val = val.substring(1, val.get_length()-2);
			}
			if(String.is_empty(key)) {
				continue;
			}
			listener.on_config_file_entry(block, key, val);
		}
		return(true);
	}
}
