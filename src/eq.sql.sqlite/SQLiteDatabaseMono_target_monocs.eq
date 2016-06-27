
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

class SQLiteDatabaseMono : SQLiteDatabase
{
	class Statement : SQLStatement
	{
		int pcounter = 0;

		embed "cs" {{{
			public Mono.Data.Sqlite.SqliteCommand command;

			string convertSQLString(string sql) {
				var sb = new System.Text.StringBuilder();
				var quote = false;
				var dquote = false;
				var slash = false;
				int n = 1;
				foreach(char c in sql) {
					if(quote) {
						if(c == '\\' && slash == false) {
							slash = true;
						}
						else {
							if(c == '\'' && slash == false) {
								quote = false;
							}
							slash = false;
						}
						sb.Append(c);
					}
					else if(dquote) {
						if(c == '\\' && slash == false) {
							slash = true;
						}
						else {
							if(c == '"' && slash == false) {
								dquote = false;
							}
							slash = false;
						}
						sb.Append(c);
					}
					else if(c == '?') {
						sb.Append("@p" + n);
						n++;
					}
					else if(c == '\'') {
						sb.Append(c);
						quote = true;
					}
					else if(c == '"') {
						sb.Append(c);
						dquote = true;
					}
					else {
						sb.Append(c);
					}
				}
				return(sb.ToString());
			}

			public bool create(Mono.Data.Sqlite.SqliteConnection db, string sql) {
				if(db == null || sql == null) {
					return(false);
				}
				var cmd = db.CreateCommand();
				if(cmd == null) {
					return(false);
				}
				cmd.CommandText = convertSQLString(sql);
				command = cmd;
				return(true);
			}
		}}}

		public SQLStatement add_param_str(String val) {
			strptr vv = null;
			if(val != null) {
				vv = val.to_strptr();
			}
			embed "cs" {{{
				if(vv == null) {
					vv = "";
				}
				if(command != null) {
					var name = "@p" + (pcounter+1);
					var param = command.Parameters.Add(name, System.Data.DbType.String);
					if(param != null) {
						pcounter ++;
						param.Value = vv;
					}
				}
			}}}
			return(this);
		}

		public SQLStatement add_param_int(int val) {
			embed "cs" {{{
				if(command != null) {
					var param = command.Parameters.Add("@p" + (pcounter+1), System.Data.DbType.Int32);
					if(param != null) {
						pcounter ++;
						param.Value = val;
					}
				}
			}}}
			return(this);
		}

		public SQLStatement add_param_double(double val) {
			embed "cs" {{{
				if(command != null) {
					var param = command.Parameters.Add("@p" + (pcounter+1), System.Data.DbType.Double);
					if(param != null) {
						pcounter ++;
						param.Value = val;
					}
				}
			}}}
			return(this);
		}

		public SQLStatement add_param_blob(Buffer val) {
			if(val == null) {
				return(this);
			}
			var ptr = val.get_pointer();
			if(ptr == null) {
				return(this);
			}
			var nptr = ptr.get_native_pointer();
			if(nptr == null) {
				return(this);
			}
			embed "cs" {{{
				if(command != null) {
					var param = command.Parameters.Add("@p" + (pcounter+1), System.Data.DbType.Binary);
					if(param != null) {
						pcounter ++;
						param.Value = nptr;
					}
				}
			}}}
			return(this);
		}

		public void reset_statement() {
			embed "cs" {{{
				if(command != null) {
					command.Parameters.Clear();
				}
			}}}
			pcounter = 0;
		}

		public String get_error() {
			return(null);
		}
	}

	embed "cs" {{{
		Mono.Data.Sqlite.SqliteConnection db;
	}}}

	public override bool initialize(File file, bool open_create) {
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
		strptr error = null;
		embed "cs" {{{
			var db = new Mono.Data.Sqlite.SqliteConnection("Data Source=" + nativepath.to_strptr());
			try {
				db.Open();
				v = true;
			}
			catch(System.Exception e) {
				error = e.ToString();
				v = false;
			}
			this.db = db;
		}}}
		if(v) {
			Log.debug("Opened Sqlite database: '%s'".printf().add(file).to_string());
		}
		else {
			Log.error("Failed to open database file: ".append(String.for_strptr(error)));
		}
		return(v);
	}

