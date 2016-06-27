
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

public class Category : Serializable, Validateable
{
	property String id;
	property String name;
	property String description;

	public void export_data(HashTable data) {
		data.set("id", get_id());
		data.set("name", get_name());
		data.set("description", get_description());
	}

	public void import_data(HashTable data) {
		set_id(data.get_string("id", id));
		set_name(data.get_string("name", name));
		set_description(data.get_string("description", description));
	}

	public bool validate(Error error) {
		if(String.is_empty(get_name())) {
			Error.set_error_message(error, "No name");
			return(false);
		}
		if(String.is_empty(get_description())) {
			Error.set_error_message(error, "No description");
			return(false);
		}
		return(true);
	}
}
