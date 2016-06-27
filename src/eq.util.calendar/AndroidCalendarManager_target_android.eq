
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

public class AndroidCalendarManager : CalendarManager
{
	public bool add_event(String title, long date_in_seconds = 0, String calendar_id, String description = null) {
		if(String.is_empty(title) || String.is_empty(calendar_id)) {
			return(false);
		}
		embed "java" {{{
			android.content.ContentValues event = new android.content.ContentValues();
			event.put("calendar_id", calendar_id.to_strptr());
			event.put("title", title.to_strptr());
			if(description != null) {
				event.put("description", description.to_strptr());
			}
			long startTime = date_in_seconds * 1000;
			event.put("dtstart", startTime);
			event.put("dtend", startTime+6000);
			String timezone_ID = java.util.TimeZone.getDefault().getID();
			event.put("eventTimezone", timezone_ID);
			android.content.ContentResolver cr = eq.api.Android.context.getContentResolver();
			if(cr == null) {
				return(false);
			}
			android.net.Uri inserted_uri = cr.insert(android.provider.CalendarContract.Events.CONTENT_URI, event);
			int eventID = Integer.parseInt(inserted_uri.getLastPathSegment());
		}}}
		return(true);
	}

	public String add_calendar(String title, Color c)
	{
		if(String.is_empty(title) || c == null) {
			return(null);
		}
		String calendar = null;
		embed "java" {{{
				int c_int = android.graphics.Color.argb((int)(c.get_a() * 255), (int)(c.get_r() * 255), (int)(c.get_g() * 255), (int)(c.get_b() * 255));
				android.content.ContentValues cv = new android.content.ContentValues();
				cv.put(android.provider.CalendarContract.Calendars.ACCOUNT_NAME, "local");
				cv.put(android.provider.CalendarContract.Calendars.ACCOUNT_TYPE, android.provider.CalendarContract.ACCOUNT_TYPE_LOCAL);
				cv.put(android.provider.CalendarContract.Calendars.NAME, title.to_strptr());
				cv.put(android.provider.CalendarContract.Calendars.CALENDAR_DISPLAY_NAME, title.to_strptr());
				cv.put(android.provider.CalendarContract.Calendars.CALENDAR_COLOR, c_int);
				cv.put(android.provider.CalendarContract.Calendars.CALENDAR_ACCESS_LEVEL, android.provider.CalendarContract.Calendars.CAL_ACCESS_OWNER);
				cv.put(android.provider.CalendarContract.Calendars.OWNER_ACCOUNT, "local");
				android.net.Uri calUri = buildCalendarUri();
				android.content.ContentResolver cr = eq.api.Android.context.getContentResolver();
				if(cr == null) {
					return(null);
				}
				android.net.Uri inserted_uri = cr.insert(calUri, cv);
				int cal_ID = Integer.parseInt(inserted_uri.getLastPathSegment());
				String cal_ID_str = Integer.toString(cal_ID);
				calendar = eq.api.String.Static.for_strptr(cal_ID_str);
		}}}
		return(calendar);
	}

	public bool remove_calendar(String calendar_id) {
		if(String.is_empty(calendar_id)) {
			return(false);
		}
		embed "java" {{{
			android.content.ContentResolver cr = eq.api.Android.context.getContentResolver();
			if(cr == null) {
				return(false);
			}
			int cal_id = Integer.parseInt(calendar_id.to_strptr());
			android.net.Uri delete_uri = android.content.ContentUris.withAppendedId(buildCalendarUri(), cal_id);
			cr.delete(delete_uri, null, null);
		}}}
		return(true);
	}

	public Collection get_all_events () {
		var col = LinkedList.create();
		embed "java" {{{
			android.content.ContentResolver cr = eq.api.Android.context.getContentResolver();
			if(cr == null) {
				return(null);
			}
			String[] columns = { "title", "description", "dtstart", "_id"};
			android.database.Cursor cursor = cr.query(android.provider.CalendarContract.Events.CONTENT_URI, columns, null, null, null);
			if(cursor == null || cursor.getCount() <= 0) {
				return(null);
			}
			while(cursor.moveToNext()) {
				String title = cursor.getString(0);
				String description = cursor.getString(1);
				long dtstart = cursor.getLong(2);
				String id = cursor.getString(3);
				Event e = new Event();
				e.set_title(eq.api.String.Static.for_strptr(title));
				if(description != null) {
					e.set_description(eq.api.String.Static.for_strptr(description));
				}
				java.text.SimpleDateFormat formatter = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");
				java.util.Calendar calendar = java.util.Calendar.getInstance();
				calendar.setTimeInMillis(dtstart);
				String formatted_date = formatter.format(calendar.getTime());
				e.set_date(eq.api.String.Static.for_strptr(formatted_date));
				e.set_seconds(dtstart / 1000);
				if(id != null) {
					e.set_id(eq.api.String.Static.for_strptr(id));
				}
				col.add((eq.api.Object)e);
			}
			cursor.close();
		}}}
		return(col);
	}

	embed "java" {{{		
		private android.net.Uri buildCalendarUri() {
			return(android.provider.CalendarContract.Calendars.CONTENT_URI
					.buildUpon()
					.appendQueryParameter(android.provider.CalendarContract.CALLER_IS_SYNCADAPTER, "true")
					.appendQueryParameter(android.provider.CalendarContract.Calendars.ACCOUNT_NAME, "local")
					.appendQueryParameter(android.provider.CalendarContract.Calendars.ACCOUNT_TYPE, android.provider.CalendarContract.ACCOUNT_TYPE_LOCAL)
					.build());
		}
	}}}
}
