
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

public class TwitterAPIConfiguration : JSONObject
{
	public static TwitterAPIConfiguration for_json_object(Object o) {
		var c = new TwitterAPIConfiguration();
		c.from_json_object(o as HashTable);
		return(c);
	}

	public TwitterAPIConfiguration() {
		non_username_paths = LinkedList.create();
	}

	property int characters_reserved_per_media;
	property int max_media_per_upload;
	property Collection non_username_paths;
	property int photo_size_limit;
	property int short_url_length;
	property int short_url_length_https;

	public Object to_json_object() {
		var ht = HashTable.create();
		ht.set("characters_reserved_per_media", characters_reserved_per_media);
		ht.set("max_media_per_upload", max_media_per_upload);
		ht.set("non_username_paths", non_username_paths);
		ht.set("photo_size_limit", photo_size_limit);
		ht.set("short_url_length", short_url_length);
		ht.set("short_url_length_https", short_url_length_https);
		return(ht);
	}

	public bool from_json_object(Object o) {
		if(o is HashTable) {
			var ht = (HashTable)o;
			characters_reserved_per_media = Integer.as_integer(ht.get("characters_reserved_per_media"));
			max_media_per_upload = Integer.as_integer(ht.get("max_media_per_upload"));
			non_username_paths = ht.get("non_username_paths") as Collection;
			photo_size_limit = Integer.as_integer(ht.get("photo_size_limit"));
			short_url_length = Integer.as_integer(ht.get("short_url_length"));
			short_url_length_https = Integer.as_integer(ht.get("short_url_length_https"));
			return(true);
		}
		return(false);
	}
}
