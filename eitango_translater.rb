require "nokogiri"
require "active_record"
require "active_support/all"
require "logger"
require "open-uri"
require "uri"

Time.zone_default = Time.find_zone! 'Tokyo'
ActiveRecord.default_timezone = :local

#ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Base.establish_connection(
  adapter:  "mysql2",
  host:     "localhost",
  username: "root",
  password: "",
  database: "weblio_dictionary",
  charset: "utf8mb4",
  collation: "utf8mb4_general_ci",
  encoding: "utf8mb4",
)

class Word < ActiveRecord::Base
end


def create_word_record(formated_word)
  weblio_root = "https://ejje.weblio.jp/content/"
  cambridge_root = "https://dictionary.cambridge.org/ja/dictionary/english/"
  word_for_search = formated_word.gsub(" ", "+")
  encoded_word = URI.encode_www_form_component(word_for_search)
  sleep 1
  weblio_html = URI.open("#{weblio_root}#{word_for_search}")
  cambridge_html = URI.open("#{cambridge_root}#{word_for_search}")
  jp_meaning = Nokogiri::HTML.parse(weblio_html).at_css(".content-explanation.ej")&.text&.strip
  en_meaning = Nokogiri::HTML.parse(cambridge_html).at_css(".def.ddef_d.db")&.text&.strip
  if jp_meaning or en_meaning then
    puts "Congratulations! You found a new word!"
    Word.create(word: formated_word, weblio_html: weblio_html, cambridge_html: cambridge_html, meaning_j: jp_meaning&.gsub(/\s/, " "), meaning_e: en_meaning&.gsub(/\s/, " "), weblio_status: 1, cambridge_status: 1)
  end
end

def mearning_select_or_create(raw_word, mode)
  formated_word = raw_word.gsub(/\s+/, " ").strip
  word_record = Word.select(:meaning_j, :meaning_e).find_by(word: formated_word)
  if word_record.nil? then
    begin
      word_record = create_word_record(formated_word)
    rescue => e
      puts e
    end
  end
  if mode == "ej" then
    jp_meaning = word_record&.meaning_j
    return "Can't find a japanese meaning of '#{formated_word}'" if jp_meaning.nil? || jp_meaning == ""
    "#{formated_word}: #{jp_meaning}"
  elsif mode == "ee"
    en_meaning = word_record&.meaning_e
    return "Can't find an english meaning of '#{formated_word}'" if en_meaning.nil? or en_meaning == ""
    "#{formated_word}: #{en_meaning}"
  end
end

def loop_for_ej_or_ee(mode)
  loop do
    printf "[#{mode}]> "
    en_word = gets.strip
    break if en_word == "chmod"
    puts mearning_select_or_create(en_word, mode)
  end
end

loop do
  puts "je    -> input: japanese phrase, output: english words"
  puts "ej    -> input: english word,    output: japanese meaning"
  puts "ee    -> input: english word,    output: english meaning"
  puts "exit  -> exit the program"
  printf "select mode> "
  mode = gets.strip

  if mode == "je" then
    puts "You selected japanese to english mode!"
    loop do
      printf "[je]> "
      jp_phrase = gets.gsub(/\s/, " ").strip
      break if jp_phrase == "chmod"
=begin
      matched_words = Word.where("`meaning_j` LIKE ?", "%#{Word.sanitize_sql_like(jp_phrase)}%")
      puts "Can't find words meaning `#{jp_phrase}`" if matched_words.empty?
      matched_words.each {|word_record| printf "#{word_record.word}, "}
=end
      sleep 1
      ej_html = URI.open("https://ejje.weblio.jp/content/#{URI.encode_www_form_component(jp_phrase)}")
      ej_doc = Nokogiri::HTML.parse(ej_html)
      matched_words = ej_doc.at_css(".content-explanation.je")
      puts matched_words ? matched_words.text.strip : "Can't find words meaning `#{jp_phrase}`"
    end
  elsif mode == "ee" or mode == "ej"
    puts "You selected english to japanese mode!" if mode == "ej"
    puts "You selected english to english mode!" if mode == "ee"
    loop_for_ej_or_ee(mode)
  elsif mode == "exit"
    break
  else
    puts "Select valid mode!"
  end
end