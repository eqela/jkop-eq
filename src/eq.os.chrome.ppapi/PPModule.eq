
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

public class PPModule : LoggerObject
{
	class PPModuleLogger : Logger
	{
		property PPModule module;
		public void log(String prefix, String msg) {
			module.post_message_string("[%s] %s".printf().add(prefix).add(msg).to_string());
		}
	}

	public static PPModule _instance;

	embed "c" {{{
		#include <string.h>
		#include "ppapi/c/pp_errors.h"
		#include "ppapi/c/pp_module.h"
		#include "ppapi/c/ppb.h"
		#include "ppapi/c/ppp.h"
		#include "ppapi/c/pp_bool.h"
		#include "ppapi/c/pp_instance.h"
		#include "ppapi/c/pp_var.h"
		#include "ppapi/c/pp_rect.h"
		#include "ppapi/c/pp_resource.h"
		#include "ppapi/c/ppp_instance.h"
		#include "ppapi/c/ppp_input_event.h"
		#include "ppapi/c/ppp_messaging.h"
		#include "ppapi/c/ppb_core.h"
		#include "ppapi/c/ppb_var.h"
		#include "ppapi/c/ppb_messaging.h"
		#include "ppapi/c/ppb_instance.h"

		PP_Bool on_did_create(PP_Instance instance, uint32_t argc, const char* argn[], const char* argv[]) {
			eq_os_chrome_ppapi_PPModule_set_pp_instance(eq_os_chrome_ppapi_PPModule__instance, (int)instance);
			if(eq_os_chrome_ppapi_PPModule_on_create(eq_os_chrome_ppapi_PPModule__instance)) {
				return(PP_TRUE);
			}
			return(PP_FALSE);
		}

		void on_did_destroy(PP_Instance instance) {
			eq_os_chrome_ppapi_PPModule_on_destroy(eq_os_chrome_ppapi_PPModule__instance);
		}

		void on_did_change_view(PP_Instance instance, PP_Resource res) {
			eq_os_chrome_ppapi_PPModule_on_change_view(eq_os_chrome_ppapi_PPModule__instance);
		}

		void on_did_change_focus(PP_Instance instance, PP_Bool has_focus) {
			int fc = 0;
			if(has_focus) {
				fc = 1;
			}
			eq_os_chrome_ppapi_PPModule_on_change_focus(eq_os_chrome_ppapi_PPModule__instance, fc);
		}

		PP_Bool on_did_handle_document_load(PP_Instance instance, PP_Resource url_loader) {
			if(eq_os_chrome_ppapi_PPModule_on_document_load(eq_os_chrome_ppapi_PPModule__instance, (int)url_loader)) {
				return(PP_TRUE);
			}
			return(PP_FALSE);
		}

		PP_Bool on_handle_input(PP_Instance instance, PP_Resource input_event) {
			if(eq_os_chrome_ppapi_PPModule_on_handle_input(eq_os_chrome_ppapi_PPModule__instance, (int)input_event)) {
				return(PP_TRUE);
			}
			return(PP_FALSE);
		}

		void on_handle_message(PP_Instance instance, struct PP_Var var_message) {
			eq_os_chrome_ppapi_PPModule_on_message(eq_os_chrome_ppapi_PPModule__instance, &var_message);
		}
	}}}

	property int pp_instance;
	ptr browser_interface = null;
	ptr ppb_core = null;
	ptr ppb_var = null;
	ptr ppb_messaging = null;
	ptr ppb_instance = null;

	public PPModule() {
		if(_instance == null) {
			_instance = this;
			Log.set_logger(new PPModuleLogger().set_module(this));
		}
	}

	public void set_browser_interface(ptr bi) {
		browser_interface = bi;
		ptr ppb_core, ppb_var, ppb_messaging, ppb_instance;
		embed {{{
			ppb_core = (void*)((PPB_GetInterface)bi)(PPB_CORE_INTERFACE);
			ppb_var = (void*)((PPB_GetInterface)bi)(PPB_VAR_INTERFACE);
			ppb_messaging = (void*)((PPB_GetInterface)bi)(PPB_MESSAGING_INTERFACE);
			ppb_instance = (void*)((PPB_GetInterface)bi)(PPB_INSTANCE_INTERFACE);
		}}}
		this.ppb_core = ppb_core;
		this.ppb_var = ppb_var;
		this.ppb_messaging = ppb_messaging;
		this.ppb_instance = ppb_instance;
	}

