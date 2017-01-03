#
# split_audio_by_track_list_file.rb
#
#


def convert_chapter start_time,end_time,file_index, track_name
	date=  "2006"
	genre= "R&B"

   #start_time = start_time - 0.25
   #end_time = end_time + 0.25

   if TARGET_FORMAT.eql? "mp3"
		codec_options = "-codec:a libmp3lame -qscale:a 2"
   else
		codec_options = ""
   end
   
   #metadata = "-metadata title=\"Track #{file_index}\" -metadata artist=\"#{artist}\" -metadata genre=\"#{genre}\" -metadata date=\"#{date}\" -metadata album=\"#{album}\" -metadata track=\"#{file_index}\""
   metadata = "-metadata title=\"#{track_name}\" -metadata track=\"#{file_index}\""
   
   conv_command = "\"#{FFMPEG_PATH}ffmpeg.exe\"  -i \"#{TARGET_FILENAME}\" -ss #{start_time} -to #{end_time} #{codec_options}  #{metadata} \"#{TARGET_FILENAME}\".split.#{file_index}.#{TARGET_FORMAT}"
   #puts "conv #{start_time} .. #{end_time} \n"
   puts "#{conv_command}\n"
   puts "Running conversion...\n"
   system "#{conv_command}\n"
end

def duration_to_seconds duration
	components = duration.split(':')
	
	return components[0].to_i * 60 + components[1].to_i
end

def parse_track_list tracks_text_file

  tracks_list = tracks_text_file.scan(/(.*)?( \t)([0-9]+\:[0-9][0-9])+/)

  print "tracks_list= #{tracks_list}\n\n"
  
  return tracks_list
end


FFMPEG_PATH="D:\\Program Files (x86)\\FFmpeg for Audacity\\"
EAC3TO_PATH="D:\\Program Files (x86)\\eac3to331\\"
TARGET_PATH="G:.\\"
TARGET_FILENAME=ARGV[0]
#TARGET_FORMAT="mp3"
TARGET_FORMAT="flac"
TRACKLIST_FILENAME="#{TARGET_FILENAME}.tracks.txt"

START_OFFSET = 0
SILENCE_BETWEEN_TRACKS = 2


#PREVIEW=true
PREVIEW=false



puts "split_audio_by_track_list_file.rb - Splits audio by track list"
puts "-------------\n\n"

stats_raw =  `type \"#{TRACKLIST_FILENAME}\"`

puts "Splitting...\n\n"

puts stats_raw

tracks = parse_track_list stats_raw

#silence_end_list = stats_raw.scan(/silence_end: -?([0-9]+\.[0-9])+/)
#silence_start_list = stats_raw.scan(/silence_start: -?([0-9]+\.[0-9])+/)

print "tracks= #{tracks}\n\n"

start_str = "0"
index = 1

next_position = START_OFFSET

tracks.each do |i|

   track_name = i[0]
  
   puts "Parsed track info  .. #{i[0]} - #{i[2]}"
   duration = duration_to_seconds i[2]
   
   end_position = duration + next_position
   
   puts "Track #{index} interval: #{next_position} .. #{end_position} (s) \t\t(duration=#{duration} s)"
   if (!PREVIEW && (duration > 0) )
		convert_chapter next_position  , end_position , index, track_name
   end
   
   next_position = end_position + SILENCE_BETWEEN_TRACKS
   index = index + 1;
end
