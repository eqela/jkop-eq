
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

class StringImpl : Stringable, Integer, Double, Boolean, String
{
	public void set_utf8_buffer(Buffer data, bool haszero) {
	}

	public void set_strptr(strptr p) {
	}

	public StringFormatter printf() {
		return(null);
	}

	public String dup() {
		return(null);
	}

	public String append(String str) {
		return(null);
	}

	public int get_length() {
		return(0);
	}

	public int get_char(int n) {
		return(0);
	}

	public String truncate(int len) {
		return(null);
	}

	public String replace(int o, int r) {
		return(null);
	}

	public String replace_char(int o, int r) {
		return(null);
	}

	public String replace_string(String o, String r) {
		return(null);
	}

	public Iterator split(int delim, int max) {
		return(null);
	}

	public String remove(int start, int len) {
		return(null);
	}

	public String insert(String str, int pos) {
		return(null);
	}

	public String substring(int start, int alength = -1) {
		return(null);
	}

	public String strip() {
		return(null);
	}

	public int str(String s) {
		return(0);
	}

	public bool contains(String s) {
		return(false);
	}

	public int rstr(String s) {
		return(0);
	}

	public int chr(int c) {
		return(0);
	}

	public int rchr(int c) {
		return(0);
	}

	public bool has_prefix(String prefix) {
		return(false);
	}

	public bool has_suffix(String suffix) {
		return(false);
	}

	public String to_string() {
		return(this);
	}

	public int compare_ignore_case(Object ao) {
		return(0);
	}

	public int compare(Object ao) {
		return(0);
	}

	public bool equals(Object ao) {
		return(false);
	}

	public bool equals_ignore_case(Object ao) {
		return(false);
	}

	public bool equals_ptr(strptr str) {
		return(false);
	}

	public bool equals_ignore_case_ptr(strptr str) {
		return(false);
	}

	public int to_integer_base(int ibase) {
		return(0);
	}

	public int to_integer() {
		return(0);
	}

	public double to_double() {
		return(0.0);
	}

	public bool to_boolean() {
		return(false);
	}

	public strptr to_strptr() {
		return(null);
	}

	public Buffer to_utf8_buffer(bool zero) {
		return(null);
	}

	public String reverse() {
		return(null);
	}

	public StringIterator iterate() {
		return(null);
	}

	public StringIterator iterate_reverse() {
		return(null);
	}

	public int hash() {
		return(0);
	}

	public String lowercase() {
		return(null);
	}

	public String uppercase() {
		return(null);
	}

	public EditableString as_editable() {
		return(null);
	}
}

