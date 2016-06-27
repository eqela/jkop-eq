
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

public class Character
{
	public static int to_uppercase(int c) {
		if(c >= 'a' && c <= 'z') {
			return(c - 'a' + 'A');
		}
		return(c);
	}

	public static int to_lowercase(int c) {
		if(c >= 'A' && c <= 'Z') {
			return(c - 'A' + 'a');
		}
		return(c);
	}

	public static bool is_digit(int c) {
		return(c >= '0' && c <= '9');
	}

	public static bool is_lowercase_alpha(int c) {
		return(c >= 'a' && c <= 'z');
	}

	public static bool is_uppercase_alpha(int c) {
		return(c >= 'A' && c <= 'Z');
	}

	public static bool is_hex_digit(int c) {
		return((c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F') || (c >= '0' && c <= '9'));
	}

	public static bool is_alnum(int c) {
		return((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9'));
	}

	public static bool is_alpha(int c) {
		return((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z'));
	}
}