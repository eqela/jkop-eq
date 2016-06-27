
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

public class SQLTableInfo
{
	public static SQLTableInfo for_name(String name) {
		return(new SQLTableInfo().set_name(name));
	}

	property String name;
	property Collection columns;
	property Collection indexes;

	public SQLTableInfo add_column(SQLTableColumnInfo info) {
		if(info == null) {
			return(this);
		}
		if(columns == null) {
			columns = LinkedList.create();
		}
		columns.add(info);
		return(this);
	}

	public SQLTableInfo add_integer_column(String name) {
		return(add_column(SQLTableColumnInfo.for_integer(name)));
	}

	public SQLTableInfo add_string_column(String name) {
		return(add_column(SQLTableColumnInfo.for_string(name)));
	}

	public SQLTableInfo add_text_column(String name) {
		return(add_column(SQLTableColumnInfo.for_text(name)));
	}

	public SQLTableInfo add_integer_key_column(String name) {
		return(add_column(SQLTableColumnInfo.for_integer_key(name)));
	}

	public SQLTableInfo add_double_column(String name) {
		return(add_column(SQLTableColumnInfo.for_double(name)));
	}

	public SQLTableInfo add_blob_column(String name) {
		return(add_column(SQLTableColumnInfo.for_blob(name)));
	}

	public SQLTableInfo add_index(String column) {
		if(String.is_empty(column) == false) {
			if(columns == null) {
				columns = LinkedList.create();
			}
			columns.add(new SQLTableColumnIndexInfo().set_column(column).set_unique(false));
		}
		return(this);
	}

	public SQLTableInfo add_unique_index(String column) {
		if(String.is_empty(column) == false) {
			if(columns == null) {
				columns = LinkedList.create();
			}
			columns.add(new SQLTableColumnIndexInfo().set_column(column).set_unique(true));
		}
		return(this);
	}
}
