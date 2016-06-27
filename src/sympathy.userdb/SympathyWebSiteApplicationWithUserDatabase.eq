
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

public class SympathyWebSiteApplicationWithUserDatabase : SympathyWebSiteApplication
{
	Collection admin_users;
	UserDatabase userdb;

	public SympathyWebSiteApplicationWithUserDatabase() {
		admin_users = LinkedList.create();
	}

	public UserDatabase get_userdb() {
		return(userdb);
	}

	public Collection get_admin_users() {
		return(admin_users);
	}

	void read_admin_users() {
		admin_users.clear();
		foreach(KeyValuePair kvp in read_datadir_config_file("admins")) {
			var key = kvp.get_key();
			var value = String.as_string(kvp.get_value());
			if("admin".equals(key)) {
				log_debug("Administrator user: `%s'".printf().add(value));
				admin_users.append(value);
			}
		}
	}

	public bool initialize() {
		if(base.initialize() == false) {
			return(false);
		}
		var dbfile = get_datadir_file("users.sqlite");
		if(dbfile.is_file() == false) {
			log_error("User database file `%s' was not found in data directory `%s'. Use symblogadmin to initialize a blog.".printf().add(dbfile).add(get_datadir()));
			return(false);
		}
		var sql = SQLiteDatabase.for_file(dbfile, false, get_logger());
		if(sql == null) {
			log_error("Failed to open user database SQLite file: `%s'".printf().add(dbfile));
			return(false);
		}
		userdb = UserDatabase.for_db(sql, get_logger());
		if(userdb == null) {
			log_error("Failed to initialize user database: `%s'".printf().add(dbfile));
			return(false);
		}
		read_admin_users();
		return(true);
	}

	public void on_maintenance() {
		base.on_maintenance();
		if(userdb != null) {
			userdb.on_maintenance();
		}
	}

	public void on_refresh() {
		base.on_refresh();
		read_admin_users();
	}
}
