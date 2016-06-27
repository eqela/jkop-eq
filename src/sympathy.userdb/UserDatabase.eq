
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
	public static UserDatabase for_db(SQLDatabase db, Logger logger = null) {
		var v = new UserDatabase();
		v.set_db(db);
		if(v.initialize(logger) == false) {
			v = null;
		}
		return(v);
	}

	property SQLDatabase db;
	property int session_ttl = 60 * 60 * 24 * 60;

	public bool initialize(Logger logger) {
		if(db == null) {
			if(logger != null) {
				logger.log_error("No database. Cannot initialize user database.");
			}
			return(false);
		}
		if(db.table_exists("credentials") == false) {
			var col = LinkedList.create();
			col.add(SQLTableColumnInfo.for_string("username"));
			col.add(SQLTableColumnInfo.for_string("password"));
			if(db.create_table("credentials", col) == false) {
				if(logger != null) {
					logger.log_error("Failed to create user database table: credentials");
				}
				return(false);
			}
		}
		if(db.table_exists("sessions") == false) {
			var col = LinkedList.create();
			col.add(SQLTableColumnInfo.for_string("sessionid"));
			col.add(SQLTableColumnInfo.for_string("username"));
			col.add(SQLTableColumnInfo.for_integer("timestamp"));
			if(db.create_table("sessions", col) == false) {
				if(logger != null) {
					logger.log_error("Failed to create user database table: sessions");
				}
				return(false);
			}
		}
		return(true);
	}

	public Collection get_all_usernames() {
		var v = LinkedList.create();
		foreach(HashTable record in db.query(db.prepare("SELECT username FROM credentials;"))) {
			var un = record.get_string("username");
			if(String.is_empty(un) == false) {
				v.add(un);
			}
		}
		return(v);
	}

	public bool add_user(String username, String password) {
		if(username == null || password == null) {
			return(false);
		}
		if(db.query_single_row(db.prepare("SELECT * FROM credentials WHERE username = ?;")
			.add_param_str(username)) != null) {
			return(false);
		}
		var data = HashTable.create();
		data.set("username", username);
		data.set("password", MD5Encoder.encode(password));
		if(db.insert("credentials", data) == false) {
			return(false);
		}
		return(true);
	}

	public bool force_change_password(String username, String password) {
		if(username == null || password == null) {
			return(false);
		}
		var cri = HashTable.create().set("username", username);
		var data = HashTable.create().set("password", MD5Encoder.encode(password));
		if(db.update("credentials", cri, data) == false) {
			return(false);
		}
		return(true);
	}

	public bool change_password(String username, String password, String new_password) {
		if(username == null || password == null || new_password == null) {
			return(false);
		}
		var cri = HashTable.create();
		cri.set("username", username);
		cri.set("password", MD5Encoder.encode(password));
		var data = HashTable.create();
		data.set("password", MD5Encoder.encode(new_password));
		if(db.update("credentials", cri, data) == false) {
			return(false);
		}
		return(true);
	}

	public bool remove_user(String username) {
		if(username == null) {
			return(false);
		}
		if(db.execute(db.prepare("DELETE FROM credentials WHERE username = ?;")
			.add_param_str(username)) == false) {
			return(false);
		}
		return(true);
	}

	public HashTable check_credentials(String username, String password) {
		return(db.query_single_row(db.prepare("SELECT * FROM credentials WHERE username = ? AND password = ?;")
			.add_param_str(username)
			.add_param_str(MD5Encoder.encode(password))));
	}

	public UserDatabaseSession create_session(String username) {
		if(String.is_empty(username)) {
			return(null);
		}
		int n;
		for(n=0; n<100000; n++) {
			var id = MD5Encoder.encode("%s%d%d".printf().add(username).add((int)SystemClock.seconds()).add(Math.random(0,1000000)).to_string());
			if(db.query_single_row(db.prepare("SELECT * FROM sessions WHERE sessionid = ?;").add_param_str(id)) == null) {
				var data = HashTable.create();
				data.set("sessionid", id);
				data.set("username", username);
				data.set("timestamp", (int)SystemClock.seconds());
				if(db.insert("sessions", data) == false) {
					return(null);
				}
				var v = new UserDatabaseSession();
				v.set_id(id);
				v.set_username(username);
				return(v);
			}
		}
		return(null);
	}

	public UserDatabaseSession get_session(String sessionid) {
		if(String.is_empty(sessionid)) {
			return(null);
		}
		var session = db.query_single_row(db.prepare("SELECT * FROM sessions WHERE sessionid = ?;").add_param_str(sessionid));
		if(session == null) {
			return(null);
		}
		var v = new UserDatabaseSession();
		v.set_id(session.get_string("sessionid"));
		v.set_username(session.get_string("username"));
		return(v);
	}

	public UserDatabaseSession get_update_session(String sessionid) {
		var session = get_session(sessionid);
		if(session == null) {
			return(null);
		}
		var cri = HashTable.create();
		cri.set("sessionid", sessionid);
		var now = SystemClock.seconds();
		var data = HashTable.create();
		data.set("timestamp", (int)now);
		// FIXME: Should limit this somehow. No need to update it on EVERY REQUEST. Perhaps check if the timestamp has changed
		// by more than some amount of time.
		if(db.update("sessions", cri, data) == false) {
			session = null;
		}
		return(session);
	}

	public void remove_session(String sessionid) {
		if(String.is_empty(sessionid) == false) {
			db.execute(db.prepare("DELETE FROM sessions WHERE sessionid = ?;")
				.add_param_str(sessionid));
		}
	}

	public void on_maintenance() {
		var now = SystemClock.seconds();
		var tt = now - session_ttl;
		db.execute(db.prepare("DELETE FROM sessions WHERE timestamp <= %d;".printf().add((int)tt).to_string()));
	}
}
