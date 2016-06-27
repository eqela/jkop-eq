
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

public class PaperOrientation : Stringable
{
	public static Collection get_all() {
		var v = LinkedList.create();
		int n;
		for(n=0; n<PaperOrientation.COUNT; n++) {
			v.add(PaperOrientation.for_value(n));
		}
		return(v);
	}

	public static bool matches(PaperOrientation oo, int value) {
		if(oo != null && oo.get_value() == value) {
			return(true);
		}
		return(false);
	}

	public static PaperOrientation for_value(int value) {
		return(new PaperOrientation().set_value(value));
	}

	public static int LANDSCAPE = 0;
	public static int PORTRAIT = 1;
	public static int COUNT = 2;

	property int value;

	public String to_string() {
		if(value == LANDSCAPE) {
			return("Landscape");
		}
		if(value == PORTRAIT) {
			return("Portrait");
		}
		return("Unknown orientation");
	}
}
