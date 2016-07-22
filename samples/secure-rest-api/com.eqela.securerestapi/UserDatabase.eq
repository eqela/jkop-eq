
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

public class UserDatabase
{
	public static UserDatabase for_sqldatabase(SQLDatabase db) {
		var v = new UserDatabase();
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
		if(db.table_exists("users") == false) {
			if(db.execute(db.prepare("CREATE TABLE users (username VARCHAR(255) PRIMARY KEY, password VARCHAR(255));")) == false) {
				return(false);
			}
			if(db.execute(db.prepare("CREATE INDEX IF NOT EXISTS users_username ON users(username);")) == false) {
				return(false);
			}
		}
		return(true);
	}

	public bool is_username_valid(String username) {
		if(String.is_empty(username)) {
			return(false);
		}
		if(username.get_length() > 15 || username.get_length() < 8) {
			return(false);
		}
		var si = username.iterate();
		while(true) {
			var c = si.next_char();
			if(c < 1) {
				break;
			}
			if((c >= 65 && c <= 90) || (c >= 97 && c <= 122) || (c >= 48 && c <= 57)) {
				continue;
			}
			return(false);
		}
		return(true);
	}

	public bool is_password_valid(String password) {
		if(String.is_empty(password)) {
			return(false);
		}
		if(password.get_length() < 8 || password.get_length() > 32) {
			return(false);
		}
		var has_lower_alpha = false;
		var has_upper_alpha = false;
		var has_numeric = false;
		var has_special = false;
		var si = password.iterate();
		while(true) {
			var c = si.next_char();
			if(c < 1) {
				break;
			}
			if(c > 32 && c < 127) {
				if(c >= 65 && c <= 90) {
					has_upper_alpha = true;
				}
				else if(c >= 97 && c <= 122) {
					has_lower_alpha = true;
				}
				else if(c >= 48 && c <= 57) {
					has_numeric = true;
				}
				else {
					has_special = true;
				}
				continue;
			}
			return(false);
		}
		return(has_lower_alpha && has_upper_alpha && has_numeric && has_special);
	}

	public bool add_user(String username, String password) {
		return(db.execute(db.prepare("INSERT INTO users ( username, password ) VALUES ( ?, ? );")
			.add_param_str(username)
			.add_param_str(SHAEncoder.encode(password, SHAEncoder.SHA256))));
	}

	public HashTable get_user_for_username(String username) {
		return(db.query_single_row(db.prepare("SELECT * FROM users WHERE username = ?;")
			.add_param_str(username)));
	}
}
