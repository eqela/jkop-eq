
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

class MyStringFormatter : StringFormatterBase
{
	embed "js" {{{
		if(!String.format) {
			String.format = function(format) {
				var args = Array.prototype.slice.call(arguments, 1);
				return format.replace(/{(\d+)}/g, function(match, number) { 
					return typeof args[number] != 'undefined'
					? args[number] 
					: match
      				;
				});
			};
		}
	}}}

	public override void format_string(StringBuffer result, String format, String value) {
		if(value == null) {
			return;
		}
		strptr r;
		embed "js" {{{
			r = String.format("{0}", value.to_strptr());
		}}}
		if(r != null) {
			result.append(String.for_strptr(r));
		}
	}

	public override void format_integer(StringBuffer result, String format, int value) {
		strptr r;
		if(format.has_suffix("x")) {
			embed "js" {{{
				r = String.format("{0}", value.toString(16));
			}}}
		}
		else if("%X".equals(format)) {
			embed "js" {{{
				r = String.format("{0}", value.toString(16).toUpperCase());
			}}}
		}
		else if("%C".equals(format) || "%c".equals(format)) {
			embed "js" {{{
				r = String.format("{0}", String.fromCharCode(value));
			}}}
		}
		else if("%u".equals(format)) {
			embed "js" {{{
				r = String.format("{0}", value >>> 32);
			}}}
		}
		else if("%o".equals(format)) {
			embed "js" {{{
				r = String.format("{0}", value.toString(8));
			}}}
		}
		else if("%d".equals(format)) {
			embed "js" {{{
				r = String.format("{0}", value);
			}}}
		}
		else {
			embed "js" {{{
				r = String.format("{0}", value);
			}}}
		}
		if(r != null) {
			result.append(String.for_strptr(r));
		}
	}

	public override void format_double(StringBuffer result, String format, double value) {
		strptr r;
		if(format.has_suffix("f") || format.has_suffix("F")) {
			var dec = 6;
			var dot = format.chr((int)'.');
			if(dot > 0) {
				dec = Integer.as_integer(format.substring(dot+1, format.get_length()-2));
			}
			embed "js" {{{
				var n = parseFloat(value);
				r = String.format("{0}", n.toFixed(dec));
			}}}
		}
		else if(format.has_suffix("e") || format.has_suffix("E")) {
			embed "js" {{{
				r = String.format("{0}", value.toExponential());
			}}}
		}
		else {
			embed "js" {{{
				r = String.format(format.to_strptr(), value);
			}}}
		}
		if(r != null) {
			result.append(String.for_strptr(r));
		}
	}
}

class StringImpl : Stringable, Integer, Double, Boolean, String
{
	class NormalIterator : Iterator, StringIterator
	{
		private String str = null;
		private int idx = 0;

		public static NormalIterator create(String str) {
			var v = new NormalIterator();
			v.str = str;
			v.idx = 0;
			return(v);
		}

		public int peek_next_char() {
			if(str != null && idx < str.get_length()) {
				return(str.get_char(idx));
			}
			return(0);
		}

		public int next_char() {
			if(str != null && idx < str.get_length()) {
				return(str.get_char(idx++));
			}
			return(0);
		}

		public int prev_char() {
			if(str != null && idx-1 >= 0) {
				return(str.get_char(--idx));
			}
			return(0);
		}

		public Object next() {
			int nc = next_char();
			if(nc < 1) {
				return(null);
			}
			return(Primitive.for_integer(nc));
		}

		public StringIterator copy() {
			var v = new NormalIterator();
			v.str = str;
			v.idx = idx;
			return(v);
		}
	}

	class ReverseIterator : Iterator, StringIterator
	{
		private String str = null;
		private int idx = 0;

		public static ReverseIterator create(String str) {
			var v = new ReverseIterator();
			v.str = str;
			if(str != null) {
				v.idx = str.get_length() - 1;
			}
			return(v);
		}

		public int peek_next_char() {
			if(str != null && idx >= 0) {
				return(str.get_char(idx));
			}
			return(0);
		}

		public int next_char() {
			if(str != null && idx >= 0) {
				return(str.get_char(idx--));
			}
			return(0);
		}

		public int prev_char() {
			if(str != null && idx+1 < str.get_length()) {
				return(str.get_char(++idx));
			}
			return(0);
		}

		public Object next() {
			int nc = next_char();
			if(nc < 1) {
				return(null);
			}
			return(Primitive.for_integer(nc));
		}

		public StringIterator copy() {
			var v = new ReverseIterator();
			v.str = str;
			v.idx = idx;
			return(v);
		}
	}

	public StringImpl() {
		embed "js" {{{
			this.jstr = null;
			this._hash = 0;
		}}}
	}

