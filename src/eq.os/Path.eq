
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

public class Path
{
	public static bool is_windows_absolute_path(String path) {
		if(path == null) {
			return(false);
		}
		var c0 = path.get_char(0);
		if((c0 >= 'a' && c0 <= 'z') || (c0 >= 'A' && c0 <= 'Z')) {
			if(path.get_char(1) == ':' && path.get_char(2) == '\\') {
				return(true);
			}
		}
		return(false);
	}

	public static bool is_absolute_path(String str) {
		var pp = Path.from_native_notation(str);
		if(pp != null && pp.has_prefix("/")) {
			return(true);
		}
		return(false);
	}

	public static int get_path_delimiter() {
		IFDEF("target_cs") {
			int c;
			embed {{{
				c = System.IO.Path.DirectorySeparatorChar;
			}}}
			return(c);
		}
		IFDEF("target_j2se") {
			int c;
			embed {{{
				c = java.io.File.separatorChar;
			}}}
			return(c);
		}
		ELSE IFDEF("target_windows") {
			return((int)'\\');
		}
		ELSE {
			return((int)'/');
		}
	}

	public static String from_native_notation(String path) {
		if(path == null) {
			return(null);
		}
		if(get_path_delimiter() == '\\') {
			var sb = StringBuffer.create();
			var it = path.split((int)'\\');
			if(it != null) {
				var first = it.next() as String;
				if(first != null) {
					if(first.get_length() == 2 && first.has_suffix(":")) {
						first = first.substring(0, first.get_length() - 1);
						sb.append_c((int)'/');
					}
					sb.append(first); //.lowercase());
					while(it != null) {
						var c = it.next() as String;
						if(c == null) {
							break;
						}
						sb.append_c((int)'/');
						sb.append(c); //.lowercase());
					}
				}
			}
			var v = sb.to_string();
			if(v != null && v.has_prefix("//")) {
				v = "/network/".append(v.substring(2));
			}
			return(v);
		}
		return(path);
	}

	public static String to_native_notation(String path) {
		if(get_path_delimiter() == '\\') {
			if(path != null) {
				var it = path.split((int)'/');
				var sb = StringBuffer.create();
				if(it != null) {
					var first = it.next() as String;
					while(String.is_empty(first)) {
						first = it.next() as String;
						if(first == null) {
							break;
						}
					}
					if(first != null) {
						sb.append(first);
						sb.append_c((int)':');
						bool f = false;
						while(true) {
							var cp = it.next() as String;
							if(cp == null) {
								break;
							}
							sb.append_c((int)'\\');
							sb.append(cp);
							f = true;
						}
						if(f == false) {
							sb.append_c((int)'\\');
						}
					}
				}
				var v = sb.to_string();
				if(v != null && v.has_prefix("network:")) {
					v = "\\".append(v.substring(8));
				}
				return(v);
			}
		}
		return(path);
	}

	public static String normalize_path(String p) {
		String v = null;
		if(p != null) {
			var comps = StringSplitter.split(p, (int)'/');
			var comp = comps.next() as String;
			v = "";
			while(comp != null) {
				if(comp.get_length() < 1) {
					;
				}
				else if(comp.equals(".")) {
					;
				}
				else if(comp.equals("..")) {
					int slash = v.rchr((int)'/');
					if(slash > 0) {
						v = v.substring(0, slash);
					}
					else {
						v = "";
					}
				}
				else {
					v = "%s/%s".printf().add(v).add(comp).to_string();
				}
				comp = comps.next() as String;
			}
			if(v.get_length() < 1) {
				v = "/";
			}
		}
		else {
			v = "/";
		}
		return(v);
	}

	private static String cwd = null;

	static String get_cwd() {
		if(cwd == null) {
			var cd = SystemEnvironment.get_current_dir();
			if(cd != null) {
				cwd = cd.get_eqela_path();
			}
			if(String.is_empty(cwd)) {
				cwd = "/";
			}
		}
		return(cwd);
	}

	public static String absolute_path(String afile, String arelative = null) {
		String file = afile;
		if(file == null) {
			file = ".";
		}
		String v = null;
		if(file != null && file.get_char(0) == '/') {
			v = file;
		}
		else {
			String relative = arelative;
			if(relative == null) {
				relative = get_cwd();
			}
			if(file == null) {
				v = relative;
			}
			else {
				v = relative.append("/").append(file);
			}
		}
		return(normalize_path(v));
	}

	public static String basename(String path) {
		if(path == null) {
			return(null);
		}
		String v = "";
		var comps = StringSplitter.split(path, (int)'/');
		if(comps != null) {
			var comp = comps.next() as String;
			while(comp != null) {
				if(comp.get_length() > 0) {
					v = comp;
				}
				comp = comps.next() as String;
			}
		}
		return(v);
	}

	public static String dirname(String path) {
		if (path == null) {
			return(null);
		}
		bool absolute = path.has_prefix("/");
		bool first = true;
		var sbuff = StringBuffer.create();
		var comps = StringSplitter.split(path, (int)'/');
		if (comps != null) {
			var comp = comps.next() as String;
			var next = comps.next() as String;
			while (comp!=null) {
				if (next==null) {
					break;
				}
				if(absolute == false && first == true) {
					sbuff.append(comp);
				}
				else if(comp.get_length() > 0) {
					sbuff.append("/".append(comp));
				}
				first = false;
				comp = next;
				next = comps.next() as String;
			}
		}
		var dname = sbuff.to_string();
		if ("".equals(dname)) {
			if(absolute) {
				return("/");
			}
			return(".");
		}
		return(dname);
	}

	public static String strip_extension(String apath) {
		if(apath == null) {
			return(null);
		}
		String v = apath;
		int r = apath.rstr(".");
		if(r >= 0) {
			v = apath.substring(0, r);
		}
		return(v);
	}

	public static String extension(String apath) {
		if(apath == null) {
			return(null);
		}
		int r = apath.rstr(".");
		if(r >= 0) {
			return(apath.substring(r+1));
		}
		return(null);
	}
}

