require 'sqlite3'
require './data'
require 'pp'
#require './data_main'
include DBDoer

module ProjectTools

	
	def choice_screen(fills, choices)
		space('std1')
		headings(fills['heading'])
		fills.each do |key,value|
			next if key == "heading"
			choice_ask(key, value)
		end
		space('std2')
		options
		make_choice(choices)
	end
	def top_crud_choices
		top_choices = {	'heading' 				=> 'Project Tools',
						'Work with projects'	=> 'projects',
						'Work with projects'	=> 'projects',
						'Work with catagories'	=> 'cat',
						'Work with notes'		=> 'notes',
						'Work with flash cards'	=> 'cards',
					}
		choice_screen(top_choices,0)
	end

	# cruder screen level allows cruding on indavidual tables
	def cruder(thing_to_do)
		begin
			space('std1')
			headings("#{thing_to_do.capitalize}")
			choice_ask("Look up a #{thing_to_do.gsub(/s$/,'')}", "look")
			choice_ask("create a #{thing_to_do.gsub(/s$/,'')}", "make")
			choice_ask("Update a #{thing_to_do.gsub(/s$/,'')}", "up")
			choice_ask("Delete a #{thing_to_do.gsub(/s$/,'')}", "del")
			space('std2')
			options
			make_choice(1,thing_to_do)
		rescue 
			puts "#{thing_to_do} is not a real thing...ok"
			top_crud_choices
		end
		
	end

	def options
		puts "| Optoins >> | main | proj | note |"
	end
	
	def exit
		make_choice(5)
	end

	# choices handler *************************************************************************************


	# make_choice recives and routes chocies
	def make_choice(what_level_to_do, *table)
		return_or_no = 0
		what = gets.chomp
		top_crud_choices if what == 'proj'
		main_screen if what == 'main'
		take_notes_screen if what == 'note' 
		
		case what_level_to_do
			when 0
				#if what.included_in?(["projects","cat","notes","cards"])
				cruder(what)
				#else
					puts "wrong selection"
					top_crud_choices
				#end
			when 1
				#puts "make choice"
				puts table
				database_filler(what, table,0)
				top_crud_choices
			when 2
				#main screen choices
				case what
					when 'pt'
						top_crud_choices
					when 'take'
						take_notes_screen
					when 'fc'
						main_fc_screen	
					else
						puts "what does that mean???\n\n"
						make_choice(what_level_to_do, table)	
				end
			when 3
				#puts "in case 3 choice_ask"
				case what
					when 'new'
						the_whole_shbang
					when 'e'
						
					when 'view'
						
						main_screen
					when 'lo'
						
						main_screen		
					when 'in'
						instructions

					else
						puts "what does that mean???\n\n"
						make_choice(what_level_to_do, table)
				end

			when 4
				return_or_no = 1

			when 5
				case what
					when 'st'

					when 'm'
						make_a_card
					when 'tr'
				end
					

			else

				puts "thats not a choice"
				make_choice(what_level_to_do, table)

		end
		what if return_or_no == 1
	end



