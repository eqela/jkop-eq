
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

public class SQLiteDatabase : SQLDatabase
{
	private static SQLiteDatabase instance() {
		IFDEF("target_android") {
			return(new SQLiteDatabaseAndroid());
		}
		ELSE IFDEF("target_c") {
			return(new SQLiteDatabaseC());
		}
		ELSE IFDEF("target_monocs") {
			return(new SQLiteDatabaseMono());
		}
		return(null);
	}

	public static SQLiteDatabase for_file(File file, bool allow_create = true, Logger logger = null) {
		if(file == null) {
			return(null);
		}
		var v = instance();
		if(v == null) {
			return(null);
		}
		v.set_logger(logger);
		if(file.is_file() == false) {
			if(allow_create == false) {
				return(null);
			}
			var pp = file.get_parent();
			if(pp.is_directory() == false) {
				if(pp.mkdir_recursive() == false) {
					Log.error("Failed to create directory: `%s'".printf().add(pp), logger);
				}
			}
			if(v.initialize(file, true) == false) {
				v = null;
			}
		}
		else {
			if(v.initialize(file, false) == false) {
				v = null;
			}
		}
		return(v);
	}

	public String get_database_type_id() {
		return("sqlite");
	}

	public virtual bool initialize(File file, bool create) {
		return(true);
	}

	public void close() {
	}

	public SQLStatement prepare(String sql) {
		return(null);
	}

	public bool execute(SQLStatement stmt) {
		return(false);
	}

	public Iterator query(SQLStatement stmt) {
		return(null);
	}

	public HashTable query_single_row(SQLStatement stmt) {
		foreach(HashTable h in query(stmt)) {
			return(h);
		}
		return(null);
	}

	public bool table_exists(String table) {
		if(table == null) {
			return(false);
		}
		var stmt = prepare("SELECT name FROM sqlite_master WHERE type='table' AND name=?;");
		if(stmt == null) {
			return(false);
		}
		stmt.add_param_str(table);
		var sr = query_single_row(stmt);
		if(sr == null) {
			return(false);
		}
		if(table.equals(sr.get_string("name")) == false) {
			return(false);
		}
		return(true);
	}

	String column_to_create_string(SQLTableColumnInfo cc) {
		var sb = StringBuffer.create();
		sb.append(cc.get_name());
		sb.append_c((int)' ');
		var tt = cc.get_type();
		if(cc.get_type() == SQLTableColumnInfo.TYPE_INTEGER_KEY) {
			sb.append("INTEGER PRIMARY KEY AUTOINCREMENT");
		}
		else if(cc.get_type() == SQLTableColumnInfo.TYPE_INTEGER) {
			sb.append("INTEGER");
		}
		else if(cc.get_type() == SQLTableColumnInfo.TYPE_STRING) {
			sb.append("VARCHAR(255)");
		}
		else if(cc.get_type() == SQLTableColumnInfo.TYPE_TEXT) {
			sb.append("TEXT");
		}
		else if(cc.get_type() == SQLTableColumnInfo.TYPE_BLOB) {
			sb.append("BLOB");
		}
		else if(cc.get_type() == SQLTableColumnInfo.TYPE_DOUBLE) {
			sb.append("REAL");
		}
		else {
			Log.error("Unknown column type: %d".printf().add(cc.get_type()));
			sb.append("UNKNOWN");
		}
		return(sb.to_string());
	}

	public bool create_table(String table, Collection columns) {
		if(table == null || columns == null) {
			return(false);
		}
		var sb = StringBuffer.create();
		sb.append("CREATE TABLE ");
		sb.append(table);
		sb.append(" (");
		var first = true;
		foreach(SQLTableColumnInfo column in columns) {
			if(first == false) {
				sb.append_c((int)',');
			}
			sb.append_c((int)' ');
			sb.append(column_to_create_string(column));
			first = false;
		}
		sb.append(" );");
		if(execute(prepare(sb.to_string())) == false) {
			return(false);
		}
		return(true);
	}

 	public bool delete_table(String table) {
		if(table == null) {
			return(false);
		}
		var sb = StringBuffer.create();
		sb.append("DROP TABLE ");
		sb.append(table);
		sb.append(";");
		if(execute(prepare(sb.to_string())) == false) {
			return(false);
		}
		return(true);
	}

	public bool create_index(String table, String column, bool unique) {
		if(table == null || column == null) {
			return(false);
		}
		var unq = "";
		if(unique) {
			unq = "UNIQUE ";
		}
		var sql = "CREATE %sINDEX %s_%s ON %s (%s);".printf().add(unq).add(table).add(column).add(table).add(column).to_string();
		if(execute(prepare(sql)) == false) {
			return(false);
		}
		return(true);
	}
}
