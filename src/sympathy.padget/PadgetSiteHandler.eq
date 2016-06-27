
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

// FIXME: Remove the /res/ thing from here: We can just do it with
// DirectoryContentHandler or something.

public class PadgetSiteHandler : HTTPRequestHandlerAdapter, HTTPRequestHandlerWithLifeCycle
{
	property String site_title;
	property String site_url;
	property String site_slogan;
	property String site_description;
	property String site_copyright;
	property String site_copyright_url;
	property String google_analytics_id;
	property String favicon_url;
	Collection padgets;
	String head_css;
	String head_js;
	Collection resource_dirs;
	String google_analytics_script;

	public PadgetSiteHandler() {
		google_analytics_script = TEXTFILE("google_analytics.html");
		favicon_url = "/res/favicon.png";
	}

	public void add_resource_dir(File dir) {
		if(resource_dirs == null) {
			resource_dirs = LinkedList.create();
		}
		resource_dirs.prepend(dir);
	}

	public void add_padget(Padget padget) {
		if(padget == null) {
			return;
		}
		if(padgets == null) {
			padgets = LinkedList.create();
		}
		padgets.add(padget);
		head_css = null;
		head_js = null;
	}

	public void remove_padget(Padget padget) {
		if(padget == null) {
			return;
		}
		if(padgets != null) {
			padgets.remove(padget);
		}
		head_css = null;
		head_js = null;
	}

	public void remove_all_padgets() {
		padgets = null;
	}

	public virtual void get_html_html_begin(StringBuffer sb) {
	}

	public virtual void get_html_html_end(StringBuffer sb) {
	}

	public virtual void get_html_body_begin(StringBuffer sb) {
	}

	public virtual void get_html_body_end(StringBuffer sb) {
	}

	public virtual void get_html_header(StringBuffer sb) {
	}

	public virtual void get_request_padgets(HTTPRequest req, Collection padgets) {
	}

	public virtual void get_css(StringBuffer sb) {
	}

	public virtual void get_javascript(StringBuffer sb) {
	}

	public virtual void execute_padget_request(HTTPRequest req, HashTable data) {
	}

	public virtual void on_padget_application_request(HTTPRequest req, HashTable data, StringBuffer sb) {
	}

	public virtual void initialize_data(HashTable data) {
	}