#database interaction**************************************************************************************
	def database_looker(what_to_do, table,pauser, *args)

		case what_to_do
			when 'lookat'
					puts "database looker #{table}"
					puts "in database looker #{args[0]}, #{args[1]}"
		 			all = DBDoer::select_from(table*'',args[0],args[1])
					col = DBDoer::table_columns('all', table*'')
					print_columns(col,all)
			else
				"non"
				main_screen
		end
			
		pause = gets if pauser == 0
	end

	# database_filler recives the crud choices 
	# and routes the choice toe the database column questions 
	# to receive answers that are sent to the dbdoer for processing 
	# into the database
	# the pauser will stop at the end of this method if it is equal to zero
	def database_filler(what_to_do, table,pauser)
		#stringer takes an array and makes a string
		stringer = ->arr{arr.map{|x| x.inspect}*', '} 
		#fixed_me takes the stringer array and removes \" and any extra whitespace
		fixed_me = ->thing{stringer.call(thing).gsub!(/\"/," ").strip}
		case what_to_do
		 	
			when 'look'
					all = DBDoer::show_all_table(fixed_me.call(table))
					col = DBDoer::table_columns('all', fixed_me.call(table))
					print_columns(col,all)
			when 'make'
				args = database_all_column_questions(fixed_me.call(table))
					DBDoer::insert(fixed_me.call(table), args)
			when 'up'
				args = database_all_column_questions(fixed_me.call(table))
					DBDoer::update(fixed_me.call(table),args)
			when 'del'
				args = database_all_column_questions(fixed_me.call(table)) 
					DBDoer::delete(fixed_me.call(table), args)
		end
		#puts "in database filler"
		pause = gets if pauser == 0
		
	end

	# database comun questions parses the database columns and 
	# poses each column as a question, then recives the answers
	# and puts them into an array 
	def database_all_column_questions(table,*skipif)
		#puts "now in col quest"
		recived_answers = [[]]
			col = DBDoer::table_columns('nonid', table)
				puts col
				quest = "\twhat is the "
				i = 0
				defined_lookup = ''

					col.each do |q|

						i +=1
						go_to_next = 0
						skipif.each do |sk|
						 	
							go_to_next = 1 if i == sk 
							
						end

						next if go_to_next == 1
							space('std2')
								print_columns(col, recived_answers)
									space('std1')
										puts quest + q + "\n"
												choose_one(q,col[i-2],recived_answers[0].last) if q.include?('id') && q != 'id'
								choice = gets.chomp
							recived_answers[0] << choice
							
					end

				print_columns(col, recived_answers)
				recived_answers
	end

	def choose_one(table, *filter)

		tab = table.gsub(/_id$/,'')
		
			puts "\n\tor to show all #{tab}? type 'y' or hit enter to continue"
				choice = gets.chomp
					if choice == 'y'
						p tab
							tabs = []
								tabs << tab
								if tab == "projects"
									database_filler('look', [tab],1)
								else
								
									database_looker('lookat', tabs, 1, filter[0], filter[1])
								end
								
						puts "\n\ttype in project id"
					end

	end



	#style elements**************************************************************************************


	# headings creats consistent heading lengths through each screen
	def headings(name)
		head_length_remove = name.to_s.length/2
		heading = "________________________________   #{name}   ________________________________"
		puts "\n\n"+ "  " + heading[head_length_remove..(head_length_remove*-1)] + "\n\n\n\n"
	end

	# choice_ask creates consistent placement of choices and input optoins on each screen
	def choice_ask(choices, input_option)
		space = "                                         "
		in_opt = "- type '#{input_option.to_s}'\n\n"
		choice = "\t#{choices.to_s}"
		new_space = space[choice.length..space.length]
		your_choice = choice + new_space + in_opt
		puts your_choice 
	end

	#this gives opetional standard spacing for printed strings
	def space(standard_or_number_of_times)
		space ="\n"
		tab = "\t"
		case standard_or_number_of_times
			when 'std1'
				3.times{puts space}
			when 'std2'
				9.times{puts space}
			when 'tab1'
				2.times{puts tab}
			else
				standard_or_number_of_times.times{puts space}
			end
	end

	# prints out columns from tables and inputs and outputs a standard output
	def print_columns(cols,inputs)
		space 	= "              "
		all_col = each_column(cols,space)
		space('std1')
		puts all_col
		puts "-------------------------------------------------------------------------------"
		inputs.each do |ins|
			puts each_inpute(ins,space)
		end
	end

	def each_column(cols,space)
		all_col = "\t"
		cols.each do |col|
			all_col << col << (space[0..-col.length])
		end
		all_col
	end

	def each_inpute(inputs,space)
		all_in = "\t"
		inputs.each do |ins|
			into = ins.to_s[0..12]
			all_in << into.to_s << (space[0..-into.to_s.length])
		end
		all_in
	end
end
 #if not exists(select * from sys.databases where name = 'notes_and_flashcards')
# 	DBDoer::set_up_tables
 #end
# puts "cols"
# pp table_columns('nonid', 'notes')
# puts "stuff"
# pp show_all_table('notes')
#Project_tools::top_crud_choices