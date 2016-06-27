
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

public class TwilioAPIClient
{
	class ResponseListener : EventReceiver
	{
		property TwilioAPIResponseListener listener;

		public void on_event(Object o) {
			if(listener == null) {
				Log.error("no TwilioAPIResponseListener object specified");
				return;
			}
			if(o is HTTPClientStringResponse) {
				listener.on_twilio_api_response(((HTTPClientStringResponse)o).get_data());
				return;
			}
			Log.error("Unknown response object");
			listener.on_twilio_api_response(null);
		}
	}

	public static TwilioAPIClient for_credentials(String sid, String token, String number, BackgroundTaskManager background_task_manager) {
		return(new TwilioAPIClient().set_background_task_manager(background_task_manager)
			.set_account_sid(sid).set_auth_token(token).set_twilio_number(number));
	}

	property BackgroundTaskManager background_task_manager;
	property String account_sid;
	property String auth_token;
	property String twilio_number;
	property String api_version;
	String authorization;
	URL url;

	public TwilioAPIClient() {
		api_version = "2010-04-01";
	}

	public BackgroundTask send_sms(String message, String to, String from, TwilioAPIResponseListener listener) {
		var sb = StringBuffer.create();
		if(String.is_empty(url)) {
			sb.append("https://api.twilio.com/");
			sb.append(api_version);
			sb.append("/Accounts/");
			sb.append(account_sid);
			sb.append("/Messages.json");
			url = URL.for_string(sb.to_string());
		}
		var params = HashTable.create()
			.set("Body", message)
			.set("To", to)
			.set("From", from);
		return(HTTPClientRequest.post_with_params(url, params)
			.set_header("Authorization", get_authorization())
			.start_get_string(background_task_manager, new ResponseListener().set_listener(listener)));
	}

	String get_authorization() {
		if(authorization == null) {
			var sb = StringBuffer.create();
			sb.append(account_sid);
			sb.append_c((int)':');
			sb.append(auth_token);
			authorization = "Basic ".append(Base64Encoder.encode_string(sb.to_string()));
		}
		return(authorization);
	}
}