	public void set_utf8_buffer(Buffer data, bool haszero) {
		if(data == null) {
			return;
		}
		var ptr = data.get_pointer();
		if(ptr == null) {
			return;
		}
		if(haszero == false) {
			// FIXME: Do what?
		}
		var nptr = ptr.get_native_pointer();
		embed "js" {{{
			this.jstr = decodeURIComponent(escape(String.fromCharCode.apply(null, nptr)));
		}}}
	}

	public void set_strptr(strptr p) {
		embed "js" {{{
			this.jstr = p;
		}}}
	}

	public StringFormatter printf() {
		return(new MyStringFormatter().set_format(this));
	}

	public String dup() {
		var v = new StringImpl();
		embed "js" {{{
			v.jstr = this.jstr;
		}}}
		return(v);
	}

	public String append(String str) {
		if(str == null) {
			return(this);
		}
		String v;
		embed "js" {{{
			v = eq.api.StringStatic.for_strptr(this.to_strptr() + str.to_strptr());
		}}}
		return(v);
	}

	public int get_length() {
		int v = 0;
		embed "js" {{{
			if(this.jstr != null) {
				v = this.jstr.length;
			}
		}}}
		return(v);
	}

	public int get_char(int n) {
		int v = 0;
		embed "js" {{{
			if(this.jstr != null) {
				v = this.jstr.charCodeAt(n);
				if(isNaN(v)) {
					v = 0;
				}
			}
		}}}
		return(v);
	}

	public String truncate(int len) {
		return(substring(0, len));
	}

	public String replace(int o, int r) {
		return(replace_char(o, r));
	}

	public String replace_char(int o, int r) {
		String v;
		embed "js" {{{
			if(this.jstr != null) {
				v = eq.api.StringStatic.for_strptr(this.jstr.replace(o, r));
			}
			else {
				v = eq.api.StringStatic.for_strptr("");
			}
		}}}
		return(v);
	}

	public String replace_string(String o, String r) {
		return(StringCommon.replace_string(this, o, r));
	}

	public Iterator split(int delim, int max) {
		return(StringCommon.split(this, delim, max));
	}

	public String remove(int start, int len) {
		return(substring(0, start).append(substring(start+len)));
	}

	public String insert(String str, int pos) {
		return(substring(0, pos).append(str).append(substring(pos)));
	}

	public String substring(int start, int alength = -1) {
		String v;
		embed "js" {{{
			if(this.jstr != null) {
				if(alength < 0) {
					v = eq.api.StringStatic.for_strptr(this.jstr.substring(start));
				}
				else {
					v = eq.api.StringStatic.for_strptr(this.jstr.substring(start, start+alength));
				}
			}
			else {
				v = eq.api.StringStatic.for_strptr("");
			}
		}}}
		return(v);
	}

	public String strip() {
		String v;
		embed "js" {{{
			if(this.jstr != null) {
				v = eq.api.StringStatic.for_strptr(this.jstr.replace(/^[\s\xA0]+/, "").replace(/[\s\xA0]+$/, ""));
			}
			else {
				v = eq.api.StringStatic.for_strptr("");
			}
		}}}
		return(v);
	}

	public int str(String s) {
		int v = -1;
		embed "js" {{{
			if(this.jstr != null) {
				v = this.jstr.indexOf(s.to_strptr());
			}
		}}}
		return(v);
	}

	public bool contains(String s) {
		return(str(s) >= 0);
	}

	public int rstr(String s) {
		int v = -1;
		embed "js" {{{
			if(this.jstr != null) {
				v = this.jstr.lastIndexOf(s.to_strptr());
			}
		}}}
		return(v);
	}

	public int chr(int c) {
		int v = -1;
		embed "js" {{{
			if(this.jstr != null) {
				v = this.jstr.indexOf(String.fromCharCode(c));
			}
		}}}
		return(v);
	}

	public int rchr(int c) {
		int v = -1;
		embed "js" {{{
			if(this.jstr != null) {
				v = this.jstr.lastIndexOf(String.fromCharCode(c));
			}
		}}}
		return(v);
	}

	public bool has_prefix(String prefix) {
		bool v = false;
		embed "js" {{{
			if(this.jstr != null) {
				var p = prefix.to_strptr();
				v = (this.jstr.match("^"+p) == p);
			}
		}}}
		return(v);
	}

	public bool has_suffix(String suffix) {
		bool v = false;
		embed "js" {{{
			if(this.jstr != null) {
				var s = suffix.to_strptr();
				v = (this.jstr.match(s+"$") == s);
			}
		}}}
		return(v);
	}

	public String to_string() {
		return(this);
	}

	public int compare_ignore_case(Object ao) {
		var str = ao as String;
		if(str == null && ao is Stringable) {
			str = ((Stringable)ao).to_string();
		}
		if(str != null) {
			return(lowercase().compare(str.lowercase()));
		}
		return(-1);
	}

