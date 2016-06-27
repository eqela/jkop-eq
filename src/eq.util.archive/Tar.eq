
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

public class Tar : ArchiveExtractorCommon
{
	public static Tar instance() {
		File z;
		IFDEF("target_win32") {
			z = File.for_eqela_path("/app/tar.exe");
			if(z.is_file()) {
				return(new Tar().set_exe(z));
			}
		}
		ELSE {
			z = File.for_eqela_path("/app/tar");
			if(z.is_file()) {
				return(new Tar().set_exe(z));
			}
		}
		z = SystemEnvironment.find_command("tar");
		if(z != null && z.is_file()) {
			return(new Tar().set_exe(z));
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
	property File tarfile;

	public bool extract_to_dir(File destdir, Logger logger = null) {
		if(tarfile == null || destdir == null) {
			return(false);
		}
		var znp = tarfile.get_native_path();
		if(String.is_empty(znp)) {
			return(false);
		}
		var dnp = destdir.get_native_path();
		if(String.is_empty(dnp)) {
			return(false);
		}
		destdir.mkdir_recursive();
		var ll = ProcessLauncher.for_file(exe).set_cwd(tarfile.get_parent());
		var tarcmd = "xf";
		if(znp.has_suffix(".tar.bz2") || znp.has_suffix(".tbz2") || znp.has_suffix("tbz")) {
			tarcmd = "jxf";
		}
		else if(znp.has_suffix(".tar.gz") || znp.has_suffix(".tgz")) {
			tarcmd = "zxf";
		}
		ll.add_param(tarcmd);
		ll.add_param(znp);
		ll.add_param("-C");
		ll.add_param(dnp);
		var r = ll.execute(logger);
		if(r != 0) {
			return(false);
		}
		return(true);
	}
}
