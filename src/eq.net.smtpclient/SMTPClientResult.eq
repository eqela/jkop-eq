
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

public class SMTPClientResult
{
	public static SMTPClientResult for_success() {
		return(new SMTPClientResult());
	}

	public static SMTPClientResult for_message(SMTPMessage msg) {
		return(new SMTPClientResult().set_message(msg));
	}

	public static SMTPClientResult for_error(String error, SMTPMessage msg = null) {
		return(new SMTPClientResult().set_message(msg).add_transaction(
			SMTPClientTransactionResult.for_error(error)));
	}

	property SMTPMessage message;
	property Collection transactions;

	public bool get_status() {
		foreach(SMTPClientTransactionResult rr in transactions) {
			if(rr.get_status() == false) {
				return(false);
			}
		}
		return(true);
	}

	public SMTPClientResult add_transaction(SMTPClientTransactionResult r) {
		if(r == null) {
			return(this);
		}
		if(transactions == null) {
			transactions = LinkedList.create();
		}
		transactions.add(r);
		return(this);
	}
}
