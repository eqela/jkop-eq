
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

public class SQLTableColumnInfo
{
	public static SQLTableColumnInfo instance(String name, int type) {
		return(new SQLTableColumnInfo().set_name(name).set_type(type));
	}

	public static SQLTableColumnInfo for_integer(String name) {
		return(new SQLTableColumnInfo().set_name(name).set_type(TYPE_INTEGER));
	}

	public static SQLTableColumnInfo for_string(String name) {
		return(new SQLTableColumnInfo().set_name(name).set_type(TYPE_STRING));
	}

	public static SQLTableColumnInfo for_text(String name) {
		return(new SQLTableColumnInfo().set_name(name).set_type(TYPE_TEXT));
	}

	public static SQLTableColumnInfo for_integer_key(String name) {
		return(new SQLTableColumnInfo().set_name(name).set_type(TYPE_INTEGER_KEY));
	}

	public static SQLTableColumnInfo for_double(String name) {
		return(new SQLTableColumnInfo().set_name(name).set_type(TYPE_DOUBLE));
	}

	public static SQLTableColumnInfo for_blob(String name) {
		return(new SQLTableColumnInfo().set_name(name).set_type(TYPE_BLOB));
	}

	public static int TYPE_INTEGER = 0;
	public static int TYPE_STRING = 1;
	public static int TYPE_TEXT = 2;
	public static int TYPE_INTEGER_KEY = 3;
	public static int TYPE_DOUBLE = 4;
	public static int TYPE_BLOB = 5;

	property String name;
	property int type;
}
