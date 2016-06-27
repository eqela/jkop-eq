
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
	embed {{{
		#include <stdio.h>
	}}}

	IFDEF("target_win32") {
		embed {{{
			#include <stdarg.h>
			int vasprintf(char **sptr, char *fmt, va_list argv) { 
				if(sptr == NULL) {
					return(-1);
				}
				*sptr = NULL;
				int w = vsnprintf(NULL, 0, fmt, argv);
				if(w < 1) {
					return(w);
				}
				*sptr = (char*)malloc(w+1);
				if(*sptr == NULL) {
					return(-1);
				}
				return vsprintf(*sptr, fmt, argv);
			}
			int asprintf( char **sptr, char *fmt, ... ) {
				int retval; 
				va_list argv; 
				va_start( argv, fmt ); 
				retval = vasprintf( sptr, fmt, argv ); 
				va_end( argv ); 
				return retval; 
			}
		}}}
	}

	public void format_string(StringBuffer result, String format, String value) {
		if(value == null) {
			return;
		}
		if(format.get_length() == 2) {
			result.append(value);
			return;
		}
		var fp = format.to_strptr();
		var vp = value.to_strptr();
		strptr p;
		int r;
		embed {{{
			r = asprintf(&p, fp, vp);
		}}}
		if(r >= 0 && p != null) {
			result.append(String.for_strptr(p));
			embed {{{
				free(p);
			}}}
		}
	}

	public void format_integer(StringBuffer result, String format, int value) {
		var fp = format.to_strptr();
		strptr p = null;
		int r;
		embed {{{
			r = asprintf(&p, fp, value);
		}}}
		if(r >= 0 && p != null) {
			result.append(String.for_strptr(p));
			embed {{{
				free(p);
			}}}
		}
	}

	public void format_double(StringBuffer result, String format, double value) {
		strptr fp;
		bool truncate = false;
		if(format.get_length() == 2) {
			embed {{{
				fp = "%.20f";
			}}}
			truncate = true;
		}
		else {
			fp = format.to_strptr();
		}
		strptr p;
		int r;
		embed {{{
			r = asprintf(&p, fp, value);
		}}}
		if(r >= 0 && p != null) {
			if(truncate) {
				embed {{{
					while(r > 1 && p[r-1] == '0' && p[r-2] != '.') {
						p[r-1] = 0;
						r--;
					}
				}}}
			}
			result.append(String.for_strptr(p));
			embed {{{
				free(p);
			}}}
		}
	}
}

class StringImpl : String, Stringable, Integer, Double, Boolean
{
	class NormalIterator : Iterator, StringIterator
	{
		StringImpl str = null;
		Pointer ptr = null;
		int pos = 0;
		int nextpos = 0;
		int nextchar = 0;

		public static NormalIterator create(StringImpl str) {
			var r = new NormalIterator();
			r.str = str;
			r.ptr = str.get_pointer();
			r.pos = 0;
			return(r);
		}

		public int peek_next_char() {
			if(nextpos < 1 || nextchar < 1) {
				update();
			}
			return(nextchar);
		}

		public int next_char() {
			var r = peek_next_char();
			pos = nextpos;
			nextpos = 0;
			nextchar = 0;
			return(r);
		}

		public int prev_char() {
			if(ptr == null) {
				return(-1);
			}
			if(pos > 0) {
				uint8 bx = ptr.get_byte(--pos);
				while ((bx >> 6) == 0x02) {
					bx = ptr.get_byte(--pos);
				}
				nextpos = 0;
				nextchar = 0;
				return(peek_next_char());
			}
			return(0);
		}