	public void close() {
		embed "cs" {{{
			if(db != null) {
				db.Close();
				db = null;
			}
		}}}
	}

	public SQLStatement prepare(String sql) {
		var v = new Statement();
		var ss = String.as_strptr(sql);
		embed "cs" {{{
			if(v.create(db, ss) == false) {
				return(null);
			}
		}}}
		return(v);
	}

	public bool execute(SQLStatement stmt) {
		if(stmt == null) {
			return(false);
		}
		var v = true;
		strptr error = null;
		embed "cs" {{{
			var cmd = ((Statement)stmt).command;
			if(cmd == null) {
				return(false);
			}
			try {
				cmd.ExecuteNonQuery();
			}
			catch(System.Exception e) {
				v = false;
				error = e.ToString();
			}
		}}}
		if(error != null) {
			Log.debug(String.for_strptr(error));
		}
		return(v);
	}

	class ResultSet : Iterator, SQLResultSetIterator
	{
		embed "cs" {{{
			public Mono.Data.Sqlite.SqliteDataReader reader;
		}}}

		public bool next_values(Array values) {
			if(values == null) {
				return(false);
			}
			if(step() == false) {
				return(false);
			}
			values.clear();
			var cols = get_column_count();
			int n;
			for(n=0; n<cols; n++) {
				var o = get_column_object(n);
				if(o == null) {
					o = "";
				}
				values.append(o);
			}
			return(true);
		}

		public bool step() {
			embed "cs" {{{
				if(reader == null) {
					return(false);
				}
				if(reader.Read() == false) {
					reader = null;
					return(false);
				}
			}}}
			return(true);
		}

		public int get_column_count() {
			int v = 0;
			embed "cs" {{{
				if(reader != null) {
					v = reader.FieldCount;
				}
			}}}
			return(v);
		}

		public Array get_column_names() {
			var v = Array.create();
			int n;
			var c = get_column_count();
			for(n=0; n<c; n++) {
				var nn = get_column_name(n);
				if(nn == null) {
					nn = "";
				}
				v.append(nn);
			}
			return(v);
		}

		public String get_column_name(int n) {
			strptr v = null;
			embed "cs" {{{
				if(reader != null) {
					v = reader.GetName(n);
				}
				if(v == null) {
					v = "";
				}
			}}}
			return(String.for_strptr(v));
		}

		public Object get_column_object(int n) {
			strptr v = null;
			embed "cs" {{{
				if(reader == null) {
					return(null);
				}
				var o = reader.GetValue(n);
				if(o == null) {
					return(null);
				}
				v = o.ToString(); //reader.GetString(n);
				if(v == null) {
					return(null);
				}
			}}}
			return(String.for_strptr(v));
		}

		public int get_column_int(int n) {
			int v = 0;
			embed "cs" {{{
				if(reader != null) {
					v = reader.GetInt32(n);
				}
			}}}
			return(v);
		}

		public double get_column_double(int n) {
			double v = 0;
			embed "cs" {{{
				if(reader != null) {
					v = reader.GetDouble(n);
				}
			}}}
			return(v);
		}

		public Object next() {
			if(step() == false) {
				return(null);
			}
			var names = get_column_names();
			if(names == null || names.count() < 1) {
				return(null);
			}
			var v = HashTable.create();
			int n;
			for(n=0; n<names.count(); n++) {
				v.set(String.as_string(names.get(n)), get_column_object(n));
			}
			return(v);
		}
	}

	public Iterator query(SQLStatement stmt) {
		if(stmt == null) {
			Log.debug("SQLite query: null statement");
			return(null);
		}
		ResultSet v = null;
		strptr error = null;
		embed "cs" {{{
			var cmd = ((Statement)stmt).command;
			if(cmd == null) {
				}}} Log.debug("SQLite query: null command"); embed "cs" {{{
				return(null);
			}
			Mono.Data.Sqlite.SqliteDataReader rdr = null;
			try {
				rdr = cmd.ExecuteReader();
			}
			catch(System.Exception e) {
				error = e.ToString();
			}
			if(rdr != null) {
				v = new ResultSet();
				v.reader = rdr;
			}
		}}}
		if(error != null) {
			Log.debug(String.for_strptr(error));
		}
		return(v);
	}
}
