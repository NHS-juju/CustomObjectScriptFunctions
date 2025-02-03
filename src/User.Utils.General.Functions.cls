/// Class of custom functions
Class User.Utils.General.Functions Extends Ens.Rule.FunctionSet
{

/*____        _                 _              _   _____ _                     
 |  _ \  __ _| |_ ___  ___     / \   _ __   __| | |_   _(_)_ __ ___   ___  ___ 
 | | | |/ _` | __/ _ \/ __|   / _ \ | '_ \ / _` |   | | | | '_ ` _ \ / _ \/ __|
 | |_| | (_| | ||  __/\__ \  / ___ \| | | | (_| |   | | | | | | | | |  __/\__ \
 |____/ \__,_|\__\___||___/ /_/   \_\_| |_|\__,_|   |_| |_|_| |_| |_|\___||___/
*/
/// Returns patient age in years when provided a date of birth in horolog/internal format. Returns 0 if less than a year old.
ClassMethod AgeInYears(DOB As %Integer) As %Integer
{
    Quit $SELECT(DOB="":"",1:($ZDATE($HOROLOG,8)-$ZDATE(DOB,8)\10000))
}

/// Returns patient age when provided a date of birth in horolog/internal format.
ClassMethod AgeInDays(DOB As %Integer) As %Integer
{
    Quit $HOROLOG-DOB
}

/// Returns patient age in a textual foramt when provided a date of birth in horolog/internal format.
ClassMethod AgeAsString(DOB As %Integer) As %Integer
{
    Set Age = ..AgeInYears(DOB)
    If Age = 0 {
        Set Age = ..AgeInDays(DOB)
        If (Age = 1) {Set Period = "day"} Else {Set Period = "days"}
    }
    Else{
        If (Age = 1) {Set Period = "year"} Else {Set Period = "years"}
    }
    Quit Age_" "_Period_" old."
}

/// Returns the day in the week,
/// where:
/// <ul><li>0 is Sunday</li>
/// <li>1 is Monday</li>
/// <li>2 is Tuesday</li>
/// <li>3 is Wednesday</li>
/// <li>4 is Thursday</li>
/// <li>5 is Friday</li>
/// <li>6 is Saturday</li></ul>
ClassMethod DayOfWeek() As %Integer [ CodeMode = expression, Final ]
{
$ZDATE($HOROLOG,10)
}

ClassMethod IsDayWeekend() As %Boolean
{
	Set dayofweek=..DayOfWeek()
	If dayofweek'=0,dayofweek'=6 Quit 0
	Quit 1
}

ClassMethod IsDaySunday() As %Boolean
{
	If ..DayOfWeek()=0 Quit 1
	Quit 0
}

ClassMethod IsDayMonday() As %Boolean
{
	If ..DayOfWeek()=1 Quit 1
	Quit 0
}

ClassMethod IsDayTuesday() As %Boolean
{
	If ..DayOfWeek()=2 Quit 1
	Quit 0
}

ClassMethod IsDayWednesday() As %Boolean
{
	If ..DayOfWeek()=3 Quit 1
	Quit 0
}

ClassMethod IsDayThursday() As %Boolean
{
	If ..DayOfWeek()=4 Quit 1
	Quit 0
}

ClassMethod IsDayFriday() As %Boolean
{
	If ..DayOfWeek()=5 Quit 1
	Quit 0
}

ClassMethod IsDaySaturday() As %Boolean
{
	If ..DayOfWeek()=6 Quit 1
	Quit 0
}

/// Check time is between 9 am and 5 pm
/// <Example>
/// ..IsInTimePeriod("09:00","17:00")
/// </Example>
/// Check time is outside of 9am to 5pm
/// <Example>
/// ..IsInTimePeriod("17:00","09:00")
/// </Example>
ClassMethod IsInTimePeriod(startTime = "00:00", endTime = "23:59")
{
	If startTime'?2N1":"2N Quit 0
	If endTime'?2N1":"2N Quit 0
	Set startTime=$ZTIMEH(startTime)
	Set endTime=$ZTIMEH(endTime)
	Set now=$PIECE($HOROLOG,",",2)
	If (startTime>endTime) {
		If now<=startTime,now>=endTime Quit 0
		Quit 1
	} Else {
		If now>=startTime,now<=endTime Quit 1
	}
	Quit 0
}

/*____            _                 
 / ___| _   _ ___| |_ ___ _ __ ___  
 \___ \| | | / __| __/ _ \ '_ ` _ \ 
  ___) | |_| \__ \ ||  __/ | | | | |
 |____/ \__, |___/\__\___|_| |_| |_|
        |___/                       
*/
/// Returns a simplified version of the system mode, and assumes Non Production Environment if not LIVE or FAILOVER.
ClassMethod WhatEnvAmI()
{
	Set Env = $SYSTEM.Version.SystemMode()
	If (Env = "LIVE")||(Env = "FAILOVER"){
		Quit "LIVE"
		}
	Quit "NPE"
}

/* ___  _   _               
  / _ \| |_| |__   ___ _ __ 
 | | | | __| '_ \ / _ \ '__|
 | |_| | |_| | | |  __/ |   
  \___/ \__|_| |_|\___|_|                          
*/
/// Method to process an array containing an address which is spread over 5 lines, and attempt to fit this into 4 lines for use with older systems that support 4 lines + postcode.
/// Final method is to simply delete the 5th line, which may not be appropriate for some use cases.
ClassMethod LegacyAddressLength(inAddress As %ArrayOfDataTypes, maxLineLength As %Integer = 35) As %ArrayOfDataTypes
{
    Set tmpAddress = inAddress.%ConstructClone(1)
    //Attempt 1 - Remove empty lines
    For i=1:1:5 {
        Set key = "Line"_i
        Set value=tmpAddress.GetAt(key)
        
        //Delete entries if the value is null
        If $LENGTH(value)=0{
            Do tmpAddress.RemoveAt(key)
        }
    }

    //Return the clean array if length is less than 5
    If tmpAddress.Count()<5{
        //Move to new Array
        Set arrCount = 1
        Set outAddress = ##Class(%ArrayOfDataTypes).%New()
        For i=1:1:5 {
            Set key = "Line"_i
            Set value=tmpAddress.GetAt(key)
            If $LENGTH(value)'=0{
                Do outAddress.SetAt(value,"Line"_arrCount)
                Do $INCREMENT(arrCount)
            } 
        }
        Quit outAddress
    }
    
    //Attempt 2 - Merge lines where possible
    For j=1:1:5 {
        Set key = "Line"_j
        Set value=tmpAddress.GetAt(key)

        If key = "Line1" {
            Set prevKey = key, PrevValue = value
        } 
        Else{
            //Only concat if we can fit both address lines + ", " into the 35 char limit
            Set pTotal = $LENGTH(value)+$LENGTH(PrevValue)
            If (pTotal <= maxLineLength-2){
                //Concat current line into previous and then delete the current line
                Set newStr = PrevValue_", "_value
                Do tmpAddress.SetAt(newStr,prevKey)
                Do tmpAddress.RemoveAt(key)
                Quit
            }
            Else{
                Set prevKey = key, PrevValue = value
            }
        }
    }
    //Move to new Array, removing the last line if there are too many lines
    Set outAddress = ##Class(%ArrayOfDataTypes).%New()
    
    Set key = ""
    Set arrCount = 1
    For k=1:1:5 {
        Set key = "Line"_k
        Set value=tmpAddress.GetAt(key)
        If $LENGTH(value)'=0{
            Do outAddress.SetAt(value,"Line"_arrCount)
            Do $INCREMENT(arrCount)
        }
    }

    If outAddress.Count()=5{
        Do outAddress.RemoveAt("Line5")
    }
    Quit outAddress
}

}
