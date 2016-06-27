
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

class PosixLoadableModule : LoggerObject, LoadableModule, ObjectFactory
{
	public static PosixLoadableModule for_file(File file, Logger logger) {
		var v = new PosixLoadableModule();
		v.set_logger(logger);
		v.set_file(file);
		return(v.initialize() as PosixLoadableModule);
	}

	public static PosixLoadableModule for_name(String name, File dir, Logger logger) {
		var fext = "so";
		IFDEF("target_osx") {
			fext = "dylib";
		}
		var ff = dir.entry("lib%s.%s".printf().add(name).add(fext).to_string());
		if(ff.is_file() == false) {
			return(null);
		}
		return(PosixLoadableModule.for_file(ff, logger));
	}

	embed "c" {{{
		#include <sys/types.h>
		#include <sys/stat.h>
		#include <unistd.h>
		#include <dlfcn.h>
	}}}

	property ptr dlhandle;
	property File file;

	~PosixLoadableModule() {
		unload();
	}

	public ptr symbol(String name) {
		if(dlhandle == null || name == null) {
			return(null);
		}
		var dh = dlhandle;
		ptr v = null;
		var sym = name.to_strptr();
		embed "c" {{{
			v = dlsym(dh, sym);
		}}}
		if(v == null && name.has_prefix("_") == false) {
			return(symbol("_".append(name)));
		}
		return(v);
	}

	String internal_symbol_name(String name) {
		var iii = "%s.%s".printf().add(get_module_name()).add(name).to_string();
		if(iii != null) {
			iii = iii.replace_char('.', '_');
		}
		return(iii);
	}

	public LoadableModule initialize() {
		if(file == null) {
			return(null);
		}
		var np = file.get_native_path();
		if(np == null) {
			return(null);
		}
		log_debug("Loading module file: `%s' ..".printf().add(file));
		bool v = false;
		ptr dh;
		var fs = np.to_strptr();
		embed "c" {{{
			dh = dlopen(fs, RTLD_LOCAL | RTLD_LAZY);
		}}}
		if(dh == null) {
			strptr dle = null;
			embed "c" {{{
				dle = dlerror(); 
			}}}
			log_debug("Module '%s' loading failed. dlerror='%s'".printf().add(file).add(String.for_strptr(dle)));
			return(null);
		}
		dlhandle = dh;
		var initf  = symbol(internal_symbol_name("Main.initialize_module"));
		if(initf != null) {
			embed "c" {{{
				void (*f)() = initf;
				f();
			}}}
		}
		return(this);
	}

	public bool unload() {
		IFDEF("target_osx") {
			return(false);
		}
		if(dlhandle == null) {
			return(true);
		}
		var cleanupf  = symbol(internal_symbol_name("Main.cleanup_module"));
		if(cleanupf != null) {
			embed "c" {{{
				void (*f)() = cleanupf;
				f();
			}}}
		}
		bool v = true;
		var dh = dlhandle;
		embed "c" {{{
			if(dlclose(dh) == 0) {
				v = 0;
			}
		}}}
		dlhandle = null;
		return(v);
	}

	String get_module_name() {
		if(file == null) {
			return(null);
		}
		var bn = file.basename();
		if(bn == null) {
			return(null);
		}
		if(bn.has_prefix("lib")) {
			bn = bn.substring(3);
		}
		return(Path.strip_extension(bn));
	}

	ptr find_create_function(String name) {
		if(dlhandle == null || name == null) {
			return(null);
		}
		var sbstr = name.replace_char('.', '_');
		if(String.is_empty(sbstr)) {
			return(null);
		}
		ptr sym = symbol("new_%s".printf().add(sbstr).to_string());
		if(sym == null) {
			if(name.chr('.') < 0) {
				var modname = get_module_name();
				if(String.is_empty(modname) == false) {
					return(find_create_function("%s.%s".printf().add(modname).add(name).to_string()));
				}
			}
		}
		return(sym);
	}

	public Object create_object(String name) {
		var sym = find_create_function(name);
		if(sym == null) {
			return(null);
		}
		Object v = null;
		embed "c" {{{
			void* (*f)() = sym;
			v = f();
		}}}
		return(v);
	}

	public bool has_object(String name) {
		var sym = find_create_function(name);
		if(sym == null) {
			return(false);
		}
		return(true);
	}
}
