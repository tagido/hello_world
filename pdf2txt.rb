#
# process_downloads.rb
#
#

# Time functions

def get_current_time_str_for_filename

	time = Time.now.getutc
	time2 = time.to_s.delete ': '

	return time2
	
end



#
# File converters
#

def convert_number_locale_from_PT_to_US number_str
	
	if number_str.nil?
		return number_str
	end
	
	#puts "original: #{number_str}\n"
	
	number_str_without_commas = number_str.delete(".")
	
	number_str_without_commas.gsub! ',', '.' 
	
	#puts "conv'd: #{number_str_without_commas}\n"
	
	return number_str_without_commas
				
end

def cgd_csv_get_entries_with_fields_from_file cgd_csv_file

	entries =  `type \"#{cgd_csv_file}\"`
	
	#entry_list = entries.scan(/(..-..-....;..-..-....;.*;.*;.*;.*;.*/)
	#entry_list = entries.split(";")
	
	#\;(.*)\;(.*)\;(.*)\;(.*)\;(.*)
	
	puts "entry_list: \\n\n #{entry_list}"
	
	return entry_list
end


#
#Consultar saldos e movimentos à ordem - 01-09-2016
#
#Conta ;0549015427400 - EUR - Conta Caderneta 
#Data de início ;01-08-2016
#Data de fim ;01-09-2016
#
#Data mov. ;Data valor ;Descrição ;Débito ;Crédito ;Saldo contabilístico ;Saldo disponível ;
def cgd_csv_convert_CSV_2_QIF new_entries_file_name, new_entries_QIF_file_name
	
	puts "Converting CSV to QIF ... \n"
	
	entries = cgd_csv_get_entries_from_file new_entries_file_name
	
	qif_file_string = "!Type:Bank\n"
	
	entries.each do |line|
	
		entry = line[0].split(";")
	
		# Parse fields
		data_mov = entry[0]
		data_valor = entry[1]
		descricao = entry[2]
		debito = convert_number_locale_from_PT_to_US entry[3]
		credito = convert_number_locale_from_PT_to_US entry[4]
		saldo_contabilistico = entry[5]
		saldo_disponivel = entry[6]
		
		# Write QIF line
		
		#split($1,data,"-");
	    #print "D"data[1]"-"data[2]"'"data[3];
		data = data_mov.split("-")
		qif_file_string = qif_file_string + "D#{data[0]}-#{data[1]}'#{data[2]}\n"
        qif_file_string = qif_file_string + "M#{descricao}\n"

		if ( debito != "")
			qif_file_string = qif_file_string + "T-#{debito}\n"	
   
	   #split($4,debito,",");
	   #split(debito[1],debito_i,".");
	   #print "T-"debito_i[1]debito_i[2]"."debito[2];	

		else
   
	   #split($5,credito,",");
	   #split(credito[1],credito_i,".");
	   #print "T"credito_i[1]credito_i[2]"."credito[2];	
			
			qif_file_string = qif_file_string +  "T#{credito}\n"	
	   end

   
   
#   split($3,categoria," ");
#   print "L"categoria[1];
	   #print "P"$3;	   
	   #print "LBills:Cellular";
	   #print "^";
	   
		qif_file_string = qif_file_string + "P#{descricao}\n"
		qif_file_string = qif_file_string + "LBills:Cellular\n"
		qif_file_string = qif_file_string +  "^\n"

	end	
	
	puts "QIF file contents:\n#{qif_file_string}\n\n"
	
	File.open(new_entries_QIF_file_name, 'w') { 
			|file| file.write(qif_file_string)
	}
end



#
# File handlers
#

def cgd_csv_match_entry new_entry, old_entries

	if new_entry.nil?
		return -1
	end

	position = 0

	old_entries.each do |entry|
	
		#puts "old entry #{position}: #{entry} #{entry.class} #{entry[0]} #{entry[0].class}"
		#puts "new entry : #{new_entry1} #{new_entry1.class} #{new_entry1[0]} #{new_entry1[0].class}"
	
		if old_entries[position][0] == new_entry[0]
			puts "Matching old entry #{position}: \n #{entry[0]}\n with:\n #{new_entry[0]}" 
			return position
		end
		
		position = position + 1
	end

	return -1
end

