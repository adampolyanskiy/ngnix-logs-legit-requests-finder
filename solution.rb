require 'pp'

filename = "access.log"

simple_ip_regex = /\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b/
log_line_regex = /(?<ip>[\d\.]+) - - \[(?<time>.+)\] "(?<request>.*)" (?<status_code>\d{3}) (?<bytes_sent>\w+) "(?<referer>.+?)" "(?<user_agent>.+)"/
legit_regexes = {
    "user_agent" => /"(Mozilla.*(Gecko|KHTML|MSIE|Presto|Trident)|Opera).+"$/,
    "referer_request_page" => /("\w+ (\/(home_page)?) HTTP\/1.\d".+?"-"|"\w+ .+? HTTP\/1.\d".+?"(.){2,}?")/,
    "bytes_sent" => /.* (304 0|\d{3} ([6-9][0-9]|[1-9]\d{2,})) .*/,
    "status_code" => /.* [^4]\d\d \d+ .*/,
    "request_page" => /"\w{3,} ((?!SQlite|sqlite|SQLite|robots.txt|webdav|wp-login|jmx-console|phpmyadmin).)* HTTP\/1\.\d"/
}

file_obj = File.read(filename)
ips = []
legit_records = []

file_obj.each_line do |line|
    captures = line.match(log_line_regex)
    if captures
        ips.push(captures[:ip])
    end

    countOfMatches = 0
    legit_regexes.each_key do |key|
        if !line.match(legit_regexes[key])
            countOfMatches += 1
        end
    end

    if countOfMatches < 2
        legit_records.push(captures[:ip])
    end
end


print("Ip count, just as they are, sorted\n")
ips.tally
    .sort_by { |ip, count| -count}
    .slice(0, 10)
    .map { |ip_count| pp ip_count.join("=>")}

print("\nLegit ips count, sorted\n")
legit_records.tally
    .sort_by { |ip, count| -count}
    .slice(0, 10)
    .map { |ip_count| pp ip_count.join("=>")}