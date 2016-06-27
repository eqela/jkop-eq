
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

public class FormField
{
	public static FormField for_type(String type) {
		if("hidden".equals(type)) {
			return(new FormFieldHidden());
		}
		if("text".equals(type)) {
			return(new FormFieldText());
		}
		if("textarea".equals(type)) {
			return(new FormFieldTextArea());
		}
		if("password".equals(type)) {
			return(new FormFieldPassword());
		}
		if("integer".equals(type)) {
			return(new FormFieldInteger());
		}
		if("list".equals(type)) {
			return(new FormFieldList());
		}
		if("select".equals(type)) {
			return(new FormFieldSelect());
		}
		return(null);
	}

	public static FormField for_data(HashTable data) {
		if(data == null) {
			return(null);
		}
		var type = data.get_string("type");
		var ff = FormField.for_type(data.get_string("type"));
		if(ff == null) {
			return(null);
		}
		ff.from_data(data);
		return(ff);
	}

	property String id;
	property String label;
	property String description;

	public virtual void from_data(HashTable data) {
		set_id(data.get_string("id"));
		set_label(data.get_string("label"));
		set_description(data.get_string("description"));
	}
}
