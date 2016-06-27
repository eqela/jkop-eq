
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

public class SEDefaultEngine : SEEngine
{
	public static void activate() {
		SEEngine.set(new SEDefaultEngine());
	}

	public SEBackend create_backend(Frame frame, bool debug) {
		IFDEF("target_osx") {
			return(SESpriteKitBackend.instance(frame, debug));
		}
		IFDEF("target_ios") {
			return(SESpriteKitBackend.instance(frame, debug));
		}
		IFDEF("target_html") {
			return(SEHTMLElementBackend.instance(frame, debug));
		}
		IFDEF("target_wpcs") {
			return(SEWPCSBackend.instance(frame, debug));
		}
		IFDEF("target_win32") {
			return(SEDirect2DBackend.instance(frame));
		}
		IFDEF("target_linux") {
			return(SESurfaceBackend.instance(frame));
		}
		IFDEF("target_android") {
			if(true) {
				return(SESurfaceBackend.instance(frame));
			}
		}
		IFDEF("target_j2me") {
			if(true) {
				return(SESurfaceBackend.instance(frame));
			}
		}
		IFDEF("target_bbjava") {
			if(true) {
				return(SESurfaceBackend.instance(frame));
			}
		}
		IFDEF("target_j2se") {
			if(true) {
				return(SESurfaceBackend.instance(frame));
			}
		}
		Log.error("Running on unsupported platform: Failed to create any backend");
		return(null);
	}
}
