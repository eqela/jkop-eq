
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

public class FacebookAPI
{
	class FacebookAPIUserProfileResponseReceiver : FacebookAPIResponseReceiver
	{
		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			var user_profile = FacebookAPIUserProfile.for_json_object(data);
			var l = get_listener();
			if(l != null) {
				l.on_facebook_api_request_completed(new FacebookAPIUserProfileResponse().set_user_profile(user_profile).set_http_resp(resp), null);
			}
		}
	}

	class FacebookAPIUserFriendsResponseReceiver : FacebookAPIResponseReceiver
	{
		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			var ht = (HashTable)data;
			var user_friends = LinkedList.create();
			var col = ht.get("data") as Collection;
			var l = get_listener();
			if(col != null && col.count() > 0) {
				foreach(Object o in col) {
					user_friends.add(FacebookAPIUserProfile.for_json_object(o));
				}
			}
			else {
				if(l != null) {
					l.on_facebook_api_request_completed(null, Error.for_message("Empty response."));
				}
				return;
			}
			var cursors = FacebookAPICursors.for_json_object(((HashTable)ht.get("paging")).get("cursors"));
			if(l != null) {
				l.on_facebook_api_request_completed(new FacebookAPIUserFriendsResponse().set_user_friends(user_friends).set_cursors(cursors).set_http_resp(resp), null);
			}
		}
	}

	class FacebookAPIUserEventsResponseReceiver : FacebookAPIResponseReceiver
	{
		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			var ht = (HashTable)data;
			var user_events = LinkedList.create();
			var col = ht.get("data") as Collection;
			var l = get_listener();
			if(col != null && col.count() > 0) {
				foreach(Object o in col) {
					user_events.add(FacebookAPIEvent.for_json_object(o));
				}
			}
			else {
				if(l != null) {
					l.on_facebook_api_request_completed(null, Error.for_message("Empty response."));
				}
				return;
			}
			var cursors = FacebookAPICursors.for_json_object(((HashTable)ht.get("paging")).get("cursors"));
			if(l != null) {
				l.on_facebook_api_request_completed(new FacebookAPIUserEventsResponse().set_user_events(user_events).set_cursors(cursors).set_http_resp(resp), null);
			}
		}
	}

	class FacebookAPIPublishResponseReceiver : FacebookAPIResponseReceiver
	{
		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			String id = ((HashTable)data).get("id") as String;
			var l = get_listener();
			if(l != null) {
				l.on_facebook_api_request_completed(new FacebookAPIPublishResponse().set_id(id).set_http_resp(resp), null);
			}
		}
	}

	class FacebookAPIPermissionsResponseReceiver : FacebookAPIResponseReceiver
	{
		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			var permissions = LinkedList.create();
			var col = ((HashTable)data).get("data") as Collection;
			var l = get_listener();
			if(col != null && col.count() > 0) {
				foreach(Object o in col) {
					permissions.add(FacebookAPIPermission.for_json_object(o));
				}
			}
			else {
				if(l != null) {
					l.on_facebook_api_request_completed(null, Error.for_message("Empty response."));
				}
				return;
			}
			if(l != null) {
				l.on_facebook_api_request_completed(new FacebookAPIPermissionsResponse()
					.set_permissions(permissions)
					.set_http_resp(resp)
					, null);
			}
		}
	}

	public static FacebookAPI instance(BackgroundTaskManager btm, String access_token) {
		var fb = new FacebookAPI();
		fb.client = FacebookAPIHTTPClient.instance(btm, access_token);
		return(fb);
	}

	public static FacebookAPI for_http_client(FacebookAPIHTTPClient client) {
		var fb = new FacebookAPI();
		fb.client = client;
		return(fb);
	}

	FacebookAPIHTTPClient client;
	String boundary = "AaB03x";

	public BackgroundTask query_current_user_profile(FacebookAPIListener listener) {
		String url = "me";
		return(client.query(url, new FacebookAPIUserProfileResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask query_user_profile_by_id(String user_id, FacebookAPIListener listener) {
		String url = user_id;
		return(client.query(url, new FacebookAPIUserProfileResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask query_permissions(FacebookAPIListener listener) {
		String url = "me/permissions";
		return(client.query(url, new FacebookAPIPermissionsResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask query_current_user_friends(FacebookAPIListener listener, int limit = 10, String after = null, String before = null) {
		var sb = StringBuffer.create();
		sb.append("me/taggable_friends?");
		sb.append("limit=");
		sb.append(String.for_integer(limit));
		if(String.is_empty(after) == false) {
			sb.append("&after=");
			sb.append(after);
		}
		else if(String.is_empty(before) == false) {
			sb.append("&before=");
			sb.append(before);
		}
		return(client.query(sb.to_string(), new FacebookAPIUserFriendsResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask query_current_user_events(FacebookAPIListener listener, int since = 0, int limit = 10, String after = null, String before = null) {
		var sb = StringBuffer.create();
		sb.append("me/events?");
		sb.append("since=");
		sb.append(String.for_integer(since));
		sb.append("&limit=");
		sb.append(String.for_integer(limit));
		if(String.is_empty(after) == false) {
			sb.append("&after=");
			sb.append(after);
		}
		else if(String.is_empty(before) == false) {
			sb.append("&before=");
			sb.append(before);
		}
		return(client.query(sb.to_string(), new FacebookAPIUserEventsResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask publish_status(FacebookMessage message, FacebookAPIListener listener) {
		var sb = StringBuffer.create();
		sb.append("me/feed?");
		sb.append("message=");
		String text = message.get_text();
		if(String.is_empty(text) == false) {
			sb.append(URLEncoder.encode(text));
		}
		var h = message.get_hashtags();
		foreach(String s in h) {
			if(String.is_empty(s)) {
				continue;
			}
			sb.append(URLEncoder.encode(s));
		}
		sb.append("&link=");
		String link = message.get_link();
		if(String.is_empty(text) == false) {
			sb.append(link);
		}
		sb.append("&object_attachment=");
		String image = message.get_facebook_image_id();
		if(String.is_empty(image) == false) {
			sb.append(image);
		}
		var user_ids = message.get_user_ids();
		var location_id = message.get_location_id();
		if(user_ids != null && user_ids.count() > 0) {
			sb.append("&place=");
			if(String.is_empty(location_id) == false) {
				sb.append(location_id);
			}
			else {
				sb.append("155021662189"); // unknown location
			}
			sb.append("&tags=");
			int x = 1;
			foreach(String id in user_ids) {
				sb.append(id);
				if(user_ids.count() - x > 0) {
					sb.append(",");
				}
				x++;
			}
		}
		return(client.publish(sb.to_string(), new FacebookAPIPublishResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask publish_status_with_album(FacebookMessage message, FacebookAPIListener listener, FacebookAPIPhotoAlbum album) {
		if(message == null || album == null) {
			return(null);
		}
		var sb = StringBuffer.create();
		sb.append("message=");
		String text = message.get_text();
		if(String.is_empty(text) == false) {
			sb.append(URLEncoder.encode(text));
		}
		var h = message.get_hashtags();
		foreach(String s in h) {
			if(String.is_empty(s)) {
				continue;
			}
			sb.append(URLEncoder.encode(s));
		}
		sb.append("&link=");
		String link = message.get_link();
		if(String.is_empty(text) == false) {
			sb.append(link);
		}
		var location_id = message.get_location_id();
		sb.append("&place=");
		if(String.is_empty(location_id) == false) {
			sb.append(location_id);
		}
		else {
			sb.append("155021662189"); // unknown location
		}
		return(check_photo_album_existence(sb.to_string(), message.get_user_ids(), album, listener));
	}

	public BackgroundTask upload_photo_by_url(String url, String message, bool hide_in_timeline = false, FacebookAPIListener listener = null) {
		var sb = StringBuffer.create();
		sb.append("me/photos?");
		sb.append("url=");
		if(String.is_empty(url) == false) {
			sb.append(url);
		}
		sb.append("&message=");
		if(String.is_empty(message) == false) {
			sb.append(message);
		}
		sb.append("&no_story=");
		sb.append(String.for_boolean(hide_in_timeline));
		return(client.publish(sb.to_string(), new FacebookAPIPublishResponseReceiver().set_listener(listener)));
	}

	public BackgroundTask upload_photo_by_file(File file, String post_details, String album_id, Collection tagged_users, FacebookAPIListener listener) {
		var sb = StringBuffer.create();
		if(String.is_empty(album_id) == true) {
			sb.append("me/photos?");
		}
		else {
			sb.append(album_id);
			sb.append("/photos?");
		}
		if(String.is_empty(post_details) == false) {
			sb.append(post_details);
		}
		BufferReader data = null;
		var mime_type = MimeTypeRegistry.type_for_file(file);
		if(mime_type.str("image") == 0) {
			data = create_multipart_form_data(file, mime_type);
		}
		return(client.publish_with_data(sb.to_string(), "multipart/form-data; boundary=".append(boundary), data, new FacebookPhotoUploadReceiver()
			.set_client(this).set_tagged_users(tagged_users).set_listener(listener)));
	}

	class FacebookAPIPhotoAlbumExistenceChecker : FacebookAPIResponseReceiver
	{
		property String post_details;
		property Collection tagged_users;
		property FacebookAPI client;
		property FacebookAPIPhotoAlbum album;

		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			if(data is HashTable) {
				var listener = get_listener();
				if(listener == null) {
					return;
				}
				var collection = ((HashTable)data).get("data") as Collection;
				if(collection != null && collection.count() > 0) {
					var name = album.get_name();
					bool is_album_existing = false;
					foreach(Object obj in collection) {
						var ht = (HashTable)obj;
						var album_name = ht.get("name") as String;
						if(album_name.equals(name) == true) {
							album.set_id(ht.get("id") as String);
							is_album_existing = true;
							break;
						}
					}
					if(is_album_existing == true) {
						client.upload_photos_to_album(post_details, album, listener, tagged_users);
					}
					else {
						client.create_photo_album(album, new FacebookPhotoAlbumCreationResponseReceiver().set_client(client).set_album(album)
							.set_tagged_users(tagged_users)
							.set_post_details(post_details).set_listener(listener));
					}
				}
			}
		}
	}

	class FacebookPhotoUploadReceiver : FacebookAPIResponseReceiver
	{
		property Collection tagged_users;
		property FacebookAPI client;

		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			String id = ((HashTable)data).get("id") as String;
			var listener = get_listener();
			if(listener != null) {
				if(String.is_empty(id) == false && tagged_users != null && tagged_users.count() > 0) {
					client.do_tag_friends(id, tagged_users, new FacebookPhotoTaggingReceiver().set_listener(listener));
					return;
				}
				listener.on_facebook_api_request_completed(new FacebookAPIPublishResponse().set_id(id).set_http_resp(resp), null);
			}
		}
	}

	class FacebookPhotoTaggingReceiver : FacebookAPIResponseReceiver
	{
		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			var listener = get_listener();
			if(listener != null) {
				listener.on_facebook_api_request_completed(new FacebookAPIPublishResponse().set_id(((HashTable)data).get("id") as String).set_http_resp(resp), null);
			}
		}
	}

	class FacebookPhotoAlbumCreationResponseReceiver : FacebookAPIResponseReceiver
	{
		property String post_details;
		property Collection tagged_users;
		property FacebookAPI client;
		property FacebookAPIPhotoAlbum album;

		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			String id = ((HashTable)data).get("id") as String;
			var listener = get_listener();
			if(listener != null && String.is_empty(id) == false) {
				album.set_id(id);
				client.upload_photos_to_album(post_details, album, listener, tagged_users);
			}
		}
	}

	class FacebookVideoUploadReceiver : FacebookAPIResponseReceiver
	{
		property Collection tagged_users;
		property FacebookAPIHTTPClient client;

		public override void on_json_response(Object data, HTTPClientStringResponse resp) {
			String id = ((HashTable)data).get("id") as String;
			var listener = get_listener();
			if(listener != null) {
				if(String.is_empty(id) == false && tagged_users != null && tagged_users.count() > 0) {
					foreach(String user in tagged_users) {
						var sb = StringBuffer.create();
						sb.append(id);
						sb.append("/tags?");
						sb.append("tag_uid=".append(user));
						client.publish(sb.to_string(), null);
					}
				}
				listener.on_facebook_api_request_completed(new FacebookAPIPublishResponse().set_id(id).set_http_resp(resp), null);
			}
		}
	}

	BackgroundTask check_photo_album_existence(String post_details, Collection tagged_users, FacebookAPIPhotoAlbum album, FacebookAPIListener listener) {
		var sb = StringBuffer.create();
		sb.append("me/albums");
		return(client.query(sb.to_string(), new FacebookAPIPhotoAlbumExistenceChecker().set_album(album).set_tagged_users(tagged_users)
			.set_post_details(post_details).set_client(this).set_listener(listener)));
	}

	public BackgroundTask create_photo_album(FacebookAPIPhotoAlbum album, FacebookAPIResponseReceiver listener) {
		if(album == null) {
			return(null);
		}
		var sb = StringBuffer.create();
		sb.append("me/albums?");
		sb.append("name=");
		var name = album.get_name();
		if(String.is_empty(name) == false) {
			sb.append(name);
		}
		sb.append("&description=");
		var desc = album.get_description();
		if(String.is_empty(desc) == false) {
			sb.append(desc);
		}
		return(client.publish(sb.to_string(), listener));
	}

	public BackgroundTask do_tag_friends(String photo_id, Collection tagged_users, FacebookAPIResponseReceiver listener) {
		var sb = StringBuffer.create();
		sb.append(photo_id);
		sb.append("/tags?");
		sb.append("tags=");
		var col = LinkedList.create();
		foreach(String user in tagged_users) {
			col.add(HashTable.create().set("tag_uid", user));
		}
		sb.append(JSONEncoder.encode(col));
		return(client.publish(sb.to_string(), listener));
	}

	public void upload_photos_to_album(String post_details, FacebookAPIPhotoAlbum album, FacebookAPIListener listener, Collection tagged_users = null) {
		if(album == null) {
			return;
		}
		var photos = album.get_photos();
		var album_id = album.get_id();
		foreach(File photo in photos) {
			upload_photo_by_file(photo, post_details, album_id, tagged_users, listener);
		}
		photos.clear();
	}

	public BackgroundTask upload_video_by_file(File file, String post_details, Collection tagged_users, FacebookAPIListener listener) {
		var sb = StringBuffer.create();
		sb.append("me/videos?");
		if(String.is_empty(post_details) == false) {
			sb.append(post_details);
		}
		BufferReader data = null;
		var mime_type = MimeTypeRegistry.type_for_file(file);
		if(mime_type.str("video") == 0) {
			data = create_multipart_form_data(file, mime_type);
		}
		return(client.publish_with_video(sb.to_string(), "multipart/form-data; boundary=".append(boundary), data, new FacebookVideoUploadReceiver()
			.set_client(client).set_tagged_users(tagged_users).set_listener(listener)));
	}

	private BufferReader create_multipart_form_data(File file, String mime_type) {
		var buffer = DynamicBuffer.create(1024);
		var ous = OutputStream.create(BufferWriter.for_buffer(buffer));
		ous.write_string("--");
		ous.write_string(boundary);
		ous.write_string("\r\n");
		ous.write_string("Content-Disposition: form-data; name=\"source\"; filename=\"%s\"".printf().add(file.basename()).to_string());
		ous.write_string("\r\n");
		ous.write_string("Content-Type: ");
		ous.write_string(mime_type);
		ous.write_string("\r\n\r\n");
		var buf = file.get_contents_buffer();
		ous.write_buffer(buf);
		ous.write_string("\r\n--");
		ous.write_string(boundary);
		ous.write_string("--}");
		return(BufferReader.for_buffer(buffer));
	}
}
