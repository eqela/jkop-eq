
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

public class GoogleCalendarAPIEvents : JSONObject
{
	public static GoogleCalendarAPIEvents for_json_object(Object o) {
		var gc = new GoogleCalendarAPIEvents();
		gc.from_json_object(o as HashTable);
		return(gc);
	}

	property HashTable events;

	public Object to_json_object() {
		var ht = HashTable.create();
		ht.set("events", events);
		return(ht);
	}

	public bool from_json_object(Object o) {
		if(o is HashTable) {
			var ht = (HashTable)o;
			var dt = parse_events(ht.get("items") as Collection);
			events = HashTable.create();
			events.set("events", dt);
			return(true);
		}
		return(false);
	}

	public Collection parse_events(Collection events) {
		var details = LinkedList.create();
		if(events != null) {
			foreach(HashTable ht in events) {
				var title = ht.get_string("summary");
				var desc = ht.get_string("description");
				var start = ht.get("start") as HashTable;
				String datetime = start.get("dateTime") as String;
				if(String.is_empty(datetime)) {
					datetime = start.get("date") as String;
				}
				var key = ht.get_string("id") as String;
				details.add(HashTable.create().set("key", key).set("title", title).set("description", desc).set("datetime", datetime));
			}
			return(details);
		}
		return(null);

	}
}