		void update() {
			if(ptr == null) {
				nextpos = pos;
				nextchar = -1;
				return;
			}
			int tmp_pos = pos;
			uint8 b1 = ptr.get_byte(tmp_pos);
			if(b1 == 0) {
				nextpos = pos;
				nextchar = -1;
				return;
			}
			int v = -1;
			if ((b1 & 0xE0) == 0xE0) { // 3 bytes
				v = (int)((b1 & 0x0F) << 12);
				uint8 b2 = ptr.get_byte(++tmp_pos);
				if (b2 != 0) {
					v += (int)((b2 & 0x3F) << 6);
				}
				else {
					v = -1;
				}
				uint8 b3 = ptr.get_byte(++tmp_pos);
				if (b3 != 0) {
					v += (int)(b3 & 0x3F);
				}
				else {
					v = -1;
				}
				tmp_pos++;
			}
			else if ((b1 & 0xC0) == 0xC0) { // 2 bytes
				v = (int)((b1 & 0x1F) << 6);
				uint8 b2 = ptr.get_byte(++tmp_pos);
				if (b2 != 0) {
					v += (int)(b2 & 0x3F);
				}
				else {
					v = -1;
				}
				tmp_pos++;
			}
			else if (b1 <= 0x7F) { // 1 byte
				v = (int)b1;
				tmp_pos++;
			}
			nextpos = tmp_pos;
			nextchar = v;
		}

		public Object next() {
			int nc = next_char();
			if(nc < 0) {
				return(null);
			}
			return(Primitive.for_integer(nc));
		}

		public StringIterator copy() {
			var r = new NormalIterator();
			r.str = str;
			r.ptr = Pointer.dup(ptr);
			r.pos = pos;
			r.nextpos = nextpos;
			r.nextchar = nextchar;
			return(r);
		}
	}

	class ReverseIterator : Iterator, StringIterator
	{
		private String str = null;
		private NormalIterator iter = null;

		public static ReverseIterator create(String str) {
			var r = new ReverseIterator();
			r.str = str;
			r.iter = str.iterate() as NormalIterator;
			if(r.iter != null) {
				while (r.iter.next_char() > 0) {
					// just iterate 'til end.
				}
			}
			return(r);
		}

		public int peek_next_char() {
			return(((NormalIterator)iter.copy()).prev_char());
		}

		public int next_char() {
			return(iter.prev_char());
		}

		public int prev_char() {
			return(iter.next_char());
		}

		public Object next() {
			int nc = next_char();
			if(nc < 0) {
				return(null);
			}
			return(Primitive.for_integer(nc));
		}

		public StringIterator copy() {
			var v = new ReverseIterator();
			v.str = str;
			if(iter != null) {
				v.iter = iter.copy() as NormalIterator;
			}
			return(v);
		}
	}

	private Buffer buffer = null;
	private Pointer pointer = null;
	private int _hash = 0;
	private int length = -1;
	private int size = -1;

	public StringImpl() {
	}

	~StringImpl() {
		buffer = null;
		pointer = null;
	}

	public void set_utf8_buffer(Buffer data, bool haszero) {
		if(haszero) {
			buffer = data;
		}
		else {
			buffer = DynamicBuffer.create(0);
			if(buffer != null) {
				DynamicBuffer.cat((DynamicBuffer)buffer, data);
				DynamicBuffer.cat_byte((DynamicBuffer)buffer, 0);
			}
		}
		if(buffer != null) {
			pointer = buffer.get_pointer();
		}
	}

	public void set_strptr(strptr p) {
		pointer = Pointer.create((ptr)p);
	}

	public Pointer get_pointer() {
		return(pointer);
	}

	public StringFormatter printf() {
		return(new MyStringFormatter().set_format(this));
	}

	public String dup() {
		return(append(null));
	}

	public String append(String str) {
		Buffer ba, bb;
		ba = to_utf8_buffer(true);
		if(str != null) {
			bb = to_utf8_buffer(true);
		}
		int sz;
		int l = 0;
		if(ba != null) {
			sz = ba.get_size();
			if(sz > 0) {
				sz--;
			}
			l += sz;
		}
		if(bb != null) {
			sz = bb.get_size();
			if(sz > 0) {
				sz--;
			}
			l += sz;
		}
		l ++;
		var sb = StringBuffer.for_initial_size(l);
		sb.append(this);
		if(str != null) {
			sb.append(str);
		}
		return(sb.to_string());
	}

	public int get_length() {
		if(length < 0) {
			length = 0;
			var it = iterate();
			while(it.next_char() > 0) {
				length ++;
			}
		}
		return(length);
	}

	public void set_length(int n) {
		length = n;
	}

	public int get_size() {
		if (size < 0) {
			if (pointer != null) {
				int i = 0;
				uint8 b1 = pointer.get_byte(i);
				while (b1 != 0) {
					i++;
					b1 = pointer.get_byte(i);
				}
				size = i;
			}
		}
		return(size);
	}

