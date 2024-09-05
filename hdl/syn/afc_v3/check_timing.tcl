set wns [get_property STATS.WNS [get_runs impl_1]]
set whs [get_property STATS.WHS [get_runs impl_1]]

puts "WNS: ${wns}"
puts "WHS: ${whs}"

if {($wns < 0) || ($whs < 0)} {
	puts "Failed timing!"
	exit 1
} else {
	puts "Passed timing."
	exit 0
}
