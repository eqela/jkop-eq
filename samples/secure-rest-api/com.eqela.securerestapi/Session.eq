
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

public class Session : JSONObject
{
	public static Session for_username(String username) {
		return(new Session()
			.initialize(username));
	}

	property String username;
	property String session_id;

	public Session initialize(String username) {
		if(String.is_empty(username)) {
			return(null);
		}
		session_id = SHAEncoder.encode("%s%d%d".printf()
			.add(username)
			.add(SystemClock.seconds())
			.add(Math.random(0, 10000000))
			.to_string(), SHAEncoder.SHA256);
		return(this);
	}

	public bool from_json_object(Object o) {
		var h = o as HashTable;
		if(h == null) {
			return(false);
		}
		session_id = h.get_string("session_id");
		username = h.get_string("username");
		if(String.is_empty(session_id) || String.is_empty(username)) {
			session_id = null;
			username = null;
			return(false);
		}
		return(true);
	}

	public Object to_json_object() {
		return(HashTable.create()
			.set("session_id", session_id)
			.set("username", username));
	}
}
