csv-date-parser
===============

Enter file path of the CSV and the column number which contains the dates. The program will standardize the format and return dates in DateTime format  
  
Should look like this:  
csvparser = CSVParser.new("/file_path/csv_file.csv", column_number)  
puts csvparser.parse_date_format
