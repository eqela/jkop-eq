
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

public class TemplateProcessor : LoggerObject
{
	public static String get_variable_value_string(HashTable vars, String varname) {
		var o = get_variable_value(vars, varname);
		if(o == null) {
			return(null);
		}
		if(o is String) {
			return((String)o);
		}
		if(o is Stringable) {
			return(((Stringable)o).to_string());
		}
		return(null);
	}

	public static Object get_variable_value(HashTable vars, String varname) {
		if(vars == null || varname == null) {
			return(null);
		}
		var vv = vars.get(varname);
		if(vv != null) {
			return(vv);
		}
		var ll = LinkedList.for_iterator(StringSplitter.split(varname, (int)'.'));
		if(ll.count() < 2) {
			return(null);
		}
		var nvar = ll.get(ll.count()-1) as String;
		ll.remove_node(ll.get_last_node());
		var cc = vars;
		foreach(String vv2 in ll) {
			if(cc == null) {
				return(null);
			}
			var vv2o = cc.get(vv2);
			cc = vv2o as HashTable;
			if(cc == null && vv2o is JSONObject) {
				cc = ((JSONObject)vv2o).to_json_object() as HashTable;
			}
		}
		if(cc != null) {
			return(cc.get(nvar));
		}
		return(null);
	}

	class MyVariableProvider : VariableProvider
	{
		property HashTable vars;
		public String get_variable_value(String name) {
			return(TemplateProcessor.get_variable_value_string(vars, name));
		}
	}

	property String marker_begin;
	property String marker_end;

	public String substitute_variables(String orig, HashTable vars) {
		return(VariableSubstitutor.substitute(orig, new MyVariableProvider().set_vars(vars)));
	}

	public String escape_html(String src) {
		if(src == null) {
			return(null);
		}
		var sb = StringBuffer.create();
		var it = src.iterate();
		int c;
		while((c = it.next_char()) > 0) {
			if(c == '<') {
				sb.append("&lt;");
			}
			else if(c == '>') {
				sb.append("&gt;");
			}
			else if(c == '&') {
				sb.append("&amp;");
			}
			else {
				sb.append_c(c);
			}
		}
		return(sb.to_string());
	}

	public bool handle_block(HashTable vars, Collection tag, Collection data, StringBuffer result, Collection include_dirs) {
		if(tag == null) {
			return(false);
		}
		var tagname = tag.get(0) as String;
		if("for".equals(tagname)) {
			var varname = tag.get(1) as String;
			var inword = tag.get(2) as String;
			var origvar = substitute_variables(tag.get(3) as String, vars);
			if(String.is_empty(varname) || String.is_empty(origvar) || "in".equals(inword) == false) {
				log_error("Invalid for tag: `%s'".printf().add(String.combine(tag, (int)' ')).to_string());
				return(false);
			}
			vars.set("__for_first", "true");
			foreach(var o in get_variable_value(vars, origvar)) {
				vars.set(varname, o);
				if(process(data, vars, result, include_dirs) == false) {
					return(false);
				}
				vars.set("__for_first", "false");
			}
			vars.remove("__for_first");
			return(true);
		}
		if("if".equals(tagname)) {
			var lvalue = tag.get(1) as String;
			if(lvalue == null) {
				return(true);
			}
			var operator = tag.get(2) as String;
			if(operator == null) {
				var varval = get_variable_value(vars, lvalue);
				if(varval == null) {
					return(true);
				}
				if(varval is Collection) {
					if(Collection.is_empty((Collection)varval)) {
						return(true);
					}
				}
				if(varval is HashTable) {
					if(((HashTable)varval).count() < 1) {
						return(true);
					}
				}
				if(varval is String) {
					if(String.is_empty((String)varval)) {
						return(true);
					}
				}
				if(process(data, vars, result, include_dirs) == false) {
					return(false);
				}
				return(true);
			}
			lvalue = substitute_variables(lvalue, vars);
			var rvalue = tag.get(3) as String;
			if(rvalue != null) {
				rvalue = substitute_variables(rvalue, vars);
			}
			if(lvalue == null || String.is_empty(operator) || rvalue == null) {
				log_error("Invalid if tag: `%s'".printf().add(String.combine(tag, (int)' ')).to_string());
				return(false);
			}
			if("==".equals(operator) || "=".equals(operator) || "is".equals(operator)) {
				if(rvalue.equals(lvalue) == false) {
					return(true);
				}
				if(process(data, vars, result, include_dirs) == false) {
					return(false);
				}
				return(true);
			}
			if("!=".equals(operator) || "not".equals(operator)) {
				if(rvalue.equals(lvalue) == true) {
					return(true);
				}
				if(process(data, vars, result, include_dirs) == false) {
					return(false);
				}
				return(true);
			}
			log_error("Unknown operator `%s' in if tag: `%s'".printf().add(operator).add(String.combine(tag, (int)' ')).to_string());
			return(false);
		}
		return(false);
	}

