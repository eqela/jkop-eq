
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

class SQLiteDatabaseC : SQLiteDatabase
{
	class Statement : LoggerObject, SQLStatement
	{
		IFDEF("target_ios") {
			embed {{{
				#import <sqlite3.h>
			}}}
		}
		ELSE {
			IFNDEF("target_win32") {
				embed {{{
					#define SQLITE_ENABLE_FTS3
					#define SQLITE_ENABLE_FTS4
				}}}
			}
			INCLUDE("SQLite.c.inc");
		}

		ptr stmt = null;
		int paramidx = 1;
		String error = null;
		property String sql = null;
		Collection strings = null;

		public Statement() {
			strings = LinkedList.create();
		}

		~Statement() {
			clear();
		}

		void clear() {
			var p = stmt;
			embed "c" {{{
				if(p != (void*)0) {
					sqlite3_finalize((sqlite3_stmt*)p);
				}
			}}}
			stmt = null;
			strings = LinkedList.create();
		}

		public bool create(ptr db, String sql) {
			bool v = false;
			stmt = null;
			paramidx = 1;
			if(db != null && sql != null) {
				var ss = sql.to_strptr();
				int r;
				strptr errmsg;
				ptr stmtp = null;
				embed "c" {{{
					r = sqlite3_prepare_v2((sqlite3*)db, ss, -1, (sqlite3_stmt**)&stmtp, (const char **)0);
					if(r == SQLITE_OK) {
						v = 1;
					}
					else {
						errmsg = sqlite3_errmsg((sqlite3*)db);
					}
				}}}
				this.stmt = stmtp;
				if(v) {
					this.sql = sql;
				}
				else {
					log_warning("Sqlite ERROR when preparing SQL statement `%s': `%s'".printf().add(sql).add(String.for_strptr(errmsg)));
				}
			}
			return(v);
		}

		public void reset_statement() {
			if(stmt != null) {
				var p = stmt;
				embed "c" {{{
					sqlite3_clear_bindings((sqlite3_stmt*)p);
					sqlite3_reset((sqlite3_stmt*)p);
				}}}
				strings = LinkedList.create();
				paramidx = 1;
			}
		}

		public SQLStatement add_param_blob(Buffer val) {
			var pt = val.get_pointer().get_native_pointer();
			var s = val.get_size();
			int v = -1;
			if(stmt != null) {
				var p = stmt;
				var pi = paramidx;
				embed "c" {{{
					if(sqlite3_bind_blob((sqlite3_stmt*)p, pi, pt, s, SQLITE_TRANSIENT) == SQLITE_OK) {
						v = pi;
						pi ++;
					}
				}}}
				paramidx = pi;
			}
			return(this);
		}

		public SQLStatement add_param_str(String aval) {
			var val = aval;
			if(val == null) {
				val = "";
			}
			int v = -1;
			if(stmt != null) {
				var p = stmt;
				var vs = val.to_strptr();
				var pi = paramidx;
				embed "c" {{{
					if(sqlite3_bind_text((sqlite3_stmt*)p, pi, vs, -1, SQLITE_STATIC) == SQLITE_OK) {
						v = pi;
						pi ++;
					}
				}}}
				paramidx = pi;
			}
			if(v >= 0) {
				strings.add(val);
			}
			return(this);
		}

		public SQLStatement add_param_int(int val) {
			int v = -1;
			if(stmt != null) {
				var p = stmt;
				var pi = paramidx;
				embed "c" {{{
					if(sqlite3_bind_int((sqlite3_stmt*)p, pi, val) == SQLITE_OK) {
						v = pi;
						pi ++;
					}
				}}}
				paramidx = pi;
			}
			return(this);
		}

		public SQLStatement add_param_double(double val) {
			int v = -1;
			if(stmt != null) {
				var p = stmt;
				var pi = paramidx;
				embed "c" {{{
					if(sqlite3_bind_double((sqlite3_stmt*)p, pi, val) == SQLITE_OK) {
						v = pi;
						pi ++;
					}
				}}}
				paramidx = pi;
			}
			return(this);
		}

