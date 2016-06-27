
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

class EqelaUserAgent
{
	public static String get_platform_user_agent(String aua) {
		var ua = aua;
		if(ua == null) {
			String name = Application.get_display_name();
			String version = Application.get_version();
			if(String.is_empty(name) == false && String.is_empty(version) == false) {
				ua = "%s/%s (%s)".printf().add(name).add(version)
					.add(VALUE("target_platform")).to_string();
			}
		}
		if(ua == null) {
			ua = "eq.net.http/%s".printf().add(VALUE("version")).to_string();
		}
		else {
			ua = "%s eq.net.http/%s".printf().add(ua).add(VALUE("version")).to_string();
		}
		return(ua);
	}
}