	public bool process(Collection data, HashTable avars, StringBuffer result, Collection include_dirs) {
		if(data == null) {
			return(true);
		}
		int blockctr = 0;
		Collection blockdata;
		Collection blocktag;
		var vars = avars;
		if(vars == null) {
			vars = HashTable.create();
		}
		foreach(var o in data) {
			var words = o as Collection;
			String tagname;
			if(words != null) {
				tagname = words.get(0) as String;
			}
			if("end".equals(tagname)) {
				blockctr --;
				if(blockctr == 0 && blockdata != null) {
					if(handle_block(vars, blocktag, blockdata, result, include_dirs) == false) {
						return(false);
					}
					blockdata = null;
					blocktag = null;
				}
			}
			if(blockctr > 0) {
				if("for".equals(tagname) || "if".equals(tagname)) {
					blockctr ++;
				}
				if(blockdata == null) {
					blockdata = LinkedList.create();
				}
				blockdata.add(o);
				continue;
			}
			if("=".equals(tagname) || "printstring".equals(tagname)) {
				var varname = substitute_variables(words.get(1) as String, vars);
				if(String.is_empty(varname) == false) {
					var vv = get_variable_value_string(vars, varname);
					if(String.is_empty(vv) == false) {
						result.append(vv);
					}
					else {
						var defaultvalue = substitute_variables(words.get(2) as String, vars);
						if(String.is_empty(defaultvalue) == false) {
							result.append(defaultvalue);
						}
					}
				}
			}
			else if("printjson".equals(tagname)) {
				var varname = substitute_variables(String.as_string(words.get(1)), vars);
				if(String.is_empty(varname) == false) {
					var vv = get_variable_value(vars, varname);
					if(vv != null) {
						result.append(JSONEncoder.encode(vv));
					}
				}
			}
			else if("import".equals(tagname)) {
				var type = words.get(1) as String;
				var filename = substitute_variables(words.get(2) as String, vars);
				if(String.is_empty(filename)) {
					log_error("Invalid import tag with empty filename");
					return(false);
				}
				File ff;
				foreach(File dir in include_dirs) {
					ff = File.for_native_path(filename, dir);
					if(ff != null && ff.is_file()) {
						break;
					}
				}
				if(ff == null || ff.is_file() == false) {
					log_error("Unable to find file to import: `%s'".printf().add(filename));
					return(false);
				}
				log_debug("Attempting to import file `%s' ..".printf().add(ff));
				var content = ff.get_contents_string();
				if(String.is_empty(content)) {
					log_error("Unable to read import file: `%s'".printf().add(ff));
					return(false);
				}
				if("html".equals(type)) {
					content = escape_html(content);
				}
				else if("template".equals(type)) {
					var t = Template.for_string(content, null, marker_begin, marker_end, include_dirs);
					if(t == null) {
						log_error("Failed to parse template file: `%s'".printf().add(ff));
						return(false);
					}
					if(process(t.get_data(), vars, result, include_dirs) == false) {
						return(false);
					}
					content = null;
				}
				else if("raw".equals(type)) {
					;
				}
				else {
					log_error("Unknown type for import: `%s'".printf().add(type));
					return(false);
				}
				if(String.is_empty(content) == false) {
					result.append(content);
				}
			}
			else if("escape_html".equals(tagname)) {
				var content = substitute_variables(words.get(1) as String, vars);
				if(content != null) {
					content = escape_html(content);
				}
				if(content != null) {
					result.append(content);
				}
			}
			else if("set".equals(tagname)) {
				if(words.count() != 3) {
					log_error("Invalid syntax for set tag: `%s'".printf().add(tagname).to_string());
					return(false);
				}
				var varname = substitute_variables(words.get(1) as String, vars);
				if(String.is_empty(varname)) {
					log_error("Empty variable name in set tag: `%s'".printf().add(tagname).to_string());
					return(false);
				}
				vars.set(varname, substitute_variables(words.get(2) as String, vars));
			}
			else if("assign".equals(tagname)) {
				if(words.count() != 3) {
					log_error("Invalid syntax for assign tag: `%s'".printf().add(tagname).to_string());
					return(false);
				}
				var varname = substitute_variables(words.get(1) as String, vars);
				if(String.is_empty(varname)) {
					log_error("Empty variable name in set tag: `%s'".printf().add(tagname).to_string());
					return(false);
				}
				var vv = String.as_string(words.get(2));
				if("none".equals(vv)) {
					vars.remove(varname);
				}
				else {
					vars.set(varname, get_variable_value(vars, vv));
				}
			}
			else if("for".equals(tagname) || "if".equals(tagname)) {
				if(blockctr == 0) {
					blocktag = words;
				}
				blockctr ++;
			}
			else if("end".equals(tagname)) {
				; // already handled
			}
			else if(tagname != null) {
				on_custom_tag(vars, result, include_dirs, tagname, words);
			}
			else if(o is String) {
				result.append((String)o);
			}
		}
		return(true);
	}

	public virtual void on_custom_tag(HashTable avars, StringBuffer result, Collection include_dirs, String tagname, Collection words) {
		// Ignore unknown tags so they can be used for extensions
	}
}
