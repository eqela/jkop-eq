
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

public class GoogleCalendarAPI
{
	class GoogleCalendarEventsResponseReceiver : GoogleCalendarAPIResponseReceiver
	{
		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			var ht = (HashTable)data;
			var events = GoogleCalendarAPIEvents.for_json_object(data);
			var l = get_listener();
			if(l != null) {
				l.on_google_api_request_completed(new GoogleCalendarAPIEventsResponse().set_calendar_events(events), null);
			}
		}
	}

	class GoogleCalendarAccessTokenResponseReceiver : GoogleCalendarAPIResponseReceiver
	{
		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			var ht = (HashTable)data;
			var accesstoken = ht.get_string("access_token");
			var expiration = ht.get_string("expires_in");
			var refreshtoken = ht.get_string("refresh_token");
			var l = get_listener();
			if(l != null) {
				l.on_google_api_request_completed(new GoogleCalendarAPIAccessTokenResponse().set_access_token(accesstoken).set_expiry_time(expiration).set_refresh_token(refreshtoken), null);
			}
		}
	}

	class GoogleCalendarRefreshTokenReceiver : GoogleCalendarAPIResponseReceiver
	{
		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			var ht = (HashTable)data;
			var accesstoken = ht.get_string("access_token");
			var expiration = ht.get_string("expires_in");
			var l = get_listener();
			if(l != null) {
				l.on_google_api_request_completed(new GoogleCalendarAPIAccessTokenResponse().set_access_token(accesstoken).set_expiry_time(expiration), null);
			}
		}
	}

	class GoogleCalendarListResponseReceiver : GoogleCalendarAPIResponseReceiver
	{
		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			var ht = (HashTable)data;
			var calendars = LinkedList.create();
			var col = ht.get("items") as Collection;
			var l = get_listener();
			if(col != null && col.count() > 0) {
				foreach(Object o in col) {
					calendars.add(GoogleCalendarAPICalendar.for_json_object(o));
				}
			}
			else {
				if(l != null) {
					l.on_google_api_request_completed(null, Error.for_message("Empty response."));
				}
				return;
			}
			if(l != null) {
				l.on_google_api_request_completed(new GoogleCalendarAPICalendarListResponse().set_calendars(calendars), null);
			}
		}
	}

	property GoogleCalendarAPIHTTPClient client;

	public static GoogleCalendarAPI instance(BackgroundTaskManager btm, String cid, String scope) {
		var gca = new GoogleCalendarAPI();
		gca.client = GoogleCalendarAPIHTTPClient.instance(btm, null, cid, scope);
		return(gca);
	}

	public BackgroundTask request_new_token(String code, GoogleCalendarAPIListener listener) {
		return(client.query_refresh_token("/oauth2/v3/token", code, new GoogleCalendarAccessTokenResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask exchange_token(String code, GoogleCalendarAPIListener listener) {
		return(client.query_access_token("/oauth2/v3/token", code, new GoogleCalendarAccessTokenResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask get_calendar_list(String token, GoogleCalendarAPIListener listener) {
		var url = "/calendar/v3/users/me/calendarList";
		return(client.query(url, token, new GoogleCalendarListResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask get_calendar_events(String id, String token, GoogleCalendarAPIListener listener) {
		var calendar_id = URLEncoder.encode(id, false, false);
		var url = "/calendar/v3/calendars/".append(calendar_id).append("/events");
		return(client.query(url, token, new GoogleCalendarEventsResponseReceiver().set_listener(listener)));
	}
}
