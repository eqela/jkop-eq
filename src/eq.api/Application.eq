
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

public class Application
{
	private static String aname = null;
	private static String adisplay_name = null;
	private static String aversion = null;
	private static String adescription = null;
	private static String acopyright = null;
	private static String alicense = null;
	private static String aurl = null;
	private static Object main = null;
	private static String instance_command = null;
	private static Collection instance_args = null;

	public static String get_instance_command() {
		return(instance_command);
	}

	public static void set_instance_command(String c) {
		instance_command = c;
	}

	public static Collection get_instance_args() {
		return(instance_args);
	}

	public static void set_instance_args(Collection a) {
		instance_args = a;
	}

	public static String get_version() {
		return(aversion);
	}

	public static String get_name() {
		return(aname);
	}

	public static Object get_main() {
		return(main);
	}

	public static String get_display_name() {
		if(String.is_empty(adisplay_name)) {
			return(get_name());
		}
		return(adisplay_name);
	}

	public static String get_description() {
		return(adescription);
	}

	public static String get_copyright() {
		return(acopyright);
	}

	public static String get_license() {
		return(alicense);
	}

	public static String get_url() {
		return(aurl);
	}

	public static void set_main(Object o) {
		Application.main = o;
	}

	public static void initialize(String appid = null, String displayname = null, String version = null, String description = null, String copyright = null, String license = null, String url = null) {
		if(Application.aname == null) {
			if(appid != null) {
				Application.aname = appid;
			}
			if(displayname != null) {
				Application.adisplay_name = displayname;
			}
			if(version != null) {
				Application.aversion = version;
			}
			if(description != null) {
				Application.adescription = description;
			}
			if(copyright != null) {
				Application.acopyright = copyright;
			}
			if(license != null) {
				Application.alicense = license;
			}
			if(url != null) {
				Application.aurl = url;
			}
		}
	}
}
