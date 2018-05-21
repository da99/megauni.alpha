	function format_publish_date (ele) { 
		var dt = new Date();
		dt.setTime(Date.parse(ele));
	    return dt.toLocaleString().replace(/\:00 /,' ');
	}; // end function set_heart_link_datetime
	
	// From: http://www.permadi.com/tutorial/urlEncoding/
	function URLencode(inputString) {
      var encodedInputString=escape(inputString);
      encodedInputString=encodedInputString.replace("+", "%2B");
      encodedInputString=encodedInputString.replace("/", "%2F"); 
      encodedInputString=encodedInputString.replace("%20", "+"); 
      return encodedInputString;
	} // end function URLencode
	
