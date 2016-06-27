
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

public class SympathyWebServerApplication : SympathyApplication
{
	property bool allow_cors = true;
	SympathyWebServerComponent component;

	public SympathyWebServerApplication() {
		component = new SympathyWebServerComponent();
	}

	public void initialize_components() {
		base.initialize_components();
		component.set_event_loop(get_event_loop());
		component.set_allow_cors(allow_cors);
		add_component(component);
	}

	public void on_refresh() {
		base.on_refresh();
		component.on_refresh();
	}

	public void on_maintenance() {
		base.on_maintenance();
		component.on_maintenance();
	}

	public void on_usage(UsageInfo ui) {
		base.on_usage(ui);
		ui.add_option("port", "TCP port", "Specify a TCP port to listen on");
		ui.add_option("vhost", "virtual host name", "Specify a virtual host to service");
		ui.add_flag("disable-cors", "Disable CORS headers from HTTP responses");
	}

	public bool on_command_line_flag(String flag) {
		if("disable-cors".equals(flag)) {
			allow_cors = false;
			return(true);
		}
		return(base.on_command_line_flag(flag));
	}

	public bool on_command_line_option(String key, String value) {
		if("port".equals(key)) {
			if(value != null) {
				component.add_port(value.to_integer());
			}
			return(true);
		}
		if("vhost".equals(key)) {
			if(value != null) {
				component.add_vhost(value);
			}
			return(true);
		}
		return(base.on_command_line_option(key, value));
	}

	public SympathyWebServerApplication set_request_handler(HTTPRequestHandler h) {
		component.set_request_handler(h);
		return(this);
	}

	public bool execute() {
		component.set_debug(get_debug());
		return(base.execute());
	}
}
