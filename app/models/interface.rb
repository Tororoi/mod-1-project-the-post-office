require "tty-prompt"
require 'colorize'
require 'colorized_string'
require "ruby_figlet"
using RubyFiglet # For String.new(...).art / .art! Moneky Patches

class Interface
    attr_accessor :prompt, :sender
    attr_reader :letter, :receiver

    def initialize()
        @prompt = TTY::Prompt.new
    end

    def run
        system "clear"
        welcome
        login
        menu
    end


###################################*** WELCOME ***#######################################
def banner
    header = "The  Post  Office".art! 'alligator'
    puts header
    puts "\n"
end

def welcome
    # display_post_office - displays banner
      welcome = "Welcome to"#.art! 'Calvin S'
      welcome.each_char {|c| putc c ; sleep 0.10; $stdout.flush }
      "....".each_char {|c| putc c ; sleep 0.4; $stdout.flush }
      system "clear"
      banner
      sleep 0.5
  end

###################################*** MAIN MENU ***#######################################
    private

        def login 
            puts "\nPlease enter your name:"
            sender_input = gets.chomp.titlecase.strip
            
            if valid_user(sender_input)
                menu 
            else
                @sender = Sender.create(name: sender_input)
                puts "Please enter your current address:"
                sender.address = gets.chomp.titlecase.strip
            end
        end


        def valid_user(sender_input)
            if Sender.find_by(name: sender_input)
                @sender = Sender.find_by(name: sender_input)
                true
            else
                false
            end
        end


        def menu
            system "clear"
            banner
            puts "Hello, #{sender.name}!"
            option = prompt.select("\nHow can we help you today?") do |menu|
                menu.choice 'Send a letter'
                menu.choice 'View Outbox' 
                menu.choice 'My Address Book'
                menu.choice 'White Pages'
                menu.choice 'Change My Address'
                menu.choice "Exit 'The Post Office'".colorize(:red)
            end
            
            system "clear"
            banner
           
            if option == 'Send a letter'
                letter
            elsif option == 'View Outbox'
                view_outbox
            elsif option == 'My Address Book'
                my_address_book
            elsif option == 'White Pages'
                white_pages
            elsif option == 'Change My Address'
                change_my_address
            elsif option == "Exit 'The Post Office'".colorize(:red)
                puts "Thank you for visiting 'The Post Office', have a great day!"
                sleep(2.0)
                system "clear"
                exit
            end
        end


        def main_menu 
            prompt.select("\nWould you like to return to the Main Menu?") do |menu|
                menu.choice "Yes"
            end
            menu
        end


        def letter
            puts("Who would you like to write your letter to?")
            receiver_name = gets.chomp.titlecase.strip
            receiver_inst = Receiver.find_by(name: receiver_name)

            if receiver_inst == nil
                puts "\n#{receiver_name} is not in your address book. Please enter their current address:"
                receiver_address = gets.chomp.titlecase.strip
                receiver_inst = Receiver.create(name: receiver_name, address: receiver_address)
            end

            puts "\nWrite your Message below:"
            message = gets.chomp
            Letter.create(sender_id: sender.id, receiver_id: receiver_inst.id, content: message)

            puts "\nThank you for completing your message. #{receiver_name} should recieve your letter in 2-3 business days." 
            sleep(3.0)
            system "clear"
            menu
        end


        def display_letter(string)
            def comma(array)
                i = 0
                while i < array.length
                    if array[i].slice(array[i].length - 1) != ","
                        i += 1
                    elsif i == array.length
                        break
                    else
                        array.insert(i+1, "\n")
                        break
                    end
                end
            end
            def sincerely(array)
                i = 0
                while i < array.length
                    if array[i].titlecase != "Sincerely,"
                    i += 1
                    elsif i == array.length
                        break
                    else
                        array.insert(i+1, "\n")
                        array.insert(i, "\n")
                        break
                    end
                end
            end
            def format(array)
                comma(array)
                sincerely(array)
                start = array.find_index {|w| w == "\n"}
                start == nil ? j = 0 : j = start
                while j < array.length
                    array.insert(j, "\n")
                    j += 8
                end
            end
            array1 = string.split
            format(array1)
            puts "\n \n"
            puts array1.join(' ').art! 'Santa Clara'
            puts "\n \n"
        end


        def view_outbox
            my_outbox = Letter.where({sender_id: sender.id})
            recipients = my_outbox.map do |letter|
                letter.receiver.name
            end.uniq

            if my_outbox.length > 0
                recipient_choice = prompt.select("Please choose a recipient:", recipients)
            else
                puts "Your outbox is currently empty."
                main_menu
            end

            if recipient_choice
                system "clear"
                banner
                friend = Receiver.find_by(name: recipient_choice)
                letters_to_friend = Letter.where({sender_id: sender.id, receiver_id: friend.id})
                letters_to_recipient = letters_to_friend.map do |letter|
                    {name: letter.content, value: letter}
                end

                view_letter = prompt.select("Please choose a letter:", letters_to_recipient)
                if view_letter
                    display_letter(view_letter.content)
                    letter_menu = prompt.select("What would you like to do?") do |menu|
                        menu.choice "Return to Main Menu"
                        menu.choice "Delete Letter"
                    end

                    if letter_menu == "Delete Letter"
                        mail_delete(view_letter)
                        main_menu
                    else
                        menu
                    end
                end
            end    
        end

        def mail_delete(letter)
            # item = Letter.find_by(content: words)
            Letter.destroy(letter.id)
            # Letter.where(content: words).destroy_all
            puts "\nYou chased after the mailman and tackled him to the ground. You got your letter back and burned it."
        end


        def change_my_address
            puts "Your current address is #{sender.address}"
            puts "What would you like to change your address to?"
            
            new_address = gets.chomp.titlecase.strip
            sender.update(address: new_address)
            
            puts "Your new address is now: #{sender.address}"
            sleep(2.0)
            menu
        end


        def white_pages
            Receiver.all.each do |person|
                puts "\nName: #{person.name}"
                puts "Address: #{person.address}"
            end
            main_menu
        end
        
        def my_address_book
            puts "My Address Book"
            my_outbox = Letter.where({sender_id: sender.id})
            recipients = my_outbox.map do |letter|
                letter.receiver
            end.uniq
            recipients.each do |recipient|
                puts "\nName: #{recipient.name}"
                puts "Address: #{recipient.address}"
            end
            main_menu
        end 

end