def cgd_csv_match_3_entries new_entry1, new_entry2, new_entry3, old_entries
	
	matching_position1 = cgd_csv_match_entry new_entry1, old_entries
	matching_position2 = cgd_csv_match_entry new_entry2, old_entries
	matching_position3 = cgd_csv_match_entry new_entry3, old_entries
	
	puts "matching_position1=#{matching_position1} , matching_position2=#{matching_position2} , matching_position3=#{matching_position3}\n"
	
	if (matching_position1 > -1 ) and (matching_position1 > -2 ) and (matching_position1 > -1 ) and (matching_position2 == (matching_position1 +1)) and (matching_position3 == (matching_position2 +1)) 
		return matching_position1
	else
		return -1
	end
	
end

def cgd_csv_find_intersection_position old_entries, new_entries

    position = 0

	new_entries.each do |entry|
	
		#puts "New entry #{position}: \n #{entry}\n"
		
		
		matching_position = cgd_csv_match_3_entries new_entries[position], new_entries[position +1], new_entries[position +2], old_entries
		
		if ( matching_position > -1 )
			return position
		end
	
		position = position + 1
	end

	return -1
end

def cgd_csv_get_entries_from_file cgd_csv_file

	entries =  `type \"#{cgd_csv_file}\"`
	
	entry_list = entries.scan(/(..-..-....;..-..-....;.*;.*;.*;.*;.*)/)
	
	#\;(.*)\;(.*)\;(.*)\;(.*)\;(.*)
	
	puts "entry_list: \\n\n #{entry_list}"
	
	return entry_list
end


def cgd_csv_write_truncated_file file, new_entries

	new_entries.each do |entry| 
		file.write("#{entry[0]}\n")
	end

end

def process_downloaded_cgd_csv_file cgd_csv_file

	puts "Found file: #{cgd_csv_file} \n\n"
	
	#system "type \"#{cgd_csv_file}\""
	
	
	#save history: last downloaded movements
	
	#system "copy \"#{cgd_csv_file}\" \"#{CGD_DOWNLOAD_HISTORY_FILE}.#{get_current_time_str_for_filename}.original.csv\""
	
	new_entries_file_name = "#{CGD_DOWNLOAD_HISTORY_FILE}.#{get_current_time_str_for_filename}.csv"
	new_entries_QIF_file_name = "#{new_entries_file_name}.qif"
	
	
	#CGD_DOWNLOAD_LAST_FILE
	
	new_entries = cgd_csv_get_entries_from_file cgd_csv_file
	
	old_entries = cgd_csv_get_entries_from_file CGD_DOWNLOAD_LAST_FILE
	
	position = cgd_csv_find_intersection_position old_entries,new_entries
	
	if (position >=0 )
		puts "Found intersection at position #{position}, discarding entries bellow this line\n"
		
		#discard entries bellow "position" 
		
		new_entries = new_entries.take(position)
		
		#puts "Truncated entries: #{new_entries} \n\n"
				
		
	else
		puts "Didn't find an intersection, assuming all new entries ...\n"
	end
	
	File.open(new_entries_file_name, 'w') { 
			|file| cgd_csv_write_truncated_file file, new_entries
	}
	
	# Convert CSV to QIF
	cgd_csv_convert_CSV_2_QIF new_entries_file_name, new_entries_QIF_file_name
	
	
	# Replace last file
	
	# Remove original downloaded file
	
	# Write to history log file
	#   últimos movimentos do ficheiro novo e do anterior, saldos
end


def check_for_cgd_csv_files 

	puts "Checking for cgd files ..."
	puts "-------------\n\n"

	cgd_csv_files= `dir #{DOWNLOADS_PATH}\\comprovativo*.csv\ /b /s`

	caps = cgd_csv_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	#
	#track_no = 1

	caps.each do |i|
	   #puts "Value of local variable is #{start_str} .. #{i}"
 
	  process_downloaded_cgd_csv_file i[0]
	 
	  # track_no = track_no + 1
	end

end

#
# Unibanco handlers
#


def unibanco_xls_get_entries_from_file unibanco_file

	entries =  `type \"#{unibanco_file}\"`
	
	entry_list = entries.scan(/(<(TR|TR )><td><\/td><td (align="left"|bg)?.*?<\/tr>)/)
	
	#\;(.*)\;(.*)\;(.*)\;(.*)\;(.*)
	
	#puts "entry_list: \\n\n #{entry_list}"
	entry_list.each do |i|
		puts "#{i[0]} \n\n"
	end
	
	
	return entry_list
