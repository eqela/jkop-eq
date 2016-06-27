
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

class ApplicationPreferencesFile : ApplicationPreferences
{
	HashTable values;
	File file;

	public ApplicationPreferencesFile set_file(File file) {
		this.file = file;
		read();
		return(this);
	}

	public bool read() {
		var cf = ConfigFile.for_file(file, true);
		if(cf == null) {
			return(false);
		}
		values = cf.as_hash_table();
		if(values == null) {
			return(false);
		}
		return(true);
	}

	public void set(String key, String value) {
		if(values == null) {
			values = HashTable.create();
		}
		if(key != null) {
			if(value == null) {
				values.remove(key);
			}
			else {
				values.set(key, value);
			}
		}
	}

	public String get(String key) {
		if(values == null) {
			return(null);
		}
		return(values.get_string(key));
	}

	public HashTable as_hash_table() {
		return(values);
	}

	public bool save() {
		if(file == null) {
			return(false);
		}
		var filedir = file.get_parent();
		if(filedir == null) {
			return(false);
		}
		if(filedir.is_directory() == false) {
			filedir.mkdir_recursive();
		}
		var cf = ConfigFile.for_hash_table(values);
		cf.set_encode_values(true);
		return(cf.write(file));
	}
}