	public bool on_http_get(HTTPRequest req) {
		// FIXME: These two should be generated Etags and handled like that
		if(req.is_for_resource("/style.css")) {
			if(head_css == null) {
				var sb = StringBuffer.create();
				get_css(sb);
				foreach(Padget padget in padgets) {
					if(sb.count() > 0) {
						sb.append_c((int)'\n');
					}
					padget.get_css(sb);
				}
				head_css = sb.to_string();
			}
			req.send_response(HTTPResponse.for_string(head_css, "text/css"));
			return(true);
		}
		if(req.is_for_resource("/script.js")) {
			if(head_js == null) {
				var sb = StringBuffer.create();
				get_javascript(sb);
				foreach(Padget padget in padgets) {
					if(sb.count() > 0) {
						sb.append_c((int)'\n');
					}
					padget.get_javascript(sb);
				}
				head_js = sb.to_string();
			}
			req.send_response(HTTPResponse.for_string(head_js, "application/javascript"));
			return(true);
		}
		if(req.is_for_prefix("/res/")) {
			var up = req.get_url_path();
			var ups = Path.normalize_path(up.substring(5));
			foreach(File resource_dir in resource_dirs) {
				var ff = resource_dir.entry(ups);
				if(ff.is_file()) {
					req.send_response(HTTPResponse.for_file(ff));
					return(true);
				}
			}
			req.send_response(HTTPResponse.for_http_not_found());
			return(true);
		}
		var data = HashTable.create();
		var session = req.get_session();
		if(session != null) {
			var ht = Serializable.to_hash_table(session);
			if(ht != null) {
				data.set("session", ht);
			}
		}
		var requestdata = HashTable.create();
		requestdata.set("path", req.get_url_path());
		data.set("request", requestdata);
		data.set("application_map", get_application_map());
		data.set("page_title", site_title);
		data.set("site_url", site_url);
		data.set("site_title", site_title);
		data.set("site_slogan", site_slogan);
		data.set("site_description", site_description);
		data.set("page_description", site_description);
		data.set("site_copyright", site_copyright);
		data.set("site_copyright_url", site_copyright_url);
		data.set("google_analytics_id", google_analytics_id);
		initialize_data(data);
		foreach(Padget padget in padgets) {
			padget.execute(req, data);
		}
		var req_padgets = LinkedList.create();
		get_request_padgets(req, req_padgets);
		foreach(Padget padget in req_padgets) {
			padget.execute(req, data);
		}
		execute_padget_request(req, data);
		if(req.is_response_sent()) {
			return(true);
		}
		var sb = StringBuffer.create();
		sb.append("<!DOCTYPE html>\n");
		sb.append("<html>\n");
		get_html_html_begin(sb);

		// HTML head 
		sb.append("<head>\n");
		sb.append("<title><%= page_title %></title>\n");
		sb.append("<link rel=\"stylesheet\" type=\"text/css\" href=\"/style.css\" />\n");
		if(String.is_empty(favicon_url) == false) {
			sb.append("<link rel=\"icon\" type=\"image/png\" href=\"%s\" />\n".printf().add(favicon_url).to_string());
		}
		sb.append("<meta name=\"viewport\" content=\"initial-scale=1,maximum-scale=1\" />\n");
		sb.append("<meta property=\"og:description\" content=\"<%= page_description %>\" />\n");
		sb.append("<script src=\"/script.js\"></script>\n");
		foreach(Padget padget in padgets) {
			padget.get_html_header(sb);
		}
		var stylesb = StringBuffer.create();
		foreach(Padget padget in req_padgets) {
			padget.get_css(stylesb);
		}
		if(stylesb.count() > 0) {
			sb.append("<style>\n");
			sb.append(stylesb.to_string());
			sb.append("</style>\n");
		}
		var jssb = StringBuffer.create();
		foreach(Padget padget in req_padgets) {
			padget.get_javascript(jssb);
		}
		if(jssb.count() > 0) {
			sb.append("<script>\n");
			sb.append(jssb.to_string());
			sb.append("</script>\n");
		}
		foreach(Padget padget in req_padgets) {
			padget.get_html_header(sb);
		}
		get_html_header(sb);
		sb.append("</head>\n");

		// Start the actual HTML Body
		sb.append("<body>\n");
		get_html_body_begin(sb);
		if(String.is_empty(google_analytics_id) == false) {
			sb.append(google_analytics_script);
		}
		foreach(Padget padget in padgets) {
			padget.get_html_body(sb);
		}
		foreach(Padget padget in req_padgets) {
			padget.get_html_body(sb);
		}
		sb.append("<div id=\"padget_container\">\n");

		// Padget header
		sb.append("<div id=\"padget_header\">\n");
		foreach(Padget padget in padgets) {
			padget.get_html_page_header(sb);
		}
		foreach(Padget padget in req_padgets) {
			padget.get_html_page_header(sb);
		}
		sb.append("</div>");

		// Actual padget content
		sb.append("<div id=\"padget_content\">\n");
		foreach(Padget padget in padgets) {
			padget.get_html_before_content(sb);
		}
		foreach(Padget padget in req_padgets) {
			padget.get_html_before_content(sb);
		}
		foreach(Padget padget in padgets) {
			padget.get_html_content(sb);
		}
		foreach(Padget padget in req_padgets) {
			padget.get_html_content(sb);
		}
		on_padget_application_request(req, data, sb);
		if(req.is_response_sent()) {
			return(true);
		}
		foreach(Padget padget in padgets) {
			padget.get_html_after_content(sb);
		}
		foreach(Padget padget in req_padgets) {
			padget.get_html_after_content(sb);
		}
		sb.append("</div>");

		// Padget footer
		sb.append("<div id=\"padget_footer\">\n");
		foreach(Padget padget in padgets) {
			padget.get_html_page_footer(sb);
		}
		foreach(Padget padget in req_padgets) {
			padget.get_html_page_footer(sb);
		}
		sb.append("</div>");

		// End the HTML body and page
		sb.append("</div>");
		get_html_body_end(sb);
		sb.append("</body>\n");
		get_html_html_end(sb);
		sb.append("</html>\n");

		// Process the template and send the HTML response
		var template_str = sb.to_string();
		var template = Template.for_string(template_str, "text/html", "<%", "%>");
		if(template == null) {
			req.send_response(HTTPResponse.for_http_internal_error());
			return(true);
		}
		template.set_processor(new HTMLTemplateProcessor());
		var html = template.to_string(data);
		if(html == null) {
			req.send_response(HTTPResponse.for_http_internal_error());
			return(true);
		}
		req.send_response(HTTPResponse.for_html_string(html));
		return(true);
	}

	public void initialize() {
	}

	public void on_maintenance() {
	}

	public void on_refresh() {
	}

	public void cleanup() {
		remove_all_padgets();
	}

	public virtual Collection get_application_map() {
		return(null);
	}
}
