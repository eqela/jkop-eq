
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

public class Zip
{
	public static Zip instance() {
		File z;
		IFDEF("target_win32") {
			z = File.for_eqela_path("/app/zip.exe");
			if(z.is_file()) {
				return(new Zip().set_exe(z));
			}
		}
		ELSE {
			z = File.for_eqela_path("/app/zip");
			if(z.is_file()) {
				return(new Zip().set_exe(z));
			}
		}
		z = SystemEnvironment.find_command("zip");
		if(z != null && z.is_file()) {
			return(new Zip().set_exe(z));
		}
		return(null);
	}

	public static bool is_available() {
		if(instance() != null) {
			return(true);
		}
		return(false);
	}

	property File exe;

	public bool compress(File zip, File src, Logger logger = null) {
		if(zip == null) {
			Log.error("NULL zipfile", logger);
			return(false);
		}
		if(src == null) {
			Log.error("NULL source file for ZIP.", logger);
			return(false);
		}
		if(exe == null) {
			Log.error("No zip command found.", logger);
			return(false);
		}
		var znp = zip.get_native_path();
		if(String.is_empty(znp)) {
			Log.error("Non-native file `%s' can not be used as a ZIP file target.".printf().add(zip), logger);
			return(false);
		}
		var snp = src.get_native_path();
		if(String.is_empty(snp)) {
			Log.error("Non-native file `%s' can not be used as ZIP source file.".printf().add(src), logger);
			return(false);
		}
		var ll = ProcessLauncher.for_file(exe).set_cwd(src.get_parent());
		ll.add_param("-q");
		ll.add_param("-r");
		ll.add_param(znp);
		ll.add_param(src.basename());
		var r = ll.execute(logger);
		if(r != 0) {
			Log.error("FAILED to produce a zip file", logger);
			return(false);
		}
		return(true);
	}
}
