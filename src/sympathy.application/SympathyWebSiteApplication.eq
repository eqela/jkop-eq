
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

public class SympathyWebSiteApplication : SympathyWebServerApplication
{
	property String site_title;
	property String site_slogan;
	property String site_description;
	property String site_copyright;
	property String site_copyright_url;
	property String google_analytics_id;
	property String site_url;

	public virtual void on_site_config_file_updated() {
	}

	public virtual void on_site_config_entry(String key, String value) {
		if("title".equals(key)) {
			site_title = value;
		}
		else if("slogan".equals(key)) {
			site_slogan = value;
		}
		else if("copyright".equals(key)) {
			site_copyright = value;
		}
		else if("copyright_url".equals(key)) {
			site_copyright_url = value;
		}
		else if("description".equals(key)) {
			site_description = value;
		}
		else if("google_analytics_id".equals(key)) {
			google_analytics_id = value;
		}
		else if("url".equals(key)) {
			site_url = value;
		}
	}

	bool read_site_config_file() {
		var kvl = read_datadir_config_file("site");
		if(kvl == null) {
			return(false);
		}
		foreach(KeyValuePair kvp in kvl) {
			on_site_config_entry(kvp.get_key(), String.as_string(kvp.get_value()));
		}
		on_site_config_file_updated();
		return(true);
	}

	void read_config() {
		if(read_site_config_file() == false) {
			var kvl = read_datadir_config_file("sympathy");
			if(kvl != null) {
				foreach(KeyValuePair kvp in kvl) {
					var key = kvp.get_key();
					var value = String.as_string(kvp.get_value());
					if("app_title".equals(key)) {
						site_title = value;
					}
					else if("app_slogan".equals(key)) {
						site_slogan = value;
					}
					else if("app_copyright".equals(key)) {
						site_copyright = value;
					}
					else if("app_url".equals(key)) {
						site_copyright_url = value;
					}
					else if("app_description".equals(key)) {
						site_description = value;
					}
					else if("google_analytics_id".equals(key)) {
						google_analytics_id = value;
					}
				}
				on_site_config_file_updated();
			}
		}
	}

	public bool initialize() {
		if(base.initialize() == false) {
			return(false);
		}
		read_config();
		return(true);
	}

	public void on_refresh() {
		base.on_refresh();
		read_config();
	}
}
