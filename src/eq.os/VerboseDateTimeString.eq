
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

public class VerboseDateTimeString
{
	public static String for_now() {
		return(for_datetime(DateTime.for_now()));
	}

	static String short_day_name(int n) {
		switch(n) {
			case 1: { return("Sun"); }
			case 2: { return("Mon"); }
			case 3: { return("Tue"); }
			case 4: { return("Wed"); }
			case 5: { return("Thu"); }
			case 6: { return("Fri"); }
			case 7: { return("Sat"); }
		}
		return(null);
	}

	static String short_month_name(int n) {
		switch(n) {
			case 1: { return("Jan"); }
			case 2: { return("Feb"); }
			case 3: { return("Mar"); }
			case 4: { return("Apr"); }
			case 5: { return("May"); }
			case 6: { return("Jun"); }
			case 7: { return("Jul"); }
			case 8: { return("Aug"); }
			case 9: { return("Sep"); }
			case 10: { return("Oct"); }
			case 11: { return("Nov"); }
			case 12: { return("Dec"); }
		}
		return(null);
	}

	public static String for_datetime(DateTime dt) {
		if(dt == null) {
			return("NODATE");
		}
		var dd = dt.get_details(true);
		if(dd == null) {
			return(dt.to_string_datetime());
		}
		return("%s, %02d %s %d %02d:%02d:%02d GMT".printf()
			.add(short_day_name(dd.get_weekday()))
			.add(dd.get_day())
			.add(short_month_name(dd.get_month()))
			.add(dd.get_year())
			.add(dd.get_hours())
			.add(dd.get_minutes())
			.add(dd.get_seconds())
			.to_string());
	}
}
