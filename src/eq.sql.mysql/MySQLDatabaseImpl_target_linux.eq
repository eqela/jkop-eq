
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
		class StringValue
		{
			property String value;
		}

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
			parameter_values.append(new StringValue().set_value(val));
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
			// FIXME
		}

		public String get_error() {
			// FIXME
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
		}

		property String mysql_sql;
		Collection parameter_values;

		public bool initialize(String mysql) {
			if(String.is_empty(mysql)) {
				return(false);
			}
			mysql_sql = mysql;
			return(true);
		}

		public Result execute(ptr mysql_db) {
			if(mysql_db == null) {
				Log.error("MySQL error: mysql_db object is null");
				return(Result.for_fail());
			}
			if(String.is_empty(mysql_sql)) {
				Log.error("MySQL error: query string is empty");
				return(Result.for_fail());
			}
			var db = mysql_db;
			var mysql = mysql_sql;
			var sql = mysql.to_strptr();
			ptr stmt = null;
			ptr meta_result = null;
			int param_count = 0;
			strptr err = null;
			embed "c" {{{
				stmt = (void*)mysql_stmt_init(db);
			}}}
			if(stmt == null) {
				Log.error("MySQL error: stmt object is null.");
				return(Result.for_fail());
			}
			embed "c" {{{
				if(mysql_stmt_prepare(stmt, sql, strlen(sql)) != 0) {
					err = mysql_stmt_error(stmt);
				}
			}}}
			if(String.is_empty(String.for_strptr(err)) == false) {
				Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
				return(Result.for_fail());
			}
			embed "c" {{{
				MYSQL_RES *prepare_meta_result = mysql_stmt_result_metadata(stmt);
				if(!prepare_meta_result) {
					err = mysql_stmt_error(stmt);
				}
				else {
					meta_result = (MYSQL_RES*)prepare_meta_result;
				}
			}}}
			if(String.is_empty(String.for_strptr(err)) == false) {
				Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
				return(Result.for_fail());
			}
			embed "c" {{{
				param_count = mysql_stmt_param_count(stmt);
			}}}
			if(param_count < 0) {
				Log.error("MySQL error: parameter count: %d".printf().add(param_count).to_string());
				return(Result.for_fail());
			}
			int error_flag = 0;
			embed "c" {{{
				my_bool v = 1;
				if(mysql_stmt_attr_set(stmt, STMT_ATTR_UPDATE_MAX_LENGTH, (void*)&v)) {
					error_flag = 1;
				}
			}}}
			if(error_flag != 0) {
				Log.error("MySQL error: call on mysql_stmt_attr_set() failed");
				return(Result.for_fail());
			}
			if(stmt == null) {
				Log.error("MySQL error: query statement object is null");
				return(Result.for_fail());
			}
			var values = parameter_values;
			int i;
			if(param_count > 0) {
				embed "c" {{{
					MYSQL_BIND bind_ptr[param_count];
					memset(bind_ptr, 0, sizeof(bind_ptr));
					int int_values[param_count];
					double double_values[param_count];
					my_bool is_null_values[param_count];
				}}}
				for(i = 0; i < param_count; i++) {
					var o = values.get(i);
					if(o is StringValue) {
						var v = ((StringValue)o).get_value();
						if(v == null) {
							embed "c" {{{
								is_null_values[i] = 1;
								bind_ptr[i].is_null = &is_null_values[i];
							}}}
						}
						else {
							var s = v.to_strptr();
							embed "c" {{{
								bind_ptr[i].buffer_type = MYSQL_TYPE_STRING;
								bind_ptr[i].buffer = (char*)s;
								bind_ptr[i].buffer_length = strlen(s);
								bind_ptr[i].is_null = 0;
								bind_ptr[i].length = 0;
							}}}
						}
					}
					else if(o is IntegerValue) {
						var v = ((IntegerValue)o).get_value();
						embed "c" {{{
							int_values[i] = v;
							bind_ptr[i].buffer_type = MYSQL_TYPE_LONG;
							bind_ptr[i].buffer = (char*)&int_values[i];
							bind_ptr[i].is_null = 0;
							bind_ptr[i].length = 0;
						}}}
					}
					else if(o is DoubleValue) {
						var v = ((DoubleValue)o).get_value();
						embed "c" {{{
							double_values[i] = v;
							bind_ptr[i].buffer_type = MYSQL_TYPE_DOUBLE;
							bind_ptr[i].buffer = (char*)&double_values[i];
							bind_ptr[i].is_null = 0;
							bind_ptr[i].length = 0;
						}}}
					}
					else if(o is BlobValue) {
						var v = ((BlobValue)o).get_value();
						if(v == null) {
							embed "c" {{{
								is_null_values[i] = 1;
								bind_ptr[i].is_null = &is_null_values[i];
							}}}
						}
						else {
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
					}
					else {
						Log.error("MySQL error: unknown parameter detected");
						return(Result.for_fail());
					}
				}
				embed "c" {{{
					if(mysql_stmt_bind_param(stmt, bind_ptr) != 0) {
						err = mysql_stmt_error(stmt);
					}
				}}}
				if(String.is_empty(String.for_strptr(err)) == false) {
					Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
					return(Result.for_fail());
				}
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
							}
						}}}
						if(String.is_empty(String.for_strptr(err)) == false) {
							Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
							return(Result.for_fail());
						}
					}
				}
			}
			int field_count;
			if(meta_result != null) {
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
				}
			}}}
			if(String.is_empty(String.for_strptr(err)) == false) {
				Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
				return(Result.for_fail());
			}
			if(field_count > 0) {
				embed "c" {{{
					MYSQL_BIND bind_res[field_count];
					memset(bind_res, 0, sizeof(bind_res));
					unsigned long length[field_count];
					int type[field_count];
					int int_data[field_count];
					double double_data[field_count];
					char *str_data[field_count];
					char *blob_data[field_count];
					char *field_name[field_count];
					my_bool is_null[field_count];
					my_bool error[field_count];
					if(mysql_stmt_store_result(stmt)) {
						error_flag = 1;
					}
				}}}
				if(error_flag != 0) {
					Log.error("MySQL error: call on mysql_stmt_store_result() failed");
					return(Result.for_fail());
				}
				embed "c" {{{
					i = 0;
					MYSQL_FIELD *field;
					while((field = mysql_fetch_field(meta_result))) {
						field_name[i] = field->name;
						switch(field->type) {
							case MYSQL_TYPE_TINY:
							case MYSQL_TYPE_SHORT:
							case MYSQL_TYPE_LONG:
							case MYSQL_TYPE_LONGLONG:
								type[i] = 0;
								bind_res[i].buffer_type = MYSQL_TYPE_LONG;
								bind_res[i].buffer = (char*)&int_data[i];
								bind_res[i].is_null = &is_null[i];
								bind_res[i].length = &length[i];
								bind_res[i].error = &error[i];
								break;
							case MYSQL_TYPE_FLOAT:
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
								bind_res[i].buffer_type = MYSQL_TYPE_BLOB;
								blob_data[i] = malloc(field->max_length);
								bind_res[i].buffer = (char*)blob_data[i];
								bind_res[i].buffer_length = field->max_length;
								bind_res[i].is_null = &is_null[i];
								bind_res[i].length = &length[i];
								bind_res[i].error = &error[i];
								break;
							default:
								printf("MySQL warning: unknown column data type detected\n");
						}
						i++;
					}
					if(mysql_stmt_bind_result(stmt, bind_res)) {
						err = mysql_stmt_error(stmt);
					}
				}}}
				if(String.is_empty(String.for_strptr(err)) == false) {
					Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
					return(Result.for_fail());
				}
				var results = LinkedList.create();
				int current_type;
				int current_is_null;
				strptr current_field = null;
				int int_v = 0;
				double double_v = 0.0;
				strptr str_v = null;
				ptr blob_v = null;
				int sz = 0;
				var fields = Array.create();
				int exit_flag = 0;
				int row_count = 0;
				while(true) {
					i = 0;
					embed "c" {{{
						if(!mysql_stmt_fetch(stmt)) {
							row_count++;
						}
						else {
							exit_flag = 1;
						}
					}}}
					if(exit_flag != 0) {
						Log.debug("MySQL: %d total row(s) fetched".printf().add(row_count).to_string());
						break;
					}
					var row = HashTable.create();
					while(i < field_count) {
						str_v = null;
						blob_v = null;
						embed "c" {{{
							current_type = type[i];
							current_is_null = 0;
							if(is_null[i]) {
								current_is_null = 1;
							}
							current_field = field_name[i];
							int_v = 0;
							double_v = 0.0;
							sz = 0;
							if(current_type == 0) {
								if(current_is_null == 0) {
									int_v = int_data[i];
								}
							}
							else if(current_type == 1) {
								if(current_is_null == 0) {
									double_v = double_data[i];
								}
							}
							else if(current_type == 2) {
								if(current_is_null == 0) {
									sz = length[i];
									str_v = str_data[i];
								}
							}
							else if(current_type == 3) {
								if(current_is_null == 0) {
									sz = length[i];
									blob_v = blob_data[i];
								}
							}
						}}}
						var key = String.for_strptr(current_field).dup();
						if(row_count == 1) {
							fields.append(key);
						}
						if(current_type == 0) {
							row.set_int(key, int_v);
						}
						else if(current_type == 1) {
							row.set_double(key, double_v);
						}
						else if(current_type == 2) {
							if(current_is_null == 0) {
								row.set(key, String.for_utf8_buffer(Buffer.for_pointer(Pointer.create(str_v), sz), false).dup());
							}
							else {
								row.set(key, null);
							}
						}
						else if(current_type == 3) {
							if(current_is_null == 0) {
								row.set(key, Buffer.dup(Buffer.for_pointer(Pointer.create(blob_v), sz)));
							}
							else {
								row.set(key, null);
							}
						}
						i++;
					}
					results.append(row);
				}
				embed "c" {{{
					i = 0;
					while(i < field_count) {
						if(type[i] == 2) {
							free(str_data[i]);
						}
						else if(type[i] == 3) {
							free(blob_data[i]);
						}
						i++;
					}
					mysql_free_result((MYSQL_RES*)meta_result);
				}}}
				meta_result = null;
				embed "c" {{{
					if(mysql_stmt_free_result((MYSQL_STMT*)stmt) != 0) {
						err = mysql_stmt_error(stmt);
					}
				}}}
				if(String.is_empty(String.for_strptr(err)) == false) {
					Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
					return(Result.for_fail());
				}
				embed "c" {{{
					if(mysql_stmt_close((MYSQL_STMT*)stmt) != 0) {
						err = mysql_stmt_error(stmt);
					}
				}}}
				if(String.is_empty(String.for_strptr(err)) == false) {
					Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
					return(Result.for_fail());
				}
				stmt = null;
				values = null;
				return(Result.for_result_set(MySQLResultSetIterator.create(results, fields)));
			}
			embed "c" {{{
				if(mysql_stmt_free_result((MYSQL_STMT*)stmt) != 0) {
					err = mysql_stmt_error(stmt);
				}
			}}}
			if(String.is_empty(String.for_strptr(err)) == false) {
				Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
				return(Result.for_fail());
			}
			embed "c" {{{
				if(mysql_stmt_close((MYSQL_STMT*)stmt) != 0) {
					err = mysql_stmt_error(stmt);
				}
			}}}
			if(String.is_empty(String.for_strptr(err)) == false) {
				Log.error("MySQL error: '%s'".printf().add(String.for_strptr(err)).to_string());
				return(Result.for_fail());
			}
			stmt = null;
			values = null;
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

	public override String get_database_type_id() {
		strptr tid = null;
		embed "c" {{{
			tid = mysql_get_client_info();
		}}}
		if(tid != null) {
			return(String.for_strptr(tid));
		}
		return("unknown");
	}

	public override void close() {
		database_name = null;
		if(mysql_db == null) {
			return;
		}
		var mysql_conn = mysql_db;
		embed "c" {{{
			mysql_close(mysql_conn);
			mysql_conn = NULL;
			mysql_library_end();
		}}}
		mysql_db = null;
	}

	public override SQLStatement prepare(String sql) {
		var v = new MySQLStatement();
		if(v.initialize(sql) == false) {
		}
		return(v);
	}

	public override bool execute(SQLStatement stmt) {
		var st = stmt as MySQLStatement;
		if(st != null) {
			var r = st.execute(mysql_db);
			return(r.get_result());
		}
		return(false);
	}

	public override Iterator query(SQLStatement stmt) {
		var st = stmt as MySQLStatement;
		if(st != null) {
			var r = st.execute(mysql_db);
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

	private String column_to_create_string(SQLTableColumnInfo cc) {
		var sb = StringBuffer.create();
		sb.append(cc.get_name());
		sb.append_c(' ');
		var tt = cc.get_type();
		if(tt == SQLTableColumnInfo.TYPE_INTEGER_KEY) {
			sb.append("INTEGER AUTO_INCREMENT, PRIMARY KEY (");
			sb.append(cc.get_name());
			sb.append_c(')');
		}
		else if(tt == SQLTableColumnInfo.TYPE_INTEGER) {
			sb.append("INTEGER");
		}
		else if(tt == SQLTableColumnInfo.TYPE_STRING) {
			sb.append("VARCHAR(255)");
		}
		else if(tt == SQLTableColumnInfo.TYPE_TEXT) {
			sb.append("LONGTEXT");
		}
		else if(tt == SQLTableColumnInfo.TYPE_DOUBLE) {
			sb.append("REAL");
		}
		else if(tt == SQLTableColumnInfo.TYPE_BLOB) {
			sb.append("LONGBLOB");
		}
		return(sb.to_string());
	}

	public override bool create_table(String table, Collection columns) {
		if(table == null || columns == null || mysql_db == null) {
			return(false);
		}
		var sb = StringBuffer.create();
		sb.append("CREATE TABLE ");
		sb.append(table);
		sb.append(" (");
		var first = true;
		foreach(SQLTableColumnInfo cc in columns) {
			if(first == false ) {
				sb.append_c(',');
			}
			sb.append_c(' ');
			sb.append(column_to_create_string(cc));
			first = false;
		}
		sb.append(" );");
		return(execute(prepare(sb.to_string())));
	}

	public override bool delete_table(String table) {
		if(table == null || mysql_db == null) {
			return(false);
		}
		var sb = StringBuffer.create();
		sb.append("DROP TABLE ");
		sb.append(table);
		sb.append_c(';');
		return(execute(prepare(sb.to_string())));
	}

	public override bool create_index(String table, String column, bool unique) {
		if(table == null || column == null || mysql_db == null) {
			return(false);
		}
		var unq = "";
		if(unique) {
			unq = "UNIQUE ";
		}
		var sqlquery = "CREATE %sINDEX %s_%s ON %s (%s);".printf().add(unq).add(table).add(column).add(table).add(column).to_string();
		return(execute(prepare(sqlquery)));
	}
}
