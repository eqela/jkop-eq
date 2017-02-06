
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

public class MySQLDatabaseImpl : SQLDatabase
{
	class MySQLStatement : SQLStatement
	{
		class BlobValue
		{
			property Buffer value;
		}

		embed "c" {{{
			#include <mysql.h>
		}}}

		public MySQLStatement() {
			parameter_values = LinkedList.create();
		}

		public SQLStatement add_param_str(String val) {
			parameter_values.append(val);
			return(this);
		}

		public SQLStatement add_param_int(int val) {
			parameter_values.append(new IntegerValue().set_value(val));
			return(this);
		}

		public SQLStatement add_param_double(double val) {
			parameter_values.append(new DoubleValue().set_value(val));
			return(this);
		}

		public SQLStatement add_param_blob(Buffer val) {
			parameter_values.append(new BlobValue().set_value(val));
			return(this);
		}

		public void reset_statement() {
		}

		public String get_error() {
			return(null);
		}

		~MySQLStatement() {
			clear();
		}

		private void clear() {
			mysql_sql = null;
			if(parameter_values != null) {
				parameter_values.clear();
				parameter_values = null;
			}
			if(mysql_meta_result != null) {
				var prepare_meta_result = mysql_meta_result;
				embed "c" {{{
					mysql_free_result((MYSQL_RES*)prepare_meta_result);
				}}}
				mysql_meta_result = null;
			}
			if(mysql_stmt != null) {
				var stmt = mysql_stmt;
				strptr err = null;
				embed "c" {{{
					if(mysql_stmt_close((MYSQL_STMT*)stmt) != 0) {
						err = mysql_stmt_error(stmt);
					}
				}}}
				mysql_stmt = null;
			}
			mysql_db = null;
		}

		property String mysql_sql;
		Collection parameter_values;
		ptr mysql_db = null;
		ptr mysql_stmt = null;
		ptr mysql_meta_result = null;
		int mysql_param_count = 0;

		public bool initialize(ptr mysql_conn, String mysql) {
			if(mysql_conn == null || String.is_empty(mysql)) {
				return(false);
			}
			mysql_db = mysql_conn;
			mysql_sql = mysql;
			return(true);
		}

		private bool prepare() {
			if(mysql_db == null) {
				Log.error("MySQL error: mysql_db object is null");
				return(false);
			}
			if(String.is_empty(mysql_sql)) {
				Log.error("MySQL error: mysql_sql string is empty");
				return(false);
			}
			var db = mysql_db;
			var mysql = mysql_sql;
			var sql = mysql.to_strptr();
			ptr stmt = null;
			ptr meta_result = null;
			int param_count = 0;
			strptr err = null;
			var result = false;
			embed "c" {{{
				stmt = (void*)mysql_stmt_init(db);
				if(stmt == NULL) {
			}}}
			Log.error("MySQL error: stmt object is null.");
			return(false);
			embed "c" {{{
				}
				if(mysql_stmt_prepare(stmt, sql, strlen(sql)) != 0) {
					err = mysql_stmt_error(stmt);
			}}}
			Log.error("MySQL error: %s".printf().add(String.for_strptr(err)).to_string());
			return(false);
			embed "c" {{{
				}
				MYSQL_RES *prepare_meta_result = mysql_stmt_result_metadata(stmt);
				if(!prepare_meta_result) {
					err = mysql_stmt_error(stmt);
			}}}
			if(String.is_empty(String.for_strptr(err)) == false) {
				Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
				return(false);
			}
			embed "c" {{{
				}
				else {
					meta_result = (MYSQL_RES*)prepare_meta_result;
			}}}
			mysql_meta_result = meta_result;
			embed "c" {{{
				}
			}}}
			mysql_stmt = stmt;
			embed "c" {{{
				param_count = mysql_stmt_param_count(stmt);
			}}}
			Log.message("MySQL: parameter count: %d".printf().add(param_count).to_string());
			embed "c" {{{
				my_bool v = 1;
				if(mysql_stmt_attr_set(stmt, STMT_ATTR_UPDATE_MAX_LENGTH, (void*)&v)) {
			}}}
			Log.error("MySQL error: call on mysql_stmt_attr_set() failed");
			return(false);
			embed "c" {{{
				}
			}}}
			mysql_param_count = param_count;
			return(true);
		}