	public int compare(Object ao) {
		var str = ao as String;
		if(str == null && ao is Stringable) {
			str = ((Stringable)ao).to_string();
		}
		if(str != null) {
			embed "js" {{{
				var strp = str.to_strptr();
				if(this.jstr == null && strp == null) {
					return(0);
				}
				else if(this.jstr == null) {
					return(1);
				}
				else if(strp == null) {
					return(-1);
				}
				else if(strp < this.jstr) {
					return(1);
				}
				else if(strp > this.jstr) {
					return(-1);
				}
				else {
					return(0);
				}
			}}}
		}
		return(-1);
	}

	public bool equals(Object ao) {
		var str = ao as String;
		if(str == null && ao is Stringable) {
			str = ((Stringable)ao).to_string();
		}
		if(str != null) {
			embed "js" {{{
				return(this.jstr == str.jstr);
			}}}
		}
		return(false);
	}

	public bool equals_ptr(strptr str) {
		if(str != null) {
			embed "js" {{{
				return(this.jstr == str);
			}}}
		}
		return(false);
	}

	public bool equals_ignore_case(Object ao) {
		var str = ao as String;
		if(str == null && ao is Stringable) {
			str = ((Stringable)ao).to_string();
		}
		if(str != null) {
			embed "js" {{{
				if(this.jstr != null && str.jstr != null) {
					return(this.jstr.toLowerCase() == str.jstr.toLowerCase());
				}
			}}}
		}
		return(false);
	}

	public bool equals_ignore_case_ptr(strptr str) {
		return(equals_ignore_case(String.for_strptr(str)));
	}

	public int to_integer() {
		int v = 0;
		var sb = StringBuffer.create();
		var it = this.iterate();
		while(it != null) {
			var c = it.next_char();
			if(c >= '0' && c <= '9') {
				sb.append_c(c);
			}
			else {
				break;
			}
		}
		if(sb.count() > 0) {
			var ss = sb.to_string();
			var ptr = ss.to_strptr();
			embed "js" {{{
				v = parseInt(ptr, 10);
			}}}
		}
		return(v);
	}

	public int to_integer_base(int n) {
		int v;
		embed "js" {{{
			if(this.jstr != null) {
				v = parseInt(this.jstr, n);
			}
		}}}
		return(v);
	}

	public double to_double() {
		double v;
		embed "js" {{{
			if(this.jstr != null) {
				v = parseFloat(this.jstr);
			}
		}}}
		return(v);
	}

	public bool to_boolean() {
		embed "js" {{{
			if(!this.jstr) {
				return(true);
			}
			var up = this.jstr.toUpperCase();
			if(up == "FALSE" || up == "NO") {
				return(false);
			}
		}}}
		return(true);
	}

	public strptr to_strptr() {
		strptr v;
		embed "js" {{{
			v = this.jstr;
		}}}
		return(v);
	}

	public Buffer to_utf8_buffer(bool zero) {
		int l = 0;
		embed "js" {{{
			var utf8str = unescape(encodeURIComponent(this.jstr));
			l = utf8str.length;
		}}}
		if(zero) {
			l ++;
		}
		var b = DynamicBuffer.create(l);
		if(b != null) {
			var ptr = b.get_pointer();
			if(ptr != null) {
				var nptr = ptr.get_native_pointer();
				embed "js" {{{
					var n = 0;
					for(n=0; n<utf8str.length; n++) {
						nptr[n] = utf8str.charCodeAt(n);
					}
					if(zero) {
						nptr[n] = 0;
					}
				}}}
			}
		}
		return(b);
	}

	public String reverse() {
		var sb = StringBuffer.create();
		var rit = iterate_reverse();
		while(rit != null) {
			int c = rit.next_char();
			if(c < 1) {
				break;
			}
			sb.append_c(c);
		}
		return(sb.to_string());
	}

	public StringIterator iterate() {
		return(NormalIterator.create(this));
	}

	public StringIterator iterate_reverse() {
		return(ReverseIterator.create(this));
	}

	public int hash() {
		int v;
		embed "js" {{{
			if(this._hash == 0 && this.jstr != null) {
				for(i=0; i<this.jstr.length; i++) {
					var ch = this.jstr.charCodeAt(i);
					this._hash = ((this._hash<<5)-this._hash)+ch;
					this._hash = this._hash & this._hash;
				}
			}
			v = this._hash;
		}}}
		return(v);
	}

	public String lowercase() {
		String v;
		embed "js" {{{
			if(this.jstr != null) {
				v = eq.api.StringStatic.for_strptr(this.jstr.toLowerCase());
			}
			else {
				v = eq.api.StringStatic.for_strptr("");
			}
		}}}
		return(v);
	}

	public String uppercase() {
		String v;
		embed "js" {{{
			if(this.jstr != null) {
				v = eq.api.StringStatic.for_strptr(this.jstr.toUpperCase());
			}
			else {
				v = eq.api.StringStatic.for_strptr("");
			}
		}}}
		return(v);
	}

	public EditableString as_editable() {
		return(SimpleEditableString.for_string(this));
	}
}
