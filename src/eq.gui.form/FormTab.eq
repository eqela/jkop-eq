
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

public class FormTab
{
	public static FormTab for_data(HashTable data) {
		var v = new FormTab();
		if(v.parse_data(data) == false) {
			v = null;
		}
		return(v);
	}

	property String id;
	property String title;
	property String description;
	property Collection fields;

	public bool parse_data(HashTable data) {
		set_id(data.get_string("id"));
		set_title(data.get_string("title"));
		set_description(data.get_string("description"));
		foreach(HashTable field in data.get("fields") as Collection) {
			var ff = FormField.for_data(field);
			if(ff == null) {
				return(false);
			}
			add_field(ff);
		}
		return(true);
	}

	public FormTab add_field(FormField field) {
		if(field == null) {
			return(this);
		}
		if(fields == null) {
			fields = LinkedList.create();
		}
		fields.append(field);
		return(this);
	}
}