	public int get_char(int n) {
		int v = 0, m = 0;
		var it = iterate();
		while((v = it.next_char()) > 0) {
			if(m == n) {
				break;
			}
			m++;
		}
		return(v);
	}

	public String truncate(int len) {
		var sb = StringBuffer.create();
		var it = iterate();
		int c = 0, n = 0;
		while(n < len && (c = it.next_char()) > 0) {
			sb.append_c(c);
			n ++;
		}
		return(sb.to_string());
	}

	public String replace(int o, int r) {
		return(replace_char(o, r));
	}

	public String replace_char(int o, int r) {
		var sb = StringBuffer.create();
		var it = iterate();
		int c = 0;
		while((c = it.next_char()) > 0) {
			if(c == o) {
				sb.append_c(r);
			}
			else {
				sb.append_c(c);
			}
		}
		return(sb.to_string());
	}

	public String replace_string(String o, String r) {
		return(StringCommon.replace_string(this, o, r));
	}

	public Iterator split(int delim, int max) {
		return(StringCommon.split(this, delim, max));
	}

	public String remove(int start, int len) {
		var sb = StringBuffer.create();
		int c = 0, n = 0;
		var it = iterate();
		while((c = it.next_char()) > 0) {
			if(n < start || n >= start+len) {
				sb.append_c(c);
			}
			n ++;
		}
		return(sb.to_string());
	}

	public String insert(String str, int pos) {
		var sb = StringBuffer.create();
		int c = 0, n = 0;
		var it = iterate();
		while(n < pos && (c = it.next_char()) > 0) {
			sb.append_c(c);
			n++;
		}
		sb.append(str);
		while((c = it.next_char()) > 0) {
			sb.append_c(c);
		}
		return(sb.to_string());
	}

	public String substring(int astart, int alength = -1) {
		var start = astart;
		if(start < 0) {
			start = 0;
		}
		var sb = StringBuffer.create();
		int c = 0, n = 0;
		var it = iterate();
		while(n < start && it.next_char() > 0) {
			n ++;
		}
		if(n == start) {
			int m = 0;
			while(alength < 0 || m < alength) {
				c = it.next_char();
				if(c < 1) {
					break;
				}
				sb.append_c(c);
				m++;
			}
		}
		return(sb.to_string());
	}

	public String strip() {
		var it = iterate();
		int c = 0, s = -1, e = 0, i = 0;
		while((c = it.next_char()) > 0) {
			if(c == ' ' || c == '\r' || c == '\n' || c == '\t') {
			}
			else if(s < 0) {
				s = i;
				e = i;
			}
			else {
				e = i;
			}
			i ++;
		}
		if(s < 0) {
			return("");
		}
		return(substring(s, e-s+1));
	}

	private bool __str(StringIterator it, String s) {
		bool v = false;
		var sit = s.iterate();
		sit.next_char(); // the first char was already matched
		while(true) {
			int c1 = it.next_char(), c2 = sit.next_char();
			if(c2 <= 0) {
				v = true;
				break;
			}
			if(c1 != c2) {
				break;
			}
		}
		return(v);
	}

	public int str(String s) {
		if(s == null) {
			return(-1);
		}
		int v = -1, c, n = 0;
		int sc0 = s.get_char(0);
		var it = iterate();
		while((c = it.next_char()) > 0) {
			if(c == sc0) {
				if(__str(it.copy(), s)) {
					v = n;
					break;
				}
			}
			n++;
		}
		return(v);
	}

	public bool contains(String s) {
		return(str(s) >= 0);
	}

	public int rstr(String s) {
		if(s == null) {
			return(-1);
		}
		int v = -1, c, n = 0;
		int sc0 = s.get_char(0);
		var it = iterate();
		while((c = it.next_char()) > 0) {
			if(c == sc0) {
				if(__str(it.copy(), s)) {
					v = n;
				}
			}
			n++;
		}
		return(v);
	}

	public int chr(int c) {
		int n = 0, i = 0;
		var it = iterate();
		while((i = it.next_char()) > 0) {
			if(c == i) {
				return(n);
			}
			n++;
		}
		return(-1);
	}

