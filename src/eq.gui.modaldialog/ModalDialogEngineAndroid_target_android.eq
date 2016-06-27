
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

class ModalDialogEngineAndroid : ModalDialogEngine
{
	property bool cancelable = true;

	public void message(Frame frame, String text, String title, ModalDialogListener listener) {
		var textp = String.as_strptr(text);
		if(textp == null) {
			embed {{{
				textp = "";
			}}}
		}
		var titlep = String.as_strptr(title);
		if(titlep == null) {
			embed {{{
				titlep = "";
			}}}
		}
		embed {{{
			final ModalDialogListener ll = listener;
			new android.app.AlertDialog.Builder(eq.api.Android.context)
				.setTitle(titlep)
				.setMessage(textp)
				.setCancelable(cancelable)
				.setPositiveButton("OK", new android.content.DialogInterface.OnClickListener() {
					public void onClick(android.content.DialogInterface dialog, int which) { 
						if(ll != null) {
							ll.on_dialog_closed();
						}
					}
				})
				.show();
		}}}
	}

	public void error(Frame frame, String text, String title, ModalDialogListener listener) {
		var textp = String.as_strptr(text);
		if(textp == null) {
			embed {{{
				textp = "";
			}}}
		}
		var titlep = String.as_strptr(title);
		if(titlep == null) {
			embed {{{
				titlep = "";
			}}}
		}
		embed {{{
			final ModalDialogListener ll = listener;
			new android.app.AlertDialog.Builder(eq.api.Android.context)
				.setTitle(titlep)
				.setMessage(textp)
				.setCancelable(cancelable)
				.setPositiveButton("OK", new android.content.DialogInterface.OnClickListener() {
					public void onClick(android.content.DialogInterface dialog, int which) { 
						if(ll != null) {
							ll.on_dialog_closed();
						}
					}
				})
				.setIcon(android.R.drawable.ic_dialog_alert)
				.show();
		}}}
	}

	public void yesno(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var textp = String.as_strptr(text);
		if(textp == null) {
			embed {{{
				textp = "";
			}}}
		}
		var titlep = String.as_strptr(title);
		if(titlep == null) {
			embed {{{
				titlep = "";
			}}}
		}
		embed {{{
			final ModalDialogBooleanListener ll = listener;
			new android.app.AlertDialog.Builder(eq.api.Android.context)
				.setTitle(titlep)
				.setMessage(textp)
				.setCancelable(cancelable)
				.setPositiveButton("Yes", new android.content.DialogInterface.OnClickListener() {
					public void onClick(android.content.DialogInterface dialog, int which) { 
						if(ll != null) {
							ll.on_dialog_boolean_result(true);
						}
					}
				})
				.setNegativeButton("No", new android.content.DialogInterface.OnClickListener() {
					public void onClick(android.content.DialogInterface dialog, int which) { 
						if(ll != null) {
							ll.on_dialog_boolean_result(false);
						}
					}
				})
				.show();
		}}}
	}

	public void okcancel(Frame frame, String text, String title, ModalDialogBooleanListener listener) {
		var textp = String.as_strptr(text);
		if(textp == null) {
			embed {{{
				textp = "";
			}}}
		}
		var titlep = String.as_strptr(title);
		if(titlep == null) {
			embed {{{
				titlep = "";
			}}}
		}
		embed {{{
			final ModalDialogBooleanListener ll = listener;
			new android.app.AlertDialog.Builder(eq.api.Android.context)
				.setTitle(titlep)
				.setMessage(textp)
				.setCancelable(cancelable)
				.setPositiveButton("OK", new android.content.DialogInterface.OnClickListener() {
					public void onClick(android.content.DialogInterface dialog, int which) { 
						if(ll != null) {
							ll.on_dialog_boolean_result(true);
						}
					}
				})
				.setNegativeButton("Cancel", new android.content.DialogInterface.OnClickListener() {
					public void onClick(android.content.DialogInterface dialog, int which) { 
						if(ll != null) {
							ll.on_dialog_boolean_result(false);
						}
					}
				})
				.show();
		}}}
	}

	public void textinput(Frame frame, String text, String title, String initial_value, ModalDialogStringListener listener) {
		var textp = String.as_strptr(text);
		if(textp == null) {
			embed {{{
				textp = "";
			}}}
		}
		var titlep = String.as_strptr(title);
		if(titlep == null) {
			embed {{{
				titlep = "";
			}}}
		}
		embed {{{
			final ModalDialogStringListener ll = listener;
			final android.widget.EditText edittext = new android.widget.EditText(eq.api.Android.context);
			android.app.AlertDialog.Builder alert = new android.app.AlertDialog.Builder(eq.api.Android.context);
			alert.setView(edittext);
			alert.setTitle(titlep);
			alert.setMessage(textp);
			alert.setCancelable(cancelable);
			alert.setPositiveButton("OK", new android.content.DialogInterface.OnClickListener() {
				public void onClick(android.content.DialogInterface dialog, int which) {
					android.view.inputmethod.InputMethodManager imm = (android.view.inputmethod.InputMethodManager)
						eq.api.Android.context.getSystemService(android.content.Context.INPUT_METHOD_SERVICE);
					imm.hideSoftInputFromWindow(edittext.getWindowToken(), 0);
					if(ll != null) {
						String str = null;
						android.text.Editable ed = edittext.getText();
						if(ed != null) {
							str = ed.toString();
						}
						if(str == null) {
							str = "";
						}
						ll.on_dialog_string_result(eq.api.String.Static.for_strptr(str));
					}
				}
			});
			alert.setNegativeButton("Cancel", new android.content.DialogInterface.OnClickListener() {
				public void onClick(android.content.DialogInterface dialog, int which) { 
					android.view.inputmethod.InputMethodManager imm = (android.view.inputmethod.InputMethodManager)
						eq.api.Android.context.getSystemService(android.content.Context.INPUT_METHOD_SERVICE);
					imm.hideSoftInputFromWindow(edittext.getWindowToken(), 0);
					if(ll != null) {
						ll.on_dialog_string_result(null);
					}
				}
			});
			android.app.AlertDialog dlg = alert.create();
			if(dlg != null) {
				dlg.getWindow().setSoftInputMode(android.view.WindowManager.LayoutParams.SOFT_INPUT_STATE_VISIBLE);
				dlg.show();
			}
		}}}
	}
}