		public Result execute() {
			if(mysql_db == null) {
				Log.error("MySQL error: mysql_db object is null");
				return(Result.for_fail());
			}
			if(String.is_empty(mysql_sql)) {
				Log.error("MySQL error: query string is empty");
				return(Result.for_fail());
			}
			if(prepare() == false) {
				Log.error("MySQL error: failed to prepare query statement");
				return(Result.for_fail());
			}
			if(mysql_stmt == null) {
				Log.error("MySQL error: query statement object is null");
				return(Result.for_fail());
			}
			var stmt = mysql_stmt;
			var param_count = mysql_param_count;
			strptr err = null;
			embed "c" {{{
				MYSQL_BIND bind_ptr[param_count];
				memset(bind_ptr, 0, sizeof(bind_ptr));
			}}}
			var values = parameter_values;
			int i;
			for(i = 0; i < param_count; i++) {
				var o = values.get(i);
				if(o is String) {
					var v = (String)o;
					if(v == null) {
						return(Result.for_fail());
					}
					var s = v.to_strptr();
					embed "c" {{{
						bind_ptr[i].buffer_type = MYSQL_TYPE_STRING;
						bind_ptr[i].buffer = (char*)s;
						bind_ptr[i].buffer_length = strlen(s);
						bind_ptr[i].is_null = 0;
						bind_ptr[i].length = 0;
					}}}
				}
				else if(o is IntegerValue) {
					var v = ((IntegerValue)o).get_value();
					embed "c" {{{
						bind_ptr[i].buffer_type = MYSQL_TYPE_LONG;
						bind_ptr[i].buffer = (char*)&(v);
						bind_ptr[i].is_null = 0;
						bind_ptr[i].length = 0;
					}}}
				}
				else if(o is DoubleValue) {
					var v = ((DoubleValue)o).get_value();
					embed "c" {{{
						bind_ptr[i].buffer_type = MYSQL_TYPE_DOUBLE;
						bind_ptr[i].buffer = (char*)&(v);
						bind_ptr[i].is_null = 0;
						bind_ptr[i].length = 0;
					}}}
				}
				else if(o is BlobValue) {
					var v = ((BlobValue)o).get_value();
					if(v == null) {
						return(Result.for_fail());
					}
					var sz = v.get_size();
					embed "c" {{{
						char *ch[sz];
						bind_ptr[i].buffer_type = MYSQL_TYPE_BLOB;
						bind_ptr[i].buffer = (char*)ch;
						bind_ptr[i].buffer_length = sz;
						bind_ptr[i].is_null = 0;
						bind_ptr[i].length = sz;
					}}}
				}
				else {
					Log.error("MySQL error: unknown parameter detected");
					return(Result.for_fail());
				}
			}
			embed "c" {{{
				if(mysql_stmt_bind_param(stmt, bind_ptr) != 0) {
					err = mysql_stmt_error(stmt);
			}}}
			Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
			return(Result.for_fail());
			embed "c" {{{
				}
			}}}
			for(i = 0; i < param_count; i++) {
				var o = values.get(i);
				if(o is BlobValue) {
					var v = ((BlobValue)o).get_value();
					if(v == null) {
						return(Result.for_fail());
					}
					var sz = v.get_size();
					var data = v.get_ptr();
					embed "c" {{{
						if(mysql_stmt_send_long_data(stmt, i, (const char*)data, sz)) {
							err = mysql_stmt_error(stmt);
							}}}
							Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
							return(Result.for_fail());
							embed "c" {{{
						}
					}}}
				}
			}
			int field_count;
			if(mysql_meta_result != null) {
				var meta_result = mysql_meta_result;
				embed "c" {{{
					field_count = mysql_num_fields(meta_result);
				}}}
			}
			else {
				field_count = 0;
			}
			embed "c" {{{
				if(mysql_stmt_execute(stmt) != 0) {
					err = mysql_stmt_error(stmt);
			}}}
			Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
			return(Result.for_fail());
			embed "c" {{{
				}
			}}}
			if(field_count > 0) {
				var meta_result = mysql_meta_result;
				var names = Array.create();
				strptr name = null;
				embed "c" {{{
					MYSQL_BIND bind_res[field_count];
					memset(bind_res, 0, sizeof(bind_res));
					unsigned long length[field_count];
					int type[field_count];
					int int_data[field_count];
					double double_data[field_count];
					char *str_data[field_count];
					char *blob_data[field_count];
					my_bool is_null[field_count];
					my_bool error[field_count];
					if(mysql_stmt_store_result(stmt)) {
				}}}
				Log.error("MySQL error: call on mysql_stmt_store_result() failed");
				return(Result.for_fail());
				embed "c" {{{
					}
					i = 0;
					MYSQL_FIELD *field;
					while((field = mysql_fetch_field(meta_result))) {
						name = field->name;
				}}}
				names.append(String.for_strptr(name).dup());
				name = null;
				embed "c" {{{
						switch(field->type) {
							case MYSQL_TYPE_LONG:
								type[i] = 0;
								bind_res[i].buffer_type = MYSQL_TYPE_LONG;
								bind_res[i].buffer = (char*)&int_data[i];
								bind_res[i].is_null = &is_null[i];
								bind_res[i].length = &length[i];
								bind_res[i].error = &error[i];
								break;
							case MYSQL_TYPE_DOUBLE:
								type[i] = 1;
								bind_res[i].buffer_type = MYSQL_TYPE_DOUBLE;
								bind_res[i].buffer = (char*)&double_data[i];
								bind_res[i].is_null = &is_null[i];
								bind_res[i].length = &length[i];
								bind_res[i].error = &error[i];
								break;
							case MYSQL_TYPE_STRING:
							case MYSQL_TYPE_VAR_STRING:
								type[i] = 2;
								bind_res[i].buffer_type = MYSQL_TYPE_STRING;
								str_data[i] = malloc(field->max_length);
								bind_res[i].buffer = (char*)str_data[i];
								bind_res[i].buffer_length = field->max_length;
								bind_res[i].is_null = &is_null[i];
								bind_res[i].length = &length[i];
								bind_res[i].error = &error[i];
								break;
							case MYSQL_TYPE_BLOB:
								type[i] = 3;
								bind_ptr[i].buffer_type = MYSQL_TYPE_BLOB;
								blob_data[i] = malloc(field->max_length);
								bind_res[i].buffer = (char*)blob_data[i];
								bind_res[i].buffer_length = field->max_length;
								bind_ptr[i].is_null = &is_null[i];
								bind_res[i].length = &length[i];
								bind_res[i].error = &error[i];
								break;
							default:
								;
						}
						i++;
					}
					if(mysql_stmt_bind_result(stmt, bind_res)) {
				}}}
				Log.error("MySQL error: call on mysql_stmt_bind_result() failed");
				return(Result.for_fail());
				embed "c" {{{
					}
				}}}
				var results = LinkedList.create();
				int int_v = 0;
				double double_v = 0.0;
				strptr str_v = null;
				ptr blob_v = null;
				int sz = 0;
				HashTable row = null;
				int r = 0;
				embed "c" {{{
					while(!mysql_stmt_fetch(stmt))
					{
				}}}
				row = HashTable.create();
				i = 0;
				while(i < field_count) {
				embed "c" {{{
							if(type[i] == 0) {
								int_v = int_data[i];
				}}}
				row.set_int(names.get(i) as String, int_v);
				embed "c" {{{
							}
							else if(type[i] == 1) {
								double_v = double_data[i];
				}}}
				row.set_double(names.get(i) as String, double_v);
				embed "c" {{{
							}
							else if(type[i] == 2) {
								str_v = str_data[i];
				}}}
				row.set(names.get(i) as String, String.for_strptr(str_v).dup());
				embed "c" {{{
							}
							else if(type[i] == 3) {
								sz = length[i];
								blob_v = blob_data[i];
				}}}
				row.set(names.get(i) as String, Buffer.for_owned_pointer(Pointer.create(blob_v), sz));
				embed "c" {{{
							}
							i++;
				}}}
				}
				r++;
				results.append(row);
				embed "c" {{{
					}
				}}}
				return(Result.for_result_set(MySQLResultSetIterator.create(results, names)));
			}
			return(Result.for_success());
		}
	}

