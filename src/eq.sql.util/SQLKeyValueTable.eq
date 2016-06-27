
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

public class SQLKeyValueTable
{
	public static SQLKeyValueTable instance(SQLDatabase db, String tablename) {
		var v = new SQLKeyValueTable();
		v.set_db(db);
		v.set_table(tablename);
		if(v.initialize() == false) {
			v = null;
		}
		return(v);
	}

	property SQLDatabase db;
	property String table;

	public bool initialize() {
		if(db == null) {
			return(false);
		}
		if(db.table_exists(table)) {
			return(true);
		}
		if(db.create_table(table, LinkedList.create()
			.add(SQLTableColumnInfo.instance("key", SQLTableColumnInfo.TYPE_STRING))
			.add(SQLTableColumnInfo.instance("value", SQLTableColumnInfo.TYPE_TEXT))) == false) {
			return(false);
		}
		return(db.create_index(table, "key", true));
	}

	class KeyIterator : Iterator
	{
		property Iterator records;
		public Object next() {
			if(records == null) {
				return(null);
			}
			var rr = records.next() as HashTable;
			if(rr == null) {
				records = null;
				return(null);
			}
			return(rr.get_string("key"));
		}
	}

	public Iterator get_all_keys() {
		if(db == null || table == null) {
			return(null);
		}
		return(new KeyIterator().set_records(db.query(db.prepare("SELECT key FROM %s;".printf().add(table).to_string()))));
	}

	public String get(String key) {
		if(db == null || table == null) {
			return(null);
		}
		var rr = db.query_single_row(db.prepare("SELECT value FROM %s WHERE key = ?;".printf().add(table).to_string()).add_param_str(key));
		if(rr == null) {
			return(null);
		}
		return(rr.get_string("value"));
	}

	public bool set(String key, String val) {
		if(db == null || table == null || key == null) {
			return(false);
		}
		if(val == null) {
			return(delete(key));
		}
		if(get(key) == null) {
			return(db.execute(db.prepare("INSERT INTO %s ( key, value ) VALUES ( ?, ? );".printf().add(table).to_string())
				.add_param_str(key).add_param_str(val)));
		}
		return(db.execute(db.prepare("UPDATE %s SET value = ? WHERE key = ?;".printf().add(table).to_string())
			.add_param_str(val).add_param_str(key)));
	}

	public bool delete(String key) {
		if(db == null || table == null || key == null) {
			return(false);
		}
		return(db.execute(db.prepare("DELETE FROM %s WHERE key = ?;".printf().add(table).to_string()).add_param_str(key)));
	}
}
