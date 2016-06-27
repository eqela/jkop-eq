
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

public class JSONEncoder
{
	static bool isnewline = true;

	static void print(String line, int indent, bool startline, bool endline, StringBuffer sb, bool nice_formatting) {
		if(startline && isnewline == false) {
			if(nice_formatting) {
				sb.append_c((int)'\n');
			}
			else {
				sb.append_c((int)' ');
			}
			isnewline = true;
		}
		if(isnewline && nice_formatting) {
			int n;
			for(n=0; n<indent; n++) {
				sb.append_c((int)'\t');
			}
		}
		sb.append(line);
		if(endline) {
			if(nice_formatting) {
				sb.append_c((int)'\n');
			}
			else {
				sb.append_c((int)' ');
			}
			isnewline = true;
		}
		else {
			isnewline = false;
		}
	}

	static void encode_collection(Collection cc, int indent, StringBuffer sb, bool nice_formatting) {
		print("[", indent, false, true, sb, nice_formatting);
		bool first = true;
		foreach(var o in cc) {
			if(first == false) {
				print(",", indent, false, true, sb, nice_formatting);
			}
			encode_object(o, indent+1, sb, nice_formatting);
			first = false;
		}
		print("]", indent, true, false, sb, nice_formatting);
	}

	static void encode_hash_table(HashTable ht, int indent, StringBuffer sb, bool nice_formatting) {
		print("{", indent, false, true, sb, nice_formatting);
		bool first = true;
		foreach(String key in ht) {
			if(first == false) {
				print(",", indent, false, true, sb, nice_formatting);
			}
			print("\"%s\" : ".printf().add(key).to_string(), indent+1, true, false, sb, nice_formatting);
			encode_object(ht.get(key), indent+1, sb, nice_formatting);
			first = false;
		}
		print("}", indent, true, false, sb, nice_formatting);
	}

	static void encode_key_value_list(KeyValueList kvl, int indent, StringBuffer sb, bool nice_formatting) {
		print("{", indent, false, true, sb, nice_formatting);
		bool first = true;
		foreach(KeyValuePair kvp in kvl) {
			var key = kvp.get_key();
			if(first == false) {
				print(",", indent, false, true, sb, nice_formatting);
			}
			print("\"%s\" : ".printf().add(key).to_string(), indent+1, true, false, sb, nice_formatting);
			encode_object(kvp.get_value(), indent+1, sb, nice_formatting);
			first = false;
		}
		print("}", indent, true, false, sb, nice_formatting);
	}

	static void encode_string(String s, int indent, StringBuffer sb, bool nice_formatting) {
		var mysb = StringBuffer.create();
		mysb.append_c((int)'"');
		foreach(Integer i in s) {
			var c = i.to_integer();
			if(c == '"') {
				mysb.append_c((int)'\\');
			}
			else if(c == '\\') {
				mysb.append_c((int)'\\');
			}
			mysb.append_c(c);
		}
		mysb.append_c((int)'"');
		print(mysb.to_string(), indent, false, false, sb, nice_formatting);
	}

	static void encode_object(Object o, int indent, StringBuffer sb, bool nice_formatting) {
		if(o == null) {
			encode_string("", indent, sb, nice_formatting);
		}
		else if(o is JSONObject) {
			encode_object(((JSONObject)o).to_json_object(), indent, sb, nice_formatting);
		}
		else if(o is Serializable) {
			var data = HashTable.create();
			((Serializable)o).export_data(data);
			encode_object(data, indent, sb, nice_formatting);
		}
		else if(o is Collection) {
			encode_collection((Collection)o, indent, sb, nice_formatting);
		}
		else if(o is HashTable) {
			encode_hash_table((HashTable)o, indent, sb, nice_formatting);
		}
		else if(o is KeyValueList) {
			encode_key_value_list((KeyValueList)o, indent, sb, nice_formatting);
		}
		else if(o is String) {
			encode_string((String)o, indent, sb, nice_formatting);
		}
		else if(o is Stringable) {
			encode_string(((Stringable)o).to_string(), indent, sb, nice_formatting);
		}
		else {
			Log.debug("JSONEncoder: Unknown object type encountered. Encoding with an empty string.");
			encode_string("", indent, sb, nice_formatting);
		}
	}

	public static String encode(Object o, bool nice_formatting = true) {
		var sb = StringBuffer.create();
		encode_object(o, 0, sb, nice_formatting);
		return(sb.to_string());
	}
}
