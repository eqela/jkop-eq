
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

class SQLiteDatabaseAndroid : SQLiteDatabase
{
	embed "java" {{{
		private android.database.sqlite.SQLiteDatabase sqldatabase = null;
	}}}

	class Statement : SQLStatement {
		private Collection strings = null;
		private String error = null;
		private String sql = null;
		private int paramidx = 1;
		embed "java" {{{
			private android.database.sqlite.SQLiteStatement sqlstatement = null;
			private android.database.sqlite.SQLiteDatabase sqldb = null;
			private android.database.Cursor sqlcursor = null;
			private java.util.Collection<java.lang.String> params = null;
		}}}

		public Statement() {
			strings = LinkedList.create();
		}

		~Statement() {
			clear();
		}

		private void clear() {
			embed "java" {{{
				if(sqlstatement != null) {
					sqlstatement.clearBindings();
					sqlstatement = null;
				}
			
			}}}
			strings = LinkedList.create();
		}

		embed "java" {{{
			public boolean create(android.database.sqlite.SQLiteDatabase sqldb, eq.api.String asql) {
				sql = asql;
				paramidx = 1;
				boolean v = true;
				if(sqldb != null && sql != null) {
					java.lang.String jsql = sql.to_strptr();
					eq.api.Iterator itr = sql.split(' ', -1);
					eq.api.String str = (eq.api.String)itr.next();
					if(sqldb != null) {
						try {
							if(eq.api.String.Static.for_strptr("select").equals_ignore_case((eq.api.Object)str)) {
								this.sqldb = sqldb;
								params = new java.util.LinkedList<java.lang.String>();
								sqlstatement = null;
							}
							else {
								sqlstatement = sqldb.compileStatement(jsql);
							}
						}
						catch(Exception e) {
							v = false;
						}
					}
				}
				return(v);
			}
		}}}

		public bool execute() {
			bool v = false;
			strptr jerr = null;
			var itr = sql.split((int)' ');
			var str = itr.next();
			embed "java" {{{
				if(sqlstatement != null) {
					try {
					}}}
						if("insert".equals_ignore_case(str)) {
							embed "java" {{{
								if(sqlstatement.executeInsert() != -1){
									v = true;
								}
							}}}
						}
						else if("update".equals_ignore_case(str) || "delete".equals_ignore_case(str)) {
							embed "java" {{{				
								if(sqlstatement.executeUpdateDelete() > 0){
									v = true;
								}
							}}}
						}
						else {
							embed "java" {{{		
								sqlstatement.execute();
								v = true;
							}}}
						}
						embed "java" {{{
					}
					catch(Exception e) {
						v = false;
						jerr = "Sqlite Error " + e;
					}
			} 
			}}}
			if(jerr != null) {
				this.error = String.for_strptr(jerr);
			}
			return(v);
		}

		public SQLStatement add_param_str(String aval) {
			String val = aval;
			if(val == null) {
				val = "";
			}
			int v = -1;
			embed "java" {{{
				if(sqlstatement != null) {
					sqlstatement.bindString(paramidx, val.to_strptr());
					v = paramidx;
					paramidx++;
				}
				else {
					params.add(val.to_strptr());
				}
			}}}
			if(v >= 0) {
				strings.add(val);
			}
			return(this);
		}

		public void reset() {
			embed "java" {{{
				if(sqlcursor != null) {
					sqlcursor.moveToFirst();
				}
			}}}
		}

		public void debug(bool v) {
			String desc = "OK";
			if(v == false) {
				desc = "FAIL";
			}
			Log.debug("Sqlite %s: '%s'".printf().add(desc).add(sql).to_string());
		}

		public String get_error() {
			return(error);
		}

		public SQLStatement add_param_int(int val) {
			int v = -1;
			embed "java" {{{
				if(sqlstatement != null) {
					sqlstatement.bindLong(paramidx, val);
					v = paramidx;
					paramidx++;
				}
				else {
					params.add(java.lang.Integer.toString(val));
				}
			}}}
			return(this);
		}

		public SQLStatement add_param_double(double val) {
			int v = -1;
			embed "java" {{{
				if(sqlstatement != null) {
					sqlstatement.bindDouble(paramidx, val);
					v = paramidx;
					paramidx++;
				}
				else {
					params.add(java.lang.Double.toString(val));
				}
			}}}
			return(this);
		}

		public SQLStatement add_param_blob(Buffer val) {
			if(val == null) {
				return(this);
			}
			int v = -1;
			ptr jblob = val.get_pointer().get_native_pointer();
			embed "java" {{{
				if(sqlstatement != null) {
					sqlstatement.bindBlob(paramidx, jblob);
					v = paramidx;
					paramidx++;
				}
			}}}
			return(this);
		}

