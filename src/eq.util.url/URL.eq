
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

public class URL : Stringable
{
	public static URL for_string(String str) {
		var v = new URL();
		v.parse(str);
		return(v);
	}

	property String scheme;
	property String username;
	property String password;
	property String host;
	property String port;
	property String path;
	property String fragment;
	property HashTable query_parameters;
	property String original;
	property bool percent_only = false;
	property bool encode_unreserved_chars = true;

	public URL dup() {
		var v = new URL().set_scheme(scheme).set_username(username)
			.set_password(password).set_host(host).set_port(port)
			.set_path(path).set_fragment(fragment);
		if(query_parameters != null) {
			v.set_query_parameters(query_parameters.dup());
		}
		return(v);
	}

	public String to_string() {
		return(to_string_do(true));
	}

	public String to_string_nohost() {
		return(to_string_do(false));
	}

	private String to_string_do(bool usehost) {
		var sb = StringBuffer.create();
		if(usehost) {
			if(scheme != null) {
				sb.append(scheme);
				sb.append("://");
			}
			if(username != null) {
				sb.append(username);
				if(password != null) {
					sb.append_c((int)':');
					sb.append(password);
				}
				sb.append_c((int)'@');
			}
			if(host != null) {
				sb.append(host);
				if(port != null) {
					sb.append_c((int)':');
					sb.append(port);
				}
			}
		}
		if(path != null) {
			sb.append(path.replace_char((int)' ', (int)'+'));
		}
		if(query_parameters != null && query_parameters.count() > 0) {
			bool first = true;
			var it = query_parameters.iterate_keys();
			while(it != null) {
				var key = it.next() as String;
				if(key == null) {
					break;
				}
				if(first) {
					sb.append_c((int)'?');
					first = false;
				}
				else {
					sb.append_c((int)'&');
				}
				sb.append(key);
				var val = query_parameters.get_string(key);
				if(val != null) {
					sb.append_c((int)'=');
					sb.append(URLEncoder.encode(val, percent_only, encode_unreserved_chars));
				}
			}
		}
		if(fragment != null) {
			sb.append_c((int)'#');
			sb.append(fragment);
		}
		return(sb.to_string());
	}

	public void parse(String astr) {
		set_original(astr);
		if(astr == null) {
			return;
		}
		var str = astr;
		var fsplit = StringSplitter.split(str, (int)'#', 2);
		str = fsplit.next() as String;
		fragment = fsplit.next() as String;
		var qsplit = StringSplitter.split(str, (int)'?', 2);
		str = qsplit.next() as String;
		var query_string = qsplit.next() as String;
		if(query_string != null) {
			var qss = StringSplitter.split(query_string, (int)'&');
			while(qss != null) {
				var qs = qss.next() as String;
				if(qs == null) {
					break;
				}
				if(query_parameters == null) {
					query_parameters = HashTable.create();
				}
				if(qs.chr((int)'=') < 0) {
					query_parameters.set(qs, null);
					continue;
				}
				var qsps = StringSplitter.split(qs, (int)'=', 2);
				var key = qsps.next() as String;
				var val = qsps.next() as String;
				if(val == null) {
					val = "";
				}
				if(String.is_empty(key) == false) {
					query_parameters.set(key, URLDecoder.decode(val));
				}
			}
		}
		var css = str.str("://");
		if(css >= 0) {
			scheme = str.substring(0, css);
			if(scheme.chr((int)':') >= 0 || scheme.chr((int)'/') >= 0) {
				scheme = null;
			}
			else {
				str = str.substring(css+3);
			}
		}
		if(str.get_char(0) == '/') {
			path = URLDecoder.decode(str);
		}
		else {
			if(str.chr((int)'/') >= 0) {
				var sssplit = StringSplitter.split(str, (int)'/', 2);
				str = sssplit.next() as String;
				path = sssplit.next() as String;
				if(path == null) {
					path = "";
				}
				if(path.get_char(0) != '/') {
					path = "/".append(path);
				}
				path = URLDecoder.decode(path);
			}
			if(str.chr((int)'@') >= 0) {
				var asplit = StringSplitter.split(str, (int)'@', 2);
				var auth = asplit.next() as String;
				str = asplit.next() as String;
				if(auth.chr((int)':') >= 0) {
					var acsplit = StringSplitter.split(auth, (int)':', 2);
					username = URLDecoder.decode(acsplit.next() as String);
					password = URLDecoder.decode(acsplit.next() as String);
				}
				else {
					username = auth;
				}
			}
			if(str.chr((int)':') >= 0) {
				var hcsplit = StringSplitter.split(str, (int)':', 2);
				str = hcsplit.next() as String;
				port = hcsplit.next() as String;
			}
			host = str;
		}
	}

	public int get_port_int() {
		if(port == null) {
			return(0);
		}
		return(port.to_integer());
	}

	public String get_query_parameter(String key) {
		if(query_parameters == null) {
			return(null);
		}
		return(query_parameters.get_string(key));
	}
}
