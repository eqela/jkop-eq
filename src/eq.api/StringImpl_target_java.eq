
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

IFNDEF("target_j2me") {
class MyStringFormatter : StringFormatterBase
{
	public override void format_string(StringBuffer result, String format, String value) {
		if(value == null) {
			return;
		}
		strptr r;
		embed "Java" {{{
			r = java.lang.String.format(format.to_strptr(), value.to_strptr());
		}}}
		if(r != null) {
			result.append(String.for_strptr(r));
		}
	}

	public override void format_integer(StringBuffer result, String format, int value) {
		strptr r;
		String aformat = format, pad_format = null;
		bool is_unsigned = false;
		int dot = aformat.chr((int)'.');
		if(dot > 0) {
			var itr = aformat.iterate();
			int chr = -1;
			StringBuffer sb = StringBuffer.create();
			StringBuffer zsb = StringBuffer.create();
			bool dotflag = false;
			while((chr = itr.next_char()) > 0) {
				if(chr == '.') {
					dotflag = true;
					zsb.append_c((int)'%');
					zsb.append_c((int)'0');
					continue;
				}
				if(chr == 'u' || chr == 'i') {
					chr = (int)'d';
					is_unsigned = chr == 'u';
				}
				if(dotflag) {
					zsb.append_c(chr);
				}
				else {
					sb.append_c(chr);
				}
			}
			sb.append_c((int)'s');
			aformat = zsb.to_string();
			pad_format = sb.to_string();
		}
		if(is_unsigned) {
			embed "Java" {{{
				r = java.lang.String.format(aformat.to_strptr(), value & 0xFFFFFFFFL);
			}}}
		}
		else {
			embed "Java" {{{
				r = java.lang.String.format(aformat.to_strptr(), value);
			}}}
		}
		if(String.is_empty(pad_format) == false) {
			embed {{{
				r = java.lang.String.format(pad_format.to_strptr(), r);
			}}}
		}
		if(r != null) {
			result.append(String.for_strptr(r));
		}
	}

	public override void format_double(StringBuffer result, String format, double value) {
		strptr r;
		String aformat = format;
		if(aformat.rchr((int)'F') > 0) {
			aformat = format.lowercase();
		}
		embed "Java" {{{
			r = java.lang.String.format(aformat.to_strptr(), value);	
		}}}
		if(r != null) {
			result.append(String.for_strptr(r));
		}
	}
}
}

class StringImpl : Stringable, Integer, Double, Boolean, String
{
	class NormalIterator : Iterator, StringIterator
	{
		private StringImpl str = null;
		private int strlength;
		private int idx = 0;

		public static NormalIterator create(StringImpl str) {
			var v = new NormalIterator();
			v.str = str;
			v.strlength = str.get_length();
			v.idx = 0;
			return(v);
		}

		public int peek_next_char() {
			if(idx < strlength) {
				embed {{{
					return(str.jstr.charAt(idx));
				}}}
			}
			return(0);
		}

		public int next_char() {
			if(idx < strlength) {
				embed {{{
					return(str.jstr.charAt(idx++));
				}}}
			}
			return(0);
		}

		public int prev_char() {
			if(idx-1 >= 0) {
				embed {{{
					return(str.jstr.charAt(--idx));
				}}}
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
			v.strlength = strlength;
			v.idx = idx;
			return(v);
		}
	}

	private class ReverseIterator : Iterator, StringIterator
	{
		private StringImpl str = null;
		private int strlength = 0;
		private int idx = 0;

		public static ReverseIterator create(StringImpl str) {
			var v = new ReverseIterator();
			v.str = str;
			if(str != null) {
				v.strlength = str.get_length();
				v.idx = v.strlength - 1;
			}
			return(v);
		}

		public int peek_next_char() {
			if(idx >= 0) {
				embed {{{
					return(str.jstr.charAt(idx));
				}}}
			}
			return(0);
		}

		public int next_char() {
			if(idx >= 0) {
				embed {{{
					return(str.jstr.charAt(idx--));
				}}}
			}
			return(0);
		}

		public int prev_char() {
			if(idx+1 < strlength) {
				embed {{{
					return(str.jstr.charAt(++idx));
				}}}
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
			v.strlength = strlength;
			return(v);
		}
	}

	embed "Java" {{{
		public java.lang.String jstr = null;
	}}}

