require 'csv'
require 'debugger'

class CSVParser

  MONTHS_ARRAY = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

  def initialize(file_path, column)
    @file = file_path
    @column = column
    @date_column = get_date_column
  end

###############
# MAIN METHODS #
###############
  def parse_date_format
    date_indexes = learn_date_format
    learned_date_indexes = fill_in_last_value(date_indexes)
    datetime_creation(learned_date_indexes)
  end

  def format #RETURNS THE FORMAT OF THE COLUMN'S DATES
    date_indexes = learn_date_format
    learned_date_indexes = fill_in_last_value(date_indexes)
    
    format = Array.new
    format[learned_date_indexes[:year]] = "YYYY"
    format[learned_date_indexes[:month]] = "MM"
    format[learned_date_indexes[:day]] = "DD"
    date_format = "#{format[0]}/#{format[1]}/#{format[2]}"
  end

private
#########################
# RUN ON INITIALIZATION #
#########################
  def get_date_column
    date_column = []
    CSV.foreach(@file) do |row|
      date_column << row[@column - 1]
    end
    standardize_format(date_column)
  end

  def standardize_format(date_column) #DOESN'T WORK FOR DATE1.CSV
    date_column.each do |date|
      #FORMATS PUNCTUATION CORRECTLY
      date.gsub!(",", "")
      date.gsub!("-", "")
      date.gsub!(".", "/")

      #TRANSLATES SPELLED OUT MONTHS INTO REPRESENTATIVE INTEGERS
      MONTHS_ARRAY.each_with_index do |month, index|
        date.gsub!(/(#{month})[a-z]{0,}/i, " #{index + 1} ")
      end

      #REMOVES TIME INFO
      date.gsub!(/\d{1,}:\d{0,}((AM)|(PM))/i, "")
      date.gsub!(/\d{1,}:\d{0,}/, "")
      date.gsub!(/\d{1,}((AM)|(PM))/i, "")

      #ADDS/REMOVES NECESSARY/UNNECESSARY /'S
      date.gsub!(" ", "/")
      date.gsub!(/\/{1,}$/, "")
      date.gsub!(/^\/{1,}/, "")
      date.gsub!(/\/{1,}/, "/")
    end
    date_column.shift if date_column.first != /\d{1,}(\/)\d{1,}(\/)\d{1,}$/ #REMOVES TOP ROW IN DATE IF ITS A HEADER
    date_column
  end

######################
# SUPPORTING METHODS #
######################
  def learn_date_format
  #ITERATES THROUGH EACH ROW AND LEARNS THE DATE FORMAT
    #IE: MM/DD/YYYY, DD/MM/YYYY, YYYY/MM/DD, ETC
    date_indexes = Hash.new
    @date_column.each do |date|
      split_date = date.split("/")
      split_date.each_with_index do |x, i|
        # study_format_learning(split_date, date_indexes) #UNCOMMENT ONLY TO STUDY ITERATION AND DATE FORMAT LEARNING
        next if i == date_indexes[:day] || i == date_indexes[:month] || i == date_indexes[:year]

        if year_indexed?(date_indexes)
          date_indexes[:day] = i and break if x.to_i > 12
        end
        if month_indexed?(date_indexes)
          date_indexes[:year] = i and break if x.to_i > 31
        end
        if day_indexed?(date_indexes)
          date_indexes[:year] = i and break if x.to_i > 12
          date_indexes[:month] = i and break if x.size == 1
        end
        if nothing_indexed?(date_indexes)
          date_indexes[:year] = i and break if x.size == 4 || x.to_i > 31
          date_indexes[:day] = i and break if x.to_i > Time.now.year%100 && x.to_i <= 31
        end
      end
      break if two_indexed?(date_indexes) #STOPS ITERATION ONCE FORMAT IS LEARNED
    end
    date_indexes
  end

  def nothing_indexed?(date_indexes)
    !year_indexed?(date_indexes) && !month_indexed?(date_indexes) && !day_indexed?(date_indexes)
  end

  def two_indexed?(date_indexes)
    year_and_month_indexed?(date_indexes) || month_and_day_indexed?(date_indexes) || day_and_year_indexed?(date_indexes)
  end

  def year_indexed?(date_indexes)
    date_indexes[:year] ? true : false
  end

  def month_indexed?(date_indexes)
    date_indexes[:month] ? true : false
  end

  def day_indexed?(date_indexes)
    date_indexes[:day] ? true : false
  end

  def year_and_month_indexed?(date_indexes)
    year_indexed?(date_indexes) && month_indexed?(date_indexes)
  end

  def day_and_year_indexed?(date_indexes)
    day_indexed?(date_indexes) && year_indexed?(date_indexes)
  end

  def month_and_day_indexed?(date_indexes)
    month_indexed?(date_indexes) && day_indexed?(date_indexes)
  end

  def fill_in_last_value(date_indexes)
  #FIGURES OUT WHICH VALUE HAS NOT BEEN DETERMINED AND ASSIGNS IT THE REMAINING INDEX
    learned_date_indexes = date_indexes
    indexes = [0, 1, 2]

    #DELETES INDEXES WHICH HAVE ALREADY BEEN ASSIGNED
    indexes.delete(learned_date_indexes[:day]) if learned_date_indexes[:day]
    indexes.delete(learned_date_indexes[:month]) if learned_date_indexes[:month]
    indexes.delete(learned_date_indexes[:year]) if learned_date_indexes[:year]
    
    #ASSIGNS REMAINING INDEX TO VALUE THAT HASN'T BEEN DETERMINED
    learned_date_indexes[:year] = indexes.first if !learned_date_indexes[:year]
    learned_date_indexes[:month] = indexes.first if !learned_date_indexes[:month]
    learned_date_indexes[:day] = indexes.first if !learned_date_indexes[:day]

    learned_date_indexes
  end

  def datetime_creation(date_indexes)
    @date_column.collect do |date|
      if date.split("/")[date_indexes[:year]].size == 2
        DateTime.strptime("20#{date.split("/")[date_indexes[:year]]}-#{date.split("/")[date_indexes[:month]]}-#{date.split("/")[date_indexes[:day]]}", "%Y-%m-%d")
      else
        DateTime.strptime("#{date.split("/")[date_indexes[:year]]}-#{date.split("/")[date_indexes[:month]]}-#{date.split("/")[date_indexes[:day]]}", "%Y-%m-%d")
      end
    end
  end

#######################
# DEVELOPMENT METHODS #
#######################
  def study_format_learning(split_date, date_indexes)
    puts "#{split_date} day:(#{date_indexes[:day]}) month:(#{date_indexes[:month]}) year:(#{date_indexes[:year]})"
  end
end

csvparser = CSVParser.new("#{Dir.pwd}/csvs/date7.csv", 3)
puts csvparser.parse_date_format
puts csvparser.format
