
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

	public void set_time_int(long seconds) {
		this.seconds = seconds;
	}

	public DateTimeDetails get_details(bool utc = false) {
		return(null);
	}

	public String to_string() {
		return(to_string_datetime());
	}

	String to_string_fmt(String fmt) {
		if(fmt == null) {
			return(null);
		}
		var csfmt = fmt.to_strptr();
		if(csfmt == null) {
			return(null);
		}
		strptr v;
		embed "cs" {{{
			var epoch = new System.DateTime(1970, 1, 1);
			var dt = epoch.AddSeconds(seconds);
			v = dt.ToString(csfmt);
		}}}
		return(String.for_strptr(v).dup());
	}

	public String to_string_datetime() {
		return(to_string_fmt("yyyy-MM-dd HH:mm"));
	}

	public String to_string_date() {
		return(to_string_fmt("yyyy-MM-dd"));
	}

	public String to_string_date_compressed() {
		return(to_string_fmt("yyyyMMdd"));
	}

	public String to_string_time(bool hours, bool minutes, bool seconds) {
		var fmt = StringBuffer.create();
		if(hours) {
			fmt.append("HH");
		}
		if(minutes) {
			if(fmt.count() > 0) {
				fmt.append_c((int)':');
			}
			fmt.append("mm");
		}
		if(seconds) {
			if(fmt.count() > 0) {
				fmt.append_c((int)':');
			}
			fmt.append("ss");
		}
		return(to_string_fmt(fmt.to_string()));
	}

	public long get_time() {
		return(seconds);
	}
}
