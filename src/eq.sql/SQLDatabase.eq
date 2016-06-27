
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

public class SQLDatabase : LoggerObject
{
	public virtual String get_database_type_id() {
		return("unknown");
	}

	public virtual void close() {
	}

	public virtual SQLStatement prepare(String sql) {
		return(null);
	}

	public virtual bool execute(SQLStatement stmt) {
		return(false);
	}

	public virtual Iterator query_all(String table) {
		return(query(prepare("SELECT * FROM %s;".printf().add(table).to_string())));
	}

	public virtual Iterator query_with_criteria(String table, HashTable criteria) {
		var sb = StringBuffer.create();
		sb.append("SELECT * FROM ");
		sb.append(table);
		var first = true;
		foreach(String key in criteria.iterate_keys()) {
			if(first) {
				sb.append(" WHERE ");
				first = false;
			}
			else {
				sb.append(" AND ");
			}
			sb.append(key);
			sb.append(" = ?");
		}
		sb.append_c((int)';');
		var sql = sb.to_string();
		var stmt = prepare(sql);
		if(stmt == null) {
			return(null);
		}
		foreach(String key in criteria.iterate_keys()) {
			var val = criteria.get_string(key);
			if(val == null) {
				val = "";
			}
			stmt.add_param_str(val);
		}
		return(query(stmt));
	}

	public virtual HashTable query_single_row_with_criteria(String table, HashTable criteria) {
		var it = query_with_criteria(table, criteria);
		if(it == null) {
			return(null);
		}
		return(it.next() as HashTable);
	}

	public virtual Iterator query(SQLStatement stmt) {
		return(null);
	}

	public virtual HashTable query_single_row(SQLStatement stmt) {
		return(null);
	}

	public virtual bool table_exists(String table) {
		return(false);
	}

	public virtual bool ensure_table(SQLTableInfo table) {
		if(table == null) {
			return(false);
		}
		var name = table.get_name();
		if(String.is_empty(name)) {
			return(false);
		}
		if(table_exists(name)) {
			return(true);
		}
		if(create_table(name, table.get_columns()) == false) {
			return(false);
		}
		foreach(SQLTableColumnIndexInfo cii in table.get_indexes()) {
			if(create_index(name, cii.get_column(), cii.get_unique()) == false) {
				delete_table(name);
				return(false);
			}
		}
		return(true);
	}

	public virtual bool create_table(String table, Collection columns) {
		return(false);
	}

	public virtual bool delete_table(String table) {
		return(false);
	}

	public virtual bool create_index(String table, String column, bool unique) {
		return(false);
	}

	public bool insert(String table, HashTable data) {
		if(String.is_empty(table) || data == null || data.count() < 1) {
			return(false);
		}
		var sb = StringBuffer.create();
		sb.append("INSERT INTO ");
		sb.append(table);
		sb.append(" ( ");
		bool first = true;
		var keys = LinkedList.for_iterator(data.iterate_keys());
		foreach(String key in keys) {
			if(first == false) {
				sb.append_c((int)',');
			}
			sb.append(key);
			first = false;
		}
		sb.append(" ) VALUES ( ");
		first = true;
		foreach(String key in keys) {
			if(first == false) {
				sb.append_c((int)',');
			}
			sb.append_c((int)'?');
			first = false;
		}
		sb.append(" );");
		var stmt = prepare(sb.to_string());
		if(stmt == null) {
			return(false);
		}
		foreach(String key in keys) {
			var o = data.get(key);
			if(o is Buffer) {
				stmt.add_param_blob((Buffer)o);
			}
			else {
				var s = String.as_string(o);
				if(s == null) {
					s = "";
				}
				stmt.add_param_str(s);
			}
		}
		return(execute(stmt));
	}

	public bool update(String table, HashTable criteria, HashTable data) {
		if(String.is_empty(table) || data == null || data.count() < 1) {
			return(false);
		}
		var sb = StringBuffer.create();
		sb.append("UPDATE ");
		sb.append(table);
		sb.append(" SET ");
		var params = LinkedList.create();
		bool first = true;
		foreach(String key in data.iterate_keys()) {
			if(first == false) {
				sb.append(", ");
			}
			sb.append(key);
			sb.append(" = ?");
			first = false;
			params.add(data.get(key));
		}
		if(criteria != null && criteria.count() > 0) {
			sb.append(" WHERE ");
			first = true;
			foreach(String criterium in criteria) {
				if(first == false) {
					sb.append(" AND ");
				}
				sb.append(criterium);
				sb.append(" = ?");
				first = false;
				params.add(criteria.get_string(criterium));
			}
		}
		sb.append_c((int)';');
		var stmt = prepare(sb.to_string());
		if(stmt == null) {
			return(false);
		}
		foreach(Object o in params) {
			if(o is Buffer) {
				stmt.add_param_blob((Buffer)o);
			}
			else {
				var s = String.as_string(o);
				if(s == null) {
					s = "";
				}
				stmt.add_param_str(s);
			}
		}
		return(execute(stmt));
	}
}
