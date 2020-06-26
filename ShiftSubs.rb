
def getInputTime
	puts "-----------------------------------"
	puts "Enter the shift time:(in sec or in msec):"
	time={}
	input_flag = true
	while input_flag 
		intime = gets.chomp

		if  (intime.include?"sec") && (intime.include?"msec") &&(intime.scan(/(?=sec)/).count == 2)
			time[:sec] = intime.scan(/\d+/).map(& :to_i)[0]
			time[:msec] = intime.scan(/\d+/).map(& :to_i)[1]
			input_flag = false
		elsif (intime.include?"sec") && (!intime.include?"msec") 
			time[:sec] = intime.scan(/\d+/).map(& :to_i)[0]
			time[:msec] = 0
			input_flag = false
		elsif intime.include?"msec"
			time[:msec] = intime.scan(/\d+/).map(& :to_i)[0]
			time[:sec] = 0
			input_flag = false
		else 
			puts "Enter the time in anyone below formats \n'10sec'\n '50msec' \n'10sec 50msec'"
		end
	end
	return time
end



def subtract_and_validate_time_left(t1,t2)
	time = t1[:msec] + (t1[:sec] + ( t1[:min] + t1[:hours]*60 ) *60) *1000
	subtr_time = t2[:msec] + t2[:sec]*1000
	time = time - subtr_time

	ans={}
	if time >=0
		ans[:sign] = '+'
		ans[:hours] = time/(60*60*1000)
		time = time % (60*60*1000)

		ans[:min] = time/(60*1000)
		time = time % (60*1000)

		ans[:sec] = time/(1000)
		ans[:msec] = time % 1000
	else
		ans[:sign] = '-'
		time = -time
		ans[:hours] = time/(60*60*1000)
		time = time % (60*60*1000)

		ans[:min] = time/(60*1000)
		time = time % (60*1000)

		ans[:sec] = time/(1000)
		ans[:msec] = time % 1000
	end
	return ans
end



def validate_time_right(timehash)
	if timehash[:msec] >=1000 
		timehash[:sec] += timehash[:msec]/1000
		timehash[:msec] = timehash[:msec]%1000
	end
	if timehash[:sec] >=60
		timehash[:min] += timehash[:sec]/60
		timehash[:sec] = timehash[:sec]%60
	end
	if timehash[:min] >=60
		timehash[:hours] += timehash[:min]/60
		timehash[:min] = timehash[:min]%60
	end
	return timehash
end




def build_time_string(timehash)
	str=""
	if(timehash[:sign]=='-')
		str = str + '-'
	end
	if timehash[:hours]<10 
		str = str +"0"
	end
	str = str +timehash[:hours].to_s+":"

	if timehash[:min]<10 
		str = str +"0"
	end
	str = str +timehash[:min].to_s+":"

	if timehash[:sec]<10 
		str = str +"0"
	end
	str = str +timehash[:sec].to_s+","

	case timehash[:msec].to_s.length
	when 1
		str = str +"00"
	when 2
		str = str +"0"
	else
	end
	str = str + timehash[:msec].to_s

	return str
end	

def shiftLeft(filename)
	time=getInputTime
	File.open("Output.srt","w") { |newfile|
		File.foreach(filename){ |line|
			times={}
			start_time={}
			end_time={}
			if line.include?"-->"
				times[:start_time] = line.scan(/\d{2}[:]\d{2}[:]\d{2}[,]\d{3}/)[0]
				start_time[:hours] = times[:start_time].split(',')[0].split(':')[0].to_i
				start_time[:min] = times[:start_time].split(',')[0].split(':')[1].to_i
				start_time[:sec] = times[:start_time].split(',')[0].split(':')[2].to_i
				start_time[:msec] = times[:start_time].split(',')[1].to_i


				times[:end_time] = line.scan(/\d{2}[:]\d{2}[:]\d{2}[,]\d{3}/)[1]
				end_time[:hours] = times[:end_time].split(',')[0].split(':')[0].to_i
				end_time[:min] = times[:end_time].split(',')[0].split(':')[1].to_i
				end_time[:sec] = times[:end_time].split(',')[0].split(':')[2].to_i
				end_time[:msec] = times[:end_time].split(',')[1].to_i

				start_time = subtract_and_validate_time_left(start_time, time)
				end_time = subtract_and_validate_time_left(end_time, time)

				start_string = build_time_string(start_time)
				end_string = build_time_string(end_time)
				
				newfile.puts ""+start_string+" --> "+end_string
			else
				newfile.puts line
			end
		}
	}
	


end

def shiftRight(filename)
	time=getInputTime
	File.open("Output.srt","w") { |newfile|
		File.foreach(filename){ |line|
			times={}
			start_time={}
			end_time={}
			if line.include?"-->"
				times[:start_time] = line.scan(/\d{2}[:]\d{2}[:]\d{2}[,]\d{3}/)[0]

				start_time[:hours] = times[:start_time].split(',')[0].split(':')[0].to_i
				start_time[:min] = times[:start_time].split(',')[0].split(':')[1].to_i
				start_time[:sec] = times[:start_time].split(',')[0].split(':')[2].to_i
				start_time[:msec] = times[:start_time].split(',')[1].to_i


				times[:end_time] = line.scan(/\d{2}[:]\d{2}[:]\d{2}[,]\d{3}/)[1]

				end_time[:hours] = times[:end_time].split(',')[0].split(':')[0].to_i
				end_time[:min] = times[:end_time].split(',')[0].split(':')[1].to_i
				end_time[:sec] = times[:end_time].split(',')[0].split(':')[2].to_i
				end_time[:msec] = times[:end_time].split(',')[1].to_i


				start_time[:sec] += time[:sec]
				start_time[:msec] += time[:msec]	

				end_time[:sec] += time[:sec]		
				end_time[:msec] += time[:msec]
				
				start_time = validate_time_right(start_time)
				end_time = validate_time_right(end_time)

				start_string = build_time_string(start_time)
				end_string = build_time_string(end_time)


				newfile.puts ""+start_string+" --> "+end_string
			else
				newfile.puts line
			end
		}
	}
end








filename="gg.srt"

puts "----------SUBTITLE SHIFTER----------"

if File.exists?(filename)
	loop_flag=true
	while loop_flag
		puts "Type your shift choice:('left' or 'right')"
		choice = gets.chomp
		choice.downcase!
		case choice
		when "left"
			loop_flag=false
			shiftLeft(filename)
			puts "-----------------------------"
			puts "sucessfull Shifted left "
		when "right"
			loop_flag=false
			shiftRight(filename)
			puts "-----------------------------"
			puts "sucessfull Shifted right "
		else 
			puts "Choice in invalid"
		end
	end
else
	puts "File does not exists\nTerminating program"
end

