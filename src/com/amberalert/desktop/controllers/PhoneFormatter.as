package com.amberalert.desktop.controllers
{
	import mx.utils.StringUtil;

	public class PhoneFormatter
	{
		// Fun fun data //
		private static var i1:int;
		private static var numNums:int;
		private static var inNums:String;
		
		/**
		 * PhoneFormatter
		 * 
		 * Function that inputs a phone number as a string then
		 * outputs the same phone number in a sepecific format.
		 * 
		 * @param retString:String
		 * @return String
		 * @author ASU Amber Alert Team
		 **/
		public static function format(inPhone:String):String
		{
			var retString:String = "";
			numNums = 0;
			inNums = "";
			if(inPhone != null)
			{
			for(i1 = 0; i1 < inPhone.length; i1++)
			{
				if(inPhone.charAt(i1) >= '0' && inPhone.charAt(i1) <= '9')
				{
					//trace('added num ' + inPhone.charAt(i1));
					numNums++;
					inNums += inPhone.charAt(i1);
				}
			}
			}
			if(numNums == 7)
				return "Area Code Required";
				
			if(numNums != 10)
				return "Invalid Phone Number";
			
			retString += '(';
			for(i1 = 0; i1 < 3; i1++)
				retString += inNums.charAt(i1);
			retString += ") ";
			
			for(i1 = 3; i1 < 6; i1++)
				retString += inNums.charAt(i1);
			retString += '-';
			
			for(i1 = 6; i1 < 10; i1++)
				retString += inNums.charAt(i1);
			
			return retString;
		}
		
		public static function strip(string:String):String
		{
			var pattern:RegExp = /\(|\)\s|\-/gixsm; 
			return string.replace(pattern, '');
		}
	}
}