
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

public class JSONParser
{
	public static JSONParser create() {
		return(new JSONParser());
	}

	public static Object parse_string(String json_string) {
		if(String.is_empty(json_string)) {
			return(null);
		}
		var j = new JSONParser();
		Object result;
		Stack element_stack = Stack.create();
		Stack error_stack = Stack.create();
		StringIterator json_si = json_string.iterate();
		result = j.json_parser(element_stack, json_si, error_stack);
		int i = 0;
		if(error_stack.count() != 0) {
			while(error_stack.count() != 0) {
				Log.message(error_stack.pop() as String);
			}
		}
		if(element_stack.count() != 0) {
			for(i = 0; i < element_stack.count(); i++) {
				var st = element_stack.pop() as String;
				if(st.equals("{")) {
					Log.message("ERROR IN PARSING : \'{\' must be closed with \'}\'");
				}
				else if(st.equals("[")) {
					Log.message("ERROR IN PARSING : \'[\' must be closed with \']\'");
				}
			}
			result = null;
		}
		return(result);
	}

	public static Object parse_file(File json_file) {
		if(json_file == null) {
			return(null);
		}
		var ss = json_file.get_contents_string();
		if(ss == null) {
			return(null);
		}
		return(JSONParser.parse_string(ss));
	}

	public static Object parse_input_stream(InputStream json_ins) {
		if(json_ins == null) {
			return(null);
		}
		return(JSONParser.parse_string(json_ins.read_all_string()));
	}

	public static Object parse_reader(Reader json_reader) {
		if(json_reader == null) {
			return(null);
		}
		return(JSONParser.parse_input_stream(InputStream.create(json_reader)));
	}

	public static Object parse_buffer(Buffer buffer) {
		if(buffer == null) {
			return(null);
		}
		var str = String.for_utf8_buffer(buffer, false);
		if(str == null) {
			return(null);
		}
		return(parse_string(str));
	}

	private Object json_parser(Stack element_stack, StringIterator json_si, Stack error_stack) {
		Object result;
		HashTable ht;
		String hash_key;
		Object hash_value;
		String val_start = "";
		int s;
		bool val_for_key = false;
		while((s = json_si.next_char()) != -1) {
			if(s == ' ' || s == '\n' || s == '\t' || s == '\r') {
				continue;
			}
			else if(s == '/') {
				s = json_si.next_char();
				if(s == '/') {
					ignore_single_line(json_si);
				}
				else if(s == '*') {
					ignore_multiple_lines(json_si);
				}
				else {
					element_stack.push("error");
					error_stack.push("ERROR IN PARSING : unexpected \'/\'");
				}
				continue;
			}
			else if(s == '{') {
				element_stack.push("{");
				if(val_start.equals("")) {
					val_start = "object";
					ht = HashTable.create();
				}
			}
			else if(s == '[') {
				element_stack.push("[");
				if(val_start.equals("")) {
					val_start = "array";
					result = array_value(element_stack, json_si, error_stack);
					break;
				} else {
					hash_value = array_value(element_stack, json_si, error_stack);
				}
			}
			else if(s == '}' && val_start.equals("object")) {
				if("{".equals(element_stack.peek())) {
					element_stack.pop();
				} else {
					error_stack.push("ERROR IN PARSING : expected \'}\'");
				}
				break;
			}
			else if(s == '\"' && !val_start.equals("")) {
				hash_key = key_name(json_si, element_stack, error_stack);
				val_for_key = false;
			}
			else if(s == ':' && hash_key != null) {
				val_for_key = true;
				hash_value = key_value(element_stack, json_si, error_stack);
				ht.set(hash_key, hash_value);
				hash_key = null;
				continue;
			}
			else if(s == ',' && !val_start.equals("")) {
				continue;
			}
			else {
				element_stack.push("error");
				error_stack.push("ERROR IN PARSING : Expected \',\' or \'}\' after property value in object");
				break;
			}
		}
		if(hash_key != null && val_for_key == false) {
			error_stack.push("ERROR IN PARSING : Expected a value for [%s] key".printf().add(hash_key).to_string());
		}
		if(val_start.equals("")) {
			error_stack.push("ERROR IN PARSING : JSON Object must begin with \'{\' or \'[\'");
		}
		if(val_start.equals("object")) {
			result = ht;
		}
		return(result);
	}

	private void ignore_single_line(StringIterator json_si) {
		int s;
		while((s = json_si.next_char()) != -1) {
			if(s == '\n') {
				break;
			}
		}
	}

