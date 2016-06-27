
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

public class SimpleHighScore
{
	public static int get_current(String name = null) {
		var filename = name;
		if(filename == null) {
			filename = "highscore";
		}
		filename = filename.append(".txt");
		var dd = ApplicationData.for_this_application();
		if(dd == null) {
			Log.error("Cannot read high score: No application data directory");
			return(0);
		}
		var ff = dd.entry(filename);
		if(ff.is_file() == false) {
			Log.debug("High score file `%s' does not exist.".printf().add(ff));
			return(0);
		}
		var txt = ff.get_contents_string();
		if(String.is_empty(txt)) {
			Log.warning("High score file `%s' is empty.".printf().add(ff));
			return(0);
		}
		Log.debug("High score file contents: `%s'".printf().add(txt));
		return(Integer.as_integer(txt, 0));
	}

	public static void update(int score = 0, String name = null) {
		var filename = name;
		if(filename == null) {
			filename = "highscore";
		}
		filename = filename.append(".txt");
		var dd = ApplicationData.for_this_application();
		if(dd == null) {
			Log.error("No application data file system found for this application");
			return;
		}
		if(dd.is_directory() == false) {
			if(dd.mkdir_recursive() == false) {
				Log.error("Failed to create directory: `%s'".printf().add(dd));
			}
		}
		var ff = dd.entry(filename);
		if(ff.set_contents_string(String.for_integer(score)) == false) {
			Log.error("Failed to write high score file: `%s'".printf().add(ff));
		}
		else {
			Log.debug("High score successfully written to: `%s'".printf().add(ff));
		}
	}
}
