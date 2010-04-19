package com.amberalert.desktop.controllers
{
	public class PhoneFormatter
	{
		// Fun fun data //
		private var i1:int;
		private var numNums:int;
		private var inNums:String;
		
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
		public function PhoneFormatter(inPhone:String):String
		{
			var retString:String = "";
			numNums = 0;
			inNums = "";
			
			for(i1 = 0; i1 < inPhone.length; i1++)
			{
				if(inPhone.charAt(i1) >= '0' && inPhone.charAt(i1) <= '9')
				{
					numNums++;
					inNums += inPhone.charAt(i1);
				}
			}
			
			if(numNums == 7)
				return "Area Code Required";
				
			if(numNums != 10)
				return "Invalid Phone Number";
			
			retString += '(';
			for(i1 = 0; i1 < 3; i1++)
				retString += inPhone.charAt(i1);
			retString += ")-";
			
			for(i1 = 3; i1 < 6; i1++)
				retSring += inPhone.charAt(i1);
			retString += '-';
			
			for(i1 = 6; i1 < 10; i1++)
				retString += inPhone.charAt(i1);
			
			return retString;
		}
	}
}