	private void ignore_multiple_lines(StringIterator json_si) {
		int s;
		while((s = json_si.next_char()) != -1) {
			if(s == '*') {
				if((s = json_si.next_char()) == '/') {
					break;
				}
			}
		}
	}

	private String key_name(StringIterator json_si, Stack element_stack, Stack error_stack) {
		var next_key = StringBuffer.for_initial_size(128);
		int s;
		while(s != -1) {
			s = json_si.next_char();
			if(!(s == '\"')) {
				if(s == '\\') {
					s = json_si.next_char();
					if(s == ('\"')) {
						next_key.append_c((int)'\"');
					}
					else if(s == ('\'')) {
						next_key.append_c((int)'\'');
					}
					else if(s == ('\\')) {
						next_key.append_c((int)'\\');
					}
					else if(s == ('n')) {
						next_key.append_c((int)'\n');
					}
					else if(s == ('t')) {
						next_key.append_c((int)'\t');
					}
					else if(s == ('r')) {
						next_key.append_c((int)'\r');
					}
					else if(s == ('u')) {
						int i = 0;
						var ucode = StringBuffer.for_initial_size(4);
						for(i = 0; i < 4; i++) {
							s = json_si.next_char();
							ucode.append_c(s);
						}
						next_key.append_c(ucode.to_string().to_integer_base(16));
					}
					else {
						next_key.append_c(s);
					}
				}
				else {
					if(s != -1) {
						next_key.append_c(s);
					}
				}
			}
			else {
				break;
			}
		}
		if(s == -1) {
			element_stack.push("error");
			error_stack.push("ERROR IN PARSING : expected closing (\") after --%s".printf().add(next_key.dup().to_string()).to_string());
			return(null);
		}
		return(next_key.to_string());
	}

	private Object key_value(Stack element_stack, StringIterator json_si, Stack error_stack) {
		Object obj;
		var val_buff = StringBuffer.for_initial_size(1024);
		String val = "";
		String val_s = "";
		int s;
		while(s != -1) {
			s = json_si.next_char();
			if(s == ' ' || s == '\n' || s == '\t' || s == '\r') {
				continue;
			}
			else if(s == '/') {
				s = json_si.next_char();
				if(s == '/') {
					ignore_single_line(json_si);
				}
				else if(s == '*') {
					ignore_multiple_lines(json_si);
				}
				else {
					element_stack.push("error");
					error_stack.push("ERROR IN PARSING : unexpected \'/\'");
					break;
				}
				continue;
			}
			else if(s == '{') {
				s = json_si.prev_char();
				obj = json_parser(element_stack, json_si, error_stack);
				return(obj);
			}
			else if(s == '[') {
				element_stack.push("[");
				obj = array_value(element_stack, json_si, error_stack);
				return(obj);
			}
			else if(s == '\"') {
				val_s = string_value(json_si, element_stack, error_stack);
				val = "string";
			}
			else if(s == ',' || s == '}') {
				s = json_si.prev_char();
				break;
			}
			else {
				while(s != -1) {
					if(s == ' ' || s == '\n' || s == '\t' || s == '\r') {
						break;
					}
					else if(s == '}' || s == ',' || s == ']'){
						s = json_si.prev_char();
						break;
					}
					else {
						val_buff.append_c(s);
						s = json_si.next_char();
					}
				}
				val = val_buff.to_string();
				break;
			}
		}
		if(val.equals("true")) {
			obj = true;
		}
		else if(val.equals("false")) {
			obj = false;
		}
		else if(val.equals("null")) {
			obj = null;
		}
		else if(val.equals("string")) {
			obj = val_s;
		}
		else if(val.contains("0") || val.contains("1") || val.contains("2") || val.contains("3") ||
			val.contains("4") || val.contains("5") || val.contains("6") ||val.contains("7") || val.contains("8") || val.contains("8") || val.contains("9")) {
			if(val.contains(".")) {
				obj = val.to_double();
			} else {
				obj = val.to_integer();
			}
		}
		else {
			element_stack.push("error");
			error_stack.push("ERROR IN PARSING : before %s".printf().add(val).to_string());
			return(null);
		}
		return(obj);
	}

