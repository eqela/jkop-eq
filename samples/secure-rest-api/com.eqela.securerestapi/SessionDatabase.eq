
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

public class SessionDatabase : HTTPRequestSessionHandler
{
	public static SessionDatabase for_sqldatabase(SQLDatabase db) {
		var v = new SessionDatabase();
		v.set_db(db);
		if(v.initialize() == false) {
			v = null;
		}
		return(v);
	}

	property SQLDatabase db;
	property String session_header_key = "sid";
	property int session_ttl = 60 * 60 * 12;
	property UserDatabase userdb;

	public bool initialize() {
		if(db == null) {
			return(false);
		}
		if(db.table_exists("sessions") == false) {
			if(db.execute(db.prepare("CREATE TABLE sessions (session_id VARCHAR(255), username VARCHAR(255), timestamp INTEGER);")) == false) {
				return(false);
			}
			if(db.execute(db.prepare("CREATE INDEX IF NOT EXISTS sessions_session_id ON sessions(session_id);")) == false) {
				return(false);
			}
			if(db.execute(db.prepare("CREATE INDEX IF NOT EXISTS sessions_timestamp ON sessions(timestamp);")) == false) {
				return(false);
			}
		}
		return(true);
	}

	Session create_session(String username) {
		var session = Session.for_username(username);
		if(session == null) {
			return(null);
		}
		if(db.execute(db.prepare("INSERT INTO sessions (session_id, username, timestamp) VALUES (?, ?, ?);")
			.add_param_str(session.get_session_id())
			.add_param_str(session.get_username())
			.add_param_int(SystemClock.seconds())) == false) {
			session = null;
		}
		return(session);
	}

	public Session authenticate_user(String username, String password) {
		var user = userdb.get_user_for_username(username);
		if(user == null) {
			return(null);
		}
		var p = user.get_string("password");
		if(String.is_empty(p) || p.equals(SHAEncoder.encode(password, SHAEncoder.SHA256)) == false) {
			return(null);
		}
		return(create_session(username));
	}

	public void on_maintenance() {
		var now = SystemClock.seconds();
		var tt = now - session_ttl;
		Log.message("SessionDatabase maintenance: Deleting sessions older than %d, now=%d".printf()
			.add(tt)
			.add(now)
			.to_string());
		db.execute(db.prepare("DELETE FROM sessions WHERE timestamp <= ?;")
			.add_param_int(tt));
	}

	public void delete_session(Session session) {
		db.execute(db.prepare("DELETE FROM sessions WHERE session_id = ?;")
			.add_param_str(session.get_session_id()));
	}

	public Session update_session(String session_id) {
		var session = get_session(session_id);
		if(session == null) {
			return(null);
		}
		if(db.execute(db.prepare("UPDATE sessions SET timestamp = ? WHERE session_id = ?;")
			.add_param_int(SystemClock.seconds())
			.add_param_str(session.get_session_id())) == false) {
			session = null;
		}
		return(session);
	}

	public Session get_session(String session_id) {
		if(String.is_empty(session_id)) {
			return(null);
		}
		var session = db.query_single_row(db.prepare("SELECT * FROM sessions WHERE session_id = ?;")
			.add_param_str(session_id));
		if(session == null) {
			return(null);
		}
		var v = new Session();
		if(v.from_json_object(session) == false) {
			v = null;
		}
		return(v);
	}

	public Object check_session(HTTPRequest req) {
		var session = req.get_session() as Session;
		if(session != null) {
			return(session);
		}
		var session_id = req.get_header(session_header_key);
		if(String.is_empty(session_id)) {
			return(null);
		}
		session = update_session(session_id);
		req.set_session(session);
		return(session);
	}
}
