
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

public class Form
{
	public static Form parse(String json) {
		var v = new Form();
		if(v.parse_json_string(json) == false) {
			v = null;
		}
		return(v);
	}

	public static Form for_data(HashTable data) {
		var v = new Form();
		if(v.parse_data(data) == false) {
			v = null;
		}
		return(v);
	}

	property String title;
	property String description;
	property Collection tabs;

	public bool parse_json_string(String json) {
		if(json == null) {
			return(false);
		}
		var data = JSONParser.parse_string(json) as HashTable;
		if(data == null) {
			return(false);
		}
		return(parse_data(data));
	}

	public bool parse_data(HashTable data) {
		if(data == null) {
			return(false);
		}
		set_title(data.get_string("title"));
		set_description(data.get_string("description"));
		foreach(HashTable tab in data.get("tabs") as Collection) {
			var ft = FormTab.for_data(tab);
			if(ft == null) {
				return(false);
			}
			add_tab(ft);
		}
		return(true);
	}

	public Form add_tab(FormTab tab) {
		if(tab == null) {
			return(this);
		}
		if(tabs == null) {
			tabs = LinkedList.create();
		}
		tabs.append(tab);
		return(this);
	}
}