	private String string_value(StringIterator json_si, Stack element_stack, Stack error_stack) {
		var string_val = StringBuffer.for_initial_size(1024);
		int s;
		while(s != -1) {
			s = json_si.next_char();
			if(!(s == '\"')) {
				if(s == '\\') {
					s = json_si.next_char();
					if(s == ('\"')) {
						string_val.append_c((int)'\"');
					}
					else if(s == ('\'')) {
						string_val.append_c((int)'\'');
					}
					else if(s == ('\\')) {
						string_val.append_c((int)'\\');
					}
					else if(s == ('n')) {
						string_val.append_c((int)'\n');
					}
					else if(s == ('t')) {
						string_val.append_c((int)'\t');
					}
					else if(s == ('r')) {
						string_val.append_c((int)'\r');
					}
					else if(s == ('u')) {
						int i = 0;
						var ucode = StringBuffer.for_initial_size(4);
						for(i = 0; i < 4; i++) {
							s = json_si.next_char();
							ucode.append_c(s);
						}
						string_val.append_c(ucode.to_string().to_integer_base(16));
					}
					else {
						string_val.append_c(s);
					}
				}
				else {
					if(s != -1) {
						string_val.append_c(s);
					}
				}
			}
			else {
				break;
			}
		}
		if(s == -1) {
			element_stack.push("error");
			error_stack.push("ERROR IN PARSING : expected \' \" \' on %s".printf().add(string_val.dup().to_string()).to_string());
		}
		return(string_val.to_string());
	}

	private Object array_object(StringIterator json_si, Stack error_stack) {
		String st = "";
		Object o;
		int s;
		var st_buff = StringBuffer.for_initial_size(1024);
		while(s != -1) {
			s = json_si.next_char();
			if(s == ' ' || s == '\n' || s == '\t' || s == '\r') {
				break;
			}
			else if(s == '}' || s == ',' || s == ']'){
				s = json_si.prev_char();
				break;
			}
			else {
				st_buff.append_c(s);
			}
		}
		st = st_buff.to_string();
		if(st.equals("true")) {
			o = true;
		}
		else if(st.equals("false")) {
			o = false;
		}
		else if(st.equals("null")) {
			o = null;
		}
		else if(st.contains("0") || st.contains("1") || st.contains("2") || st.contains("3") ||
			st.contains("4") || st.contains("5") || st.contains("6") || st.contains("7") || st.contains("8") || st.contains("8") || st.contains("9")) {
			if(st.contains(".")) {
				o = st.to_double();
			}
			else {
				o = st.to_integer();
			}
		}
		else {
			error_stack.push("ERROR IN PARSING : unexpected value [%s]".printf().add(st).to_string());
		}
		return(o);
	}

	private Array array_value(Stack element_stack, StringIterator json_si, Stack error_stack) {
		Array array_obj;
		array_obj = Array.create();
		String array_key = "";
		int s;
		bool array_closed = false;
		bool next_object = true;
		bool expect_next = false;
		while(s != -1) {
			s = json_si.next_char();
			if(s == ' ' || s == '\n' || s == '\t' || s == '\r') {
				continue;
			}
			else if(s == '/') {
				s = json_si.next_char();
				if(s == '/') {
					ignore_single_line(json_si);
				}
				else if(s == '*') {
					ignore_multiple_lines(json_si);
				}
				else {
					element_stack.push("error");
					error_stack.push("ERROR IN PARSING : unexpected \'/\'");
					break;
				}
				continue;
			}
			else if(s == '{' && next_object) {
				s = json_si.prev_char();
				array_obj.add(json_parser(element_stack, json_si, error_stack));
				next_object = false;
				expect_next = false;
			}
			else if(s == ',') {
				next_object = true;
				expect_next = true;
				continue;
			}
			else if(s == '[' && next_object) {
				element_stack.push("[");
				array_obj.add(array_value(element_stack, json_si, error_stack));
				next_object = false;
				expect_next = false;
			}
			else if(s == ']') {
				if("[".equals(element_stack.peek())) {
					if(element_stack.count() != 0) {
						element_stack.pop();
					}
				}
				array_closed = true;
				break;
			}
			else if(s == '\"' && next_object) {
				array_key = string_value(json_si, element_stack, error_stack);
				array_obj.add(array_key);
				next_object = false;
				expect_next = false;
			}
			else {
				if(next_object) {
					s = json_si.prev_char();
					array_obj.add(array_object(json_si, error_stack));
					next_object = false;
					expect_next = false;
				}
				else {
					error_stack.push("ERROR IN PARSING : expected \',\' or \']\'");
					break;
				}
			}
		}
		if(array_closed == false) {
			error_stack.push("ERROR IN PARSING : \'[\' must be closed with \']\'");
			return(null);
		}
		return(array_obj);
	}
}

