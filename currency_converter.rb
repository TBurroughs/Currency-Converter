require 'sqlite3'
require 'open-uri'

# Create a new database if one does not exist
$db = SQLite3::Database.new('currency.db')
$db.execute %Q{ create table if not exists currency(
                customer_name varchar(10),
                current_date_time date,
                source_currency varchar(3),
                target_currency varchar(3),
                source_amount float,
                target_amount float);
              } 
              
# Display country and currency code               
puts
puts "Currency Codes".rjust(16)
puts "==================="
currency_codes = { "United States" => "USD",  
	"Euro" => "EUR", "England" => "GBP", 
	"Japan" => "JPY", "Singapore" => "SGD", 
	"Hong Kong" => "HKD", "Austrailia" => "AUD", 
	"Sweden" => "SEK"
	}
currency_codes.each { |x, y| puts "#{x} = #{y}".rjust(19) } 

# Accept user input
puts
print "Enter your name: ".rjust(27)
customer_name = gets.chomp
customer_name.capitalize!
print "Enter the source currency: "
source_currency = gets.chomp
source_currency.upcase!
print "Enter the target currency: ".rjust(27)
target_currency = gets.chomp
target_currency.upcase!
print "Enter the source amount: ".rjust(27)
source_amount = gets.chomp.to_f

# Complete URL 
prefix = "http://download.finance.yahoo.com/d/quotes.csv?s="
suffix = "=X&f=sl1d1t1ba&e=.csv"
url = prefix + source_currency + target_currency + suffix

# Dowload...Open...Read the .csv file
download = open(url).read
# Split the .csv file and store exchange rate (index 1)
exchange_rate = download.split(",")[1].to_f
# Calculate target_amount 
target_amount = exchange_rate * source_amount 

# Create a timestamp 
t = Time.now
current_date_time = "%d-%d-%d %d:%.2d:%.2d" % 
[t.year, t.mon, t.day, t.hour, t.min, t.sec]

# Create a new record in the database 
$db.execute %Q/
  insert into currency values(
    '#{customer_name}',
    '#{current_date_time}',
    '#{source_currency}',
    '#{target_currency}',
    '#{source_amount}',
    '#{target_amount}')/
puts

# Output database records 
display_results = $db.execute "select * from currency;"  
display_results.each do |a, b, c, d, e, f| 
	puts "Name: ".rjust(17) + "#{a}" + "\n" +
	"Date & Time: ".rjust(17) + "#{b}" + "\n" +
	"Source Currency: " + "#{c}" + "\n" +
	"Target Currency: " + "#{d}" + "\n" +
	"Source Amount: ".rjust(17) + "%.2f" % "#{e}" + "\n" +
	"Target Amount: ".rjust(17) + "%.2f" % "#{f}" + "\n" 
	puts
end
$db.close