		public int step() {
			int v;
			embed "c" {{{
				v = SQLITE_ERROR;
			}}}
			if(stmt != null) {
				bool r = false;
				var p = stmt;
				embed "c" {{{
					v = sqlite3_step((sqlite3_stmt*)p);
					if(v == SQLITE_OK || v == SQLITE_DONE || v == SQLITE_ROW) {
						r = 1;
					}
				}}}
				if(r == false) {
					error = "Sqlite error %d".printf().add(Primitive.for_integer(v)).to_string();
				}
			}
			else {
				error = "Statement is NULL";
			}
			return(v);
		}

		public void reset() {
			if(stmt != null) {
				var p = stmt;
				embed "c" {{{
					sqlite3_reset((sqlite3_stmt*)p);
				}}}
			}
		}

		public String get_error() {
			return(error);
		}

		public int get_column_count() {
			int v = 0;
			if(stmt != null) {
				var p = stmt;
				embed "c" {{{
					v = sqlite3_column_count((sqlite3_stmt*)p);
				}}}
			}
			return(v);
		}

		public String get_column_name(int n) {
			String v = null;
			if(stmt != null) {
				strptr rp = null;
				var p = stmt;
				embed "c" {{{
					rp = (char*)sqlite3_column_name((sqlite3_stmt*)p, n);
				}}}
				if(rp != null) {
					v = String.for_strptr(rp).dup();
				}
			}
			return(v);
		}

		public int get_column_int(int n) {
			int v = 0;
			if(stmt != null) {
				var p = stmt;
				embed "c" {{{
					v = sqlite3_column_int((sqlite3_stmt*)p, n);
				}}}
			}
			return(v);
		}

		public double get_column_double(int n) {
			double v = 0.0;
			if(stmt != null) {
				var p = stmt;
				embed "c" {{{
					v = sqlite3_column_double((sqlite3_stmt*)p, n);
				}}}
			}
			return(v);
		}

		public Object get_column_object(int n) {
			Object v = null;
			if(stmt != null) {
				int ct;
				bool is_blob;
				var p = stmt;
				embed "c" {{{
					is_blob = sqlite3_column_type((sqlite3_stmt*)p, n) == SQLITE_BLOB;
				}}}
				if(is_blob) {
					ptr rp;
					int b;
					embed "c" {{{
						rp = (void*)sqlite3_column_blob((sqlite3_stmt*)p, n);
						b = sqlite3_column_bytes((sqlite3_stmt*)p, n);
					}}}
					v = Buffer.dup(Buffer.for_pointer(Pointer.create(rp), b));
				}
				else {
					int ll = -1;
					embed "c" {{{
						char* tp = (char*)sqlite3_column_text((sqlite3_stmt*)p, n);
						if(tp != NULL) {
							ll = strlen(tp);
						}
					}}}
					if(ll >= 0) {
						var bb = DynamicBuffer.create(ll+1);
						var rpptr = bb.get_ptr();
						embed "c" {{{
							strcpy(rpptr, tp);
						}}}
						v = String.for_utf8_buffer(bb, true);
					}
				}
			}
			return(v);
		}
	}

	class ResultSet : Iterator, SQLResultSetIterator
	{
		Statement stmt = null;
		Array column_names;

		public static ResultSet create(Statement stmt) {
			var v = new ResultSet();
			v.stmt = stmt;
			return(v);
		}

		public bool next_values(Array v) {
			if(stmt == null || v == null) {
				return(false);
			}
			int row;
			embed "c" {{{
				row = SQLITE_ROW;
			}}}
			int r = stmt.step();
			if(r == row) {
				v.clear();
				int c = get_column_count();
				int n;
				for(n=0; n<c; n++) {
					var cv = stmt.get_column_object(n);
					if(cv == null) {
						cv = "";
					}
					v.append(cv);
				}
				return(true);
			}
			return(false);
		}

		public Object next() {
			if(stmt == null) {
				return(null);
			}
			int row;
			embed "c" {{{
				row = SQLITE_ROW;
			}}}
			HashTable v = null;
			int r = stmt.step();
			if(r == row) {
				v = HashTable.create();
				var cns = get_column_names();
				int c = cns.count();
				int n;
				for(n=0; n<c; n++) {
					var cn = cns.get(n) as String, cv = stmt.get_column_object(n);
					if(cn!=null) {
						v.set(cn, cv);
					}
				}
			}
			return(v);
		}

