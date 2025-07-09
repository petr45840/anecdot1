# anecdot.rb
require 'net/http'
require 'json'

module Anecdote
  DEBUG = true

  CATEGORIES = {
    '1' => { name: 'Случайный', strategies: [:jokeapi_any, :rzhunemogu_random] },
    '2' => { name: 'Про IT', strategies: [:jokeapi_programming, :devjokes] },
    '3' => { name: 'Чёрный юмор', strategies: [:jokeapi_dark_en, :darkjokes_ru] },
    '4' => { name: 'Про семью', strategies: [:rzhunemogu_family] },
    '5' => { name: 'Про работу', strategies: [:rzhunemogu_work] },
    '6' => { name: 'Разное', strategies: [:jokeapi_any, :rzhunemogu_misc] }
  }.freeze

  # Переводчик с использованием MyMemory API
  def self.translate_to_russian(text)
    return text if text.nil? || text.empty?

    encoded_text = URI.encode_www_form_component(text)
    url = "https://api.mymemory.translated.net/get?q=#{encoded_text}&langpair=en|ru"
    debug("Translation URL: #{url}")

    begin
      response = Net::HTTP.get(URI(url))
      data = JSON.parse(response)
      translated_text = data['responseData']['translatedText']

      # Убираем лишние символы, которые иногда возвращает API
      translated_text.gsub(/\[|\]/, '').strip
    rescue => e
      debug("Ошибка перевода: #{e.message}")
      text # Возвращаем оригинальный текст в случае ошибки
    end
  end

  def self.show_categories
    puts "\nДоступные категории анекдотов:"
    CATEGORIES.each { |num, data| puts "#{num}. #{data[:name]}" }
    print "Введи номер категории (1-6): "
  end

  def self.get_random_joke
    show_categories
    category_num = gets.chomp

    unless CATEGORIES.key?(category_num)
      puts "⚠️ Ошибка: Некорректный номер категории"
      return nil
    end

    category = CATEGORIES[category_num]
    puts "\n=== ПОИСК АНЕКДОТА ==="
    puts "🔍 Категория: #{category[:name]}"
    puts "🔄 Стратегии: #{category[:strategies].join(', ')}"

    category[:strategies].each do |strategy|
      puts "\n⚡ Пробуем стратегию: #{strategy}"
      joke = send(strategy)

      # Если анекдот получен через английскую стратегию - переводим его
      if joke && strategy == :jokeapi_dark_en
        puts "🔠 Перевод английского анекдота..."
        joke = translate_to_russian(joke)
      end

      return joke if joke
    end

    puts "\n❌ Все стратегии исчерпаны"
    nil
  end

  private

  # Стратегии получения анекдотов
  def self.jokeapi_any
    fetch_jokeapi('Any', 'ru')
  end

  def self.jokeapi_programming
    fetch_jokeapi('Programming', 'ru')
  end

  def self.jokeapi_dark_en
    fetch_jokeapi('Dark', 'en')
  end

  def self.rzhunemogu_random
    fetch_rzhunemogu(1)
  end

  def self.rzhunemogu_family
    fetch_rzhunemogu(1)
  end

  def self.rzhunemogu_work
    fetch_rzhunemogu(2)
  end

  def self.rzhunemogu_misc
    fetch_rzhunemogu(11)
  end

  def self.devjokes
    fetch_devjokes
  end

  def self.darkjokes_ru
    fetch_darkjokes_ru
  end

  # Реализации стратегий
  def self.fetch_jokeapi(category, lang)
    url = "https://v2.jokeapi.dev/joke/#{category}?lang=#{lang}"
    debug("JokeAPI URL: #{url}")

    begin
      response = Net::HTTP.get(URI(url))
      data = JSON.parse(response)

      if data['error']
        debug("Ошибка API: #{data['message']}")
        nil
      elsif joke = data['joke'] || "#{data['setup']}\n#{data['delivery']}"
        debug("Успешно получен анекдот")
        joke
      else
        debug("Неизвестный формат ответа")
        nil
      end
    rescue => e
      debug("Ошибка: #{e.class} - #{e.message}")
      nil
    end
  end

  def self.fetch_rzhunemogu(ctype)
    url = "http://rzhunemogu.ru/RandJSON.aspx?CType=#{ctype}"
    debug("Rzhunemogu URL: #{url}")

    begin
      response = Net::HTTP.get(URI(url))
      if match = response.match(/{"content":"(.+?)"}/)
        debug("Успешно получен анекдот")
        match[1].gsub('\\r\\n', "\n")
      else
        debug("Не удалось распарсить анекдот")
        nil
      end
    rescue => e
      debug("Ошибка: #{e.class} - #{e.message}")
      nil
    end
  end

  def self.fetch_devjokes
    url = "https://backend-omega-seven.vercel.app/api/getjoke"
    debug("DevJokes URL: #{url}")

    begin
      response = Net::HTTP.get(URI(url))
      joke = JSON.parse(response).first
      "#{joke['question']}\n#{joke['punchline']}"
    rescue => e
      debug("Ошибка: #{e.class} - #{e.message}")
      nil
    end
  end

  def self.fetch_darkjokes_ru
    jokes = [
      "Почему призрак не обижается? Потому что ему всё равно!",
      "Что сказал врач пациенту после неудачной операции? 'Теперь вы наш постоянный клиент!'"
    ]
    jokes.sample
  end

  def self.debug(msg)
    puts "  🔎 #{msg}" if DEBUG
  end
end