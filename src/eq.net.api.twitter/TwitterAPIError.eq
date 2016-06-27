
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

public class TwitterAPIError : Error, JSONObject
{
	public static TwitterAPIError for_json_object(Object o) {
		var tt_error = new TwitterAPIError();
		tt_error.from_json_object(o as HashTable);
		return(tt_error);
	}

	public Object to_json_object() {
		var ht = HashTable.create();
		ht.set("message", get_message());
		ht.set("code", Integer.as_integer(get_code()));
		return(ht);
	}

	public bool from_json_object(Object o) {
		if(o is HashTable) {
			var ht = (HashTable)o;
			set_message(ht.get("message") as String);
			set_code("%d".printf().add(Integer.as_integer(ht.get("code"))).to_string());
			return(true);
		}
		return(false);
	}
}
