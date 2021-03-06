#Random pickup-line generator

#User-stories
#I want to send an SMS to a phone number
#by using the console typing "generator.ruby send number person"
#The SMS includes
# - a random pickup pickup-line
# - the name of the person
# - some other intro text

#require 'rubygems'
#require 'twilio-ruby'

#Object-design
# This is part of a pattern called a "method object" -- look up for more info
class QuoteRetriever
	def initialize(type)
		@type = type
	end

	def quote
		raise "File does not exist" unless File.exists?(file_name)
		File.open(file_name).readlines.sample
	end

	private
		def file_name
			@type + ".txt"
		end
end


class Controller
	def initialize(quote)
		@quote = quote
	end

	def run(input)
		# Embrace destructured assignment and the "splat" operator
		quote = QuoteRetriever.new(quote_type).quote
		quote_type, command, number, name = *input
		raise "you must pass the `send` command" unless command
		print_status(name, number)
		message = Message.generate(name, Parser.run(file_name), quote_type)
		Messenger.send_SMS(number, message)
	end

	private

		def print_status(name, number)
			p "send to #{$name}, number #{$number}"
			p "the following message"
		end
end

class Viewer
	def render(text)
	end
end

class Message
	def self.generate(name, all_messages, type)
		line = all_messages.sample.join(" ")
		if type == "sherif"
			return "#{name}, #{line.downcase} Best wishes, Sherif"
		else
			return "#{name}, #{line}"
		end
	end
end

class Parser
	attr_reader :messages

	@all_messages = []

	def self.run(file)
		File.open(file).each do |line|
			@all_messages << line.split
		end
		return @all_messages
	end

	def self.show
		@all_messages.each do |message|
			p message
		end
		p @all_messages.size
	end

# Inspiration for some day....a Sinatra route which knows how to Twilio-out a message..good luck!
# post '/pickups/:source_phone' do
# 	pickup = Pickup.all.sample
# 	Twilio.new(content: pickup.body, destination: params[:source_phone])
# end


end

class Messenger
	def self.send_SMS(number, message)
		`curl -X POST 'https://api.twilio.com/2010-04-01/Accounts/AC7a19ff5f4ab5fe7d93e722f8fff9bc3f/Messages.json' \
		--data-urlencode 'To=#{number}'  \
		--data-urlencode 'From=+16504092678'  \
		--data-urlencode 'Body="#{message}"' \
		-u AC7a19ff5f4ab5fe7d93e722f8fff9bc3f:7d19dc48b3fad97e4b1a001541cb9a5e`
		p "message sent"
		p message
	end
end

puts
Kernel.exit 0
#Run program
# this is known as dependency inversion
# Normally speaking a controller would need to get a quote, in order to SMS it out, but instead what we say is
# Controller, you will be given a quote, and then you need to bundle it up into an SMS.  The idea is that
# a programmer can look at the following line and know where the quote comes from at a glance, and can trust
# that the string (a quote) that is passed in, will not be changed
Controller.new(QuoteRetriever.new('pickup').quote).run(ARGV)
#p $command == "send"

#Driver code
#p Message.generate("Justin", Parser.run('pickups.txt'))
#Parser.show

#p $messages.count != 0



