
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

public interface DateTime : Stringable
{
	public static DateTime for_now() {
		return(DateTime.for_time(SystemClock.seconds()));
	}

	public static DateTime for_time(long seconds) {
		var v = DateTimeImpl.instance();
		if(v == null) {
			return(null);
		}
		v.set_time_int(seconds);
		return(v);
	}

	public static DateTime for_timeval(TimeVal tv) {
		if(tv == null) {
			return(null);
		}
		var v = DateTimeImpl.instance();
		if(v == null) {
			return(null);
		}
		v.set_time_int(tv.get_seconds());
		return(v);
	}

	public DateTimeDetails get_details(bool utc = false);
	public void set_time_int(long seconds);
	public String to_string_datetime();
	public String to_string_date();
	public String to_string_date_compressed();
	public String to_string_time(bool hours = true, bool minutes = true, bool seconds = true);
	public long get_time();
}
