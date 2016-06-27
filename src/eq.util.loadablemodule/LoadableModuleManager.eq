
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

public class LoadableModuleManager : LoggerObject, ObjectFactory
{
	public static LoadableModuleManager for_module_directory(File dir, Logger logger = null) {
		var v = new LoadableModuleManager();
		v.set_logger(logger);
		v.set_libdir(dir);
		return(v);
	}

	property File libdir;
	HashTable modules;

	~LoadableModuleManager() {
		unload_modules();
	}

	public LoadableModule load_module(String name) {
		if(libdir == null) {
			return(null);
		}
		log_debug("Trying to load module: `%s' from `%s' ..".printf().add(name).add(libdir));
		var v = LoadableModule.for_name(name, libdir, get_logger());
		if(v == null) {
			log_error("Failed to load module `%s' in `%s'".printf().add(name).add(libdir));
			return(null);
		}
		log_debug("Successfully loaded module: `%s'".printf().add(name));
		return(v);
	}

	public LoadableModule get_module(String name) {
		LoadableModule v;
		if(modules != null) {
			v = modules.get(name) as LoadableModule;
			if(v != null) {
				return(v);
			}
		}
		v = load_module(name);
		if(v != null) {
			if(modules == null) {
				modules = HashTable.create();
			}
			modules.set(name, v);
		}
		return(v);
	}

	public Object create_object(String name) {
		if(String.is_empty(name)) {
			return(null);
		}
		var ld = name.rchr((int)'.');
		if(ld > 0) {
			var modname = name.substring(0,ld);
			var mod = get_module(modname);
			if(mod == null) {
				return(null);
			}
			var o = mod.create_object(name);
			if(o == null) {
				log_warning("Module `%s' does not provide class: `%s'".printf().add(mod.get_file()).add(name));
			}
			else {
				return(o);
			}
		}
		return(null);
	}

	public void unload_modules() {
		if(modules == null) {
			return;
		}
		foreach(LoadableModule mod in modules.iterate_values()) {
			log_debug("Unloading module: `%s' ..".printf().add(mod.get_file()));
			mod.unload();
		}
		modules = null;
	}
}
