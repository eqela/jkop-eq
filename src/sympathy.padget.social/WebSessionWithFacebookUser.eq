
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

public class WebSessionWithFacebookUser : WebSessionWithUsername
{
	public static WebSessionWithFacebookUser instance(FacebookAPIUserProfile profile) {
		return(new WebSessionWithFacebookUser().set_profile(profile));
	}

	FacebookAPIUserProfile profile;
	property String facebook_token;

	public FacebookAPIUserProfile get_profile() {
		return(profile);
	}

	public WebSessionWithFacebookUser set_profile(FacebookAPIUserProfile profile) {
		this.profile = profile;
		if(profile != null) {
			set_username(profile.get_id());
		}
		else {
			set_username(null);
		}
		return(this);
	}

	public void get_properties(HashTable ht) {
		base.get_properties(ht);
		ht.set("facebook_token", facebook_token);
		if(profile != null) {
			var fields = profile.to_json_object() as HashTable;
			if(fields != null) {
				foreach(String key in fields.iterate_keys()) {
					ht.set(key, fields.get_string(key));
				}
			}
		}
	}
}
