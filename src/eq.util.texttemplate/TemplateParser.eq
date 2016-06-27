
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

public class TemplateParser
{
	static bool handle_include_tag(Collection words, File filedir, Collection include_dirs, String marker_begin, String marker_end, Collection v) {
		if(words == null || v == null) {
			Log.error("TemplateParser / handle_include_tag: Incomplete parameters");
			return(false);
		}
		var file = words.get(1) as String;
		if(file == null) {
			Log.error("TemplateParser / handle_include_tag: No file was given");
			return(false);
		}
		File ff;
		if(Path.is_absolute_path(file)) {
			ff = File.for_native_path(file);
		}
		else {
			var x = File.for_eqela_path(file, filedir);
			if(x.is_file()) {
				ff = x;
			}
			if(ff == null && include_dirs != null) {
				foreach(File f in include_dirs) {
					var x2 = File.for_eqela_path(file, f);
					if(x2.is_file()) {
						ff = x2;
						break;
					}
				}
			}
		}
		if(ff == null || ff.is_file() == false) {
			Log.error("TemplateParser / handle_include_tag: Include file `%s' was not found".printf().add(file));
			return(false);
		}
		var cc = ff.get_contents_string();
		if(cc == null) {
			Log.error("TemplateParser / handle_include_tag: Failed to read file: `%s'".printf().add(ff));
			return(false);
		}
		if(parse(cc, ff.get_parent(), include_dirs, marker_begin, marker_end, v) == false) {
			Log.error("TemplateParser / handle_include_tag: Failed to parse file: `%s'".printf().add(ff));
			return(false);
		}
		return(true);
	}

	public static bool parse(String inputdata, File filedir, Collection include_dirs, String marker_begin, String marker_end, Collection v, Logger logger = null) {
		if(marker_begin == null || marker_end == null || marker_begin.get_length() != 2 || marker_end.get_length() != 2) {
			Log.error("Invalid template markers: `%s', `%s'".printf().add(marker_begin).add(marker_end));
			return(false);
		}
		var mb1 = marker_begin.get_char(0);
		var mb2 = marker_begin.get_char(1);
		var me1 = marker_end.get_char(0);
		var me2 = marker_end.get_char(1);
		int pc;
		StringBuffer tag;
		StringBuffer data;
		foreach(Integer i in inputdata) {
			var c = i.to_integer();
			// parsing the tag
			if(tag != null) {
				if(pc == me1 && tag.count() > 2) {
					tag.append_c(pc);
					tag.append_c(c);
					if(c == me2) {
						var tt = tag.to_string();
						var tts = tt.substring(2, tt.get_length()-4).strip();
						var words = SplitQuoted.split(tts, (int)' ');
						if("include".equals(words.get(0))) {
							if(handle_include_tag(words, filedir, include_dirs, marker_begin, marker_end, v) == false) {
								return(false);
							}
						}
						else {
							v.add(words);
						}
						tag = null;
					}
				}
				else if(c != me1) {
					tag.append_c(c);
				}
			}
			// parsing text data
			else {
				if(pc == mb1) {
					if(c == mb2) {
						if(data != null) {
							v.add(data.to_string());
							data = null;
						}
						tag = StringBuffer.create();
						tag.append_c(pc);
						tag.append_c(c);
					}
					else {
						if(data == null) {
							data = StringBuffer.create();
						}
						data.append_c(pc);
						data.append_c(c);
					}
				}
				else if(c != mb1) {
					if(data == null) {
						data = StringBuffer.create();
					}
					data.append_c(c);
				}
			}
			pc = c;
		}
		if(pc == mb1) {
			if(data == null) {
				data = StringBuffer.create();
			}
			data.append_c(pc);
		}
		if(data != null) {
			v.add(data.to_string());
			data = null;
		}
		if(tag != null) {
			Log.error("Unfinished tag: `%s'".printf().add(tag.to_string()), logger);
			return(false);
		}
		return(true);
	}
}