	public StringImpl() {
	}

	public void set_utf8_buffer(Buffer data, bool haszero) {
		if(data == null) {
			return;
		}
		var jpointer = data.get_pointer() as PointerImpl;
		var jptr = jpointer.get_native_pointer();
		int idx = jpointer.get_current_index(), size = data.get_size();
		var n = idx;
		var finalsize = size;
		embed {{{
			if(haszero) {
				finalsize = 0;
				for(int cnt = 0; cnt < jptr.length; cnt++) {
					int i = jptr[cnt];
					if(i != 0) {
						finalsize += 1;
					}
					else {
						break;
					}
				}
			}
			try {
				jstr = new java.lang.String(jptr, idx, finalsize, "UTF-8");
			}
			catch(Exception e) {
			}
		}}}
	}

	public void set_strptr(strptr p) {
		embed "Java" {{{
			jstr = p;
		}}}
	}

	public StringFormatter printf() {
		IFDEF("target_j2me") {
			return(StringFormatterImpl.create(this));
		}
		ELSE {
			return(new MyStringFormatter().set_format(this));
		}
	}

	public String dup() {
		var v = new StringImpl();
		embed "Java" {{{
			v.jstr = this.jstr;
			v._length = this._length;
		}}}
		return(v);
	}

	public String append(String str) {
		int sl;
		if(str == null || (sl = str.get_length()) < 1) {
			return(this);
		}
		strptr vptr;
		embed "Java" {{{
			vptr = to_strptr() + str.to_strptr();
		}}}
		var v = String.for_strptr(vptr);
		if(_length > 0) {
			((StringImpl)v)._length = _length + sl;
		}
		return(v);
	}

	public int _length = -1;

	public int get_length() {
		if(_length < 0) {
			embed "Java" {{{
				if(jstr != null) {
					_length = jstr.length();
				}
				else {
					_length = 0;
				}
			}}}
		}
		return(_length);
	}

	public int get_char(int n) {
		embed "Java" {{{
			try {
				if(jstr != null) {
					return(jstr.charAt(n));
				}
			}
			catch(Exception e) {
			}
		}}}
		return(0);
	}

	public String truncate(int len) {
		return(substring(0, len));
	}

	public String replace(int o, int r) {
		return(replace_char(o, r));
	}

	public String replace_char(int o, int r) {
		strptr vptr;
		embed "Java" {{{
			try {
				if(jstr != null) {
					vptr = jstr.replace((char)o, (char)r);
				}
			}
			catch(Exception e) {
				vptr = null;
			}
		}}}
		if (vptr==null) {
			return(this);
		}
		return(String.for_strptr(vptr));
	}

	public String replace_string(String o, String r) {
		return(StringCommon.replace_string(this, o, r));
	}

	public Iterator split(int delim, int max) {
		return(StringCommon.split(this, delim, max));
	}

	public String remove(int start, int len) {
		var ss = substring(0, start);
		if(ss != null) {
			return(ss.append(substring(start+len)));
		}
		return(this);
	}

	public String insert(String str, int pos) {
		var ss = substring(0, pos);
		if(ss != null) {
			return(ss.append(str).append(substring(pos)));
		}
		return(this);
	}

	public String substring(int start, int alength = -1) {
		strptr vptr = null;
		embed "Java" {{{
			try {
				if(jstr != null) {
					if(alength < 0) {
						vptr = jstr.substring(start);
					}
					else {
						vptr = jstr.substring(start, start+alength);
					}
				}
			}
			catch(Exception e) {
				vptr = null;
			}
		}}}
		if (vptr==null) {
			return(this);
		}
		return(String.for_strptr(vptr));
	}

	public String strip() {
		strptr vptr;
		embed "Java" {{{
			try {
				if(jstr != null) {
					vptr = jstr.trim();
				}
			}
			catch(Exception e) {
				vptr = null;
			}
		}}}
		if (vptr==null) {
			return(this);
		}
		return(String.for_strptr(vptr));
	}

	public int str(String s) {
		if(s == null) {
			return(-1);
		}
		int v;
		embed "Java" {{{
			try {
				if(jstr != null) {
					v = jstr.indexOf(s.to_strptr());
				}
			}
			catch(Exception e) {
				v = -1;
			}
		}}}
		return(v);
	}

	public bool contains(String s) {
		return(str(s) >= 0);
	}

