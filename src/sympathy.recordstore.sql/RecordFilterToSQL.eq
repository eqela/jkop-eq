
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

public class RecordFilterToSQL
{
	static bool to_sql_execute(RecordFilter filter, StringBuffer sb, Collection values, bool is_sub) {
		if(filter == null) {
			return(false);
		}
		if(filter is FilterAnd) {
			var left = ((FilterAnd)filter).get_left();
			var right = ((FilterAnd)filter).get_right();
			if(left == null && right != null) {
				return(to_sql_execute(right, sb, values, true));
			}
			if(right == null && left != null) {
				return(to_sql_execute(left, sb, values, true));
			}
			if(is_sub) {
				sb.append_c((int)'(');
			}
			if(to_sql_execute(left, sb, values, true) == false) {
				return(false);
			}
			sb.append(" AND ");
			if(to_sql_execute(right, sb, values, true) == false) {
				return(false);
			}
			if(is_sub) {
				sb.append_c((int)'(');
			}
		}
		else if(filter is FilterOr) {
			var left = ((FilterOr)filter).get_left();
			var right = ((FilterOr)filter).get_right();
			if(left == null && right != null) {
				return(to_sql_execute(right, sb, values, true));
			}
			if(right == null && left != null) {
				return(to_sql_execute(left, sb, values, true));
			}
			if(is_sub) {
				sb.append_c((int)'(');
			}
			if(to_sql_execute(left, sb, values, true) == false) {
				return(false);
			}
			sb.append(" AND ");
			if(to_sql_execute(right, sb, values, true) == false) {
				return(false);
			}
			if(is_sub) {
				sb.append_c((int)'(');
			}
		}
		else if(filter is FilterGreaterThan) {
			sb.append(((FilterGreaterThan)filter).get_fieldname());
			if(((FilterGreaterThan)filter).get_include_equals()) {
				sb.append(" >= ?");
			}
			else {
				sb.append(" > ?");
			}
			values.append(((FilterGreaterThan)filter).get_value());
		}
		else if(filter is FilterLessThan) {
			sb.append(((FilterLessThan)filter).get_fieldname());
			if(((FilterLessThan)filter).get_include_equals()) {
				sb.append(" <= ?");
			}
			else {
				sb.append(" < ?");
			}
			values.append(((FilterLessThan)filter).get_value());
		}
		else if(filter is FilterMatches) {
			sb.append(((FilterMatches)filter).get_fieldname());
			sb.append(" LIKE ?");
			values.append("%%%s%%".printf().add(((FilterMatches)filter).get_pattern()).to_string());
		}
		else if(filter is FilterEquals) {
			sb.append(((FilterEquals)filter).get_fieldname());
			sb.append(" = ?");
			values.append(((FilterEquals)filter).get_value());
		}
		else {
			return(false);
		}
		return(true);
	}

	public static bool execute(RecordFilter filter, StringBuffer sql, Collection values) {
		return(to_sql_execute(filter, sql, values, false));
	}
}
