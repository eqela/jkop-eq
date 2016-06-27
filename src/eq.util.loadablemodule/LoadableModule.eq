
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

public interface LoadableModule : ObjectFactory
{
	public static LoadableModule for_file(File file, Logger logger = null) {
		if(file == null) {
			return(null);
		}
		IFDEF("target_posix") {
			return(PosixLoadableModule.for_file(file, logger));
		}
		ELSE IFDEF("target_win32") {
			return(Win32LoadableModule.for_file(file, logger));
		}
		ELSE {
			Log.error("Loadable modules are not implemented for this platform.", logger);
			return(null);
		}
	}

	public static LoadableModule for_name(String name, File dir, Logger logger = null) {
		if(String.is_empty(name) || dir == null) {
			return(null);
		}
		IFDEF("target_posix") {
			return(PosixLoadableModule.for_name(name, dir, logger));
		}
		ELSE IFDEF("target_win32") {
			return(Win32LoadableModule.for_name(name, dir, logger));
		}
		ELSE {
			Log.error("Loadable modules are not implemented for this platform.", logger);
			return(null);
		}
	}

	public File get_file();
	public bool unload();
	public bool has_object(String name);
}
