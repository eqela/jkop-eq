
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

public class TemplateDirectory : LoggerObject
{
	public static TemplateDirectory for_directory(File dir, Logger logger = null) {
		return((TemplateDirectory)new TemplateDirectory().set_dir(dir).set_logger(logger));
	}

	property File dir;
	property String marker_begin;
	property String marker_end;

	public bool process(HashTable data, File destdir) {
		if(dir == null) {
			return(false);
		}
		foreach(File f in dir.entries()) {
			var of = destdir.entry(f.basename());
			if(f.is_directory()) {
				if(of.is_directory() == false) {
					if(of.mkdir_recursive() == false) {
						log_error("`%s': Failed to create directory".printf().add(of));
						return(false);
					}
				}
				if(TemplateDirectory.for_directory(f).process(data, destdir.entry(f.basename())) == false) {
					return(false);
				}
			}
			else if(f.has_extension("t")) {
				var tpl = Template.for_file(f, marker_begin, marker_end);
				if(tpl == null) {
					log_error("`%s': Failed to read template".printf().add(f));
					return(false);
				}
				var str = tpl.to_string(data);
				if(str == null) {
					log_error("`%s': Failed to process template".printf().add(f));
					return(false);
				}
				var os = OutputStream.create(of.write());
				if(os == null) {
					log_error("`%s': Failed to write output file".printf().add(of));
					return(false);
				}
			}
			else {
				if(f.copy_to(of) == false) {
					log_error("`%s': Failed to copy to `%s'".printf().add(f).add(of));
					return(false);
				}
			}
		}
		return(true);
	}
}
