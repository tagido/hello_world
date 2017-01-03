#
# mp3_to_mp4.rb
#
# Creates an mp4 video with the given mp3 audio file and an image
# Video duration is set to the mp3 duration
#

def get_mp3_duration file

	file_info = `\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{file}\" 2>&1`

	#puts "file info=#{file_info}"
	
	duration = file_info.scan(/..:..:..\.../)
	
	#puts "MP3 duration=#{duration}"
	
	return duration[0]
end

FFMPEG_PATH="D:\\Program Files (x86)\\FFmpeg for Audacity\\"
EAC3TO_PATH="D:\\Program Files (x86)\\eac3to331\\"
TARGET_PATH=".\\"
#IMAGE_PATH="\"d:\\Mais imagens\\Cartazes\\DJ Estaline\\Caixode do lixo.jpg\""
IMAGE_PATH=".\\Mito_Duplo_Radio_Full_HD_v2.jpg"
MP3_PATH = ARGV[0]

puts "mp3_to_mp4.rb - Creates an mp4 video with the given mp3 audio file and an image"
puts "-------------"

puts "mp3=#{MP3_PATH}"

if MP3_PATH

	MP4_PATH = "#{MP3_PATH}.mp4"

	puts "mp4=#{MP4_PATH}"
	
	mp3_duration = get_mp3_duration MP3_PATH
	
	puts "MP3 duration=#{mp3_duration}"

    puts "Converting...\n\n"	
	
	system "\"#{FFMPEG_PATH}ffmpeg.exe\" -loop 1 -i #{IMAGE_PATH} -i \"#{MP3_PATH}\" -t #{mp3_duration} -pix_fmt yuv420p \"#{MP4_PATH}\""
else

	puts "Invalid args"
end