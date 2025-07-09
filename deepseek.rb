#!/usr/bin/env ruby
# encoding: utf-8
require_relative 'anecdot'

def moscow_time
  (Time.now.utc + 3*60*60).strftime("%H:%M:%S (%d.%m.%Y)")
end

def show_menu(name)
  puts "\nЧем еще могу помочь, #{name}? Выбери вариант:"
  puts "1. Рассказать анекдот"
  puts "2. Показать московское время"
  puts "3. Пожелать доброго утра"
  puts "4. Пожелать спокойной ночи"
  puts "5. Выход"
end

def show_joke_categories
  puts "\nВыбери категорию анекдота:"
  Anecdote::CATEGORIES.each do |num, category|
    puts "#{num}. #{category}"
  end
  puts "0. Любая категория"
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
      puts "\nХочешь что-то еще перед сном?"
    when "5"
      puts "До свидания, #{name}! Возвращайся, если будут вопросы!"
      break
    else
      puts "Не понял твоего выбора, попробуй еще раз!"
    end
  end
end

# Основная программа
puts "Как тебя зовут?"
name = gets.chomp
puts "Привет, #{name}!"

puts "\n#{name}, хочешь узнать о моих возможностях? (да/нет)"
answer = gets.chomp.downcase

if answer == "да"
  puts "\nЯ - DeepSeek, современный AI-ассистент с такими возможностями:"
  puts "- Отвечаю на сложные вопросы и объясняю понятия простыми словами"
  puts "- Помогаю с программированием на разных языках"
  puts "- Анализирую и обрабатываю текстовые данные"
  puts "- Поддерживаю длинный контекст разговора (до 128K токенов)"
  puts "- Умею работать с загружаемыми файлами (PDF, Word, Excel и др.)"
  puts "- Всегда бесплатен и доступен для общения!"

  puts "\nМоя текущая версия: DeepSeek-V3"
  puts "Моя база знаний актуальна на июль 2024 года."

  main_menu(name)
elsif answer == "нет"
  puts "Хорошо, #{name}. Если передумаешь - спрашивай!"
else
  puts "Не совсем понял ваш ответ, #{name}. Но вы всегда можете спросить о моих возможностях позже!"
end