#!/usr/bin/env ruby
# encoding: utf-8
require_relative 'anecdot'
require 'net/http'
require 'json'

def moscow_time
  (Time.now.utc + 3*60*60).strftime("%H:%M:%S (%d.%m.%Y)")
end

def show_menu(name)
  puts "\nЧем еще могу помочь, #{name}? Выбери вариант:"
  puts "1. Рассказать анекдот"
  puts "2. Показать московское время"
  puts "3. Пожелать доброго утра"
  puts "4. Пожелать спокойной ночи"
  puts "5. Помощь"
  puts "6. Поздравить с днем рождения"
  puts "7. Показать погоду"
  puts "8. Выход"
end

def show_joke_categories
  puts "\nВыбери категорию анекдота:"
  Anecdote::CATEGORIES.each do |num, category|
    puts "#{num}. #{category}"
  end
  puts "0. Любая категория"
end

def get_petersburg_weather
  begin
    # Используем Open-Meteo API как резервный вариант
    url = URI("https://api.open-meteo.com/v1/forecast?latitude=59.94&longitude=30.31&current_weather=true")
    response = Net::HTTP.get(url)
    data = JSON.parse(response)
    
    if data['current_weather']
      temp = data['current_weather']['temperature']
      wind = data['current_weather']['windspeed']
      weather_code = data['current_weather']['weathercode']
      
      # Преобразуем код погоды в текст
      weather_desc = case weather_code
                    when 0 then "Ясно ☀️"
                    when 1..3 then "Переменная облачность ⛅"
                    when 45..48 then "Туман 🌫️"
                    when 51..67 then "Дождь 🌧️"
                    when 71..77 then "Снег ❄️"
                    when 80..82 then "Ливень 🌧️"
                    when 85..86 then "Снегопад ❄️"
                    when 95..99 then "Гроза ⛈️"
                    else "Облачно ☁️"
                    end
      
      "\nПогода в Санкт-Петербурге (#{Time.now.strftime('%d.%m.%Y %H:%M')}):\n" +
      "☁️ Состояние: #{weather_desc}\n" +
      "🌡 Температура: #{temp.round}°C\n" +
      "🌬 Ветер: #{wind.round(1)} м/с"
    else
      "\nНе удалось получить данные о погоде. Сервис временно недоступен."
    end
  rescue => e
    "\nОшибка при получении погоды: #{e.message}"
  end
end

def main_menu(name)
  loop do
    show_menu(name)
    choice = gets.chomp

    case choice
    when "1"
      puts "\nИщу лучший анекдот для тебя..."
      if joke = Anecdote.get_random_joke
        puts "\n#{joke}"
      else
        puts "К сожалению, не удалось найти анекдот 😔"
      end
      puts "\nЧем ещё могу помочь?"
    when "2"
      puts "\nТекущее московское время: #{moscow_time}"
      puts "\nЧто-то еще?"
    when "3"
      puts "\n#{name}, желаю тебе самого солнечного и продуктивного утра! 🌞"
      puts "Пусть день начнётся с хорошего настроения и приятных событий!"
      puts "\nМогу еще чем-то помочь?"
    when "4"
      puts "\nСпокойной ночи, #{name}! 🌙"
      puts "Пусть тебе снятся приятные сны, а завтрашний день будет ещё лучше!"
      puts "\nХочешь сказку на ночь? (да/нет)"
      answer = gets.chomp.downcase
      if answer == "да"
        puts "\nЖил-был маленький ёжик. Каждый вечер он заворачивался в листик, как в одеялко, и засыпал под шёпот ветра. 🌿✨ Звёзды светили ему в окошко, а луна пела колыбельную. Сладких снов, #{name}!"
      end
      puts "\nЧем ещё могу помочь?"
    when "5"
      puts "\nЯ могу:"
      puts "- Рассказать анекдот (пункт 1)"
      puts "- Показать текущее время в Москве (пункт 2)"
      puts "- Пожелать доброго утра (пункт 3)"
      puts "- Пожелать спокойной ночи (пункт 4)"
      puts "- Показать погоду (пункт 7)"
      puts "- Выйти из программы (пункт 8)"
      puts "\nЧто тебя интересует?"
    when "6"
      puts "\n#{name}, поздравляю тебя с Днём Рождения! 🎉"
      puts "       #{'*' * (name.length + 6)}"
      puts "      | #{name} |"
      puts "       #{'*' * (name.length + 6)}"
      puts "\nЧем ещё могу помочь?"
    when "7"
      puts get_petersburg_weather
      puts "\nЧем ещё могу помочь?"
    when "8"
      puts "\nСпасибо, что пользовался программой, #{name}! До свидания! 👋"
      exit
    else
      puts "\nНеизвестный вариант. Пожалуйста, выбери номер из меню."
    end
  end
end

puts "Привет! Я - твой личный помощник. Как тебя зовут?"
name = gets.chomp

puts "\nПриятно познакомиться, #{name}! Я могу рассказать анекдот, показать московское время, пожелать доброго утра или спокойной ночи, а также поздравить с днем рождения. Чем ты хочешь, чтобы я занялся?"
main_menu(name)