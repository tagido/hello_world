#
# dvd_info.rb
#
#
require 'ostruct'

origin = OpenStruct.new
origin.x = 0
origin.y = 0

# Wait for the spacebar key to be pressed
def wait_for_spacebar
   print "Press space to continue ...\n"
   sleep 1 while $stdin.getc != " "
end


def get_DVD_MediaInfo

	result = system "\"#{DVD_MEDIA_INFO_PATH}dvd+rw-mediainfo.exe\" \\\\.\\e: > #{TARGET_PATH}\\dvd_info.media_info.txt"

	if (result == false) 
		print "#### Could not read DVD structure, exiting ... \n"
		exit
	end	

	stats_raw = `type #{TARGET_PATH}\\dvd_info.media_info.txt`

	print stats_raw

	mediainfo = OpenStruct.new
	
	mediainfo.n_sessions = stats_raw.scan(/Number of Sessions:    ([0-9]+)/)[0][0]
	mediainfo.disc_status = stats_raw.scan(/Disc status:           (.+)/)[0][0]
	
	print "\n\nN_sessions = #{mediainfo.n_sessions}\n"
	print "disc status = #{mediainfo.disc_status}\n"
	
	print "===============================\n\n"
	
	return stats_raw
 
end


def conv_hhmmss_to_seconds time_string

 seconds = "#{time_string}".split(':').map { |a| a.to_i }.inject(0) { |a, b| a * 60 + b}

 return seconds
 
end


def extract_raw_data_from_track2


   dvd_stream_command = "\"#{DD_PATH}dd.exe\" bs=2048 skip=15888 if=\\\\.\\#{DVD_PATH}"
   
   conv_command = dvd_stream_command + "> #{TARGET_PATH}\\dvd_vr.busto.raw\""

   puts "#{conv_command}\n"
   puts "Running RAW extraction for DVD ...\n"
   system "#{conv_command}\n"
   
end

def extract_files_from_raw_data

	current_block_index = 0

    #open("#{TARGET_PATH}\\vob_block.raw", 'rb') do |f|
	open("#{TARGET_PATH}\\dvd_vr.busto.raw", 'rb') do |f|
	
	#and current_block_index < 1000000
	  
	  while (block=f.read(2048) )
	  
		
			
		r = Regexp.new("(\x00\x00\x01\xba|\x00\x00\x01\xbb|\x00\x00\x01\xb9|DVDVIDEO-VMG|DVDVIDEO-VTS|NSR02|DVDVRMANAGER|DVDAUTH-INFO)".force_encoding("binary"), Regexp::FIXEDENCODING)
		
		signatures = block.scan( r )
		
		#puts "#{current_block_index}: #{current_block_index*2048}..#{(current_block_index+1)*2048}..  signatures=#{signatures}"
		
		if (!signatures.nil? and signatures.length>0 )
			#puts("Found signatures at block #{current_block_index}\n")
			puts "#{current_block_index}: #{current_block_index*2048}..#{(current_block_index+1)*2048}..  signatures=#{signatures}"
		end
		
		current_block_index = current_block_index + 1
	  end
	  
	  
	  
	end
	
end

# MPG, VOB DVD Video Movie File (video/dvd, video/mpeg) or DVD MPEG2
# 
# Header:
# 
# 00 00 01 BA 	  
# 
# Trailer:
# 00 00 01 B9 


FFMPEG_PATH="D:\\Program Files (x86)\\FFmpeg for Audacity\\"
HANDBRAKECLI_PATH="D:\\Program Files\\Handbrake\\"
DD_PATH="D:\\Downloads\\dd-0.6beta3\\"
DVD_MEDIA_INFO_PATH="D:\\Downloads\\dd-0.6beta3\\"

DVD_PATH="E:"

#DVD_PATH="\"H:\\DVDs Musicais\\Tony Carreira\\\""
#DVD_PATH="\"H:\\DVDs Musicais\\FengShui\\\""
#DVD_PATH="H:.\\"

DVD_VOB_PATH="#{DVD_PATH}VIDEO_TS\\"
#DVD_VOB_CONCAT_LIST="#{DVD_VOB_PATH}VTS_01_0.VOB\|#{DVD_VOB_PATH}VTS_01_1.VOB\|#{DVD_VOB_PATH}VTS_01_2.VOB\|#{DVD_VOB_PATH}VTS_01_3.VOB\|#{DVD_VOB_PATH}VTS_01_4.VOB"

time = Time.now.getutc
time2 = time.to_s.delete ': '


#TARGET_PATH="G:\\temp\\dvd_info\\dvd_vr.files.#{time2}"

TARGET_PATH="G:\\temp\\dvd_info\\dvd_vr.files"


print "mkdir \"#{TARGET_PATH}\""

system "mkdir \"#{TARGET_PATH}\""


TARGET_FILENAME="DVD - Track "
DVD_AUDIO_STREAM_INDEX="4"

PAUSE=false


puts "dvd_vr_extract_files.rb - Gets info from unfinalized DVDs\n"
puts "-------------\n\n"
puts "Reading DVD structure ...\n\n"

#get_DVD_MediaInfo
#extract_raw_data_from_track2
extract_files_from_raw_data

# TODO: ver automaticamente se é um DVD-VR não finalizado
# TODO: mostrar espaço livre e ocupado
# TODO: mostrar tempo estimado de vídeo no DVD
