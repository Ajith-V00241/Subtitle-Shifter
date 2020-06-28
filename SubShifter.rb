# SubShifter class
class SubShifter

	def initialize(option, time_shift_hash, filename)
		@option = option
		@shift_time = time_shift_hash[:second] + time_shift_hash[:milli_second]*0.001
		@filename = filename
	end

	def shift
		puts "     Shifter time( in seconds): #{@shift_time}"
		begin
			File.open("Output.srt", "w") { |newfile| 
				File.foreach(@filename) { |line|
					if !line.include?"-->"
						newfile.puts line
					else
						# BEFORE SHIFT
						start_time = instantiate_time(line.scan(/\d{2}[:]\d{2}[:]\d{2}[,]\d{3}/)[0])
						end_time = instantiate_time(line.scan(/\d{2}[:]\d{2}[:]\d{2}[,]\d{3}/)[1])

						# AFTER SHIFT
						if(@option == "right") #Right Shifting
							start_time_string = frame_time_string(correct_nsec(start_time + @shift_time))
							end_time_string = frame_time_string(correct_nsec(end_time + @shift_time))
						elsif(@option == "left") #Left Shifting
							start_time_string = check_and_frame_time_left(start_time, @shift_time)
							end_time_string = check_and_frame_time_left(end_time, @shift_time)
							
						end
						newfile.puts start_time_string + " --> " + end_time_string + "\n"
					end
				}
			}
		rescue Exception => e
			puts e.message
			exit
		end
	end

	private
	#instantiate time from given string 
	def instantiate_time(time)
		hour = time.scan(/\d{2}/).map(& :to_i)[0]
		min = time.scan(/\d{2}/).map(& :to_i)[1]					
		sec = time.scan(/\d{2}/).map(& :to_i)[2]
		msec = time.scan(/\d{3}/).map(& :to_i)[0]
		
		correct_nsec(Time.new(2020, 1, 1, hour, min, sec, "+00:00")+msec*0.001)
	end

	# checks if each shifted time goes beyond start and frame resulting time as string
	def check_and_frame_time_left(time, shift_time)
		if(time.hour==0 && time.min==0)
			if(time.sec + time.nsec*0.000000001) < shift_time #block for shifted time which goes beyond start
				@modified_shift_time = -(time-(Time.new(2020,1,1,0,0,0,"+00:00")+shift_time))
				frame_time_string(Time.new(2020,1,1,0,0,0,"+00:00") + @modified_shift_time, true)
			else
				frame_time_string(correct_nsec(time - shift_time))
			end
		else
			frame_time_string(correct_nsec(time - shift_time))
		end
	end

	#approximation of time in nano seconds
	def correct_nsec(time)
		if time.nsec%1000000 == 999999
			time = time + 0.000000001
		end
		time
	end

	#Formatting of time to be printed as String
	def correct_digit(digit, is_milli_second=false)
		str=""
		if !is_milli_second
			if digit < 10
				str = str + "0"
			end
			str = str + digit.to_s
		else
			if digit < 10
				str = str + "00"
			elsif digit < 100
				str = str + "0"
			end
			str = str + digit.to_s
		end
		str
	end

	#printing of time as String
	def frame_time_string(time, negative_time=false)
		if negative_time
			"-" + correct_digit(time.hour) + ":" + correct_digit(time.min) + ":" + correct_digit(time.sec) + "," + correct_digit(((time.nsec)*0.000001).to_i, true)
		else
			correct_digit(time.hour) + ":" + correct_digit(time.min) + ":" + correct_digit(time.sec) + "," + correct_digit(((time.nsec)*0.000001).to_i, true)
		end
	end

end