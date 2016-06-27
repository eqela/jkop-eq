
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

public class CountrySelectorWidget : ComboButtonWidget
{
	public CountrySelectorWidget() {
		add_item(new ActionItem().set_text("Afghanistan").set_data("AF"));
		add_item(new ActionItem().set_text("Åland Islands").set_data("AX"));
		add_item(new ActionItem().set_text("Albania").set_data("AL"));
		add_item(new ActionItem().set_text("Algeria").set_data("DZ"));
		add_item(new ActionItem().set_text("American Samoa").set_data("AS"));
		add_item(new ActionItem().set_text("Andorra").set_data("AD"));
		add_item(new ActionItem().set_text("Angola").set_data("AO"));
		add_item(new ActionItem().set_text("Anguilla").set_data("AI"));
		add_item(new ActionItem().set_text("Antarctica").set_data("AQ"));
		add_item(new ActionItem().set_text("Antigua and Barbuda").set_data("AG"));
		add_item(new ActionItem().set_text("Argentina").set_data("AR"));
		add_item(new ActionItem().set_text("Armenia").set_data("AM"));
		add_item(new ActionItem().set_text("Aruba").set_data("AW"));
		add_item(new ActionItem().set_text("Australia").set_data("AU"));
		add_item(new ActionItem().set_text("Austria").set_data("AT"));
		add_item(new ActionItem().set_text("Azerbaijan").set_data("AZ"));
		add_item(new ActionItem().set_text("Bahamas").set_data("BS"));
		add_item(new ActionItem().set_text("Bahrain").set_data("BH"));
		add_item(new ActionItem().set_text("Bangladesh").set_data("BD"));
		add_item(new ActionItem().set_text("Barbados").set_data("BB"));
		add_item(new ActionItem().set_text("Belarus").set_data("BY"));
		add_item(new ActionItem().set_text("Belgium").set_data("BE"));
		add_item(new ActionItem().set_text("Belize").set_data("BZ"));
		add_item(new ActionItem().set_text("Benin").set_data("BJ"));
		add_item(new ActionItem().set_text("Bermuda").set_data("BM"));
		add_item(new ActionItem().set_text("Bhutan").set_data("BT"));
		add_item(new ActionItem().set_text("Bolivia").set_data("BO"));
		add_item(new ActionItem().set_text("Bosnia and Herzegovina").set_data("BA"));
		add_item(new ActionItem().set_text("Botswana").set_data("BW"));
		add_item(new ActionItem().set_text("Bouvet Island").set_data("BV"));
		add_item(new ActionItem().set_text("Brazil").set_data("BR"));
		add_item(new ActionItem().set_text("British Indian Ocean Territory").set_data("IO"));
		add_item(new ActionItem().set_text("Brunei Darussalam").set_data("BN"));
		add_item(new ActionItem().set_text("Bulgaria").set_data("BG"));
		add_item(new ActionItem().set_text("Burkina Faso").set_data("BF"));
		add_item(new ActionItem().set_text("Burundi").set_data("BI"));
		add_item(new ActionItem().set_text("Cambodia").set_data("KH"));
		add_item(new ActionItem().set_text("Cameroon").set_data("CM"));
		add_item(new ActionItem().set_text("Canada").set_data("CA"));
		add_item(new ActionItem().set_text("Cape Verde").set_data("CV"));
		add_item(new ActionItem().set_text("Cayman Islands").set_data("KY"));
		add_item(new ActionItem().set_text("Central African Republic").set_data("CF"));
		add_item(new ActionItem().set_text("Chad").set_data("TD"));
		add_item(new ActionItem().set_text("Chile").set_data("CL"));
		add_item(new ActionItem().set_text("China").set_data("CN"));
		add_item(new ActionItem().set_text("Christmas Island").set_data("CX"));
		add_item(new ActionItem().set_text("Cocos (Keeling) Islands").set_data("CC"));
		add_item(new ActionItem().set_text("Colombia").set_data("CO"));
		add_item(new ActionItem().set_text("Comoros").set_data("KM"));
		add_item(new ActionItem().set_text("Congo").set_data("CG"));
		add_item(new ActionItem().set_text("Congo, The Democratic Republic of The").set_data("CD"));
		add_item(new ActionItem().set_text("Cook Islands").set_data("CK"));
		add_item(new ActionItem().set_text("Costa Rica").set_data("CR"));
		add_item(new ActionItem().set_text("Cote D'ivoire").set_data("CI"));
		add_item(new ActionItem().set_text("Croatia").set_data("HR"));
		add_item(new ActionItem().set_text("Cuba").set_data("CU"));
		add_item(new ActionItem().set_text("Cyprus").set_data("CY"));
		add_item(new ActionItem().set_text("Czech Republic").set_data("CZ"));
		add_item(new ActionItem().set_text("Denmark").set_data("DK"));
		add_item(new ActionItem().set_text("Djibouti").set_data("DJ"));
		add_item(new ActionItem().set_text("Dominica").set_data("DM"));
		add_item(new ActionItem().set_text("Dominican Republic").set_data("DO"));
		add_item(new ActionItem().set_text("Ecuador").set_data("EC"));
		add_item(new ActionItem().set_text("Egypt").set_data("EG"));
		add_item(new ActionItem().set_text("El Salvador").set_data("SV"));
		add_item(new ActionItem().set_text("Equatorial Guinea").set_data("GQ"));
		add_item(new ActionItem().set_text("Eritrea").set_data("ER"));
		add_item(new ActionItem().set_text("Estonia").set_data("EE"));
		add_item(new ActionItem().set_text("Ethiopia").set_data("ET"));
		add_item(new ActionItem().set_text("Falkland Islands (Malvinas)").set_data("FK"));
		add_item(new ActionItem().set_text("Faroe Islands").set_data("FO"));
		add_item(new ActionItem().set_text("Fiji").set_data("FJ"));
		add_item(new ActionItem().set_text("Finland").set_data("FI"));
		add_item(new ActionItem().set_text("France").set_data("FR"));
		add_item(new ActionItem().set_text("French Guiana").set_data("GF"));
		add_item(new ActionItem().set_text("French Polynesia").set_data("PF"));
		add_item(new ActionItem().set_text("French Southern Territories").set_data("TF"));
		add_item(new ActionItem().set_text("Gabon").set_data("GA"));
		add_item(new ActionItem().set_text("Gambia").set_data("GM"));
		add_item(new ActionItem().set_text("Georgia").set_data("GE"));
		add_item(new ActionItem().set_text("Germany").set_data("DE"));
		add_item(new ActionItem().set_text("Ghana").set_data("GH"));
		add_item(new ActionItem().set_text("Gibraltar").set_data("GI"));
		add_item(new ActionItem().set_text("Greece").set_data("GR"));
		add_item(new ActionItem().set_text("Greenland").set_data("GL"));
		add_item(new ActionItem().set_text("Grenada").set_data("GD"));
		add_item(new ActionItem().set_text("Guadeloupe").set_data("GP"));
		add_item(new ActionItem().set_text("Guam").set_data("GU"));
		add_item(new ActionItem().set_text("Guatemala").set_data("GT"));
		add_item(new ActionItem().set_text("Guernsey").set_data("GG"));
		add_item(new ActionItem().set_text("Guinea").set_data("GN"));
		add_item(new ActionItem().set_text("Guinea-bissau").set_data("GW"));
		add_item(new ActionItem().set_text("Guyana").set_data("GY"));
		add_item(new ActionItem().set_text("Haiti").set_data("HT"));
		add_item(new ActionItem().set_text("Heard Island and Mcdonald Islands").set_data("HM"));
		add_item(new ActionItem().set_text("Holy See (Vatican City State)").set_data("VA"));
		add_item(new ActionItem().set_text("Honduras").set_data("HN"));
		add_item(new ActionItem().set_text("Hong Kong").set_data("HK"));
		add_item(new ActionItem().set_text("Hungary").set_data("HU"));
		add_item(new ActionItem().set_text("Iceland").set_data("IS"));
		add_item(new ActionItem().set_text("India").set_data("IN"));
		add_item(new ActionItem().set_text("Indonesia").set_data("ID"));
		add_item(new ActionItem().set_text("Iran, Islamic Republic of").set_data("IR"));
		add_item(new ActionItem().set_text("Iraq").set_data("IQ"));
		add_item(new ActionItem().set_text("Ireland").set_data("IE"));
		add_item(new ActionItem().set_text("Isle of Man").set_data("IM"));
		add_item(new ActionItem().set_text("Israel").set_data("IL"));
		add_item(new ActionItem().set_text("Italy").set_data("IT"));
		add_item(new ActionItem().set_text("Jamaica").set_data("JM"));
		add_item(new ActionItem().set_text("Japan").set_data("JP"));
		add_item(new ActionItem().set_text("Jersey").set_data("JE"));
		add_item(new ActionItem().set_text("Jordan").set_data("JO"));
		add_item(new ActionItem().set_text("Kazakhstan").set_data("KZ"));
		add_item(new ActionItem().set_text("Kenya").set_data("KE"));
		add_item(new ActionItem().set_text("Kiribati").set_data("KI"));
		add_item(new ActionItem().set_text("Korea, Democratic People's Republic of").set_data("KP"));
		add_item(new ActionItem().set_text("Korea, Republic of").set_data("KR"));
		add_item(new ActionItem().set_text("Kuwait").set_data("KW"));
		add_item(new ActionItem().set_text("Kyrgyzstan").set_data("KG"));
		add_item(new ActionItem().set_text("Lao People's Democratic Republic").set_data("LA"));
		add_item(new ActionItem().set_text("Latvia").set_data("LV"));
		add_item(new ActionItem().set_text("Lebanon").set_data("LB"));
		add_item(new ActionItem().set_text("Lesotho").set_data("LS"));
		add_item(new ActionItem().set_text("Liberia").set_data("LR"));
		add_item(new ActionItem().set_text("Libyan Arab Jamahiriya").set_data("LY"));
		add_item(new ActionItem().set_text("Liechtenstein").set_data("LI"));
		add_item(new ActionItem().set_text("Lithuania").set_data("LT"));
		add_item(new ActionItem().set_text("Luxembourg").set_data("LU"));
		add_item(new ActionItem().set_text("Macao").set_data("MO"));
		add_item(new ActionItem().set_text("Macedonia, The Former Yugoslav Republic of").set_data("MK"));
		add_item(new ActionItem().set_text("Madagascar").set_data("MG"));
		add_item(new ActionItem().set_text("Malawi").set_data("MW"));
		add_item(new ActionItem().set_text("Malaysia").set_data("MY"));
		add_item(new ActionItem().set_text("Maldives").set_data("MV"));
		add_item(new ActionItem().set_text("Mali").set_data("ML"));
		add_item(new ActionItem().set_text("Malta").set_data("MT"));
		add_item(new ActionItem().set_text("Marshall Islands").set_data("MH"));
		add_item(new ActionItem().set_text("Martinique").set_data("MQ"));
		add_item(new ActionItem().set_text("Mauritania").set_data("MR"));
		add_item(new ActionItem().set_text("Mauritius").set_data("MU"));
		add_item(new ActionItem().set_text("Mayotte").set_data("YT"));
		add_item(new ActionItem().set_text("Mexico").set_data("MX"));
		add_item(new ActionItem().set_text("Micronesia, Federated States of").set_data("FM"));
		add_item(new ActionItem().set_text("Moldova, Republic of").set_data("MD"));
		add_item(new ActionItem().set_text("Monaco").set_data("MC"));
		add_item(new ActionItem().set_text("Mongolia").set_data("MN"));
		add_item(new ActionItem().set_text("Montenegro").set_data("ME"));
		add_item(new ActionItem().set_text("Montserrat").set_data("MS"));
		add_item(new ActionItem().set_text("Morocco").set_data("MA"));
		add_item(new ActionItem().set_text("Mozambique").set_data("MZ"));
		add_item(new ActionItem().set_text("Myanmar").set_data("MM"));
		add_item(new ActionItem().set_text("Namibia").set_data("NA"));
		add_item(new ActionItem().set_text("Nauru").set_data("NR"));
		add_item(new ActionItem().set_text("Nepal").set_data("NP"));
		add_item(new ActionItem().set_text("Netherlands").set_data("NL"));
		add_item(new ActionItem().set_text("Netherlands Antilles").set_data("AN"));
		add_item(new ActionItem().set_text("New Caledonia").set_data("NC"));
		add_item(new ActionItem().set_text("New Zealand").set_data("NZ"));
		add_item(new ActionItem().set_text("Nicaragua").set_data("NI"));
		add_item(new ActionItem().set_text("Niger").set_data("NE"));
		add_item(new ActionItem().set_text("Nigeria").set_data("NG"));
		add_item(new ActionItem().set_text("Niue").set_data("NU"));
		add_item(new ActionItem().set_text("Norfolk Island").set_data("NF"));
		add_item(new ActionItem().set_text("Northern Mariana Islands").set_data("MP"));
		add_item(new ActionItem().set_text("Norway").set_data("NO"));
		add_item(new ActionItem().set_text("Oman").set_data("OM"));
		add_item(new ActionItem().set_text("Pakistan").set_data("PK"));
		add_item(new ActionItem().set_text("Palau").set_data("PW"));
		add_item(new ActionItem().set_text("Palestinian Territory, Occupied").set_data("PS"));
		add_item(new ActionItem().set_text("Panama").set_data("PA"));
		add_item(new ActionItem().set_text("Papua New Guinea").set_data("PG"));
		add_item(new ActionItem().set_text("Paraguay").set_data("PY"));
		add_item(new ActionItem().set_text("Peru").set_data("PE"));
		add_item(new ActionItem().set_text("Philippines").set_data("PH"));
		add_item(new ActionItem().set_text("Pitcairn").set_data("PN"));
		add_item(new ActionItem().set_text("Poland").set_data("PL"));
		add_item(new ActionItem().set_text("Portugal").set_data("PT"));
		add_item(new ActionItem().set_text("Puerto Rico").set_data("PR"));
		add_item(new ActionItem().set_text("Qatar").set_data("QA"));
		add_item(new ActionItem().set_text("Reunion").set_data("RE"));
		add_item(new ActionItem().set_text("Romania").set_data("RO"));
		add_item(new ActionItem().set_text("Russian Federation").set_data("RU"));
		add_item(new ActionItem().set_text("Rwanda").set_data("RW"));
		add_item(new ActionItem().set_text("Saint Helena").set_data("SH"));
		add_item(new ActionItem().set_text("Saint Kitts and Nevis").set_data("KN"));
		add_item(new ActionItem().set_text("Saint Lucia").set_data("LC"));
		add_item(new ActionItem().set_text("Saint Pierre and Miquelon").set_data("PM"));
		add_item(new ActionItem().set_text("Saint Vincent and The Grenadines").set_data("VC"));
		add_item(new ActionItem().set_text("Samoa").set_data("WS"));
		add_item(new ActionItem().set_text("San Marino").set_data("SM"));
		add_item(new ActionItem().set_text("Sao Tome and Principe").set_data("ST"));
		add_item(new ActionItem().set_text("Saudi Arabia").set_data("SA"));
		add_item(new ActionItem().set_text("Senegal").set_data("SN"));
		add_item(new ActionItem().set_text("Serbia").set_data("RS"));
		add_item(new ActionItem().set_text("Seychelles").set_data("SC"));
		add_item(new ActionItem().set_text("Sierra Leone").set_data("SL"));
		add_item(new ActionItem().set_text("Singapore").set_data("SG"));
		add_item(new ActionItem().set_text("Slovakia").set_data("SK"));
		add_item(new ActionItem().set_text("Slovenia").set_data("SI"));
		add_item(new ActionItem().set_text("Solomon Islands").set_data("SB"));
		add_item(new ActionItem().set_text("Somalia").set_data("SO"));
		add_item(new ActionItem().set_text("South Africa").set_data("ZA"));
		add_item(new ActionItem().set_text("South Georgia and The South Sandwich Islands").set_data("GS"));
		add_item(new ActionItem().set_text("Spain").set_data("ES"));
		add_item(new ActionItem().set_text("Sri Lanka").set_data("LK"));
		add_item(new ActionItem().set_text("Sudan").set_data("SD"));
		add_item(new ActionItem().set_text("Suriname").set_data("SR"));
		add_item(new ActionItem().set_text("Svalbard and Jan Mayen").set_data("SJ"));
		add_item(new ActionItem().set_text("Swaziland").set_data("SZ"));
		add_item(new ActionItem().set_text("Sweden").set_data("SE"));
		add_item(new ActionItem().set_text("Switzerland").set_data("CH"));
		add_item(new ActionItem().set_text("Syrian Arab Republic").set_data("SY"));
		add_item(new ActionItem().set_text("Taiwan, Province of China").set_data("TW"));
		add_item(new ActionItem().set_text("Tajikistan").set_data("TJ"));
		add_item(new ActionItem().set_text("Tanzania, United Republic of").set_data("TZ"));
		add_item(new ActionItem().set_text("Thailand").set_data("TH"));
		add_item(new ActionItem().set_text("Timor-leste").set_data("TL"));
		add_item(new ActionItem().set_text("Togo").set_data("TG"));
		add_item(new ActionItem().set_text("Tokelau").set_data("TK"));
		add_item(new ActionItem().set_text("Tonga").set_data("TO"));
		add_item(new ActionItem().set_text("Trinidad and Tobago").set_data("TT"));
		add_item(new ActionItem().set_text("Tunisia").set_data("TN"));
		add_item(new ActionItem().set_text("Turkey").set_data("TR"));
		add_item(new ActionItem().set_text("Turkmenistan").set_data("TM"));
		add_item(new ActionItem().set_text("Turks and Caicos Islands").set_data("TC"));
		add_item(new ActionItem().set_text("Tuvalu").set_data("TV"));
		add_item(new ActionItem().set_text("Uganda").set_data("UG"));
		add_item(new ActionItem().set_text("Ukraine").set_data("UA"));
		add_item(new ActionItem().set_text("United Arab Emirates").set_data("AE"));
		add_item(new ActionItem().set_text("United Kingdom").set_data("GB"));
		add_item(new ActionItem().set_text("United States").set_data("US"));
		add_item(new ActionItem().set_text("United States Minor Outlying Islands").set_data("UM"));
		add_item(new ActionItem().set_text("Uruguay").set_data("UY"));
		add_item(new ActionItem().set_text("Uzbekistan").set_data("UZ"));
		add_item(new ActionItem().set_text("Vanuatu").set_data("VU"));
		add_item(new ActionItem().set_text("Venezuela").set_data("VE"));
		add_item(new ActionItem().set_text("Viet Nam").set_data("VN"));
		add_item(new ActionItem().set_text("Virgin Islands, British").set_data("VG"));
		add_item(new ActionItem().set_text("Virgin Islands, U.S.").set_data("VI"));
		add_item(new ActionItem().set_text("Wallis and Futuna").set_data("WF"));
		add_item(new ActionItem().set_text("Western Sahara").set_data("EH"));
		add_item(new ActionItem().set_text("Yemen").set_data("YE"));
		add_item(new ActionItem().set_text("Zambia").set_data("ZM"));
		add_item(new ActionItem().set_text("Zimbabwe").set_data("ZW"));
	}
}
