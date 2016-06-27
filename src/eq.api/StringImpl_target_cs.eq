
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
	int printf_to_string_format(String af, StringBuffer sb) {
		String alignment, formatstring;
		var ch = af.iterate();
		int v;
		if(ch.next_char() == '%') {
			while(true) {
				int tmp = ch.next_char();
				if(tmp == 0) {
					break;
				}
				if(tmp >= 'A' && tmp <= 'z') {
					v = tmp;
					break;
				}
				if(tmp == '.') {
					alignment = sb.to_string();
					continue;
				}
				sb.append_c(tmp);
			}
			if(alignment == null) {
				alignment = sb.to_string();
				if(alignment.get_char(0) == '0') {
					formatstring = alignment;
					alignment = null;
				}
			}
			else {
				formatstring = sb.to_string();
			}
		}
		sb.append_c((int)'{');
		sb.append_c((int)'0');
		if(String.is_empty(alignment) == false) {
			sb.append_c((int)',');
			sb.append(alignment);
		}
		sb.append_c((int)':');
		sb.append_c(v);
		if(String.is_empty(formatstring) == false) {
			sb.append(formatstring);
		}
		sb.append_c((int)'}');
		return(v);
	}

	public override void format_integer(StringBuffer result, String aformat, int value) {
		if("%c".equals(aformat)) {
			result.append_c(value);
			return;
		}
		strptr r;
		StringBuffer sb = StringBuffer.create();
		int fid = printf_to_string_format(aformat, sb);
		var sformat = sb.to_string();
		strptr sf = sformat.to_strptr();
		if(fid == 'd' || fid == 'x' || fid == 'X') {
			embed "cs" {{{
				r = System.String.Format(sf, value);
			}}}
		}
		else if(fid == 'u') {
			embed "cs" {{{
				r = System.String.Format("{0}", (uint)value);
			}}}
		}
		else if(fid == 'o') {
			embed "cs" {{{
				r = System.Convert.ToString(value, 8);
			}}}
		}
		else {
			embed "cs" {{{
				r = value.ToString();
			}}}
		}
		if(r != null) {
			result.append(String.for_strptr(r));
		}
	}

	public override void format_double(StringBuffer result, String aformat, double value) {
		strptr r;
		StringBuffer sb = StringBuffer.create();
		int fid = printf_to_string_format(aformat, sb);
		var sformat = sb.to_string();
		strptr sf = sformat.to_strptr();
		if(fid == 'f' || fid == 'F' || fid == 'e' || fid == 'E') {
			embed "cs" {{{
				r = System.String.Format(sf, value);
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
			return(-1);
		}

		public int next_char() {
			if(str != null && idx < str.get_length()) {
				return(str.get_char(idx++));
			}
			return(-1);
		}

		public int prev_char() {
			if(str != null && idx-1 >= 0) {
				return(str.get_char(--idx));
			}
			return(-1);
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

	private class ReverseIterator : Iterator, StringIterator
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

	embed "cs" {{{
		System.String cstr = null;
	}}}

	public void set_utf8_buffer(Buffer data, bool haszero) {
		if(data == null) {
			return;
		}
		var length = data.get_size();
		if(haszero == true) {
			length = length - 1;
		}
		var pointer = data.get_pointer() as PointerImpl;
		var sptr = pointer.get_native_pointer();
		var idx = pointer.get_current_index();
		embed "cs" {{{
			cstr = System.Text.Encoding.UTF8.GetString(sptr, idx, length);
		}}}
	}

	public void set_strptr(strptr p) {
		embed "cs" {{{
			cstr = p;
		}}}
	}

	public StringFormatter printf() {
		return(new MyStringFormatter().set_format(this));
	}

	public void set_cstr(strptr s) {
		embed "cs" {{{
			this.cstr = s;
		}}}
	}

	public String dup() {
		var v = new StringImpl();
		embed "cs" {{{
			v.set_cstr(this.cstr);
		}}}
		return(v);
	}

	public String append(String str) {
		if(str==null || str.get_length() < 1) {
			return(this);
		}
		strptr vptr;
		embed "cs" {{{
			vptr = to_strptr() + str.to_strptr();
		}}}
		return(String.for_strptr(vptr));
	}

	public int get_length() {
		int v = 0;
		embed "cs" {{{
			if (cstr!=null) {
				v = cstr.Length;
			}
		}}}
		return(v);
	}

	public int get_char(int n) {
		if(n < 0 || n >= get_length()) {
			return(0);
		}
		int v;
		embed "cs" {{{
			v = (int)cstr[n];
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
		strptr vptr;
		embed "cs" {{{
			try {
				vptr = cstr.Replace((char)o, (char)r);
			}
			catch {
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
		if (start<0 || len <0 || start+len > get_length()) {
			return(this);
		}
		strptr vptr;
		embed "cs" {{{
			try {
				vptr = cstr.Remove(start, len);
			}
			catch {
				vptr = null;
			}
		}}}
		if (vptr==null) {
			return(this);
		}
		return(String.for_strptr(vptr));
	}

	public String insert(String str, int pos) {
		if (pos<0 || pos>get_length() || str==null) {
			return(this);
		}
		strptr vptr;
		embed "cs" {{{
			try {
				vptr = cstr.Insert(pos, str.to_strptr());
			}
			catch {
				vptr = null;
			}
		}}}
		if (vptr==null) {
			return(this);
		}
		return(String.for_strptr(vptr));
	}

	public String substring(int start, int alength = -1) {
		strptr vptr = null;
		embed "cs" {{{
			try {
				if(alength < 0) {
					vptr = cstr.Substring(start);
				}
				else {
					vptr = cstr.Substring(start, alength);
				}
			}
			catch {
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
		embed "cs" {{{
			try {
				vptr = cstr.Trim();
			}
			catch {
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
		embed "cs" {{{
			try {
				v = cstr.IndexOf(s.to_strptr());
			}
			catch {
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
		embed "cs" {{{
			try {
				v = cstr.LastIndexOf(s.to_strptr());
			}
			catch {
				v = -1;
			}
		}}}
		return(v);
	}

	public int chr(int c) {
		int v;
		embed "cs" {{{
			try {
				v = cstr.IndexOf((char)c);
			}
			catch {
				v = -1;
			}
		}}}
		return(v);
	}

	public int rchr(int c) {
		int v;
		embed "cs" {{{
			try {
				v = cstr.LastIndexOf((char)c);
			}
			catch {
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
		embed "cs" {{{
			try {
				v = cstr.StartsWith(prefix.to_strptr());
			}
			catch {
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
		embed "cs" {{{
			try {
				v = cstr.EndsWith(suffix.to_strptr());
			}
			catch {
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
			embed "cs" {{{
				try {
					return(System.String.Compare(cstr, str.to_strptr(), System.StringComparison.CurrentCultureIgnoreCase));
				}
				catch {
					return(-1);
				}
			}}}
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
			embed "cs" {{{
				try {
					return(System.String.Compare(cstr, str.to_strptr()));
				}
				catch {
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
			embed "cs" {{{
				try {
					return(cstr.Equals(str.to_strptr()));
				}
				catch {
					return(false);
				}
			}}}
		}
		return(false);
	}

	public bool equals_ptr(strptr str) {
		if(str != null) {
			embed "cs" {{{
				if(cstr == null) {
					return(false);
				}
				try {
					return(cstr.Equals(str));
				}
				catch {
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
			embed "cs" {{{
				try {
					return(cstr.Equals(str.to_strptr(), System.StringComparison.CurrentCultureIgnoreCase));
				}
				catch {
					return(false);
				}
			}}}
		}
		return(false);
	}

	public bool equals_ignore_case_ptr(strptr str) {
		if(str != null) {
			embed "cs" {{{
				if(cstr == null) {
					return(false);
				}
				try {
					return(cstr.Equals(str, System.StringComparison.CurrentCultureIgnoreCase));
				}
				catch {
					return(false);
				}
			}}}
		}
		return(false);
	}

	public int to_integer_base(int ibase) {
		if(ibase == 10) {
			return(to_integer());
		}
		if(ibase != 16) {
			return(-1); // only support 10 and 16
		}
		int v = 0;
		embed "cs" {{{
			try {
				v = System.Int32.Parse(cstr, System.Globalization.NumberStyles.HexNumber);
			}
			catch {
				v = 0;
			}
		}}}
		return(v);
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
			embed "cs" {{{
				try {
					v = System.Int32.Parse(ptr);
				}
				catch {
					v = 0;
				}
			}}}
		}
		return(v);
	}

	public double to_double() {
		double v = 0.0;
		embed "cs" {{{
			try {
				v = System.Double.Parse(cstr);
			}
			catch {
				v = 0.0;
			}
		}}}
		return(v);
	}

	public bool to_boolean() {
		embed "cs" {{{
			if(cstr == null) {
				return(true);
			}
			if(System.String.Compare(cstr, "false", true) == 0 || System.String.Compare(cstr, "no", true) == 0) {
				return(false);
			}
		}}}
		return(true);
	}

	public strptr to_strptr() {
		strptr v;
		embed "cs" {{{
			v = cstr;
		}}}
		return(v);
	}

	public Buffer to_utf8_buffer(bool zero) {
		ptr bts = null;
		int sz = 0;
		embed "cs" {{{
			try {
				System.Text.UTF8Encoding utfe = new System.Text.UTF8Encoding();
				bts = utfe.GetBytes(cstr);
			}
			catch {
				bts = null;
			}
			if(bts != null) {
				sz = bts.Length;
			}
		}}}
		if(bts != null) {
			// FIXME: Super slow. Double realloaction just to add a byte. Ouch.
			var pb = Buffer.for_pointer(Pointer.create(bts), sz);
			if(zero == false) {
				return(pb);
			}
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
		embed "cs" {{{
			try {
				v = cstr.GetHashCode();
			}
			catch {
				v = 0;
			}
		}}}
		return(v);
	}

	public String lowercase() {
		strptr vptr;
		embed "cs" {{{
			try {
				vptr = cstr.ToLower();
			}
			catch {
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
		embed "cs" {{{
			try {
				vptr = cstr.ToUpper();
			}
			catch {
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

