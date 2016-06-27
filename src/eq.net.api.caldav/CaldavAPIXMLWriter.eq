
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

public class CaldavAPIXMLWriter
{
	public static String create_multilinks(Collection links) {
		var xmlmaker = new XMLMaker();
		var multiget_startelement = XMLMakerStartElement.for_name("c:calendar-multiget");
		multiget_startelement.attribute("xmlns:d", "DAV:");
		multiget_startelement.attribute("xmlns:c", "urn:ietf:params:xml:ns:caldav");
		var prop_startelement = XMLMakerStartElement.for_name("d:prop");
		var etag_element = XMLMakerElement.for_name("d:getetag");
		var cdat_element = XMLMakerElement.for_name("c:calendar-data");
		var prop_endelement = XMLMakerEndElement.for_name("d:prop");
		xmlmaker.add(multiget_startelement);
		xmlmaker.add(prop_startelement);
		xmlmaker.add(etag_element);
		xmlmaker.add(cdat_element);
		xmlmaker.add(prop_endelement);
		var links_startelement = XMLMakerStartElement.for_name("d:href").set_single_line(true);
		var links_endelement = XMLMakerEndElement.for_name("d:href");
		foreach(String l in links) {
			xmlmaker.add(links_startelement);
			xmlmaker.add(l);
			xmlmaker.add(links_endelement);
		}
		var multiget_endelement = XMLMakerEndElement.for_name("c:calendar-multiget");
		xmlmaker.add(multiget_endelement);
		return(xmlmaker.to_string());
	}

	public static String create_calendar_home_set() {
		var xmlmaker = new XMLMaker();
		var propfind_startelement = XMLMakerStartElement.for_name("d:propfind");
		propfind_startelement.attribute("xmlns:c", "urn:ietf:params:xml:ns:caldav");
		propfind_startelement.attribute("xmlns:d", "DAV:");
		var prop_startelement = XMLMakerStartElement.for_name("d:prop");
		var calendar_set = XMLMakerElement.for_name("c:calendar-home-set");
		var prop_endelement = XMLMakerEndElement.for_name("d:prop");
		var propfind_endelement = XMLMakerEndElement.for_name("d:propfind");
		xmlmaker.add(propfind_startelement);
		xmlmaker.add(prop_startelement);
		xmlmaker.add(calendar_set);
		xmlmaker.add(prop_endelement);
		xmlmaker.add(propfind_endelement);
		return(xmlmaker.to_string());
	}

	public static String create_principal_request() {
		var xmlmaker = new XMLMaker();
		var propfind_startelement = XMLMakerStartElement.for_name("d:propfind");
		propfind_startelement.attribute("xmlns:d", "DAV:");
		var prop_startelement = XMLMakerStartElement.for_name("d:prop");
		var principal_element = XMLMakerElement.for_name("d:current-user-principal");
		var prop_endelement = XMLMakerEndElement.for_name("d:prop");
		var propfind_endelement = XMLMakerEndElement.for_name("d:propfind");
		xmlmaker.add(propfind_startelement);
		xmlmaker.add(prop_startelement);
		xmlmaker.add(principal_element);
		xmlmaker.add(prop_endelement);
		xmlmaker.add(propfind_endelement);
		return(xmlmaker.to_string());
	}

	public static String calendar_identification() {
		var xmlmaker = new XMLMaker();
		var propfind_startelement = XMLMakerStartElement.for_name("d:propfind");
		propfind_startelement.attribute("xmlns:c", "urn:ietf:params:xml:ns:caldav");
		propfind_startelement.attribute("xmlns:cs", "http://calendarserver.org/ns/");
		propfind_startelement.attribute("xmlns:d", "DAV:");
		var prop_startelement = XMLMakerStartElement.for_name("d:prop");
		var resourcetype_element = XMLMakerElement.for_name("d:resourcetype");
		var displayname_element = XMLMakerElement.for_name("d:displayname");
		var ctag_element = XMLMakerElement.for_name("cs:getctag");
		var calendarcomponent_element = XMLMakerElement.for_name("c:supported-calendar-component-set");
		var prop_endelement = XMLMakerEndElement.for_name("d:prop");
		var propfind_endelement = XMLMakerEndElement.for_name("d:propfind");
		xmlmaker.add(propfind_startelement);
		xmlmaker.add(prop_startelement);
		xmlmaker.add(resourcetype_element);
		xmlmaker.add(displayname_element);
		xmlmaker.add(ctag_element);
		xmlmaker.add(calendarcomponent_element);
		xmlmaker.add(prop_endelement);
		xmlmaker.add(propfind_endelement);
		return(xmlmaker.to_string());
	}

	public static String create_request() {
		var xmlmaker = new XMLMaker();
		var query_startelement = XMLMakerStartElement.for_name("c:calendar-query");
		query_startelement.attribute("xmlns:c", "urn:ietf:params:xml:ns:caldav");
		query_startelement.attribute("xmlns:d", "DAV:");
		var prop_startelement = XMLMakerStartElement.for_name("d:prop");
		var etag_element = XMLMakerElement.for_name("d:getetag");
		var cdata_element = XMLMakerElement.for_name("d:calendar-data");
		var filter_startelement = XMLMakerStartElement.for_name("c:filter");
		var cfilter_startelement = XMLMakerStartElement.for_name("c:comp-filter");
		cfilter_startelement.attribute("name", "VCALENDAR");
		var inner_cfiltstarterelement = XMLMakerElement.for_name("c:comp-filter");
		inner_cfiltstarterelement.attribute("name", "VEVENT");
		var prop_endelement = XMLMakerEndElement.for_name("d:prop");
		var filter_endelement = XMLMakerEndElement.for_name("c:filter");
		var cfilter_endelement = XMLMakerEndElement.for_name("c:comp-filter");
		var query_endelement = XMLMakerEndElement.for_name("c:calendar-query");
		xmlmaker.add(query_startelement);
		xmlmaker.add(prop_startelement);
		xmlmaker.add(etag_element);
		xmlmaker.add(cdata_element);
		xmlmaker.add(prop_endelement);
		xmlmaker.add(filter_startelement);
		xmlmaker.add(cfilter_startelement);
		xmlmaker.add(inner_cfiltstarterelement);
		xmlmaker.add(cfilter_endelement);
		xmlmaker.add(filter_endelement);
		xmlmaker.add(query_endelement);
		return(xmlmaker.to_string());
	}
}
