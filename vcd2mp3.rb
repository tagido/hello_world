#
# vcd2mp3.rb
#
#


FFMPEG_PATH="D:\\Program Files (x86)\\FFmpeg for Audacity\\"
EAC3TO_PATH="D:\\Program Files (x86)\\eac3to331\\"
BLURAY_PATH="G:."
TARGET_PATH="G:.\\"
SOURCE_DRIVE=ARGV[0]
TARGET_FILENAME=ARGV[1]


# isrc cn-d15-02-394-00/V.J6
# API KEY: Nv6VchT2Zo

puts "vcd2mp3.rb - Converts a VCD to mp3 (audio only)"
puts "-------------\n\n"

MPEG1_FILES= `dir #{SOURCE_DRIVE}\\MPEGAV\\AVSEQ??.DAT\ /b /s`


#system "\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{SOURCE_DRIVE}\\MPEGAV\\AVSEQ01.DAT\"  -codec:a libmp3lame -qscale:a 2 \"#{TARGET_FILENAME}\".vcd.mp3"

caps = MPEG1_FILES.scan(/AVSEQ../)

puts "Found files:\n #{caps} \n\n"

track_no = 1

caps.each do |i|
   #puts "Value of local variable is #{start_str} .. #{i}"

   system "\"#{FFMPEG_PATH}ffmpeg.exe\" -i \"#{SOURCE_DRIVE}\\MPEGAV\\#{i}.DAT\" -metadata track=\"#{track_no}\"  -codec:a libmp3lame -qscale:a 2 \"#{TARGET_FILENAME}\".vcd.#{track_no}.mp3"
   
   track_no = track_no + 1
end
