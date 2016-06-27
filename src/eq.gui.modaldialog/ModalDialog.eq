
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

public class ModalDialog
{
	static ModalDialogEngine engine;

	public static void set_engine(ModalDialogEngine e) {
		engine = e;
	}

	public static ModalDialogEngine get_engine() {
		return(engine);
	}

	public static void set_cancelable_android(bool cancelable) {
		IFDEF("target_android") {
			if(engine == null) {
				engine = create_engine();
			}
			((ModalDialogEngineAndroid)engine).set_cancelable(cancelable);
		}
	}

	static ModalDialogEngine create_engine() {
		IFDEF("target_osx") {
			return(new ModalDialogEngineOSX());
		}
		ELSE IFDEF("target_android") {
			return(new ModalDialogEngineAndroid());
		}
		ELSE IFDEF("target_ios") {
			return(new ModalDialogEngineIOS());
		}
		ELSE IFDEF("target_linux") {
			return(new ModalDialogEngineLinux());
		}
		ELSE IFDEF("target_win32") {
			return(new ModalDialogEngineWin32());
		}
		ELSE IFDEF("target_wpcs") {
			return(new ModalDialogEngineWPCS());
		}
		ELSE IFDEF("target_html5") {
			return(new ModalDialogEngineHTML5());
		}
		ELSE IFDEF("target_uwpcs") {
			return(new ModalDialogEngineUWPCS());
		}
		ELSE IFDEF("target_j2se") {
			return(new ModalDialogEngineJ2SE());
		}
		ELSE {
			return(new ModalDialogEngineGeneric());
		}
	}

	public static void message(String text, String title = null, ModalDialogListener listener = null, Frame frame = null) {
		if(engine == null) {
			engine = create_engine();
		}
		var tit = title;
		if(String.is_empty(tit)) {
			tit = "Message";
		}
		engine.message(frame, text, tit, listener);
	}

	public static void error(String text, String title = null, ModalDialogListener listener = null, Frame frame = null) {
		if(engine == null) {
			engine = create_engine();
		}
		var tit = title;
		if(String.is_empty(tit)) {
			tit = "Error";
		}
		engine.error(frame, text, tit, listener);
	}

	public static void yesno(String text, String title, ModalDialogBooleanListener listener, Frame frame = null) {
		if(engine == null) {
			engine = create_engine();
		}
		var tit = title;
		if(String.is_empty(tit)) {
			tit = "Question";
		}
		engine.yesno(frame, text, tit, listener);
	}

	public static void okcancel(String text, String title, ModalDialogBooleanListener listener, Frame frame = null) {
		if(engine == null) {
			engine = create_engine();
		}
		var tit = title;
		if(String.is_empty(tit)) {
			tit = "Error";
		}
		engine.okcancel(frame, text, tit, listener);
	}

	public static void textinput(String text, String title, String initial_value, ModalDialogStringListener listener, Frame frame = null) {
		if(engine == null) {
			engine = create_engine();
		}
		var tit = title;
		if(String.is_empty(tit)) {
			tit = "Question";
		}
		engine.textinput(frame, text, tit, initial_value, listener);
	}
}
