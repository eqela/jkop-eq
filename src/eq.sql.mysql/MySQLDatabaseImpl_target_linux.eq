
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
	class Statement : LoggerObject, SQLStatement
	{
		class DoubleParam
		{
			public double val;
			property double param_val;
		}

		class IntegerParam
		{
			public int val;
			property int param_val;
		}

		embed "c" {{{
			#include <mysql.h>
		}}}

		property String sql;
		ptr stmt = null;
		ptr bind = null;
		Collection bind_values = null;
		Array data = null;
		String error = null;
		int paramidx = 0;
		int totalparamidx = 0;
		bool is_binding = false;

		~Statement() {
			clear();
		}

		private void clear() {
			stmt = null;
			bind = null;
			bind_values = null;
			data = null;
		}

		public bool create(ptr db, String sql) {
			var v = false;
			if(db != null && sql != null) {
				var ss = sql.to_strptr();
				strptr err = null;
				var mdb = db;
				int cnt = 0;
				ptr st = null;
				ptr bd = null;
				if(sql.contains("?")) {
					is_binding = true;
					embed "c" {{{
						st = (void*)mysql_stmt_init(mdb);
						if(!st) {
							}}}
							log_error("Out of memory ..");
							return(false);
							embed "c" {{{
						}
						if(mysql_stmt_prepare(st, ss, strlen(ss))) {
							err = mysql_stmt_error(st);
							v = 1;
						}
						else {
							}}}
							stmt = st;
							embed "c" {{{
							cnt = mysql_stmt_param_count(st);
							MYSQL_BIND bnd[cnt];
							bd = malloc(cnt * sizeof(bnd));
						}
					}}}
					bind = bd;
					bind_values = LinkedList.create();
					totalparamidx = cnt;
				}
				else {
					embed "c" {{{
						if(mysql_query(mdb, ss)) {
							err = mysql_error(mdb);
							v = 1;
						}
						else {
							}}}
							stmt = mdb;
							embed "c" {{{
						}
					}}}
				}
				if(v == false) {
					this.sql = sql;
				}
				else {
					log_warning("MySQL ERROR when preparing MySQL statement `%s': `%s'".printf().add(sql).add(String.for_strptr(err)).to_string());
				}
			}
			return(v);
		}

		public SQLStatement add_param_str(String val) {
			if(stmt != null && bind != null) {
				var aval = val;
				if(aval == null) {
					aval = "";
				}
				var v = -1;
				var vs = aval.to_strptr();
				var pi = paramidx;
				var bd = bind;
				embed "c" {{{
					MYSQL_BIND* bnd = (MYSQL_BIND*)bd;
					bnd[pi].buffer_type = MYSQL_TYPE_STRING;
					bnd[pi].buffer = (char*)vs;
					bnd[pi].buffer_length = strlen(vs);
					bnd[pi].is_null = 0;
					bnd[pi].length = 0;
					v = pi;
					pi++;
					bd = (void*)bnd;
				}}}
				bind = bd;
				paramidx = pi;
				if(v >= 0) {
					bind_values.append(aval);
				}
				if(paramidx == totalparamidx) {
					bind_execute_params();
				}
			}
			return(this);
		}

		public SQLStatement add_param_int(int val) {
			if(stmt != null && bind != null) {
				var v = -1;
				var iv = new IntegerParam().set_param_val(val);
				var pi = paramidx;
				var bd = bind;
				embed "c" {{{
					MYSQL_BIND* bnd = (MYSQL_BIND*)bd;
					bnd[pi].buffer_type = MYSQL_TYPE_LONG;
					bnd[pi].buffer = (char*)&(((eq_sql_mysql_MySQLDatabaseImpl_Statement_IntegerParam*)iv)->val);
					bnd[pi].is_null = 0;
					bnd[pi].length = 0;
					v = pi;
					pi++;
					bd = (void*)bnd;
				}}}
				bind = bd;
				paramidx = pi;
				if(v >= 0) {
					bind_values.append(iv);
				}
				if(paramidx == totalparamidx) {
					bind_execute_params();
				}
			}
			return(this);
		}

		public SQLStatement add_param_double(double val) {
			if(stmt != null && bind != null) {
				var v = -1;
				var iv = new DoubleParam().set_param_val(val);
				var pi = paramidx;
				var bd = bind;
				embed "c" {{{
					MYSQL_BIND* bnd = (MYSQL_BIND*)bd;
					bnd[pi].buffer_type = MYSQL_TYPE_DOUBLE;
					bnd[pi].buffer = (char*)&(((eq_sql_mysql_MySQLDatabaseImpl_Statement_DoubleParam*)iv)->val);
					bnd[pi].is_null = 0;
					bnd[pi].length = 0;
					v = pi;
					pi++;
					bd = (void*)bnd;
				}}}
				bind = bd;
				paramidx = pi;
				if(v >= 0) {
					bind_values.append(iv);
				}
				if(paramidx == totalparamidx) {
					bind_execute_params();
				}
			}
			return(this);
		}

		public SQLStatement add_param_blob(Buffer val) {
			if(stmt != null && bind != null) {
				if(val == null) {
					return(this);
				}
				var v = -1;
				var s = val.get_size();
				var pi = paramidx;
				var bd = bind;
				embed "c" {{{
					MYSQL_BIND* bnd = (MYSQL_BIND*)bd;
					char *ch[s];
					bnd[pi].buffer_type = MYSQL_TYPE_BLOB;
					bnd[pi].buffer = (char*)ch;
					bnd[pi].buffer_length = s;
					bnd[pi].is_null = 0;
					bnd[pi].length = 0;
					v = pi;
					pi++;
					bd = (void*)bnd;
				}}}
				bind = bd;
				paramidx = pi;
				if(v >= 0) {
					bind_values.append(val);
				}
				if(paramidx == totalparamidx) {
					bind_execute_params();
				}
			}
			return(this);
		}

		private void bind_execute_params() {
			if(stmt != null && bind != null) {
				var p = stmt;
				strptr err = null;
				var bd = bind;
				embed "c" {{{
					MYSQL_BIND* bnd = (MYSQL_BIND*)bd;
					if(mysql_stmt_bind_param(p, bnd) != 0) {
						err = mysql_stmt_error(p);
						}}}
						error = "MySQL error %s".printf().add(String.for_strptr(err)).to_string();
						return;
						embed "c" {{{
					}
					}}}
					int cnt = 0;
					foreach(Object o in bind_values) {
						if(o is String) {
							var str = ((String)o).to_strptr();
							embed "c" {{{
								bnd[cnt].length = strlen(str);
							}}}
						}
						else if(o is IntegerParam) {
							var ip = (IntegerParam)o;
							ip.val = ip.get_param_val();
						}
						else if(o is DoubleParam) {
							var dp = (DoubleParam)o;
							dp.val = dp.get_param_val();
						}
						else if(o is Buffer) {
							var bf = (Buffer)o;
							var b = bf.get_pointer().get_native_pointer();
							var s = bf.get_size();
							embed "c" {{{
								if(mysql_stmt_send_long_data(p, cnt, (const char*)b, s)) {
									err = mysql_stmt_error(p);
									}}}
									error = "MySQL error %s".printf().add(String.for_strptr(err)).to_string();
									return;
									embed "c" {{{
								}
							}}}
						}
						cnt++;
					}
					embed "c" {{{
					if(mysql_stmt_execute(p) != 0) {
						err = mysql_stmt_error(p);
						}}}
						error = "MySQL error %s".printf().add(String.for_strptr(err)).to_string();
						return;
						embed "c" {{{
					}
				}}}
			}
		}

		public int validate_request() {
			var s = 0;
			if(stmt != null) {
				var p = stmt;
				if(is_binding) {
					embed "c" {{{
						s = mysql_stmt_errno(p);
					}}}
				}
				else {
					embed "c" {{{
						s = mysql_errno(p);
					}}}
				}
				if(s != 0) {
					error = "MySQL error %d".printf().add(Primitive.for_integer(s)).to_string();
				}
			}
			else {
				error = "Statement is NULL";
			}
			return(s);
		}

		public String get_error() {
			return(error);
		}

		public void debug(bool b) {
			var desc = "OK";
			if(b == false || String.is_empty(sql)) {
				desc = "FAIL";
			}
			log_debug("MySQL %s: `%s'".printf().add(desc).add(sql).to_string());
		}

		public bool prepare_data() {
			if(stmt != null) {
				HashTable ht;
				data = Array.create();
				strptr rp = null;
				bool is_blob = false;
				var p = stmt;
				embed "c" {{{
					MYSQL_RES *res = mysql_use_result(p);
					MYSQL_FIELD *field = mysql_fetch_fields(res);
					MYSQL_ROW row;
					int numfields = mysql_num_fields(res);
					while((row = mysql_fetch_row(res))) {
						unsigned long *lengths = mysql_fetch_lengths(res);
						}}}
						ht = HashTable.create();
						embed "c" {{{
						int c;
						for(c = 0; c < numfields; c++) {
							rp = (char*)field[c].name;
							is_blob = field[c].type == MYSQL_TYPE_BLOB;
							}}}
							if(is_blob) {
								ptr ro = null;
								int b;
								embed "c" {{{
									ro = (void*)row[c];
									b = (int)lengths[c];
								}}}
								if(rp != null) {
									ht.set(String.for_strptr(rp).dup(), Buffer.dup(Buffer.for_pointer(Pointer.create(ro), b)));
								}
							}
							else {
								strptr ro = null;
								embed "c" {{{
									ro = (char*)row[c];
								}}}
								if(rp != null) {
									ht.set(String.for_strptr(rp).dup(), String.for_strptr(ro).dup());
								}
							}
							embed "c" {{{
						}
						}}}
						data.append(ht);
						embed "c" {{{
					}
					mysql_free_result(res);
				}}}
				return(true);
			}
			return(false);
		}

		public HashTable get_row_data(int i) {
			if(data != null) {
				if(i > -1 && i < data.count()) {
					return(data.get(i) as HashTable);
				}
			}
			return(null);
		}
	}

	class ResultSet : Iterator
	{
		Statement stmt = null;
		int count = 0;

		public static ResultSet create(Statement stmt) {
			var rs = new ResultSet();
			if(stmt.validate_request() == 0) {
				if(stmt.prepare_data()) {
					rs.stmt = stmt;
				}
			}
			return(rs);
		}

		public Object next() {
			if(stmt == null) {
				return(null);
			}
			var ht = stmt.get_row_data(count);
			count++;
			return(ht);
		}
	}

	embed "c" {{{
		#include <mysql.h>
	}}}

	public static MySQLDatabaseImpl for_server(String server, String database, String username, String password) {
		var mysqld = new MySQLDatabaseImpl();
		mysqld.server = server;
		mysqld.username = username;
		mysqld.password = password;
		mysqld.database = database;
		if(mysqld.initialize() == false) {
			mysqld.close();
			mysqld = null;
		}
		return(mysqld);
	}

	String server;
	String username;
	String password;
	String database;
	ptr mysql = null;

	~MySQLDatabaseImpl() {
		close();
	}

	private bool initialize() {
		if(String.is_empty(server)) {
			server = "";
		}
		if(String.is_empty(username)) {
			username = "";
		}
		if(String.is_empty(password)) {
			password = "";
		}
		if(String.is_empty(database)) {
			database = "";
		}
		ptr myserver = server.to_strptr();
		ptr myusername = username.to_strptr();
		ptr mypassword = password.to_strptr();
		ptr mydatabase = database.to_strptr();
		ptr mysql = null;
		strptr err = null;
		embed "c" {{{
			mysql = (void*)mysql_init(NULL); 
			if(mysql == NULL) {
				err = mysql_error(mysql);
				}}}
				log_error(String.for_strptr(err));
				return(false);
				embed "c" {{{
			}
			if(mysql_real_connect(mysql, myserver, myusername, mypassword, mydatabase, 0, NULL, 0) == NULL) {
				err = mysql_error(mysql);
				}}}
				log_error(String.for_strptr(err));
				return(false);
				embed "c" {{{
			}
		}}}
		this.mysql = mysql;
		log_debug("Successfully connected to `%s@%s' with `%s' database ..".printf().add(username).add(server).add(database).to_string());
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
		if(mysql == null) {
			return;
		}
		log_debug("Connection from `%s@%s' was closed ..".printf().add(username).add(server).to_string());
		var sqlconn = mysql;
		embed "c" {{{
			mysql_close(sqlconn);
		}}}
		server = null;
		username = null;
		password = null;
		database = null;
		mysql = null;
	}

	public override SQLStatement prepare(String sql) {
		var s = new Statement();
		s.set_logger(get_logger());
		if(s.create(mysql, sql) == false) {
		}
		return(s);
	}

	public override bool execute(SQLStatement stmt) {
		var b = false;
		var sqlstm = stmt as Statement;
		if(sqlstm != null) {
			log_debug("Executing MySQL: `%s'".printf().add(sqlstm.get_sql()).to_string());
			if(sqlstm.validate_request() == 0) {
				b = true;
			}
			else {
				b = false;
			}
			sqlstm.debug(b);
		}
		if(b == false && mysql != null) {
			ptr sqlconn = mysql;
			strptr err = null;
			embed "c" {{{
				err = mysql_error(sqlconn);
			}}}
			if(err != null) {
				log_debug("Error when executing MySQL statement: `%s'".printf().add(String.for_strptr(err)).to_string());
			}
		}
		return(b);
	}

	public override Iterator query(SQLStatement stmt) {
		var sqlstm = stmt as Statement;
		if(sqlstm != null) {
			log_debug("Executing MySQL query: `%s'".printf().add(sqlstm.get_sql()).to_string());
			var it = ResultSet.create(sqlstm);
			if(sqlstm.validate_request() == 0) {
				sqlstm.debug(true);
				return(it);
			}
			sqlstm.debug(false);
			return(it);
		}
		return(null);
	}

	public override HashTable query_single_row(SQLStatement stmt) {
		foreach(HashTable ht in query(stmt)) {
			return(ht);
		}
		return(null);
	}

	public override bool table_exists(String table) {
		if(table == null) {
			return(false);
		}
		var ht = query_single_row(prepare("SHOW TABLES LIKE '%s';".printf().add(table).to_string()));
		if(ht == null) {
			return(false);
		}
		var id = "Tables_in_%s (%s)".printf().add(database).add(table).to_string();
		if(table.equals(ht.get_string(id)) == false) {
			return(false);
		}
		return(true);
	}

	private String column_to_create_string(SQLTableColumnInfo cc) {
		var sb = StringBuffer.create();
		sb.append(cc.get_name());
		sb.append_c(' ');
		var tt = cc.get_type();
		if(tt == SQLTableColumnInfo.TYPE_INTEGER_KEY) {
			sb.append("INTEGER PRIMARY KEY AUTO_INCREMENT");
		}
		else if(tt == SQLTableColumnInfo.TYPE_INTEGER) {
			sb.append("INTEGER");
		}
		else if(tt == SQLTableColumnInfo.TYPE_STRING) {
			sb.append("VARCHAR(255)");
		}
		else if(tt == SQLTableColumnInfo.TYPE_TEXT) {
			sb.append("TEXT");
		}
		else if(tt == SQLTableColumnInfo.TYPE_DOUBLE) {
			sb.append("DOUBLE");
		}
		else if(tt == SQLTableColumnInfo.TYPE_BLOB) {
			sb.append("BLOB");
		}
		return(sb.to_string());
	}

	public override bool create_table(String table, Collection columns) {
		if(table == null || columns == null || mysql == null) {
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
		if(execute(prepare(sb.to_string())) == false) {
			return(false);
		}
		return(true);
	}

	public override bool delete_table(String table) {
		if(table == null || mysql == null) {
			return(false);
		}
		var sb = StringBuffer.create();
		sb.append("DROP TABLE ");
		sb.append(table);
		sb.append_c(';');
		if(execute(prepare(sb.to_string())) == false) {
			return(false);
		}
		return(true);
	}

	public override bool create_index(String table, String column, bool unique) {
		if(table == null || column == null || mysql == null) {
			return(false);
		}
		var unq = "";
		if(unique) {
			unq = "UNIQUE ";
		}
		var sqlquery = "CREATE %sINDEX %s_%s ON %s (%s);".printf().add(unq).add(table).add(column).add(table).add(column).to_string();
		if(execute(prepare(sqlquery)) == false) {
			return(false);
		}
		return(true);
	}
}