	class MySQLResultSetIterator : Iterator, SQLResultSetIterator
	{
		public static MySQLResultSetIterator create(Collection results, Array column_names) {
			var v = new MySQLResultSetIterator();
			v.results = results;
			v.column_names = column_names;
			return(v);
		}

		Collection results;
		Array column_names;
		int column_count = 0;
		int row_index = -1;

		public Object next() {
			if(results == null || step() == false) {
				return(null);
			}
			var v = HashTable.create();
			var cns = get_column_names();
			int c = cns.count();
			int n;
			for(n = 0; n < c; n++) {
				var cn = cns.get(n) as String, cv = get_column_object(n);
				if(cn!=null) {
					v.set(cn, cv);
				}
			}
			return(v);
		}

		public bool next_values(Array values) {
			if(results == null || values == null) {
				return(false);
			}
			if(step() == false) {
				return(false);
			}
			values.clear();
			int c = get_column_count();
			int n;
			for(n = 0; n < c; n++) {
				var cv = get_column_object(n);
				if(cv == null) {
					cv = "";
				}
				values.append(cv);
			}
			return(true);
		}

		public bool step() {
			if(results == null) {
				return(false);
			}
			row_index++;
			if(row_index < results.count()) {
				return(true);
			}
			row_index--;
			return(false);
		}

