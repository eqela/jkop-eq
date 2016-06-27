
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

package eq.gui.sysdep.android;

public class AndroidLogger
{
	public static void debug(String e) {
		eq.api.Log.Static.debug((eq.api.Object)eq.api.String.Static.for_strptr(e), null, null);
	}

	public static void error(String e) {
		eq.api.Log.Static.error((eq.api.Object)eq.api.String.Static.for_strptr(e), null, null);
	}

	public static void message(String e) {
		eq.api.Log.Static.message((eq.api.Object)eq.api.String.Static.for_strptr(e), null, null);
	}

	public static void warning(String e) {
		eq.api.Log.Static.warning((eq.api.Object)eq.api.String.Static.for_strptr(e), null, null);
	}
}