end

def unibanco_is_numeric_field_with_US_notation descricao
	if (descricao.include? "Juros sobre o saldo em ") or (descricao == "Imp. Selo art 17.3.1 TGIS") or (descricao == "Imp. Selo art 17.2.1 TGIS") or (descricao == "Juros Anteriores") 
		return true
	else	
		return false
	end
end

#
#
#
#Ex:
#<TR><td></td><td align="left">14.03</td><td>SHELL HU 14210,00 HUF</td><td align="right">45,93</td><td align="right"></td></tr>
#
#
def unibanco_xls_convert_XLS_2_QIF new_entries_file_name, new_entries_QIF_file_name, month, year
	
	puts "Converting XLS to QIF ... \n"
	
	entries = unibanco_xls_get_entries_from_file new_entries_file_name
	
	qif_file_string = "!Type:Bank\n"
	
	last_data_mov = "01.#{month}"
	
	entries.each do |line|
	
		#entry = line[0].split(";")
		#puts "line=#{line[0]} \n"
		
		#entry = line[0].scan(/<(TR|TR )><td><\/td><td (align="left"|bgColor="#FFFFFF")><\/td><td>(.*)<\/td>.*?<\/tr>/)
		entry = line[0].gsub "</td><td>",";"
		entry = entry.gsub "</td><td align=\"right\">",";"
		entry = entry.gsub "<TR><td></td><td align=\"left\">",""
		entry = entry.gsub ";</td></tr>",""
		entry = entry.gsub "<TR ><td></td><td bgColor=\"#FFFFFF\">",""
		entry = entry.gsub "<TR ><td></td><td width=\"60\" bgColor=\"#FFFFFF\">",""
		entry = entry.gsub "</td><td align=\"right\" width=\"90\">",";"
		entry = entry.gsub "</td><td align=\"right\" width=\"90\" >",";"
		entry = entry.gsub "</td></tr>",""
	
		puts "entry=#{entry} \n"
	
		entry_fields = entry.split(";")
		
		puts "entry_fields=#{entry_fields} \n"
	
		# Parse fields
		data_mov = entry_fields[0]
		if (data_mov == "")
			data_mov = last_data_mov
		end
		
		descricao = entry_fields[1]
		
		if !(unibanco_is_numeric_field_with_US_notation descricao)
		
			debito = convert_number_locale_from_PT_to_US entry_fields[2]
		else
			debito = entry_fields[2]
		end
		
		if entry_fields[3].nil?
			credito = 0
		else
			credito = convert_number_locale_from_PT_to_US entry_fields[3]
		end
				
		# Write QIF line
		
		#split($1,data,"-");
	    #print "D"data[1]"-"data[2]"'"data[3];
		data = data_mov.split(".")
		
		# TODO: extrair método 
		qif_file_string = qif_file_string + "D#{data[0]}-#{data[1]}'#{year}\n"
        qif_file_string = qif_file_string + "M#{descricao}\n"

		if ( debito != "")
			qif_file_string = qif_file_string + "T-#{debito}\n"	
   
	   #split($4,debito,",");
	   #split(debito[1],debito_i,".");
	   #print "T-"debito_i[1]debito_i[2]"."debito[2];	

		else
   
	   #split($5,credito,",");
	   #split(credito[1],credito_i,".");
	   #print "T"credito_i[1]credito_i[2]"."credito[2];	
			
			qif_file_string = qif_file_string +  "T#{credito}\n"	
	   end

   
   
#   split($3,categoria," ");
#   print "L"categoria[1];
	   #print "P"$3;	   
	   #print "LBills:Cellular";
	   #print "^";
	   
		qif_file_string = qif_file_string + "P#{descricao}\n"
		qif_file_string = qif_file_string + "LBills:Cellular\n"
		qif_file_string = qif_file_string +  "^\n"

		last_data_mov = data_mov
	end	
	
	puts "QIF file contents:\n#{qif_file_string}\n\n"
	
	File.open(new_entries_QIF_file_name, 'w') { 
			|file| file.write(qif_file_string)
	}
end


def unibanco_xls_write_truncated_file file, new_entries

	new_entries.each do |entry| 
		file.write("#{entry[0]}\n")
	end

end



