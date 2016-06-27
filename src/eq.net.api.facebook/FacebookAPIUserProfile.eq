
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

public class FacebookAPIUserProfile : JSONObject
{
	public static FacebookAPIUserProfile for_json_object(Object o) {
		var up = new FacebookAPIUserProfile();
		up.from_json_object(o as HashTable);
		return(up);
	}

	property String id;
	property String name;
	property String firstname;
	property String lastname;
	property String gender;
	property String email_address;
	property String image_url;

	public Object to_json_object() {
		var ht = HashTable.create();
		ht.set("id", id);
		ht.set("name", name);
		ht.set("first_name", firstname);
		ht.set("last_name", lastname);
		ht.set("gender", gender);
		ht.set("email", email_address);
		return(ht);
	}

	public bool from_json_object(Object o) {
		if(o is HashTable) {
			var ht = (HashTable)o;
			id = ht.get("id") as String;
			name = ht.get("name") as String;
			firstname = ht.get("first_name") as String;
			lastname = ht.get("last_name") as String;
			gender = ht.get("gender") as String;
			email_address = ht.get("email") as String;
			var picture = ht.get("picture") as HashTable;
			if(picture != null) {
				var data = picture.get("data") as HashTable;
				if(data != null) {
					image_url = data.get_string("url");
				}
			}
			return(true);
		}
		return(false);
	}
}