		public int get_column_count() {
			if(column_count < 1) {
				if(column_names != null) {
					column_count = column_names.count();
				}
			}
			return(column_count);
		}

		public Array get_column_names() {
			return(column_names);
		}

		public String get_column_name(int n) {
			return(column_names.get(n) as String);
		}

		public Object get_column_object(int n) {
			var r = results.get(row_index) as HashTable;
			if(r != null) {
				return(r.get(get_column_name(n)));
			}
			return(null);
		}

		public int get_column_int(int n) {
			return(Integer.as_integer(get_column_object(n)));
		}

		public double get_column_double(int n) {
			return(Double.as_double(get_column_object(n)));
		}
	}

	class Result
	{
		public static Result for_fail() {
			return(new Result().set_result(false));
		}

		public static Result for_success() {
			return(new Result().set_result(true));
		}

		public static Result for_result_set(SQLResultSetIterator result_set) {
			return(new Result().set_result(true).set_result_set(result_set));
		}

		property bool result;
		property SQLResultSetIterator result_set;
	}

	embed "c" {{{
		#include <mysql.h>
	}}}

	~MySQLDatabaseImpl() {
		close();
	}

	ptr mysql_db = null;
	String database_name;

	public static MySQLDatabaseImpl for_server(String server, String database, String username, String password) {
		var v = new MySQLDatabaseImpl();
		if(v.initialize(server, database, username, password) == false) {
			v = null;
		}
		return(v);
	}

	public bool initialize(String server, String database, String username, String password) {
		var host = server.to_strptr();
		database_name = database;
		var db = database.to_strptr();
		var un = username.to_strptr();
		var pw = password.to_strptr();
		ptr mysql_conn = null;
		embed "c" {{{
			mysql_conn = mysql_init(NULL);
			if(mysql_conn == NULL) {
		}}}
				return(false);
		embed "c" {{{
			}
			if(mysql_real_connect(mysql_conn, host, un, pw, db, 0, NULL, 0) == NULL) {
				mysql_close(mysql_conn);
		}}}
				return(false);
		embed "c" {{{
			}
		}}}
		this.mysql_db = mysql_conn;
		return(true);
	}

	public override void close() {
		if(mysql_db == null) {
			return;
		}
		var mysql_conn = mysql_db;
		embed "c" {{{
			mysql_close(mysql_conn);
		}}}
		mysql_db = null;
	}

	public override SQLStatement prepare(String sql) {
		var v = new MySQLStatement();
		if(v.initialize(mysql_db, sql) == false) {
		}
		return(v);
	}

	public override bool execute(SQLStatement stmt) {
		var st = stmt as MySQLStatement;
		if(st != null) {
			var r = st.execute();
			return(r.get_result());
		}
		return(false);
	}

	public override Iterator query(SQLStatement stmt) {
		var st = stmt as MySQLStatement;
		if(st != null) {
			var r = st.execute();
			return(r.get_result_set());
		}
		return(null);
	}

	public override HashTable query_single_row(SQLStatement stmt) {
		var v = query(stmt);
		if(v != null) {
			return(v.next() as HashTable);
		}
		return(null);
	}

	public override bool table_exists(String table) {
		if(String.is_empty(database_name) || String.is_empty(table)) {
			return(false);
		}
		var v = query_single_row(prepare("SELECT TABLE_NAME FROM information_schema.tables WHERE table_schema = ? AND table_name = ? LIMIT 1;").add_param_str(database_name).add_param_str(table));
		if(v != null) {
			return(table.equals(v.get_string("TABLE_NAME")));
		}
		return(false);
	}
}
