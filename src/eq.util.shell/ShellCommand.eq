
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

public class ShellCommand : Stringable
{
	public static ShellCommand instance() {
		return(new ShellCommand());
	}

	public static ShellCommand for_file(File file) {
		return(new ShellCommand().add_word(String.as_string(file)));
	}

	public static ShellCommand for_words(Collection words) {
		return(new ShellCommand().set_words(words));
	}

	public static ShellCommand for_string(String str) {
		return(new ShellCommand().set_commandline(str));
	}

	public static ShellCommand for_command(String cmd) {
		return(new ShellCommand().set_words(LinkedList.create().add(cmd)));
	}

	Collection words;
	String commandline;
	property String execute_message;
	property File cwd;
	property bool ignore_return_value = false;
	property bool ignore_output = false;

	public int as_return_value(int r) {
		if(ignore_return_value) {
			return(0);
		}
		return(r);
	}

	public ShellCommand set_commandline(String commandline) {
		this.commandline = commandline;
		return(this);
	}

	public String get_commandline() {
		if(words == null) {
			return(commandline);
		}
		var sb = StringBuffer.create();
		if(commandline != null) {
			sb.append(commandline);
		}
		foreach(String p in words) {
			if(sb.count() > 0) {
				sb.append_c((int)' ');
			}
			sb.append_c((int)'\'');
			sb.append(p);
			sb.append_c((int)'\'');
		}
		return(sb.to_string());
	}

	public ShellCommand set_words(Collection words) {
		this.words = words;
		return(this);
	}

	Collection separate_env_words(Collection words, HashTable envdest) {
		if(words == null) {
			return(words);
		}
		Collection v;
		bool f = true;
		int envs = 0;
		foreach(String word in words) {
			if(f) {
				if(word.chr((int)'=') > 0) {
					if(envdest != null) {
						var sp = StringSplitter.split(word, (int)'=', 2);
						var key = sp.next() as String;
						var val = sp.next() as String;
						envdest.set(key, val);
					}
					envs ++;
					continue;
				}
				else {
					f = false;
				}
			}
			if(f == false && envs < 1) {
				return(words);
			}
			if(v == null) {
				v = LinkedList.create();
			}
			v.add(word);
		}
		if(v == null) {
			v = LinkedList.create();
		}
		return(v);
	}

	public Collection get_words(File cwd, HashTable env, HashTable custom_env) {
		if(commandline == null) {
			return(separate_env_words(words, custom_env));
		}
		var ww = CommandLineProcessor.process(commandline, cwd, env);
		if(ww == null) {
			ww = LinkedList.create();
		}
		foreach(String w in words) {
			ww.append(w);
		}
		return(separate_env_words(ww, custom_env));
	}

	public ShellCommand add_word(String word) {
		if(word != null) {
			if(words == null) {
				words = LinkedList.create();
			}
			words.append(word);
		}
		return(this);
	}

	public ShellCommand add_word_file(File file) {
		if(file != null) {
			if(words == null) {
				words = LinkedList.create();
			}
			words.append(file.get_native_path());
		}
		return(this);
	}

	public String to_string() {
		return(get_commandline());
	}
}
