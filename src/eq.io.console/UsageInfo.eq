
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

public class UsageInfo : Stringable
{
	class Parameter
	{
		property String name;
		property String description;
	}

	class Flag
	{
		property String flag;
		property String description;
	}

	class Option
	{
		property String name;
		property String value;
		property String description;
	}

	property String command;
	property String description;
	property String param_desc;
	Collection data;

	public UsageInfo() {
		command = SystemEnvironment.get_env_var("_EQ_ARGV0");
		if(String.is_empty(command)) {
			command = Application.get_instance_command();
		}
		if(String.is_empty(command)) {
			var ss = SystemEnvironment.find_self();
			if(ss != null) {
				command = ss.basename();
			}
		}
		if(String.is_empty(command)) {
			command = "(command)";
		}
		data = LinkedList.create();
		param_desc = "[parameters]";
	}

	public UsageInfo add_section(String name) {
		data.add(name);
		return(this);
	}

	void ensure_section() {
		if(data.count() < 1) {
			add_section("Available parameters");
		}
	}

	public UsageInfo add_parameter(String name, String description) {
		ensure_section();
		data.add(new Parameter().set_name(name).set_description(description));
		return(this);
	}

	public UsageInfo add_flag(String flag, String description) {
		ensure_section();
		data.add(new Flag().set_flag(flag).set_description(description));
		return(this);
	}

	public UsageInfo add_option(String name, String value, String description) {
		ensure_section();
		data.add(new Option().set_name(name).set_value(value).set_description(description));
		return(this);
	}

	public String to_string() {
		var sb = StringBuffer.create();
		sb.append("Usage: ");
		sb.append(command);
		if(String.is_empty(param_desc) == false) {
			sb.append_c((int)' ');
			sb.append(param_desc);
		}
		sb.append_c((int)'\n');
		sb.append_c((int)'\n');
		if(String.is_empty(description) == false) {
			sb.append(description);
			sb.append_c((int)'\n');
			sb.append_c((int)'\n');
		}
		int longest = 0;
		var db = true;
		foreach(var o in data) {
			if(o is Parameter) {
				var nn = ((Parameter)o).get_name();
				if(nn != null) {
					var ll = nn.get_length();
					if(ll > longest) {
						longest = ll;
					}
				}
			}
			else if(o is Flag) {
				var ff = ((Flag)o).get_flag();
				if(ff != null) {
					var ll = ff.get_length() + 1;
					if(ll > longest) {
						longest = ll;
					}
				}
			}
			else if(o is Option) {
				var name = ((Option)o).get_name();
				var value = ((Option)o).get_value();
				var ss = "-%s=[%s]".printf().add(name).add(value).to_string();
				var ll = ss.get_length();
				if(ll > longest) {
					longest = ll;
				}
			}
		}
		if(longest < 30) {
			longest = 30;
		}
		var format = "  %%-%ds%%s%%s\n".printf().add(longest).to_string();
		foreach(var o in data) {
			if(o is String) {
				if(db == false) {
					sb.append_c((int)'\n');
				}
				sb.append((String)o);
				sb.append_c((int)':');
				sb.append_c((int)'\n');
				sb.append_c((int)'\n');
				db = true;
			}
			else if(o is Parameter) {
				var p = (Parameter)o;
				var desc = p.get_description();
				var delim = " - ";
				if(String.is_empty(desc)) {
					delim = "";
				}
				sb.append(format.printf().add(p.get_name()).add(delim).add(desc).to_string());
				db = false;
			}
			else if(o is Flag) {
				var f = (Flag)o;
				var desc = f.get_description();
				var delim = " - ";
				if(String.is_empty(desc)) {
					delim = "";
				}
				var ss = "-".append(f.get_flag());
				sb.append(format.printf().add(ss).add(delim).add(desc).to_string());
				db = false;
			}
			else if(o is Option) {
				var name = ((Option)o).get_name();
				var value = ((Option)o).get_value();
				var desc = ((Option)o).get_description();
				var delim = " - ";
				if(String.is_empty(desc)) {
					delim = "";
				}
				var ss = "-%s=[%s]".printf().add(name).add(value).to_string();
				sb.append(format.printf().add(ss).add(delim).add(desc).to_string());
				db = false;
			}
		}
		if(db == false) {
			sb.append_c((int)'\n');
		}
		return(sb.to_string());
	}
}
