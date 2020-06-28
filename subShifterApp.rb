class SubShifterApp
	require_relative 'SubShifter'
	def self.main
		if ARGV.length < 2
			raise "Fewer number of arguments\n\n\ntry --> ruby sub_shifter.rb left \"99,244\"\n\n\n"
		else
			puts "\n\n======== SUBTILE SHIFTER =========\n"
			time_shift = Hash.new
			time_shift[:second] = ARGV[1].scan(/\d+/).map(& :to_i)[0]
			time_shift[:milli_second] = ARGV[1].scan(/\d+/).map(& :to_i)[1]
			begin
				filename = "gg.srt"
				File.open(filename,"r")
			rescue Exception => e
				puts e
				exit
			end
			s = SubShifter.new(ARGV[0], time_shift, filename)
			s.shift
			puts "\n-------- SHIFT SUCCESSFUL --------\n"
			puts "Your subtitle file '#{filename}'' is shifted #{ARGV[0]} by #{time_shift[:second]} seconds and #{time_shift[:milli_second]} milliseconds\n and generated as 'output.srt' file"
			puts "\n----------------------------------\n\n"
		end
	end
end

SubShifterApp.main
