
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

class DateTimeImpl : DateTime, Stringable
{
	int seconds;

	public static DateTimeImpl instance() {
		return(new DateTimeImpl());
	}

	public DateTimeDetails get_details(bool utc = false) {
		return(null);
	}

	public void set_time_int(long seconds) {
		this.seconds = seconds;
		embed {{{
			this.date = new Date(seconds * 1000);
		}}}
	}

	public String to_string() {
		return(to_string_datetime());
	}

	public String to_string_datetime() {
		return("%s %s".printf().add(to_string_date()).add(to_string_time(true, true, false)).to_string());
	}

	public String to_string_date() {
		strptr v, year, month, day;
		embed {{{
			year = "" + this.date.getFullYear();
			month = "" + (this.date.getMonth() + 1);
			day = "" + (this.date.getDay() + 1);
			if(month.length < 2) {
				month = "0" + month;
			}
			if(day.length < 2) {
				day = "0" + day;
			}
			v = year + "-" + month + "-" + day;
		}}}
		return(String.for_strptr(v).dup());
	}

	public String to_string_date_compressed() {
		strptr v, year, month, day;
		embed {{{
			year = "" + this.date.getFullYear();
			month = "" + (this.date.getMonth() + 1);
			day = "" + (this.date.getDay() + 1);
			if(month.length < 2) {
				month = "0" + month;
			}
			if(day.length < 2) {
				day = "0" + day;
			}
			v = year + month + day;
		}}}
		return(String.for_strptr(v).dup());
	}

	public String to_string_time(bool hours, bool minutes, bool seconds) {
		strptr hh, mm, ss;
		embed {{{
			hh = "" + (this.date.getHours());
			mm = "" + (this.date.getMinutes());
			ss = "" + (this.date.getSeconds());
			if(hh.length < 2) {
				hh = "0" + hh;
			}
			if(mm.length < 2) {
				mm = "0" + mm;
			}
			if(ss.length < 2) {
				ss = "0" + ss;
			}
		}}}
		var v = StringBuffer.create();
		if(hours) {
			v.append(String.for_strptr(hh));
		}
		if(minutes) {
			if(v.count() > 0) {
				v.append_c(':');
			}
			v.append(String.for_strptr(mm));
		}
		if(seconds) {
			if(v.count() > 0) {
				v.append_c(':');
			}
			v.append(String.for_strptr(ss));
		}
		return(v.to_string());
	}

	public long get_time() {
		return(seconds);
	}
}
