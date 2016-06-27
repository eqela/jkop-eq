
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

public class CaldavAPI
{
	class CaldavAuthenticationResponse : CaldavAPIResponseReceiver
	{
		public override void on_string_response(String data, HTTPClientStringResponse resp) {
			var listener = get_listener();
			if(data != null) {
				if(listener != null) {
					listener.on_caldav_request_completed(new CaldavUserCredentials().set_login(true), null);
					return;
				}
			}
		}
	}

	class CaldavCalendarIDResponse : CaldavAPIResponseReceiver
	{
		property CaldavAPIResponseHandler handler;

		public override void on_string_response(String data, HTTPClientStringResponse resp) {
			var parser = XMLKeyValueParser.parse_string(data);
			var ids = parser.get("DAV:href") as Collection;
			var listener = get_listener();
			if(ids == null) {
				if(handler != null) {
					handler.on_caldav_request_completed(null, Error.for_message("Response Empty"));
					return;
				}
			}
			if(handler != null) {
				handler.on_caldav_request_completed(new CaldavAPICalendarID().set_calendar_id(ids), null);
			}
		}
	}

	class CaldavCalendarDetailsResponse : CaldavAPIResponseReceiver
	{
		property CaldavAPIResponseHandler handler;

		public override void on_string_response(String data, HTTPClientStringResponse resp) {
			var parser = XMLKeyValueParser.parse_string(data);
			var details = parser.get("DAV:href") as Collection;
			var listener = get_listener();
			if(details == null) {
				if(handler != null) {
					handler.on_caldav_request_completed(null, Error.for_message("Response Empty"));
					return;
				}
			}
			if(handler != null) {
				handler.on_caldav_request_completed(new CaldavAPICalendarDetails().set_calendar_details(details), null);
			}
		}
	}

	class CaldavPrincipalUserResponse : CaldavAPIResponseReceiver
	{
		property CaldavAPIResponseHandler handler;

		public override void on_string_response(String data, HTTPClientStringResponse resp) {
			var parser = XMLKeyValueParser.parse_string(data);
			var user = parser.get("DAV:href") as Collection;
			var listener = get_listener();
			if(user == null) {
				if(handler != null) {
					handler.on_caldav_request_completed(null, Error.for_message("Response Empty"));
					return;
				}
			}
			if(handler != null) {
				handler.on_caldav_request_completed(new CaldavAPIPrincipalUserResponse().set_users(user), null);
			}
		}
	}

	class CaldavCalendarICSResponse : CaldavAPIResponseReceiver
	{
		property CaldavAPIResponseHandler handler;

		class ICSLinksParser : XMLParser
		{
			Collection links;
			bool is_href = false;

			public Collection parse_data(String c) {
				links = LinkedList.create();
				if(parse_string(c) == true) {
					return(links);
				}
				return(null);
			}

			public override void on_start_element(String element, HashTable params) {
				if("DAV:href".equals(element)) {
					is_href = true;
				}
			}

			public override void on_end_element(String element) {
				if("DAV:href".equals(element)) {
					is_href = false;
				}
			}

			public override void on_cdata(String cdata) {
				if(is_href == true) {
					links.add(cdata);
				}
			}
		}

		public override void on_string_response(String data, HTTPClientStringResponse resp) {
			var icsparser = new ICSLinksParser();
			var ics_links = icsparser.parse_data(data);
			var listener = get_listener();
			if(ics_links == null) {
				if(handler != null) {
					handler.on_caldav_request_completed(null, Error.for_message("Response Empty"));
					return;
				}
			}
			if(handler != null) {
				handler.on_caldav_request_completed(new CaldavAPIICSResponse().set_ics(ics_links), null);
			}
		}
	}

	class CaldavCalendarDataResponse : CaldavAPIResponseReceiver
	{
		property CaldavAPIResponseHandler handler;

		class ICSResponseParser : XMLParser
		{
			Collection response_cdata;
			bool is_calendar_data = false;

			public Collection parse_data(String c) {
				response_cdata = LinkedList.create();
				if(parse_string(c) == true) {
					return(response_cdata);
				}
				return(null);
			}

			public override void on_start_element(String element, HashTable params) {
				if("calendar-data".equals(element)) {
					is_calendar_data = true;
				}
			}

			public override void on_end_element(String element) {
				if("calendar-data".equals(element)) {
					is_calendar_data = false;
				}
			}

			public override void on_cdata(String cdata) {
				if(is_calendar_data == true) {
					response_cdata.add(cdata);
				}
			}
		}

		public override void on_string_response(String data, HTTPClientStringResponse resp) {
			var icsparser = new ICSResponseParser();
			var calendar_details = icsparser.parse_data(data);
			var listener = get_listener();
			if(calendar_details == null) {
				if(handler != null) {
					handler.on_caldav_request_completed(null, Error.for_message("Failed to parse response"));
				}
				return;
			}

			if(handler != null) {
				handler.on_caldav_request_completed(new CaldavAPIEventsDetailsResponse().set_event_details(calendar_details), null);
			}
		}
	}

	public static CaldavAPI instance(BackgroundTaskManager btm, String host) {
		var caldavapi = new CaldavAPI();
		caldavapi.client = CaldavAPIHTTPClient.instance(btm, host);
		return(caldavapi);
	}

	property CaldavAPIHTTPClient client;
	CaldavAPIResponseHandler response_handler;

	public BackgroundTask get_calendar_id(String url, String code, String data, CaldavAPIListener listener) {
		return(client.get(url, code, data, "1", new CaldavCalendarIDResponse().set_handler(response_handler).set_listener(listener)));
	}

	public BackgroundTask get_calendar_details(String url, String code, String data, CaldavAPIListener listener) {
		return(client.get(url, code, data, "0", new CaldavCalendarDetailsResponse().set_handler(response_handler).set_listener(listener)));
	}

	public BackgroundTask query_user(String url, String code, String data, CaldavAPIListener listener) {
		return(client.get(url, code, data, "0", new CaldavAuthenticationResponse().set_listener(listener)));
	}

	public BackgroundTask get_calendar_events(String code, String data, CaldavAPIListener listener) {
		response_handler = new CaldavAPIResponseHandler();
		response_handler.set_caldav_api(this);
		response_handler.set_listener(listener);
		response_handler.set_code(code);
		return(client.get(null, code, data, "0", new CaldavPrincipalUserResponse().set_handler(response_handler).set_handler(response_handler).set_listener(listener)));
	}

	public BackgroundTask get_calendar_cdata(String id, String code, String data, CaldavAPIListener listener) {
		return(client.query(id, code, data, new CaldavCalendarDataResponse().set_handler(response_handler).set_listener(listener)));
	}

	public BackgroundTask get_events(String id, String code, String data, CaldavAPIListener listener) {
		return(client.query(id, code, data, new CaldavCalendarICSResponse().set_handler(response_handler).set_listener(listener)));
	}
}
