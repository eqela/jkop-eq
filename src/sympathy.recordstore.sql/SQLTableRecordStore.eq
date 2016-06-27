
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

public class SQLTableRecordStore : RecordStoreAdapter
{
	public static SQLTableRecordStore for_db_table(SQLDatabase db, String table) {
		return(new SQLTableRecordStore().set_db(db).set_table(table));
	}

	property SQLDatabase db;
	property String table;
	HashTable indexes;

	// FIXME: Table versioning?

	public SQLTableRecordStore() {
		indexes = HashTable.create();
	}

	public SQLTableRecordStore add_index(String index) {
		indexes.set_bool(index, false);
		return(this);
	}

	public SQLTableRecordStore add_unique_index(String index) {
		indexes.set_bool(index, true);
		return(this);
	}

	public bool initialize(Error error) {
		if(db == null) {
			Error.set_error_message(error, "No db");
			return(false);
		}
		var sti = SQLTableInfo.for_name(table);
		foreach(String key in indexes) {
			sti.add_string_column(key);
			if(indexes.get_bool(key)) {
				sti.add_unique_index(key);
			}
			else {
				sti.add_index(key);
			}
		}
		sti.add_text_column("data");
		if(db.ensure_table(sti) == false) {
			Error.set_error_message(error, "Failed to create / update table: `%s'".printf().add(table).to_string());
			return(false);
		}
		return(true);
	}

	HashTable serialize_to_strings(HashTable data) {
		var v = HashTable.create();
		HashTable vd;
		foreach(String key in data.iterate_keys()) {
			var io = indexes.get(key);
			if(io == null) {
				if(vd == null) {
					vd = HashTable.create();
				}
				vd.set(key, data.get(key));
				continue;
			}
			v.set(key, data.get(key));
		}
		if(vd == null) {
			v.set("data", "");
		}
		else {
			v.set("data", JSONEncoder.encode(vd, false));
		}
		return(v);
	}

	public bool append(Object object, Error error) {
		if(object == null) {
			Error.set_error_message(error, "Null object");
			return(false);
		}
		var record_object = to_record_object(object);
		if(validate_record_object(record_object, error) == false) {
			return(false);
		}
		if(db == null || String.is_empty(table)) {
			Error.set_error_message(error, "Missing db or table");
			return(false);
		}
		var record = object_to_record(record_object);
		if(record == null) {
			Error.set_error_message(error, "Cannot convert object to record");
			return(false);
		}
		var data = serialize_to_strings(record);
		if(db.insert(table, data) == false) {
			Error.set_error_message(error, "Failed to insert");
			return(false);
		}
		return(true);
	}

	HashTable as_hash_table(Object o) {
		if(o == null) {
			return(null);
		}
		if(o is HashTable) {
			return((HashTable)o);
		}
		if(o is Serializable) {
			var v = HashTable.create();
			((Serializable)o).export_data(v);
			return(v);
		}
		return(null);
	}

	public bool update(Object object, RecordFilter filter, Error error) {
		if(object == null) {
			Error.set_error_message(error, "Null object");
			return(false);
		}
		var ro = get_one_matching(filter, null, error);
		if(ro == null) {
			return(false);
		}
		var ht_orig = as_hash_table(ro);
		var ht_updt = as_hash_table(object);
		if(ht_orig == null) {
			ht_orig = HashTable.create();
		}
		if(ht_updt != null) {
			foreach(String key in ht_updt) {
				ht_orig.set(key, ht_updt.get(key));
			}
		}
		var record_object = to_record_object(ht_orig);
		if(validate_record_object(record_object, error) == false) {
			return(false);
		}
		if(db == null || String.is_empty(table)) {
			Error.set_error_message(error, "Missing db or table");
			return(false);
		}
		var record = object_to_record(record_object);
		if(record == null) {
			Error.set_error_message(error, "Cannot convert object to record");
			return(false);
		}
		var data = serialize_to_strings(record);
		var values = LinkedList.create();
		var sql = StringBuffer.create();
		sql.append("UPDATE ");
		sql.append(table);
		sql.append(" SET ");
		var first = true;
		foreach(String key in data.iterate_keys()) {
			if(first == false) {
				sql.append(", ");
			}
			sql.append(key);
			sql.append(" = ?");
			values.append(data.get(key));
			first = false;
		}
		if(filter != null) {
			sql.append(" WHERE ");
			if(RecordFilterToSQL.execute(filter, sql, values) == false) {
				Error.set_error_message(error, "Invalid record filter");
				return(false);
			}
		}
		var sqls = sql.to_string();
		var stmt = db.prepare(sqls);
		if(stmt == null) {
			Error.set_error_message(error, "Invalid SQL statement: `%s'".printf().add(sqls).to_string());
			return(false);
		}
		foreach(Object val in values) {
			if(val is Buffer) {
				stmt.add_param_blob((Buffer)val);
			}
			else {
				stmt.add_param_str(String.as_string(val));
			}
		}
		var r = db.execute(stmt);
		if(r == false) {
			Error.set_error_message(error, "Failed to update");
			return(false);
		}
		return(true);
	}

