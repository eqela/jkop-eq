
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
	embed "c" {{{
		#include <time.h>
	}}}

	long seconds;

	public static DateTimeImpl instance() {
		return(new DateTimeImpl());
	}

	public void set_time_int(long seconds) {
		this.seconds = seconds;
	}

	public String to_string() {
		return(to_string_datetime());
	}

	String to_string_fmt(String fmt) {
		if(fmt == null) {
			return(null);
		}
		var fmtp = fmt.to_strptr();
		if(fmtp == null) {
			return(null);
		}
		strptr v = null;
		var s = seconds;
		embed "c" {{{
			char buf[1024];
			time_t tp = (time_t)s;
			struct tm* lt;
			lt = localtime(&tp);
			if(strftime(buf, 1023, fmtp, lt) > 0) {
				v = buf;
			}
		}}}
		if(v == null) {
			return(null);
		}
		return(String.for_strptr(v).dup());
	}

	public String to_string_datetime() {
		return(to_string_fmt("%Y-%m-%d %H:%M"));
	}

	public String to_string_date() {
		return(to_string_fmt("%Y-%m-%d"));
	}

	public String to_string_date_compressed() {
		return(to_string_fmt("%Y%m%d"));
	}

	public String to_string_time(bool hours, bool minutes, bool seconds) {
		var fmt = StringBuffer.create();
		if(hours) {
			fmt.append("%H");
		}
		if(minutes) {
			if(fmt.count() > 0) {
				fmt.append_c(':');
			}
			fmt.append("%M");
		}
		if(seconds) {
			if(fmt.count() > 0) {
				fmt.append_c(':');
			}
			fmt.append("%S");
		}
		return(to_string_fmt(fmt.to_string()));
	}

	public long get_time() {
		return(seconds);
	}

	public DateTimeDetails get_details(bool utc) {
		var s = seconds;
		embed {{{
			time_t tp = (time_t)s;
		}}}
		embed {{{
			struct tm* lt;
		}}}
		if(utc == false) {
			embed {{{
				lt = localtime(&tp);
			}}}
		}
		else {
			embed {{{
				lt = gmtime(&tp);
			}}}
		}
		int dwday, dday, dmonth, dyear, dhours, dmins, dseconds;
		embed {{{
			if(lt != NULL) {
				dwday = lt->tm_wday + 1;
				dday = lt->tm_mday;
				dmonth = lt->tm_mon + 1;
				dyear = 1900 + lt->tm_year;
				dhours = lt->tm_hour;
				dmins = lt->tm_min;
				dseconds = lt->tm_sec;
			}
		}}}
		return(new DateTimeDetails().set_weekday(dwday).set_day(dday).set_month(dmonth).set_year(dyear)
			.set_hours(dhours).set_minutes(dmins).set_seconds(dseconds));
	}
}
