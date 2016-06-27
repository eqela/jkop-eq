
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
		IFDEF("target_j2me") {
			//FIXME
			return("");
		}
		ELSE {
			if(fmt == null) {
				return(null);
			}
			var fmtp = fmt.to_strptr();
			if(fmtp == null) {
				return(null);
			}
			strptr v = null;
			var s = seconds;
			embed "java" {{{
				java.util.Calendar cal = java.util.Calendar.getInstance();
				cal.setTimeInMillis(seconds * 1000);
				v = String.format(fmtp, cal);
			}}}
			if(v == null) {
				return(null);
			}
			return(String.for_strptr(v).dup());
		}
	}

	public String to_string_datetime() {
		return(to_string_fmt("%1$tF %1$tH:%1$tM"));
	}

	public String to_string_date() {
		return(to_string_fmt("%1$tF"));
	}

	public String to_string_date_compressed() {
		return(to_string_fmt("%1$tY%1$tm%1$td"));
	}

	public String to_string_time(bool hours, bool minutes, bool seconds) {
		var fmt = StringBuffer.create();
		if(hours) {
			fmt.append("%1$tH");
		}
		if(minutes) {
			if(fmt.count() > 0) {
				fmt.append_c((int)':');
			}
			fmt.append("%1$tM");
		}
		if(seconds) {
			if(fmt.count() > 0) {
				fmt.append_c((int)':');
			}
			fmt.append("%1$tS");
		}
		return(to_string_fmt(fmt.to_string()));
	}

	public long get_time() {
		return(seconds);
	}

	public DateTimeDetails get_details(bool utc) {
		IFDEF("target_j2me") {
			// FIXME
			return(null);
		}
		ELSE {
			int dwday, dday, dmonth, dyear, dhours, dmins, dseconds;
			embed "java" {{{
				java.util.TimeZone tz = java.util.TimeZone.getDefault();
				if(utc == true) {
					tz = java.util.TimeZone.getTimeZone("UTC");	
				}
				java.util.Calendar cal = java.util.Calendar.getInstance();
				cal.setTimeZone(tz);
				cal.setTimeInMillis(seconds*1000);
				dday = cal.get(java.util.Calendar.DAY_OF_MONTH);
				dmonth = cal.get(java.util.Calendar.MONTH) + 1;
				dyear = cal.get(java.util.Calendar.YEAR);
				dwday = cal.get(java.util.Calendar.DAY_OF_WEEK);
				dhours = cal.get(java.util.Calendar.HOUR_OF_DAY);
				dmins = cal.get(java.util.Calendar.MINUTE);
				dseconds = cal.get(java.util.Calendar.SECOND);
			}}}
			return(new DateTimeDetails().set_weekday(dwday).set_day(dday).set_month(dmonth).set_year(dyear)
				.set_hours(dhours).set_minutes(dmins).set_seconds(dseconds));
		}
	}
}
