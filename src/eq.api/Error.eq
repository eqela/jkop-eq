
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

public class Error : Stringable
{
	public static Error for_code(String code) {
		return(new Error().set_code(code));
	}

	public static Error for_message(String message) {
		return(new Error().set_message(message));
	}

	public static Error instance(String code, String message = null) {
		return(new Error().set_code(code).set_message(message));
	}

	public static Error set(Error error, String code, String message = null) {
		if(error == null) {
			return(null);
		}
		error.set_code(code);
		error.set_message(message);
		return(error);
	}

	public static Error set_error_code(Error error, String code) {
		return(Error.set(error, code, null));
	}

	public static Error set_error_message(Error error, String message) {
		return(Error.set(error, null, message));
	}

	public static bool is_error(Object o) {
		if(o == null) {
			return(false);
		}
		if(o is Error == false) {
			return(false);
		}
		var e = (Error)o;
		if(String.is_empty(e.get_code()) && String.is_empty(e.get_message())) {
			return(false);
		}
		return(true);
	}

	public static String as_string(Error error) {
		if(error == null) {
			return(null);
		}
		return(error.to_string());
	}

	property String code;
	property String message;

	public Error clear() {
		code = null;
		message = null;
		return(this);
	}

	public String to_string() {
		if(String.is_empty(message) == false) {
			return(message);
		}
		if(String.is_empty(code) == false) {
			return(code);
		}
		return(null);
	}
}
