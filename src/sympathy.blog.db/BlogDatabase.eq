
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

public class BlogDatabase
{
	public static BlogDatabase for_db(SQLDatabase db, Error error = null) {
		if(db == null) {
			return(null);
		}
		var v = new BlogDatabase();
		v.set_db(db);
		if(v.initialize(error) == false) {
			return(null);
		}
		return(v);
	}

	property SQLDatabase db;
	SQLTableRecordStore articles;
	SQLTableRecordStore categories;

	public RecordStore get_article_store() {
		return(articles);
	}

	public RecordStore get_category_store() {
		return(categories);
	}

	public bool initialize(Error error) {
		if(db == null) {
			return(false);
		}
		articles = new ArticleStore().set_db(db);
		if(articles.initialize(error) == false) {
			return(false);
		}
		categories = new CategoryStore().set_db(db);
		if(categories.initialize(error) == false) {
			return(false);
		}
		return(true);
	}

	public Article get_article_by_id(String id) {
		return(articles.get_one_matching(FilterEquals.values("id", id), null, null) as Article);
	}

	public Article get_article_by_title_id(String id) {
		return(articles.get_one_matching(FilterEquals.values("title_id", id), null, null) as Article);
	}

	RecordFilter get_filter(String categoryid, bool include_drafts) {
		RecordFilter categoryfilter;
		RecordFilter draftfilter;
		if(categoryid != null) {
			categoryfilter = FilterEquals.values("category", categoryid);
		}
		if(include_drafts == false) {
			draftfilter = FilterEquals.values("published", "1");
		}
		if(categoryfilter != null && draftfilter != null) {
			return(FilterAnd.rules(categoryfilter, draftfilter));
		}
		if(categoryfilter != null) {
			return(categoryfilter);
		}
		if(draftfilter != null) {
			return(draftfilter);
		}
		return(null);
	}

	public int get_article_count(String categoryid, bool include_drafts) {
		return(articles.get_record_count(get_filter(categoryid, include_drafts), null));
	}

	Collection article_fields;

	public Collection get_article_list_fields() {
		if(article_fields == null) {
			article_fields = LinkedList.create().add("id").add("title_id").add("timestamp").add("title").add("intro");
		}
		return(article_fields);
	}

	public Collection get_articles(String categoryid, bool include_drafts, int offset, int limit) {
		return(articles.get_records(
			get_filter(categoryid, include_drafts),
			offset, limit,
			LinkedList.create().add(SortingRule.for_field("timestamp").set_ascending(false)),
			get_article_list_fields(),
			null));
	}

	public Collection get_all_published_articles(int offset, int limit) {
		return(get_articles(null, false, offset, limit));
	}

	public Collection get_all_articles(int offset, int limit) {
		return(get_articles(null, true, offset, limit));
	}

	public Collection get_categories() {
		return(categories.get_all_records(
			LinkedList.create().add(SortingRule.for_field("name").set_ascending(true)),
			null,
			null));
	}

	public Category get_category_by_id(String id) {
		return(categories.get_one_matching(FilterEquals.values("id", id), null, null) as Category);
	}

	public bool delete_category_by_id(String id) {
		return(categories.delete(FilterEquals.values("id", id), null));
	}

	/*
	public bool on_pre_delete(DFWRecord record, Error error) {
		if(record is Category) {
			var cc = (Category)record;
			var ccs = get_articles_by_category(cc.get_id(), true);
			if(ccs != null) {
				var r = ccs.next();
				if(r != null) {
					Error.set_error_message(error, "Cannot delete: There are articles published under this category.");
					return(false);
				}
			}
		}
		return(true);
	}
	*/
}