	public int rchr(int c) {
		int n = 0, i = 0, v = -1;
		var it = iterate();
		while((i = it.next_char()) > 0) {
			if(c == i) {
				v = n;
			}
			n++;
		}
		return(v);
	}

	public bool has_prefix(String prefix) {
		if(prefix != null) {
			var ti = this.iterate(), oi = prefix.iterate();
			int to = -1, oo = -1;
			while(true) {
				to = ti.next_char();
				oo = oi.next_char();
				if(oo < 1) {
					return(true);
				}
				else if(to < 1) {
					return(false);
				}
				else if(to != oo) {
					return(false);
				}
			}
		}
		return(true);
	}

	public bool has_suffix(String suffix) {
		bool v = false;
		if(suffix != null) {
			int c = suffix.get_length();
			int d = this.get_length();
			if(d >= c) {
				var end = this.substring(d - c);
				if(end != null && end.equals(suffix)) {
					v = true;
				}
			}
		}
		return(v);
	}

	public String to_string() {
		return(this);
	}

	public int compare_ignore_case(Object ao) {
		return(do_compare(ao, true));
	}

	public int compare(Object ao) {
		return(do_compare(ao, false));
	}

	int do_compare(Object ao, bool ignorecase) {
		if(this == ao) {
			return(0);
		}
		int v = -1;
		String o = ao as String;
		if(o == null) {
			return(1);
		}
		var ti = this.iterate(), oi = o.iterate();
		int to = 0, oo = 0;
		while(ti != null && oi != null) {
			to = ti.next_char();
			oo = oi.next_char();
			if(ignorecase) {
				if(to >= 'A' && to <= 'Z') {
					to = to - 'A' + 'a';
				}
				if(oo >= 'A' && oo <= 'Z') {
					oo = oo - 'A' + 'a';
				}
			}
			if(to <= 0 && oo > 0) {
				v = -1;
				break;
			}
			else if(to > 0 && oo <= 0) {
				v = 1;
				break;
			}
			else if(to <= 0&& oo <= 0) {
				v = 0;
				break;
			}
			else if(to < oo) {
				v = -1;
				break;
			}
			else if(to > oo) {
				v = 1;
				break;
			}
		}
		return(v);
	}

	public bool equals(Object ao) {
		if(this == ao) {
			return(true);
		}
		if(ao == null || ao is StringImpl == false) {
			return(false);
		}
		if(_hash > 0 && ((StringImpl)ao)._hash > 0 && _hash != ((StringImpl)ao)._hash) {
			return(false);
		}
		if(pointer == null || ((StringImpl)ao).pointer == null) {
			return(false);
		}
		var mp = (strptr)((PointerImpl)pointer).pointer;
		var op = (strptr)((PointerImpl)((StringImpl)ao).pointer).pointer;
		if(mp == null || op == null) {
			return(false);
		}
		embed "c" {{{
			while(1) {
				if(*mp != *op) {
					return(0);
				}
				if(*mp == 0) {
					break;
				}
				mp ++;
				op ++;
			}
		}}}
		return(true);
	}

	public bool equals_ptr(strptr op) {
		if(op == null || pointer == null) {
			return(false);
		}
		var mp = (strptr)((PointerImpl)pointer).pointer;
		if(mp == null) {
			return(false);
		}
		embed "c" {{{
			while(1) {
				if(*mp != *op) {
					return(0);
				}
				if(*mp == 0) {
					break;
				}
				mp ++;
				op ++;
			}
		}}}
		return(true);
	}

	public bool equals_ignore_case(Object ao) {
		if(this == ao) {
			return(true);
		}
		var o = ao as String;
		if(o == null && ao is Stringable) {
			var aos = ao as Stringable;
			o = aos.to_string();
		}
		if(o == null) {
			return(false);
		}
		return(compare_ignore_case(o) == 0);
	}

	public bool equals_ignore_case_ptr(strptr str) {
		return(equals_ignore_case(String.for_strptr(str)));
	}

	public int to_integer() {
		return(to_integer_base(10));
	}

