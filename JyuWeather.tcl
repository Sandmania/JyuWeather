# The MIT License (MIT)
# 
# Copyright (c) 2013 Jouni Latvatalo
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Parses weather information from http://weather.jyu.fi/

set dir /home/users/sandman/tDOM/lib/tdom0.8.2
source [file join $dir pkgIndex.tcl]
package require tdom

namespace eval JyuWeather {

bind pub - !saa_test JyuWeather::get_weather_jyu

proc get_weather_jyu {} {
	putlog "[clock format [clock seconds] -format %Y-%m-%dT23:59:59%z]"
        set url http://weather.jyu.fi/
	catch {set token [::http::geturl $url -timeout 5000]} error
	putlog "error $error"

	putlog "token $token"


              if {[string match -nocase "*couldn't open socket*" $error]} {
                        ::http::cleanup $token
                        return "Socket error."
                }

                if { [::http::status $token] == "timeout" } {
                        ::http::cleanup $token
                        return "Connection timed out."
                }

                set data [::http::data $token]
                ::http::cleanup $token
                #putlog "data $data"

        set domTree [dom parse -keepEmpties -html $data]

        set root [$domTree documentElement]

	set timeAndDate [$root selectNode {//*[@id="c2"]/text()}]
	set outsideTemperature [$root selectNode {//*[@id="table-a"]/tbody/tr[1]/td[2]}]
	set windSpeed [$root selectNode {//*[@id="table-a"]/tbody/tr[3]/td[2]}]
	set windchill [$root selectNode {//*[@id="table-a"]/tbody/tr[4]/td[2]}]

	#putlog "root $root"

	#putlog "timeAndDate [$timeAndDate asText]"
	#putlog "outsideTemperature [$outsideTemperature asText]"
	#putlog "windSpeed [$windSpeed asText]"
	#putlog "windchill [$windchill asText]"

	set result "\002JYU\002 @ [$timeAndDate asText] \002temp:\002 [$outsideTemperature asText] \002wind speed:\002 [$windSpeed asText] \002wind chill:\002 [$windchill asText]"
	
        return $result

}


}