def process_downloaded_unibanco_xls_file unibanco_file, index

	puts "Found file: #{unibanco_file} \n\n"
	
	
	#save history: last downloaded movements
	
	
	new_entries_file_name = "#{UNIBANCO_DOWNLOAD_HISTORY_FILE}.#{get_current_time_str_for_filename}.#{index}.xls"
	new_entries_QIF_file_name = "#{new_entries_file_name}.qif"
	
	system "copy \"#{unibanco_file}\" \"#{new_entries_file_name}\""

	new_entries = unibanco_xls_get_entries_from_file unibanco_file
	
	#old_entries = cgd_csv_get_entries_from_file CGD_DOWNLOAD_LAST_FILE
	
	#position = cgd_csv_find_intersection_position old_entries,new_entries
	
	position = -1
	
	if (position >=0 )
		puts "Found intersection at position #{position}, discarding entries bellow this line\n"
		
		#discard entries bellow "position" 
		
		new_entries = new_entries.take(position)
		
		#puts "Truncated entries: #{new_entries} \n\n"
				
		
	else
		puts "Didn't find an intersection, assuming all new entries ...\n"
	end
	
	File.open(new_entries_file_name, 'w') { 
			|file| unibanco_xls_write_truncated_file file, new_entries
	}
	
	# Convert XLS to QIF
	unibanco_xls_convert_XLS_2_QIF new_entries_file_name, new_entries_QIF_file_name, "05", "2016"
	
	
	# Replace last file
	
	# Remove original downloaded file
	
	# Write to history log file
	#   últimos movimentos do ficheiro novo e do anterior, saldos
end


def check_for_unibanco_xls_files 

	puts "Checking for unibanco files ..."
	puts "-------------\n\n"

	unibanco_files= `dir #{DOWNLOADS_PATH}\\Mapa???Extr*.xls\ /b /s`

	caps = unibanco_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	#
	#track_no = 1

	index = 1
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
 
	  #process_downloaded_cgd_csv_file i[0]
	  process_downloaded_unibanco_xls_file i[0], index
	 
	  index = index + 1 
	end

end

def create_target_dir target_dir
	print "mkdir \"#{target_dir}\"  \n\n"
	system "mkdir \"#{target_dir}\""
	
	system "mkdir \"#{target_dir}\"\\png"
	system "mkdir \"#{target_dir}\"\\txt"
end

def extract_png_from_pdf source_path, target_dir
	puts "Extracting PNG files from #{source_path} ... \n\n"
	
	# -density 300 
	command = "\"#{IMAGEMAGICK_PATH}\\magick.exe\" -density 300  \"#{source_path}\" \"#{target_dir}\\png\\page.png\""

	puts "### Executing: #{command}"
	system command
end

def extract_txt_from_png source_path

	puts "Extracting TXT files from #{source_path} ... \n\n"
	
	png_files= `dir #{source_path}\\png\\*.png\ /b /s /od`
	
	caps = png_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	index = 0
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
	  
	  command = "\"#{OCR_TESSERACT_PATH}tesseract.exe\" \"#{i[0]}\" #{source_path}\\txt\\page#{index} -psm 3 --tessdata-dir \"#{OCR_TESSERACT_PATH}tessdata\" -l por \"#{OCR_TESSERACT_PATH}tessdata\\pdf.config"
	  
	  puts "command=#{command}\n\n"
	  
	  system command
	 
	  index = index + 1 
	end

    # d:\Program Files\tesseract\tesseract.exe" page1-1.png -psm 3 --tessdata-dir "d:\Program Files\tesseract\tessdata" pdf -l por pdf.config
end


def concat_extracted_txt_files source_path

	puts "Extracting TXT single file from #{source_path} ... \n\n"
	
	txt_files= `dir #{source_path}\\txt\\*.txt\ /b /s /od`
	
	caps = txt_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	index = 0
	
	command = "copy "
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
 
	  #process_downloaded_cgd_csv_file i[0]
	  #process_downloaded_unibanco_xls_file i[0], index
	  
	  if index == 0
		command = command + "\"#{i[0]}\""
	  else
		command = command + "+\"#{i[0]}\""
	  end
	  
	  
	  index = index + 1 
	end

	command = command + " \"#{source_path}\\full_text.txt\""
	puts "command=#{command}\n\n"
	system command
	
end


