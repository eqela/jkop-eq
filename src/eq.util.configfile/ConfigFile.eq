
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

public class ConfigFile : Iterateable
{
	property KeyValueList data;
	property bool encode_values = false;

	public static ConfigFile for_file(File file, bool encode_values = false) {
		var v = new ConfigFile();
		v.set_encode_values(encode_values);
		if(v.read(file) == false) {
			v = null;
		}
		return(v);
	}

	public static ConfigFile for_hash_table(HashTable ht) {
		return(new ConfigFile().set_data_as_hash_table(ht));
	}

	public ConfigFile() {
		data = new KeyValueList();
	}

	public void clear() {
		data = new KeyValueList();
	}

	public ConfigFile set_data_as_hash_table(HashTable dt) {
		data = new KeyValueList();
		foreach(String key in dt) {
			data.append(key, dt.get(key));
		}
		return(this);
	}

	public String get_string_value(String key) {
		if(data == null) {
			return(null);
		}
		return(data.get_string(key));
	}

	public int get_int_value(String key, int def = 0) {
		var ss = get_string_value(key);
		if(ss == null) {
			return(def);
		}
		return(ss.to_integer());
	}

	public double get_double_value(String key, double def = 0.0) {
		var ss = get_string_value(key);
		if(ss == null) {
			return(def);
		}
		return(ss.to_double());
	}

	public HashTable as_hash_table() {
		if(data == null) {
			return(null);
		}
		return(data.as_hash_table());
	}

	public KeyValueList get_values(String filter = null) {
		var v = new KeyValueList();
		foreach(KeyValuePair kv in data) {
			var key = kv.get_key();
			var oi = key.chr((int)'[');
			if(oi > 0 && key.has_suffix("]")) {
				var rkey = key.substring(0, oi);
				var cond = key.substring(oi+1, key.get_length()-oi-2);
				if(cond.has_suffix("*") && filter != null && filter.has_prefix(cond.substring(0, cond.get_length()-1))) {
					v.append(rkey, kv.get_value());
				}
				else if(filter != null && filter.equals(cond)) {
					v.append(rkey, kv.get_value());
				}
			}
			else {
				v.append(key, kv.get_value());
			}
		}
		return(v);
	}

	public Iterator iterate() {
		var vals = get_values();
		if(vals == null) {
			return(null);
		}
		return(vals.iterate());
	}

	public virtual bool read(File file) {
		if(file == null) {
			return(false);
		}
		var ins = InputStream.create(file.read());
		if(ins == null) {
			return(false);
		}
		String line;
		String tag;
		while((line = ins.readline()) != null) {
			line = line.strip();
			if(String.is_empty(line) || line.has_prefix("#")) {
				continue;
			}
			if(line.has_suffix("{")) {
				if(tag == null) {
					tag = line.substring(0, line.get_length()-1);
					if(tag != null) {
						tag = tag.strip();
					}
				}
				continue;
			}
			if("}".equals(line)) {
				tag = null;
				continue;
			}
			var sp = StringSplitter.split(line, (int)':', 2);
			if(sp == null) {
				continue;
			}
			var key = sp.next() as String;
			var val = sp.next() as String;
			if(key != null) {
				key = key.strip();
			}
			if(val != null) {
				val = val.strip();
			}
			if(val != null && val.has_prefix("\"") && val.has_suffix("\"")) {
				val = val.substring(1, val.get_length()-2);
			}
			if(String.is_empty(key)) {
				continue;
			}
			if(tag != null) {
				key = "%s[%s]".printf().add(key).add(tag).to_string();
			}
			if(encode_values) {
				data.append(key, URLDecoder.decode(val));
			}
			else {
				data.append(key, val);
			}
		}
		return(true);
	}

	public virtual bool write(File outfile) {
		if(outfile == null || data == null) {
			return(false);
		}
		var os = OutputStream.create(outfile.write());
		if(os == null) {
			return(false);
		}
		foreach(KeyValuePair kvp in data) {
			if(encode_values) {
				os.println("%s: %s".printf().add(kvp.get_key()).add(URLEncoder.encode(kvp.get_value() as String)).to_string());
			}
			else {
				os.println("%s: %s".printf().add(kvp.get_key()).add(kvp.get_value()).to_string());
			}
		}
		return(true);
	}
}