		public bool step() {
			if(stmt == null) {
				return(false);
			}
			int row;
			embed "c" {{{
				row = SQLITE_ROW;
			}}}
			HashTable v = null;
			int r = stmt.step();
			if(r != row) {
				return(false);
			}
			return(true);
		}

		int _column_count = 0;
		public int get_column_count() {
			if(_column_count < 1) {
				if(stmt != null) {
					_column_count = stmt.get_column_count();
				}
			}
			return(_column_count);
		}

		public Array get_column_names() {
			if(column_names == null) {
				column_names = Array.create();
				int n;
				for(n=0; n<get_column_count(); n++) {
					var cn = get_column_name(n);
					if(cn == null) {
						cn = "";
					}
					column_names.append(cn);
				}
			}
			return(column_names);
		}

		public String get_column_name(int n) {
			if(stmt == null) {
				return(null);
			}
			return(stmt.get_column_name(n));
		}

		public Object get_column_object(int n) {
			if(stmt == null) {
				return(null);
			}
			return(stmt.get_column_object(n));
		}

		public int get_column_int(int n) {
			if(stmt == null) {
				return(0);
			}
			return(stmt.get_column_int(n));
		}

		public double get_column_double(int n) {
			if(stmt == null) {
				return(0.0);
			}
			return(stmt.get_column_double(n));
		}
	}

	ptr db = null;

	~SQLiteDatabaseC() {
		close();
	}

	public void close() {
		if(db != null) {
			var dbp = db;
			embed "c" {{{
				sqlite3_close((sqlite3*)dbp);
			}}}
			db = null;
		}
	}

	public bool initialize(File file, bool open_create) {
		bool v = false;
		if(file != null) {
			var nativepath = file.get_native_path();
			if(nativepath == null) {
				log_error("Database file '%s' is not on a native filesystem. Cannot open.".printf().add(file).to_string());
			}
			else {
				int r;
				var fnp = nativepath.to_strptr();
				ptr dbp = null;
				embed "c" {{{
					r = sqlite3_open_v2(fnp, (struct sqlite3**)&dbp, SQLITE_OPEN_READWRITE | (open_create ? SQLITE_OPEN_CREATE : 0), (const char*)0);
				}}}
				this.db = dbp;
				if(r == 0) {
					v = true;
				}
				else {
					strptr err = null;
					embed "c" {{{
						err = sqlite3_errmsg((struct sqlite3*)dbp);
					}}}
					if(err == null) {
						log_error("Unknown SQLite error %d occurred when opening database `%s'".printf().add(r).add(file).to_string());
					}
					else {
						log_error("SQLite error %d when opening database `%s': `%s'".printf().add(r).add(file).add(String.for_strptr(err)).to_string());
					}
				}
			}
		}
		return(v);
	}

	public SQLStatement prepare(String sql) {
		var v = new Statement();
		v.set_logger(get_logger());
		if(v.create(this.db, sql) == false) {
		}
		return(v);
	}

	public bool execute(SQLStatement stmta) {
		bool v = false;
		var stmt = stmta as Statement;
		int r_done;
		int r_row;
		embed "c" {{{
			r_done = SQLITE_DONE;
			r_row = SQLITE_ROW;
		}}}
		if(stmt != null) {
			stmt.reset();
			while(true) {
				int r = stmt.step();
				if(r == r_done) {
					v = true;
					break;
				}
				else if(r == r_row) {
					; // in this case, we ignore the rows
				}
				else {
					v = false;
					break;
				}
			}
		}
		if(v == false && db != null) {
			var dbp = db;
			strptr errmsg;
			embed "c" {{{
				errmsg = sqlite3_errmsg((sqlite3*)dbp);
			}}}
			if(errmsg != null) {
				log_debug("Error when executing SQL statement: `%s'".printf().add(String.for_strptr(errmsg)));
			}
		}
		return(v);
	}

	public Iterator query(SQLStatement stmta) {
		Iterator v = null;
		var stmt = stmta as Statement;
		if(stmt != null) {
			stmt.reset();
			v = ResultSet.create(stmt);
		}
		return(v);
	}
}
