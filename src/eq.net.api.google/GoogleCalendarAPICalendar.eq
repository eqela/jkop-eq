
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

public class GoogleCalendarAPICalendar : JSONObject
{
	public static GoogleCalendarAPICalendar for_json_object(Object o) {
		var gc = new GoogleCalendarAPICalendar();
		gc.from_json_object(o as HashTable);
		return(gc);
	}

	property String kind;
	property String etag;
	property String id;
	property String summary;
	property String time_zone;
	property String access_role;

	public Object to_json_object() {
		var ht = HashTable.create();
		ht.set("kind", kind);
		ht.set("etag", etag);
		ht.set("id", id);
		ht.set("summary", summary);
		ht.set("time_zone", time_zone);
		ht.set("access_role", access_role);
		return(ht);
	}

	public bool from_json_object(Object o) {
		if(o is HashTable) {
			var ht = (HashTable)o;
			kind = ht.get("kind") as String;
			etag = ht.get("etag") as String;
			id = ht.get("id") as String;
			summary = ht.get("summary") as String;
			time_zone = ht.get("time_zone") as String;
			access_role = ht.get("access_role") as String;
			return(true);
		}
		return(false);
	}
}
