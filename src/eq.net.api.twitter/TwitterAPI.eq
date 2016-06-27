
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

public class TwitterAPI
{
	class TwitterAPITokenRequestResponseReceiver : TwitterAPIStringReponseReceiver
	{
		public void on_string_response(String data, HTTPClientStringResponse resp) {
			var ht = QueryString.parse(data);
			var oauth_token = ht.get("oauth_token") as String;
			var oauth_token_secret = ht.get("oauth_token_secret") as String;
			var oauth_callback_confirmed = Boolean.as_boolean(ht.get("oauth_callback_confirmed") as String);
			var l = get_listener();
			if(l != null) {
				l.on_twitter_api_request_completed(new TwitterAPIRequestTokenResponse()
					.set_oauth_token(oauth_token)
					.set_oauth_token_secret(oauth_token_secret)
					.set_oauth_callback_confirmed(oauth_callback_confirmed), null);
			}
		}
	}

	class TwitterAPIAccessTokenResponseReceiver : TwitterAPIStringReponseReceiver
	{
		public void on_string_response(String data, HTTPClientStringResponse resp) {
			var ht = QueryString.parse(data);
			var oauth_token = ht.get("oauth_token") as String;
			var oauth_token_secret = ht.get("oauth_token_secret") as String;
			var l = get_listener();
			if(l != null) {
				l.on_twitter_api_request_completed(new TwitterAPIAccessTokenResponse()
					.set_oauth_token(oauth_token)
					.set_oauth_token_secret(oauth_token_secret), null);
			}
		}
	}

	class TwitterAPIUserProfileResponseReceiver : TwitterAPIJSONReponseReceiver
	{
		public void on_json_response(Object data, HTTPClientStringResponse resp) {
			var user_profile = TwitterAPIUserProfile.for_json_object(data);
			var l = get_listener();
			if(l != null) {
				l.on_twitter_api_request_completed(new TwitterAPIUserProfileResponse().set_user_profile(user_profile), null);
			}
		}
	}

	class TwitterAPIConfigurationResponseReceiver : TwitterAPIJSONReponseReceiver
	{
		public void on_json_response(Object data, HTTPClientStringResponse resp) {
			var tt_config = TwitterAPIConfiguration.for_json_object(data);
			var l = get_listener();
			if(l != null) {
				l.on_twitter_api_request_completed(new TwitterAPIConfigurationResponse().set_twitter_config(tt_config), null);
			}
		}
	}

	class TwitterAPIPostStatusResponseReceiver : TwitterAPIJSONReponseReceiver
	{
		public void on_json_response(Object data, HTTPClientStringResponse resp) {
			var ht = (HashTable)data;
			var id = ht.get("id_str") as String;
			var l = get_listener();
			if(l != null) {
				l.on_twitter_api_request_completed(new TwitterAPIPostStatusResponse().set_id(id), null);
			}
		}
	}

	class TwitterAPIUpoadPhotoResponseReceiver : TwitterAPIJSONReponseReceiver
	{
		public void on_json_response(Object data, HTTPClientStringResponse resp) {
			var ht = (HashTable)data;
			var id = ht.get("media_id_string") as String;
			var l = get_listener();
			if(l != null) {
				l.on_twitter_api_request_completed(new TwitterAPIUploadPhotoResponse().set_id(id), null);
			}
		}
	}

	public static TwitterAPI instance(BackgroundTaskManager btm, String ckey, String csecret) {
		var tt = new TwitterAPI();
		tt.client = TwitterAPIHTTPClient.instance(btm, ckey, csecret);
		return(tt);
	}

	public static TwitterAPI for_http_client(TwitterAPIHTTPClient client) {
		var tt = new TwitterAPI();
		tt.client = client;
		return(tt);
	}

	property TwitterAPIHTTPClient client;

	public BackgroundTask get_current_user_profile(TwitterAPIListener listener) {
		return(client.get("account/verify_credentials.json", new TwitterAPIUserProfileResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask get_twitter_config(TwitterAPIListener listener) {
		return(client.get("help/configuration.json", new TwitterAPIConfigurationResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask post_status(String status, Collection media_ids = null, TwitterAPIListener listener = null) {
		var sb = StringBuffer.create();
		sb.append("statuses/update.json?");
		sb.append("status=");
		sb.append(status);
		if(media_ids != null) {
			sb.append("&media_ids=");
			int x = 1;
			foreach(String id in media_ids) {
				sb.append(id);
				if(media_ids.count() - x > 0) {
					sb.append(",");
				}
				x++;
			}
		}
		return(client.post(sb.to_string(), new TwitterAPIPostStatusResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask upload_photo(File file, TwitterAPIListener listener){
		var boundary = "AaB03x";
		var buffer = DynamicBuffer.create(1024);
		var ous = OutputStream.create(BufferWriter.for_buffer(buffer));
		ous.write_string("--");
		ous.write_string(boundary);
		ous.write_string("\r\n");
		ous.write_string("Content-Disposition: form-data; name=\"media\"; filename=\"%s\"".printf().add(file.basename()).to_string());
		ous.write_string("\r\n");
		ous.write_string("Content-Type: ");
		ous.write_string("application/octet-stream");
		ous.write_string("\r\n\r\n");
		var buf = file.get_contents_buffer();
		ous.write_buffer(buf);
		ous.write_string("\r\n--");
		ous.write_string(boundary);
		ous.write_string("--}");
		var data = BufferReader.for_buffer(buffer);
		return(client.post_with_data("multipart/form-data; boundary=".append(boundary), data, new TwitterAPIUpoadPhotoResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask request_oauth_token_for_login(String oauth_callback, TwitterAPIListener listener) {
		return(client.post_for_login("oauth/request_token", oauth_callback, new TwitterAPITokenRequestResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask request_access_token(TwitterAPIConvertableToken token, String tsecret, TwitterAPIListener listener) {
		return(client.post_for_access_token("oauth/access_token", token, tsecret, new TwitterAPIAccessTokenResponseReceiver().set_listener(listener)));
	}
}