	public int to_integer_base(int ibase) {
		bool negative = false;
		int digitcount = 0;
		int basen = 10;
		// step 1. determine the number of digits in the string (and negative/basen values)
		{
			var it = iterate();
			if(it.next_char() == '-') {
				negative = true;
			}
			else {
				it = iterate();
			}
			if(it.next_char() == '0' && it.next_char() == 'x') {
				basen = 16;
			}
			else {
				it = iterate();
				if(negative) {
					it.next_char();
				}
			}
			int c = 0;
			while((c = it.next_char()) > 0) {
				if((c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F')) {
					basen = 16;
				}
				else if(c >= '0' && c <= '9') {
				}
				else {
					// non-digit encountered; stop here.
					break;
				}
				digitcount ++;
			}
		}
		if(ibase != -1) {
			basen = ibase;
		}
		// step 2. compute the actual value
		int v = 0, c = 0, pow = 1, n;
		{
			for(n=0; n<digitcount-1; n++) {
				pow *= basen;
			}
		}
		var it = iterate();
		if(it.next_char() == '-') {
		}
		else {
			it = iterate();
		}
		if(it.next_char() == '0' && it.next_char() == 'x') {
		}
		else {
			it = iterate();
			if(negative) {
				it.next_char();
			}
		}
		while((c = it.next_char()) > 0) {
			n = 0;
			if(c >= 'a' && c <= 'f') {
				n = c - 'a' + 10;
			}
			else if(c >= 'A' && c <= 'F') {
				n = c - 'A' + 10;
			}
			else if(c >= '0' && c <= '9') {
				n = c - '0';
			}
			else {
				break;
			}
			if(n > 0) {
				v += pow * n;
			}
			pow /= basen;
		}
		if(negative) {
			v *= -1;
		}
		return(v);
	}

	public double to_double() {
		var valstr = to_strptr();
		double v = 0;
		if(valstr != null) {
			embed {{{
				v = atof(valstr);
			}}}
		}
		return(v);
	}

	public bool to_boolean() {
		var it = iterate();
		if(it == null) {
			return(true);
		}
		int c = it.next_char();
		if(c == 'f') {
			if(it.next_char() == 'a' && it.next_char() == 'l' && it.next_char() == 's' && it.next_char() == 'e') {
				return(false);
			}
		}
		else if(c == 'n') {
			if(it.next_char() == 'o') {
				return(false);
			}
		}
		return(true);
	}

	public strptr to_strptr() {
		if(pointer == null) {
			return(null);
		}
		return(((PointerImpl)pointer).pointer);
		// return(pointer.get_native_pointer());
	}

	public Buffer to_utf8_buffer(bool zero) {
		if(buffer != null) {
			if(zero) {
				return(buffer);
			}
			else {
				return(SubBuffer.create(buffer, 0, buffer.get_size() - 1));
			}
		}
		if(pointer == null) {
			return(null);
		}
		int add = 0;
		if(zero) {
			add = 1;
		}
		return(Buffer.for_pointer(pointer, get_size() + add));
	}

	public String reverse() {
		var sb = StringBuffer.create();
		var it = iterate_reverse();
		int c = 0;
		while((c = it.next_char()) > 0) {
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
		if(_hash > 0) {
			return(_hash);
		}
		var sp = to_strptr();
		if(sp == null) {
			return(_hash);
		}
		int ll = 0;
		int hh = 5381;
		embed "c" {{{
			while(*sp) {
				hh = ((hh << 5) + hh) + (*sp);
				ll ++;
				sp ++;
			}
		}}}
		_hash = hh;
		length = ll;
		/*
		_hash = 5381;
		var it = iterate();
		int c = 0;
		length = 0;
		while((c = it.next_char()) > 0) {
			_hash = ((_hash << 5) + _hash) + c;
			length ++;
		}
		*/
		return(_hash);
	}

	public String lowercase() {
		var sb = StringBuffer.create();
		var it = iterate();
		int c;
		while((c = it.next_char()) > 0) {
			if(c >= 'A' && c <= 'Z') {
				c = c - 'A' + 'a';
			}
			sb.append_c(c);
		}
		return(sb.to_string());
	}

	public String uppercase() {
		var sb = StringBuffer.create();
		var it = iterate();
		int c;
		while((c = it.next_char()) > 0) {
			if(c >= 'a' && c <= 'z') {
				c = c - 'a' + 'A';
			}
			sb.append_c(c);
		}
		return(sb.to_string());
	}

	public EditableString as_editable() {
		return(SimpleEditableString.for_string(this));
	}
}
