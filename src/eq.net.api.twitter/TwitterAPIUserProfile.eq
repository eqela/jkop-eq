
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

public class TwitterAPIUserProfile : JSONObject
{
	public static TwitterAPIUserProfile for_json_object(Object o) {
		var up = new TwitterAPIUserProfile();
		up.from_json_object(o as HashTable);
		return(up);
	}

	property String id;
	property String name;
	property String screen_name;
	property String location;
	property String profile_image_url;

	public Object to_json_object() {
		var ht = HashTable.create();
		ht.set("id_str", id);
		ht.set("name", name);
		ht.set("screen_name", screen_name);
		ht.set("location", location);
		ht.set("profile_image_url", profile_image_url);
		return(ht);
	}

	public bool from_json_object(Object o) {
		if(o is HashTable) {
			var ht = (HashTable)o;
			id = ht.get("id_str") as String;
			name = ht.get("name") as String;
			screen_name = ht.get("screen_name") as String;
			location = ht.get("location") as String;
			profile_image_url = ht.get("profile_image_url") as String;
			return(true);
		}
		return(false);
	}
}
