require "tty-prompt"

class Interface
    attr_accessor :prompt, :sender
    attr_reader :letter,:receiver

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
    


    def welcome
      # display_post_office - displays banner
        puts "Welcome to 'The Post Office.' Whaddya want??"
    end



###################################*** MAIN MENU ***#######################################
    private

        def valid_user
            if Sender.find_by(name: @sender_input)
                @sender = Sender.find_by(name: @sender_input)
                true
            else
                false
            end
        end

        def login 
            puts "Please enter your name:"
            @sender_input = gets.chomp.titlecase
            if valid_user
                puts "Welcome Back, #{@sender_input}"
            else
                @sender = Sender.create(name: @sender_input)
                puts "Please enter your address:"
                @sender_address_input = gets.chomp.titlecase
                sender.address = @sender_address_input
            end
        end

        def menu
            option = prompt.select("What would you like to do?") do |menu|
                menu.choice 'Send a letter'
                menu.choice 'View letters' #disabled?: sender.letters.length
                menu.choice 'Change address'
                menu.choice "Exit 'The Post Office'"
            end
            if option == 'Send a letter'
                system "clear"
                letter(@sender)
            elsif option == 'View letters'
                system "clear"
                view_outbox(@sender)
            elsif option == 'Change address'
                system "clear"
                info_change(@sender)
            elsif option == 'Exit Menu'
                system "clear"
            end
        end

        def letter(sender)
            puts("Who would like to write to?")
            receiver_name = gets.chomp.titlecase
            receiver_inst = Receiver.find_by(name: receiver_name)
            if receiver_inst == nil
                puts "#{receiver_name.capitalize} is not in your address book. Please enter their address:"
                receiver_address = gets.chomp
                receiver_inst = Receiver.create(name: receiver_name, address: receiver_address)
            end
            puts "Write your letter below"
            message = gets.chomp
            Letter.create(sender_id: sender.id, receiver_id: receiver_inst.id, content: message)
            puts "Message Complete" 
            sleep(1.0)
            system "clear"
            menu
        end

        def view_outbox(sender)
            outbox = Letter.all.select do |letter|
                letter.sender_id == sender.id
            end
            choices = outbox.map do |letter|
                letter.receiver.name
            end.uniq
            sent_to = prompt.select("Please choose a receiver:", choices)
            if sent_to 
                system "clear"
                friend = Receiver.find_by(name: sent_to)
                mail = friend.letters.map do |letter|
                    letter.content
                end
                view_mail = prompt.select("Please choose a letter:", mail)
                puts view_mail.class.to_s
                if view_mail
                    delete_letter = prompt.select("What would you like to do?") do |menu|
                        menu.choice "Return to Main Menu"
                        menu.choice "Delete Letter"
                    end
                    if delete_letter == "Delete Letter"
                        mail_delete(view_mail)
                    else
                    end
                end
            end
            
            yes_no = prompt.select("Are you ready to return to the Main Menu?") do |menu|
                menu.choice "Yes"
                # menu.choice "No"
            end
            sleep(0.5)
            system "clear"
            menu
        end

        def mail_delete(words) #Cancel outgoing mail
            Letter.where(content: words).destroy_all
            puts "You chased after the mailman and tackled him to the ground. You got your letter back and burned it."
        end
        
        def info_change(sender)
            puts "Your current address is #{sender.address}"
            puts "What would you like to change your address to?"
            new_address = gets.chomp.titlecase
            sender.update(address: new_address)
            puts "Your new address is now: #{sender.address}"
            sleep(2.0)
            system "clear"
            menu
        end
    
end
