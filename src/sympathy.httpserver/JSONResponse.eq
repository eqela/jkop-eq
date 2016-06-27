
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

public class JSONResponse
{
	public static HashTable for_error(Error error = null) {
		var v = HashTable.create();
		v.set("status", "error");
		if(error != null) {
			var msg = error.get_message();
			if(String.is_empty(msg) == false) {
				v.set("message", msg);
			}
			var code = error.get_code();
			if(String.is_empty(code) == false) {
				v.set("code", code);
			}
		}
		return(v);
	}

	public static HashTable for_error_message(String message = null, String code = null) {
		var v = HashTable.create();
		v.set("status", "error");
		if(String.is_empty(message) == false) {
			v.set("message", message);
		}
		if(String.is_empty(code) == false) {
			v.set("code", code);
		}
		return(v);
	}

	public static HashTable for_ok(Object data = null) {
		var v = HashTable.create();
		v.set("status", "ok");
		if(data != null) {
			v.set("data", data);
		}
		return(v);
	}

	public static HashTable for_details(String status, String code, String msg) {
		var v = HashTable.create();
		if(status != null) {
			v.set("status", status);
		}
		if(code != null) {
			v.set("code", code);
		}
		if(msg != null) {
			v.set("message", msg);
		}
		return(v);
	}

	public static HashTable for_missing_data(String type = null) {
		if(type != null) {
			return(for_error_message("Missing data: ".append(type), "missing_data"));
		}
		return(for_error_message("Missing data", "missing_data"));
	}

	public static HashTable for_invalid_data(String type = null) {
		if(type != null) {
			return(for_error_message("Invalid data: ".append(type), "invalid_data"));
		}
		return(for_error_message("Invalid data", "invalid_data"));
	}

	public static HashTable for_already_exists() {
		return(for_error_message("Already exists", "already_exists"));
	}

	public static HashTable for_invalid_request(String type = null) {
		if(type != null) {
			return(for_error_message("Invalid request: ".append(type), "invalid_request"));
		}
		return(for_error_message("Invalid request", "invalid_request"));
	}

	public static HashTable for_not_allowed() {
		return(for_error_message("Not allowed", "not_allowed"));
	}

	public static HashTable for_failed_to_create() {
		return(for_error_message("Failed to create", "failed_to_create"));
	}

	public static HashTable for_not_found() {
		return(for_error_message("Not found", "not_found"));
	}

	public static HashTable for_authentication_failed() {
		return(for_error_message("Authentication failed", "authentication_failed"));
	}

	public static HashTable for_incorrect_username_password() {
		return(for_error_message("Incorrect username and/or password", "authentication_failed"));
	}

	public static HashTable for_internal_error(String details = null) {
		if(details != null) {
			return(for_error_message("Internal error: ".append(details), "internal_error"));
		}
		return(for_error_message("Internal error", "internal_error"));
	}
}