	public bool delete(RecordFilter filter, Error error) {
		if(db == null || String.is_empty(table)) {
			Error.set_error_message(error, "Missing db or table");
			return(false);
		}
		var values = LinkedList.create();
		var sql = StringBuffer.create();
		sql.append("DELETE FROM ");
		sql.append(table);
		if(filter != null) {
			sql.append(" WHERE ");
			if(RecordFilterToSQL.execute(filter, sql, values) == false) {
				Error.set_error_message(error, "Invalid record filter");
				return(false);
			}
		}
		var sqls = sql.to_string();
		var stmt = db.prepare(sqls);
		if(stmt == null) {
			Error.set_error_message(error, "Invalid SQL statement: `%s'".printf().add(sqls).to_string());
			return(false);
		}
		foreach(Object val in values) {
			stmt.add_param_str(String.as_string(val));
		}
		var r = db.execute(stmt);
		if(r == false) {
			Error.set_error_message(error, "Failed to delete");
			return(false);
		}
		return(true);
	}

	bool create_select_sql(String results, RecordFilter filter, int offset, int limit, Collection sorting, StringBuffer sql, Collection values) {
		sql.append("SELECT ");
		if(results == null) {
			sql.append("*");
		}
		else {
			sql.append(results);
		}
		sql.append(" FROM ");
		sql.append(table);
		if(filter != null) {
			sql.append(" WHERE ");
			if(RecordFilterToSQL.execute(filter, sql, values) == false) {
				return(false);
			}
		}
		if(sorting != null) {
			var first = true;
			foreach(SortingRule rule in sorting) {
				if(first) {
					sql.append(" ORDER BY ");
				}
				else {
					sql.append(", ");
				}
				sql.append(rule.get_field());
				if(rule.get_ascending()) {
					sql.append(" ASC");
				}
				else {
					sql.append(" DESC");
				}
				first = false;
			}
		}
		if(limit > 0) {
			sql.append(" LIMIT ");
			sql.append(String.for_integer(limit));
		}
		if(offset > 0) {
			sql.append(" OFFSET ");
			sql.append(String.for_integer(offset));
		}
		return(true);
	}

	public int get_record_count(RecordFilter filter, Error error) {
		if(db == null || String.is_empty(table)) {
			Error.set_error_message(error, "Missing db or table");
			return(-1);
		}
		var sql = StringBuffer.create();
		var values = LinkedList.create();
		if(create_select_sql("COUNT(*) AS count", filter, 0, 0, null, sql, values) == false) {
			Error.set_error_message(error, "Invalid input data for get_record_count");
			return(-1);
		}
		var sqls = sql.to_string();
		var stmt = db.prepare(sqls);
		if(stmt == null) {
			Error.set_error_message(error, "Invalid SQL statement: `%s'".printf().add(sqls).to_string());
			return(-1);
		}
		foreach(Object val in values) {
			stmt.add_param_str(String.as_string(val));
		}
		var r = db.query(stmt);
		if(r == null) {
			Error.set_error_message(error, "Failed to execute query");
			return(-1);
		}
		var o = r.next() as HashTable;
		if(o == null) {
			Error.set_error_message(error, "Empty result record (?)");
			return(-1);
		}
		return(o.get_int("count", 0));
	}

	public Collection get_records(RecordFilter filter, int offset, int limit, Collection sorting, Collection fields, Error error) {
		if(db == null || String.is_empty(table)) {
			Error.set_error_message(error, "Missing db or table");
			return(null);
		}
		var sql = StringBuffer.create();
		var values = LinkedList.create();
		if(create_select_sql("*", filter, offset, limit, sorting, sql, values) == false) {
			Error.set_error_message(error, "Invalid input data for get_records");
			return(null);
		}
		var sqls = sql.to_string();
		var stmt = db.prepare(sqls);
		if(stmt == null) {
			Error.set_error_message(error, "Invalid SQL statement: `%s'".printf().add(sqls).to_string());
			return(null);
		}
		foreach(Object val in values) {
			stmt.add_param_str(String.as_string(val));
		}
		var r = db.query(stmt);
		if(r == null) {
			Error.set_error_message(error, "Failed to execute query");
			return(null);
		}
		var v = LinkedList.create();
		foreach(HashTable o in r) {
			var data = o.get("data");
			if(data != null) {
				o.remove("data");
				var ddc = JSONParser.parse_string(String.as_string(data)) as HashTable;
				if(ddc != null) {
					foreach(String key in ddc.iterate_keys()) {
						o.set(key, ddc.get(key));
					}
				}
			}
			if(fields != null) {
				var x = HashTable.create();
				foreach(String field in fields) {
					x.set(field, o.get(field));
				}
				v.append(x);
			}
			else {
				var ro = record_to_object(o);
				if(ro != null) {
					v.append(ro);
				}
			}
		}
		return(v);
	}

	public virtual Serializable create_serializable_object() {
		return(null);
	}

	public virtual bool validate_record_object(Object object, Error error) {
		if(object != null && object is Validateable) {
			if(((Validateable)object).validate(error) == false) {
				return(false);
			}
		}
		return(true);
	}

	public Object to_record_object(Object object) {
		if(object == null) {
			return(null);
		}
		if(object is HashTable) {
			return(record_to_object((HashTable)object));
		}
		return(object);
	}

	public virtual Object record_to_object(HashTable record) {
		var ro = create_serializable_object();
		if(ro != null) {
			ro.import_data(record);
			return(ro);
		}
		return(record);
	}

	public virtual HashTable object_to_record(Object o) {
		if(o == null) {
			return(null);
		}
		if(o is HashTable) {
			return((HashTable)o);
		}
		if(o is Serializable) {
			var v = HashTable.create();
			((Serializable)o).export_data(v);
			return(v);
		}
		return(null);
	}
}