	public int rstr(String s) {
		if(s == null) {
			return(-1);
		}
		int v;
		IFDEF("target_j2me") {
			bool flag = false;
			var str = s.to_strptr();
			embed "Java" {{{
				int mstr; 
				int sstr;
				for(mstr = jstr.length() - 1, sstr = str.length() - 1; mstr > -1; mstr--) {
					if(jstr.charAt(mstr) == str.charAt(sstr)) {
						flag = true;
						sstr--;
					}
					else {
						flag = false;
						sstr = str.length()-1;
					}
					if(flag && sstr == -1) {
						v = mstr;
						break;
					}
				}
			}}}
		}
		ELSE {
			embed "Java" {{{
				try {
					if(jstr != null) {
						v = jstr.lastIndexOf(s.to_strptr());
					}
				}
				catch(Exception e) {
					v = -1;
				}
			}}}
		}
		return(v);
	}

	public int chr(int c) {
		int v;
		embed "Java" {{{
			try {
				if(jstr != null) {
					v = jstr.indexOf(c);
				}
			}
			catch(Exception e) {
				v = -1;
			}
		}}}
		return(v);
	}

	public int rchr(int c) {
		int v;
		embed "Java" {{{
			try {
				if(jstr != null) {
					v = jstr.lastIndexOf(c);
				}
			}
			catch(Exception e) {
				v = -1;
			}
		}}}
		return(v);
	}

	public bool has_prefix(String prefix) {
		if(prefix == null) {
			return(false);
		}
		bool v;
		embed "Java" {{{
			try {
				if(jstr != null) {
					v = jstr.startsWith(prefix.to_strptr());
				}
			}
			catch(Exception e) {
				v = false;
			}
		}}}
		return(v);
	}

	public bool has_suffix(String suffix) {
		if(suffix == null) {
			return(false);
		}
		bool v;
		embed "Java" {{{
			try {
				if(jstr != null) {
					v = jstr.endsWith(suffix.to_strptr());
				}
			}
			catch(Exception e) {
				v = false;
			}
		}}}
		return(v);
	}

	public String to_string() {
		return(this);
	}

	public int compare_ignore_case(Object ao) {
		if(ao == null) {
			return(-1);
		}
		var str = ao as String;
		if(str == null && ao is Stringable) {
			str = ((Stringable)ao).to_string();
		}
		if(str != null) {
			IFDEF("target_j2me") {
				var ss = str.to_strptr();
				embed "Java" {{{
					try {
						java.lang.String temp_jstr = jstr.toLowerCase();
						java.lang.String temp_str = ss.toLowerCase();
						return(temp_jstr.compareTo(ss));
					}
					catch(Exception e) {
						return(-1);
					}
				}}}
			}
			ELSE {
				embed "Java" {{{
					try {
						return(jstr.compareToIgnoreCase(str.to_strptr()));
					}
					catch(Exception e) {
						return(-1);
					}
				}}}
			}
		}
		return(-1);
	}

	public int compare(Object ao) {
		if(ao == null) {
			return(-1);
		}
		var str = ao as String;
		if(str == null && ao is Stringable) {
			str = ((Stringable)ao).to_string();
		}
		if(str != null) {
			embed "Java" {{{
				try {
					if(jstr != null) {
						return(jstr.compareTo(str.to_strptr()));
					}
				}
				catch(Exception e) {
					return(-1);
				}
			}}}
		}
		return(-1);
	}

	public bool equals(Object ao) {
		if(ao == null) {
			return(false);
		}
		var str = ao as String;
		if(str == null && ao is Stringable) {
			str = ((Stringable)ao).to_string();
		}
		if(str != null) {
			embed "Java" {{{
				try {
					if(jstr != null) {
						return(jstr.equals(str.to_strptr()));
					}
				}
				catch(Exception e) {
					return(false);
				}
			}}}
		}
		return(false);
	}

	public bool equals_ptr(strptr str) {
		if(str != null) {
			embed "Java" {{{
				try {
					if(jstr != null) {
						return(jstr.equals(str));
					}
				}
				catch(Exception e) {
					return(false);
				}
			}}}
		}
		return(false);
	}