def concat_extracted_hocr_files source_path

	puts "Extracting hocr single file from #{source_path} ... \n\n"
	
	txt_files= `dir #{source_path}\\txt\\*.hocr\ /b /s /od`
	
	caps = txt_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	index = 0
	
	command = "copy "
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
 
	  #process_downloaded_cgd_csv_file i[0]
	  #process_downloaded_unibanco_xls_file i[0], index
	  
	  if index == 0
		command = command + "\"#{i[0]}\""
	  else
		command = command + "+\"#{i[0]}\""
	  end
	  
	  system "copy \"#{i[0]}\" \"#{i[0]}.xhtml\""
	  
	  index = index + 1 
	end

	command = command + " \"#{source_path}\\full_text.xhtml\""
	puts "command=#{command}\n\n"
	system command
	
end





def concat_extracted_pdf_files source_path

	puts "Extracting TXT single file from #{source_path} ... \n\n"
	
	txt_files= `dir #{source_path}\\txt\\*.pdf\ /b /s /od`
	
	caps = txt_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	index = 0
	
	#command = "\"#{IMAGEMAGICK_PATH}\\magick.exe\" -adjoin "
	
	command = "\"#{GS_PATH}gswin32c\" -q -sPAPERSIZE=a4 -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=\"#{source_path}\\full_text.pdf\""
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
 	  
		command = command + " \"#{i[0]}\""
	  	  
	  index = index + 1 
	end

	#command = command + " \"#{source_path}\\full_text.pdf\""
	puts "command=#{command}\n\n"
	system command
	
	
	
	#"pdf2txt.dir.PAGE2\txt\page2.pdf pdf2txt.dir.PAGE2\txt\page3.pdf
	
end


def convert_pdf_2_txt source_path

	time = Time.now.getutc
	time2 = time.to_s.delete ': '

	time2 = "#{source_path}"

	target_dir = "#{TARGET_PATH}pdf2txt.dir.#{time2}"

	create_target_dir target_dir

	extract_png_from_pdf source_path, target_dir

	extract_txt_from_png target_dir

	concat_extracted_txt_files target_dir
	concat_extracted_hocr_files target_dir
	#concat_extracted_pdf_files TARGET_DIR	
	
end

def convert_multiple_pdf_2_txt

	puts "#### Extracting Multiple PDF files in the current directory  ... \n"
	puts "#### ... \n\n"
	puts "#### ... \n\n"
	
	pdf_files= `dir *.pdf /b /od`
	
	caps = pdf_files.scan(/(.*)\n/)

	puts "Found files:\n #{caps} \n\n"

	index = 0
	
	caps.each do |i|
	   puts "Value of local variable is #{i}"
 	  
	   convert_pdf_2_txt i[0]
	  	  
	   index = index + 1 
	end
	
end

#DOWNLOADS_PATH="C:\\Users\\tagido\\Downloads"
#MONEY_PATH="D:\\Mais documentos\\Projectos\\Money SRC"
#MONEY_DOWNLOAD_HISTORY_PATH="#{MONEY_PATH}\\download_history"
#CGD_DOWNLOAD_HISTORY_FILE="#{MONEY_DOWNLOAD_HISTORY_PATH}\\cgd_history.txt"
#CGD_DOWNLOAD_LAST_FILE="#{MONEY_DOWNLOAD_HISTORY_PATH}\\cgd_csv_last.csv"

#UNIBANCO_DOWNLOAD_HISTORY_FILE="#{MONEY_DOWNLOAD_HISTORY_PATH}\\Unibanco\\unibanco_history.txt"

OCR_TESSERACT_PATH="D:\\Program Files\\tesseract\\"
IMAGEMAGICK_PATH="D:\\Program Files\\ImageMagick-7.0.2-Q16\\"
GS_PATH="D:\\Program Files (x86)\\gs\\gs9.16\\bin\\"
SOURCE_PATH=ARGV[0]
TARGET_PATH="G:.\\"

time = Time.now.getutc
time2 = time.to_s.delete ': '

time2 = "#{SOURCE_PATH}"
TARGET_DIR="#{TARGET_PATH}pdf2txt.dir.#{time2}"

# TODO: correr o magick em blocos (quando são ficheiros muito grandes, encrava)

puts "pdf2txt.rb - ..."
puts "-------------\n\n"

if (SOURCE_PATH == "all")
	convert_multiple_pdf_2_txt
else
	convert_pdf_2_txt SOURCE_PATH
end