	public ptr get_browser_interface() {
		return(browser_interface);
	}

	public String var_to_string(ptr vv) {
		if(ppb_var == null) {
			return(null);
		}
		var ppb = this.ppb_var;
		int len;
		ptr vr;
		embed {{{
			uint32_t len32 = 0;
			vr = (void*)((PPB_Var*)ppb)->VarToUtf8(*(struct PP_Var*)vv, &len32);
			len = (int)len32;
		}}}
		if(vr == null) {
			return(null);
		}
		var buf = Buffer.for_pointer(Pointer.create(vr), len);
		return(String.for_utf8_buffer(buf, false).dup());
	}

	public void post_message_string(String msg) {
		if(ppb_messaging == null || ppb_var == null || msg == null) {
			return;
		}
		var msgstr = msg.to_strptr();
		var ppb = ppb_messaging;
		var ppbvar = ppb_var;
		var ppi = pp_instance;
		embed {{{
			struct PP_Var myvar = ((PPB_Var*)ppbvar)->VarFromUtf8(msgstr, strlen(msgstr));
			((PPB_Messaging*)ppb)->PostMessage((PP_Instance)ppi, myvar);
			((PPB_Var*)ppbvar)->Release(myvar);
		}}}
	}

	public virtual bool on_create() {
		return(true);
	}

	public virtual void on_destroy() {
	}

	public virtual void on_change_view() {
	}

	public virtual void on_change_focus(bool has_focus) {
	}

	public virtual bool on_document_load(int resource) {
		return(false);
	}

	public virtual bool on_handle_input(int resource) {
		return(false);
	}

	public virtual void on_message_string(String msg) {
	}

	public virtual void on_message(ptr msg) {
		var varapi = ppb_var;
		if(varapi == null) {
			return;
		}
		var msgstr = var_to_string(msg);
		if(msgstr == null) {
			return;
		}
		on_message_string(msgstr);
		/*
		embed {{{
			struct PP_Var* varmsg = (struct PP_Var*)msg;
			if(varmsg->type == PP_VARTYPE_UNDEFINED) {
			}
			else if(varmsg->type == PP_VARTYPE_NULL) {
			}
			else if(varmsg->type == PP_VARTYPE_BOOL) {
			}
			else if(varmsg->type == PP_VARTYPE_INT32) {
			}
			else if(varmsg->type == PP_VARTYPE_DOUBLE) {
			}
			else if(varmsg->type == PP_VARTYPE_STRING) {
			}
			else if(varmsg->type == PP_VARTYPE_OBJECT) {
			}
			else if(varmsg->type == PP_VARTYPE_ARRAY) {
			}
			else if(varmsg->type == PP_VARTYPE_DICTIONARY) {
			}
			else if(varmsg->type == PP_VARTYPE_ARRAY_BUFFER) {
			}
			else if(varmsg->type == PP_VARTYPE_RESOURCE) {
			}
		}}}
		*/
	}

	public virtual ptr get_interface_raw(strptr interface_name) {
		embed "c" {{{
			if(strcmp(interface_name, PPP_INSTANCE_INTERFACE) == 0) {
				static PPP_Instance instance_interface = {
					&on_did_create,
					&on_did_destroy,
					&on_did_change_view,
					&on_did_change_focus,
					&on_did_handle_document_load
				};
				return(&instance_interface);
			}
			else if(strcmp(interface_name, PPP_INPUT_EVENT_INTERFACE) == 0) {
				static PPP_InputEvent input_interface = {
					&on_handle_input
				};
				return(&input_interface);
			}
			else if (strcmp(interface_name, PPP_MESSAGING_INTERFACE) == 0) {
				static PPP_Messaging messaging_interface = {
					&on_handle_message
				};
				return(&messaging_interface);
			}
		}}}
		return(null);
	}
}
