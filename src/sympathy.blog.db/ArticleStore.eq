
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

class ArticleStore : SQLTableRecordStore
{
	public ArticleStore() {
		set_table("articles");
		add_unique_index("id");
		add_unique_index("title_id");
		add_index("category");
		add_index("published");
		add_index("timestamp");
	}

	public bool validate_record_object(Object object, Error error) {
		if(base.validate_record_object(object, error) == false) {
			return(false);
		}
		var article = object as Article;
		if(article == null) {
			Error.set_error_message(error, "Object is not an article");
			return(false);
		}
		if(String.is_empty(article.get_id())) {
			article.set_id(UniqueHash.generate());
		}
		return(true);
	}

	public Serializable create_serializable_object() {
		return(new Article());
	}
}
