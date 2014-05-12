require 'sqlite3'
require './data'
require './data_mover'
require	'./data_note_taker'
require 'pp'
include DBDoer
include ProjectTools



	def main_fc_screen
		main_fc_choices = {'heading' 		=>'Flash Cards',
						'Start flash cards'		=> 'st',
						'Make a flash card'		=>'m',
						'Flash card training'	=> 'tr',
						}
		ProjectTools::choice_screen(main_fc_choices,5)
	end

	class MakeCard

		attr_accessor :noteid, :question, :answer, :example, :follow_question, :follow_answer, :score

		def initialize(*args)
			@noteid, @question, @answer, @example, @follow_question, @follow_answer, @score = args.flatten
		end

		def to_array
			array = [@noteid, @question, @answer, @example, @follow_question, @follow_answer]

		end

		def formatt(card)
			space(14)
				puts "\t\t#{card}"
			space("std2")		
		end
		
		def percent_of(n)
	    	self.to_f / n.to_f * 100.0
		end
		
		def quest
			formatt(@question)
		end

		def ans
			formatt(@answer)
		end

		def score_answer
			match = 0
			gets.chomp.split(' ').each do |word|
			 match += 1 if	@answer.include?(word)
			end
			actual_answer = @answer.split(' ').length
			@score = (match).percent_of(actual_answer) if match != 0 or match != nil

		end

		def save_to_db 
			arr = to_array
		
			DBDoer::insert("cards",arr)
		end
	end	
	def make_a_card
		q = ['note id', 'Question', 'Answer', 'Example', 'Follow Question', 'Follow answer']
		answers = []
		q.each do |what|
			space(16)
			puts "\twhat is the #{what}"
			space('std1')
			answers << gets.chomp
		end
		card = MakeCard.new(answers)
		
		card.save_to_db
		card.score_answer
		main_fc_screen
	end

	def recive_cards

	end

	def call_card(one_card)
		card = MakeCard.new(one_card)
		card.quest
		gets
	end
