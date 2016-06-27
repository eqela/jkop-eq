
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

public class Template : LoggerObject
{
	public static bool process_string_to_file(String ttxt, File file, HashTable props, String marker_begin = null, String marker_end = null) {
		if(file == null) {
			return(false);
		}
		var mb = marker_begin, me = marker_end;
		if(mb == null) {
			mb = "{{";
		}
		if(me == null) {
			me = "}}";
		}
		var template = Template.for_string(ttxt, "text/plain", mb, me);
		if(template == null) {
			return(false);
		}
		var str = template.to_string(props);
		if(str == null) {
			return(false);
		}
		if(file.set_contents_string(str) == false) {
			return(false);
		}
		return(true);
	}

	public static String process_string(String ttxt, HashTable props, String marker_begin = null, String marker_end = null) {
		var mb = marker_begin, me = marker_end;
		if(mb == null) {
			mb = "{{";
		}
		if(me == null) {
			me = "}}";
		}
		var template = Template.for_string(ttxt, "text/plain", mb, me);
		if(template == null) {
			return(null);
		}
		return(template.to_string(props));
	}

	property Collection data;
	property String mimetype;
	property File file;
	property TemplateProcessor processor;
	property String marker_begin;
	property String marker_end;

	public static Template for_string(String idata, String type, String marker_begin, String marker_end, Collection include_dirs = null) {
		var c = LinkedList.create();
		if(TemplateParser.parse(idata, null, include_dirs, marker_begin, marker_end, c) == false) {
			return(null);
		}
		var v = new Template();
		v.set_mimetype(type);
		v.set_data(c);
		v.set_marker_begin(marker_begin);
		v.set_marker_end(marker_end);
		return(v);
	}

	public static Template for_file(File file, String marker_begin, String marker_end, Collection include_dirs = null) {
		if(file == null) {
			return(null);
		}
		var c = LinkedList.create();
		if(TemplateParser.parse(file.get_contents_string(), file.get_parent(), include_dirs, marker_begin, marker_end, c) == false) {
			return(null);
		}
		var v = new Template();
		if(file.has_extension("t") || file.has_extension("tpl") || file.has_extension("template")) {
			v.set_mimetype(MimeTypeRegistry.type_for_file(file.get_parent().entry(Path.strip_extension(file.basename()))));
		}
		else {
			v.set_mimetype(MimeTypeRegistry.type_for_file(file));
		}
		v.set_data(c);
		v.set_file(file);
		v.set_marker_begin(marker_begin);
		v.set_marker_end(marker_end);
		return(v);
	}

	public String to_string(HashTable vars, File directory = null, Logger logger = null) {
		var result = StringBuffer.create();
		var dirs = LinkedList.create();
		if(directory != null) {
			dirs.add(directory);
		}
		File currentdir;
		if(file != null) {
			currentdir = file.get_parent();
		}
		if(currentdir != null && currentdir.is_same(directory) == false) {
			dirs.add(currentdir);
		}
		if(processor == null) {
			processor = new TemplateProcessor();
		}
		processor.set_logger(logger);
		processor.set_marker_begin(marker_begin);
		processor.set_marker_end(marker_end);
		if(processor.process(data, vars, result, dirs) == false) {
			return(null);
		}
		return(result.to_string());
	}

	public Collection get_accessed_variables() {
		var v = LinkedList.create();
		var flags = HashTable.create();
		foreach(Collection o in data) {
			var tag = o.get(0) as String;
			if("=".equals(tag)) {
				var vv = o.get(1) as String;
				if(String.is_empty(vv) == false && flags.get_bool(vv) == false) {
					v.add(vv);
					flags.set_bool(vv, true);
				}
			}
			else if("for".equals(tag)) {
				var vv = o.get(3) as String;
				if(String.is_empty(vv) == false && flags.get_bool(vv) == false) {
					v.add(vv);
					flags.set_bool(vv, true);
				}
			}
			else if("if".equals(tag)) {
				var vv = o.get(1) as String;
				if(String.is_empty(vv) == false && flags.get_bool(vv) == false) {
					v.add(vv);
					flags.set_bool(vv, true);
				}
			}
		}
		return(v);
	}
}