	public bool equals_ignore_case(Object ao) {
		if(ao == null) {
			return(false);
		}
		var str = ao as String;
		if(str == null && ao is Stringable) {
			str = ((Stringable)ao).to_string();
		}
		if(str != null) {
			embed "Java" {{{
				try {
					if(jstr != null) {
						return(jstr.equalsIgnoreCase(str.to_strptr()));
					}
				}
				catch(Exception e) {
					return(false);
				}
			}}}
		}
		return(false);
	}

	public bool equals_ignore_case_ptr(strptr str) {
		return(equals_ignore_case(String.for_strptr(str)));
	}

	public int to_integer_base(int ibase) {
		if(ibase == 10) {
			return(to_integer());
		}
		int v = 0;
		embed "Java" {{{
			try {
				if(jstr != null) {
					v = java.lang.Integer.parseInt(jstr, ibase);
				}
			}
			catch(Exception e) {
				v = 0;
			}
		}}}
		return(v);
	}

	public int to_integer() {
		int v = 0;
		strptr s;
		IFDEF("target_j2me") {
			embed {{{
				java.lang.StringBuffer buffer = new java.lang.StringBuffer();
				for(int i = 0; i < jstr.length(); i++) {
					char c = jstr.charAt(i);
					if(c >= '0' && c <= '9') {
						buffer.append(c);
					}
				}
				s = buffer.toString();
			}}}
		}
		ELSE {
			embed {{{
				s = jstr.replaceAll("[^0-9]", "");
			}}}
		}
		embed "Java" {{{
			try {
				if(jstr != null) {
					v = java.lang.Integer.parseInt(s);
				}
			}
			catch(Exception e) {
				v = 0;
			}
		}}}
		return(v);
	}

	public double to_double() {
		double v = 0.0;
		embed "Java" {{{
			try {
				if(jstr != null) {
					v = java.lang.Double.parseDouble(jstr);
				}
			}
			catch(Exception e) {
				v = 0.0;
			}
		}}}
		return(v);
	}

	public bool to_boolean() {
		embed "java" {{{
			if(jstr == null) {
				return(true);
			}
			if(jstr.equalsIgnoreCase("false") || jstr.equalsIgnoreCase("no")) {
				return(false);
			}
		}}}
		return(true);
	}

	public strptr to_strptr() {
		strptr v;
		embed "Java" {{{
			v = jstr;
		}}}
		return(v);
	}

	public Buffer to_utf8_buffer(bool zero) {
		ptr bts = null;
		int sz = 0;
		embed "Java" {{{
			try {
				if(jstr != null) {
					bts = jstr.getBytes("UTF-8");
				}
			}
			catch(Exception e) {
				bts = null;
			}
			if(bts != null) {
				sz = bts.length;
			}
		}}}
		if(bts != null) {
			var pb = Buffer.for_pointer(Pointer.create(bts), sz);
			if(zero == false) {
				return(pb);
			}
			// FIXME: Super slow. Double realloaction just to add a byte. Ouch.
			if(pb != null) {
				var npb = Buffer.dup(pb) as DynamicBuffer;
				if(npb != null) {
					appendbyte(npb, 0);
					return(npb);
				}
			}
		}
		return(null);
	}

	private void appendbyte(DynamicBuffer buffer, uint8 byte) {
		if(buffer == null) {
			return;
		}
		int pos = buffer.get_size();
		if(buffer.append(1)) {
			var ptr = buffer.get_pointer();
			if(ptr != null) {
				ptr.set_byte(pos, byte);
			}
		}
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
		embed "Java" {{{
			try {
				if(jstr != null) {
					v = jstr.hashCode();
				}
			}
			catch(Exception e) {
				v = 0;
			}
		}}}
		return(v);
	}

	public String lowercase() {
		strptr vptr;
		embed "Java" {{{
			try {
				if(jstr != null) {
					vptr = jstr.toLowerCase();
				}
			}
			catch(Exception e) {
				vptr = null;
			}
		}}}
		if (vptr==null) {
			return(this);
		}
		return(String.for_strptr(vptr));
	}

	public String uppercase() {
		strptr vptr;
		embed "Java" {{{
			try {
				if(jstr != null) {
					vptr = jstr.toUpperCase();
				}
			}
			catch(Exception e) {
				vptr = null;
			}
		}}}
		if (vptr==null) {
			return(this);
		}
		return(String.for_strptr(vptr));
	}

	public EditableString as_editable() {
		return(SimpleEditableString.for_string(this));
	}
}