		public int get_result() {
			int v = -1;
			strptr jerr = null;
			strptr jsql = sql.to_strptr();
			embed "java" {{{
				try {
					if(sqldb != null) {
						sqlcursor = sqldb.rawQuery(jsql, (java.lang.String[])params.toArray(new java.lang.String[params.size()]));
						v = sqlcursor.getCount();
					}
				}
				catch(Exception e) {
					jerr = "Sqlite Error " + e;
				}
			}}}
			if(jerr != null) {
				this.error = String.for_strptr(jerr);
			}
			return(v);
		}

		public bool step() {
			bool v = false;
			embed "java" {{{
				if(sqlcursor != null) {
					try {
						v = sqlcursor.moveToNext();
					}
					catch(Exception e) {
					}
				}
			}}}
			return(v);
		}

		public String get_column_name(int idx) {
			String v = null;
			strptr column_name = null;
			embed "java" {{{
				if(sqlcursor != null) {
					try {
						column_name = sqlcursor.getColumnName(idx);
					}
					catch(Exception e) {
					}
				}
			}}}
			if(column_name != null) {
				v = String.for_strptr(column_name);
			}
			return(v);
		}

		public bool is_after_last() {
			bool v = false;
			embed "java" {{{
				v = sqlcursor.isAfterLast();
			}}}
			return(v);
		}

		public String get_column_text(int idx) {
			String v = null;
			strptr column_string = null;
			embed "java" {{{
				if(sqlcursor != null) {
					try {
						column_string = sqlcursor.getString(idx);
					}
					catch(Exception e) {
					}
				}
			}}}
			if(column_string != null) {
				v = String.for_strptr(column_string);
			}
			return(v);
		}

		public int get_column_count() {
			int v = -1;
				embed "java" {{{
					if(sqlcursor != null) {
						try {
							v = sqlcursor.getColumnCount();
						}
						catch(Exception e) {
						}
					}
				}}}
			return(v);
		}
	}

	class ResultSet : Iterator
	{
		private Statement sqlstmt = null;
		private int rscount = 0;

		public static ResultSet create(Statement stmt) {
			var v = new ResultSet();
			v.sqlstmt = stmt;
			v.rscount = stmt.get_result();
			return(v);
		}

		public Object next() {
			HashTable v = null;
			if(sqlstmt != null) {
				sqlstmt.step();
				if(rscount > 0 && sqlstmt.is_after_last() == false) {
					v = HashTable.create();
					int ccnt = sqlstmt.get_column_count(), n = 0;
					for(n = 0; n < ccnt; n++) {
						var cn = sqlstmt.get_column_name(n), ct = sqlstmt.get_column_text(n);
						if(cn != null) {
							v.set(cn, ct);
						}
					}
				}
			}
			return(v);
		}
	}

	public String get_database_type_id() {
		return("sqlite");
	}

	public SQLStatement prepare(String sql) {
		var v = new Statement();
		embed "java" {{{
			if(v.create(sqldatabase, sql) == false) {
				return(null);
			}
		}}}
		return(v);
	}

	public bool execute(SQLStatement stmt) {
		bool v = false;
		var ss = stmt as Statement;
		if(ss != null) {
			v = ss.execute();
		}
		return(v);
	}

	public Iterator query(SQLStatement astmt) {
		Iterator v = null;
		var stmt = astmt as Statement;
		if(stmt != null) {
			v = ResultSet.create(stmt);
		}
		return(v);
	}

	public bool initialize(File file, bool open_create) {
		if(file == null) {
			return(false);
		}
		if(open_create == false && file.is_file() == false) {
			Log.error("Database does not exist: '%s'".printf().add(file).to_string());
			return(false);
		}
		var nativepath = file.get_native_path();
		if(nativepath == null) {
			Log.error("Database file '%s' is not on a native filesystem. Cannot open.".printf().add(file).to_string());
			return(false);
		}
		bool v = false;
		embed "java" {{{
			try {
				sqldatabase = android.database.sqlite.SQLiteDatabase.openOrCreateDatabase(nativepath.to_strptr(), null);
				v = true;
			}
			catch(Exception e) {
				v = false;
			}
		}}}
		if(v) {
			Log.debug("Opened Sqlite database: '%s'".printf().add(file).to_string());
		}
		else {
			if(open_create) {
				Log.error("Failed to create database. Please check write permissions");
			}
		}
		return(v);
	}

	public void close() {
		embed {{{
			if(sqldatabase != null) {
				sqldatabase.close();
				sqldatabase = null;
			}
		}}}
	}
}

