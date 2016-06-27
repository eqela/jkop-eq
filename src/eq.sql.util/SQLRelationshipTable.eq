
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

public class SQLRelationshipTable
{
	public static SQLRelationshipTable instance(SQLDatabase db, String tablename, Collection columns) {
		var v = new SQLRelationshipTable();
		v.set_db(db);
		v.set_table(tablename);
		if(v.initialize(columns) == false) {
			v = null;
		}
		return(v);
	}

	property SQLDatabase db;
	property String table;

	public bool initialize(Collection columns) {
		if(db == null) {
			return(false);
		}
		if(db.table_exists(table)) {
			return(true);
		}
		var cols = LinkedList.create();
		foreach(String column in columns) {
			cols.add(SQLTableColumnInfo.instance(column, SQLTableColumnInfo.TYPE_STRING));
		}
		cols.add(SQLTableColumnInfo.instance("data", SQLTableColumnInfo.TYPE_TEXT));
		if(db.create_table(table, cols) == false) {
			return(false);
		}
		bool v = true;
		foreach(String column in columns) {
			if(db.create_index(table, column, false) == false) {
				v = false;
			}
		}
		return(true);
	}

	public HashTable get_entry(String key, String value) {
		var it = get_entries(key, value);
		if(it == null) {
			return(null);
		}
		return(it.next() as HashTable);
	}

	public Iterator get_all_entries() {
		if(db == null) {
			return(null);
		}
		return(db.query(db.prepare("SELECT * FROM %s;".printf().add(table).to_string())));
	}

	public Iterator get_entries(String key, String value) {
		if(db == null || key == null || value == null) {
			return(null);
		}
		return(db.query(db.prepare("SELECT * FROM %s WHERE %s = ?;".printf().add(table).add(key).to_string()).add_param_str(value)));
	}

	public bool add_entry(HashTable entry) {
		if(db == null || entry == null || table == null) {
			return(false);
		}
		var sb = StringBuffer.create();
		sb.append("INSERT INTO %s ( ".printf().add(table).to_string());
		bool first = true;
		foreach(String key in entry) {
			if(first == false) {
				sb.append(", ");
			}
			sb.append(key);
			first = false;
		}
		sb.append(" ) VALUES ( ");
		first = true;
		foreach(String key in entry) {
			if(first == false) {
				sb.append(", ");
			}
			sb.append_c((int)'?');
			first = false;
		}
		sb.append(" );");
		var q = db.prepare(sb.to_string());
		foreach(String key in entry) {
			q.add_param_str(entry.get_string(key));
		}
		return(db.execute(q));
	}

	public bool delete_entry(String key, String val) {
		if(db == null || table == null || key == null || val == null) {
			return(false);
		}
		return(db.execute(db.prepare("DELETE FROM %s WHERE %s = ?;".printf().add(table).add(key).to_string()).add_param_str(val)));
	}
}
