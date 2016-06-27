
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

class EnterAddressWidget : MobileApplicationScreenWidget, HTTPJSONClientListener
{
	FormWidget form;

	public Object get_mobile_app_title() {
		return("Database Wizard");
	}

	public Collection get_mobile_app_menu_items() {
		return(null);
	}

	public Collection get_mobile_app_toolbar_items() {
		return(null);
	}

	public void initialize() {
		base.initialize();
		set_draw_color(Color.instance("black"));
		add(CanvasWidget.for_color(Color.instance("#CCCCCC")));
		form = FormWidget.instance();
		form.add_text_field("address", "Server Address", "Please enter the base URL address of the database server",
			"http://test.training.eqela.com/api",
			null, TextInputWidget.INPUT_TYPE_URL);
		form.add_button(null, "Get started >", "start");
		add(form);
	}

	public void cleanup() {
		base.cleanup();
		form = null;
	}

	public void on_json_response(Object o) {
		var tables = o as Collection;
		if(tables == null) {
			ModalDialog.error("Failed to retrieve table list. Please check the server address.");
			return;
		}
		widget_stack_push(new TableListWidget().set_baseurl(form.get_form_field_value_string("address")).set_tables(tables));
	}

	public void on_event(Object o) {
		if("start".equals(o)) {
			var add = form.get_form_field_value_string("address");
			if(String.is_empty(add) || "http://".equals(add)) {
				ModalDialog.error("Please enter the server address");
				return;
			}
			new HTTPJSONClientDialog().set_listener(this).set_url(add).set_message("Getting table list ..").execute(get_frame());
		}
	}
}
