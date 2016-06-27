
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

public class HTTPRequestLoggerCommon : HTTPRequestLogger
{
	property File logdir;

	public void log_http_transaction(HTTPRequest request, HTTPResponse resp, int written, String aremote_address) {
		var remote_address = aremote_address;
		if(String.is_empty(remote_address)) {
			remote_address = "-";
		}
		String username = null;
		if(String.is_empty(username)) {
			username = "-";
		}
		String sessionid = null;
		if(String.is_empty(sessionid)) {
			sessionid = "-";
		}
		var dt = DateTime.for_now();
		var dets = dt.get_details(true);
		String log_time;
		if(dets != null) {
			log_time = "%02d/%02d/%04d:%02d:%02d:%02d UTC".printf()
				.add(Primitive.for_integer(dets.get_day()))
				.add(Primitive.for_integer(dets.get_month()))
				.add(Primitive.for_integer(dets.get_year()))
				.add(Primitive.for_integer(dets.get_hours()))
				.add(Primitive.for_integer(dets.get_minutes()))
				.add(Primitive.for_integer(dets.get_seconds())).to_string();
		}
		else {
			log_time = "[DATE/TIME]";
		}
		var rf = request.get_header("referer");
		if(String.is_empty(rf)) {
			rf = "-";
		}
		var logline = "%s %s %s [%s] \"%s %s %s\" %s %d \"%s\" \"%s\"".printf()
			.add(remote_address)
			.add(username)
			.add(sessionid)
			.add(log_time)
			.add(request.get_method())
			.add(request.get_url())
			.add(request.get_version())
			.add(resp.get_status())
			.add(written)
			.add(rf)
			.add(request.get_header("user-agent")).to_string();
		if(logdir != null) {
			String logidname;
			if(dets != null) {
				logidname = "accesslog_%04d%02d%02d.log".printf()
					.add(dets.get_year())
					.add(dets.get_month())
					.add(dets.get_day()).to_string();
			}
			else {
				logidname = "accesslog.log";
			}
			var os = OutputStream.create(logdir.entry(logidname).append());
			if(os == null && logdir.is_directory() == false) {
				logdir.mkdir_recursive();
				os = OutputStream.create(logdir.entry(logidname).append());
			}
			if(os != null) {
				os.println(logline);
			}
			Log.debug(logline);
		}
		else {
			Log.message(logline);
		}
	}
}