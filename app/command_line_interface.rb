require_relative '../app/User.rb'
require_relative '../app/Compliment.rb'
require_relative '../app/UserCompliment.rb'
require_relative '../app/UserContact.rb'
require_relative '../app/texting.rb'
require 'colorize'
ActiveRecord::Base.logger = nil

class CommandLineInterface

  attr_accessor :user, :contact_user, :command, :compliment, :contact_check

  def logo_message
    puts "===================================================================================="
     puts "
     ██╗    ██╗██╗  ██╗██╗   ██╗
     ██║    ██║██║  ██║╚██╗ ██╔╝
     ██║ █╗ ██║███████║ ╚████╔╝
     ██║███╗██║██╔══██║  ╚██╔╝
     ╚███╔███╔╝██║  ██║   ██║▄█╗
      ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝╚═╝

     ████████╗██╗  ██╗ █████╗ ███╗   ██╗██╗  ██╗    ██╗   ██╗ ██████╗ ██╗   ██╗██╗
     ╚══██╔══╝██║  ██║██╔══██╗████╗  ██║██║ ██╔╝    ╚██╗ ██╔╝██╔═══██╗██║   ██║██║
        ██║   ███████║███████║██╔██╗ ██║█████╔╝      ╚████╔╝ ██║   ██║██║   ██║██║
        ██║   ██╔══██║██╔══██║██║╚██╗██║██╔═██╗       ╚██╔╝  ██║   ██║██║   ██║╚═╝
        ██║   ██║  ██║██║  ██║██║ ╚████║██║  ██╗       ██║   ╚██████╔╝╚██████╔╝██╗
        ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝       ╚═╝    ╚═════╝  ╚═════╝ ╚═╝ ".colorize(:light_blue).blink

  puts "===================================================================================="
  end

  def welcome
    puts "Welcome to Why, Thank You!".colorize(:light_blue).bold
    puts "Give personalized compliments to your friends or yourself!".colorize(:light_blue).bold
    puts "======================================"
    welcome_or_create
  end

  def welcome_or_create

    user_data = data_collection()

    if User.find_by(user_data) == nil
      @user = User.create(user_data)
      puts "Pleasure to meet you #{@user.first_name}!".green.bold
      puts "------------------------"
    else
      @user = User.find_by(user_data)
      puts "Great having you back #{@user.first_name}!".green.bold
      puts "------------------------"
    end
    display_menu
  end

  def data_collection
    user_data = {}
    print "Please enter first name: "
    user_data[:first_name] = gets.chomp
    puts "------------------------"
    print "Please enter last name: "
    user_data[:last_name] = gets.chomp
    puts "------------------------"
    print "Please enter phone number: "
    user_data[:phone_number] = gets.chomp
    puts "------------------------"

    user_data
  end

  def display_menu
    puts "MAIN MENU".colorize(:light_blue).bold
    puts "======================================"
    puts "Enter 's' to send a compliment".colorize(:yellow)
    puts "Enter 'r' to receive a compliment".colorize(:yellow)
    puts "Enter 'c' to view your contacts".colorize(:yellow)
    puts "Enter 'v' to view all the compliments you have generated".colorize(:yellow)
    puts "Enter 'q' to quit".colorize(:yellow)
    puts "======================================"

    get_menu_command
  end

  def get_menu_command
    @command = gets.chomp
    process_menu_command
  end

  def process_menu_command
    if @command == 's'
      get_send_command()
    elsif @command == 'r'
      get_compliment_command()
    elsif @command == 'v'
      display_user_compliments()
    elsif @command == 'c'
      get_contact_command()
    elsif @command == 'q'
      quit()
    else
      puts "Please enter a valid command".colorize(:red)
      get_menu_command()
    end
  end

  def get_compliment_command
    puts "======================================"
    puts "Enter '1' for a badass compliment".colorize(:yellow)
    puts "Enter '2' for a quirky compliment".colorize(:yellow)
    puts "Enter '3' to go back to main menu".colorize(:yellow)
    puts "======================================"

    @compliment_command = gets.chomp
    process_compliment_command()
  end

  def process_compliment_command

    if @command == 's' && @compliment_command == '1'
      generate_chuck(@contact_user.first_name, @contact_user.last_name)
      save_compliment_to_user(@user)
      if get_refresh_command()
        Texting.send_message(@contact_user.phone_number, @compliment.content)
        sent_compliment()
        sleep 1.2
        display_menu()
      else
        process_compliment_command()
      end

    elsif @command == 'r' && @compliment_command == '1'
      generate_chuck(@user.first_name, @user.last_name)
      save_compliment_to_user(@user)
      if get_refresh_command()
        Texting.send_message(@user.phone_number, @compliment.content)
        sent_compliment()
        sleep 1.2
        display_menu()
      else
        process_compliment_command()
      end

    elsif @command == 's' && @compliment_command == '2'
      generate_leslie(@contact_user.first_name, @contact_user.last_name)
      save_compliment_to_user(@user)
      if get_refresh_command()
        Texting.send_message(@contact_user.phone_number, @compliment.content)
        sent_compliment()
        sleep 1.2
        display_menu()
      else
        process_compliment_command()
      end

    elsif @command == 'r' && @compliment_command == '2'
      generate_leslie(@user.first_name, @user.last_name)
      save_compliment_to_user (@user)
      if get_refresh_command()
        Texting.send_message(@user.phone_number, @compliment.content)
        sent_compliment()
        sleep 1.2
        display_menu()
      else
        process_compliment_command()
      end
    elsif @compliment_command == '3'
      display_menu()

    else
      puts "Please enter a valid command".colorize(:red)
      get_compliment_command()
    end
  end

  def contact_creation(user_data)
    @contact_user = User.find_or_create_by(user_data)
    UserContact.create(user_id: @user.id, contact_id: @contact_user.id)
    puts "#{@contact_user.first_name} has been saved in your contacts!".colorize(:green).bold
    sleep 1.2
  end

  def display_contacts
    puts "--------------------------------------"
    @user.contacts.each_with_index do |contact, index|
      puts "#{index + 1}. #{contact.first_name} #{contact.last_name}"
      puts "--------------------------------------"
    end
  end

  def get_contact_command
    display_contacts
    puts "======================================"
    puts "Enter contact name to send them a compliment".colorize(:yellow)
    puts "Enter 'a' to add a contact".colorize(:yellow)
    puts "Enter 'b' to go back to main menu".colorize(:yellow)
    puts "======================================"
    @command = gets.chomp
    @contact_check = @command.split(" ")
    process_contact_command
  end

  def check_contacts
    @user.contacts.find_by(first_name: @contact_check[0], last_name: @contact_check[1])
  end

  def process_contact_command
    if @command == 'b'
      display_menu()
    elsif @command == 'a'
      user_data = data_collection()
      contact_creation(user_data)
      get_contact_command()
    elsif check_contacts()
        @command = 's'
        @contact_user = check_contacts()
        get_compliment_command()
    else
      puts "======================================"
      puts "That person is not in your contacts!".colorize(:red)
      puts "======================================"
      sleep 1.2
      get_contact_command()
    end
  end

  def display_user_compliments
    puts "--------------------------------------"
    @user.compliments.each_with_index do |compliment, index|
      puts "#{index + 1} #{compliment.content}"
      puts "--"
    end
    "--------------------------------------"
    display_menu()
  end

  def get_send_command
    puts "======================================"
    puts "Enter 'a' to send to one of your contacts".colorize(:yellow)
    puts "Enter 'b' to send to a new contact".colorize(:yellow)
    puts "======================================"

    @command = gets.chomp
    process_send_command
  end

  def process_send_command
    if @command == 'a'
      get_contact_command()
    elsif @command == 'b'
      @command = 's'
      user_data = data_collection()
      contact_creation(user_data)
      get_compliment_command()
    end
  end

  def generate_chuck(first_name, last_name)
    chuck = Compliment.customize_chuck(first_name, last_name)
    @compliment = Compliment.create(content:chuck)
  end

  def save_compliment_to_user (user)
    UserCompliment.create(user_id: user.id, compliment_id: @compliment.id)
  end

  def generate_leslie(first_name, last_name)
    leslie = Compliment.get_leslie(first_name, last_name)
    @compliment = Compliment.create(content:leslie)
  end

  def display_compliment
    puts "Here is the compliment you generated"
    puts "======================================"
    puts @compliment.content.green.bold
    puts "======================================"
  end

  def get_refresh_command
    display_compliment
    puts "======================================"
    puts "Enter '1' to send this compliment".yellow
    puts "Enter '2' to generate a new compliment".yellow
    puts "======================================"
    @refresh_command = gets.chomp
    process_refresh_command
  end

  def process_refresh_command
    if @refresh_command == '1'
      true
    elsif @refresh_command == '2'
      false
    else
      puts "Please enter a valid command".colorize(:red)
      get_refresh_command()
    end
  end

  def sent_compliment
    pid = fork{ exec 'afplay', "success.mp3" }
    puts "======================================"
    puts "Your compliment has been sent! Nice!".colorize(:green).bold
    puts "======================================"
  end

  def quit
    puts "======================================"
    puts "Why, Thank You for using our service, goodbye!".colorize(:light_blue).bold.blink
    puts "======================================"
    pid = fork{ exec 'afplay', "thanks!.wav" }
    exit(true)
  end



end
