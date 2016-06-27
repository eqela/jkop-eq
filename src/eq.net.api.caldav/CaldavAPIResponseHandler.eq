
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

public class CaldavAPIResponseHandler : CaldavAPIListener
{
	property CaldavAPI caldav_api;
	property CaldavAPIListener listener;
	property String code;
	Collection event_details;
	Collection ids;
	String calendar_id;
	int counter = 1;
	int calendar_count = 0;

	public CaldavAPIResponseHandler() {
		event_details = LinkedList.create();
	}

	public void on_caldav_request_completed(CaldavAPIResponse resp, Error err) {
		if(resp == null) {
			if(calendar_id == null) {
				listener.on_caldav_request_completed(null, Error.for_message("No events retrieved"));
				return;
			}
		}
		if(resp is CaldavAPIPrincipalUserResponse) {
			var user_response = (CaldavAPIPrincipalUserResponse)resp;
			var users = user_response.get_users();
			String principal_user;
			foreach(String str in users) {
				if(str.has_prefix("/principals")) {
					principal_user = str;
					break;
				}
			}
			caldav_api.get_calendar_details(principal_user, code, CaldavAPIXMLWriter.create_calendar_home_set(), this);
			return;
		}
		if(resp is CaldavAPICalendarDetails) {
			var data = (CaldavAPICalendarDetails)resp;
			var details = data.get_calendar_details();
			String url;
			foreach(String str in details) {
				if(str.has_prefix("/dav")) {
					url = str;
					break;
				}
			}
			caldav_api.get_calendar_id(url, code, CaldavAPIXMLWriter.calendar_identification(), this);
			return;
		}
		if(resp is CaldavAPICalendarID) {
			var data = (CaldavAPICalendarID)resp;
			ids = data.get_calendar_id();
			calendar_count = ids.count() - 1;
			calendar_id = ids.get(counter) as String;
			caldav_api.get_events(calendar_id, code, CaldavAPIXMLWriter.create_request(), this);
			return;
		}
		if(resp is CaldavAPIICSResponse) {
			var data = (CaldavAPIICSResponse)resp;
			var links = data.get_ics();
			caldav_api.get_calendar_cdata(calendar_id, code, CaldavAPIXMLWriter.create_multilinks(links), this);
			return;
		}
		if(resp is CaldavAPIEventsDetailsResponse) {
			var data = (CaldavAPIEventsDetailsResponse)resp;
			var details = data.get_event_details();
			String line;
			bool is_event = false;
			foreach(String str in details) {
				var ht = HashTable.create();
				var reader = InputStream.for_reader(StringReader.for_string(str));
				while((line = reader.readline()) != null) {
					if(line.has_prefix("BEGIN:VEVENT")) {
						is_event = true;
					}
					if(is_event == true) {
						if(line.has_prefix("SUMMARY:")) {
							ht.set("summary", line.substring(8));
						}
						if(line.has_prefix("DTSTART;")) {
							var dt = line.split((int)':');
							var timezoneid = dt.next() as String;
							var datetime = dt.next() as String;
							ht.set("datetime", datetime);
						}
						if(line.has_prefix("END:VCALENDAR")) {
							event_details.add(ht);
						}
					}
				}
			}
		}
		if(counter < calendar_count) {
			counter++;
			calendar_id = ids.get(counter) as String;
			caldav_api.get_events(calendar_id, code, CaldavAPIXMLWriter.create_request(), this);
			return;
		}
		if(listener != null) {
			listener.on_caldav_request_completed(new CaldavAPIEventsResponse().set_events(event_details), null);
		}
		return;
	}
}
