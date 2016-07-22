
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

public class PersonDatabase
{
	public static PersonDatabase for_sqldatabase(SQLDatabase db) {
		var v = new PersonDatabase();
		v.set_db(db);
		if(v.initialize() == false) {
			v = null;
		}
		return(v);
	}

	property SQLDatabase db;

	public bool initialize() {
		if(db == null) {
			return(false);
		}
		if(db.table_exists("persons") == false) {
			if(db.execute(db.prepare("CREATE TABLE persons (name VARCHAR(255) PRIMARY KEY, age INTEGER, gender VARCHAR(255));")) == false) {
				return(false);
			}
		}
		return(true);
	}

	public Collection get_persons() {
		var persons = db.query(db.prepare("SELECT * FROM persons;"));
		if(persons == null) {
			return(null);
		}
		return(LinkedList.for_iterator(persons));
	}

	public HashTable get_person(String name) {
		return(db.query_single_row(db.prepare("SELECT * FROM persons WHERE name = ?;")
			.add_param_str(name)));
	}

	public bool add_person(String name, int age, String gender) {
		return(db.execute(db.prepare("INSERT INTO persons (name, age, gender) VALUES (?, ?, ?);")
			.add_param_str(name)
			.add_param_int(age)
			.add_param_str(gender)));
	}

	public bool update_person(String name, String new_name, int age, String gender) {
		return(db.execute(db.prepare("UPDATE persons SET name = ?, age = ?, gender = ? WHERE name = ?;")
			.add_param_str(new_name)
			.add_param_int(age)
			.add_param_str(gender)
			.add_param_str(name)));
	}

	public bool delete_person(String name) {
		return(db.execute(db.prepare("DELETE FROM persons WHERE name = ?;")
			.add_param_str(name)));
	}

	public bool delete_persons() {
		return(db.execute(db.prepare("DELETE FROM persons;")));
	}
}
