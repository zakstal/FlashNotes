
require 'sqlite3'

module DBDoer
	# open_db opens the requested database
	def open_db(db_name)
		db = SQLite3::Database.open"#{db_name}"
		db
	end
	# db_doer executes a sqlite string when our_in is set to in 
	# and when set to out, returns any the result of an executed string
	def db_doer(out_in, db, stringmaker)
		db = open_db("#{db}.db")
		begin
			if out_in == "in"
				db.execute stringmaker
			elsif out_in == "out"
				get_out = db.execute stringmaker
				return get_out
			else
				"missing in or out"
			end

		end
		db.close
	end

	# the stringmaker allows you to select when you want to do in the database,
	# create a table, make a column, insert a record, delete a record or update an entry.
	# it takes the arguments, inserts them into a string, and then runs the db_doer
	def stringmaker_create_porject_db(select, db, table, *args)
		#this expl_arr lambda takes and array and makes a string
		expl_arr = -> arr{arr.map{|x| x.inspect}.join(', ')}
		case select
			when :new_table
				puts "yes table ..... #{table}"
				#create a table: db, new_db
				data = "CREATE TABLE IF NOT EXISTS #{table} (id INTEGER PRIMARY KEY AUTOINCREMENT)"
			when :new_column
				#add column: table, col_name
				puts "yes columns ..... #{args[0]}"
				data = "ALTER TABLE #{table} ADD COLUMN #{args[0]} TEXT"
			when :insert
				#insert into table: col_name,value
				puts "insert"
				cols = expl_arr.call(args[0][0])
				vals = expl_arr.call(args[0][1])
				data = "INSERT INTO #{table}(#{cols}) VALUES(#{vals})"
			when :delete
				#delete entry from table: table ,col_name,value
				puts "delete"
				cols = args[0][0]
				vals = args[0][1]
				data = "DELETE FROM #{table} WHERE #{cols}=#{vals}"
			when :update_entry
				#update entry: table, col_name, new_value, ,value
				col_name 	= args[0][2]
				new_value 	= args[0][3]	
				id 			= args[0][0]
				val&ue 		= args[0][1]
				puts "here"
				data = "UPDATE #{table} SET '#{col_name}'= '#{new_value}' WHERE '#{id}'='#{value}'"
		end
		db_doer('in', db,data)
	end

	# this allows you to create a table and its columns in one go
	# put the name of the table as the first argument, then add 
	# as many columns as needed
	def add_a_table(table, *cols)
		stringmaker_create_porject_db :new_table, 'notes_and_flashcards', table
			columns = cols
				columns.each do |col|
					stringmaker_create_porject_db :new_column, 'notes_and_flashcards', table, col
				end
	end

	# this is the initial table setup for all the info the program will do. 
	# more tables can be added if needed with add_a_table
	def set_up_tables
		add_a_table("projects", 'projects')
		add_a_table("cat",'projects_id', 'catagory')
		add_a_table("notes",'projects_id','cat_id', 'pagenum_or_note_name', 'note')
		add_a_table("cards", 'notes_id', 'Question', 'Answer','Example', 'Follow_Question', 'Follow_Answer')
		add_a_table("scores", 'cards_id', 'score', 'time_date')
		#add_a_table("saved_project_notetakeing", "projects_id", "cat_id", Time.now) this is for saved note projects
		puts "set up complete"
	end


	# this retrives the columns in a table.
	# the all in all_or_nonid retrives all the columns and outputs an array.
	# the nonid retrives all columns except the id column and retuns an array
	# that is used in insert_into_table 
	def table_columns(all_or_nonid, table)
		cols = []
		table_cols = "PRAGMA table_info('#{table}')"
		db_doer('out',"notes_and_flashcards", table_cols).each do |col|
			if	all_or_nonid == "all"
				cols << col[1] 
			elsif all_or_nonid == "nonid"
				cols << col[1] if col[1] != 'id'
			else
				puts "wrong argument, all nor nonid"
			end
		end
		#puts "yes colms"
		cols
	end

	# insert_into_table takes the idless array of columns from table_columns (when set to nonid)
	# and puts that array along with an array of values that you want to insert into a table into a
	# new array called args which is sent off to the stringmaker to be executed. sounds morbid.
	def insert(table, *values)
		args = []
		args << table_columns('nonid', table) << values.flatten
		stringmaker_create_porject_db :insert, 'notes_and_flashcards', table, args
	end

	def delete(table, *values)
		args = []
		args << table_columns('all', table)[0] << values.flatten
			args.flatten!
			stringmaker_create_porject_db :delete, 'notes_and_flashcards', table, args
	end

	def update(table,*values)
		args = []
		args << table_columns('all', table)[0] << values.flatten
			args.flatten!
		stringmaker_create_porject_db :update_entry, 'notes_and_flashcards', table, args
	end

	# def ins_del_updt(insert_delete_update, table, *values)
	# 	args = []
		
	# 	#p args
	# 	if insert_delete_update == "insert"
	# 		choice = :insert
	# 		args << table_columns('nonid', table) << values.flatten
	# 	elsif insert_delete_update == "delete"
	# 		choice = :delete
	# 		args << table_columns('all', table)[0] << values.flatten
	# 		args.flatten!
	# 	elsif insert_delete_update == 'update'
	# 		choice = :update_entry
	# 		args << table_columns('all', table)[0] << values.flatten
	# 		args.flatten!
	# 	else
	# 		"insert of delete?"
	# 	end
	# 	p args
	# 	stringmaker_create_porject_db choice, 'notes_and_flashcards', table, args
	# end	

	# this shows all the data from a requested table
	def show_all_table(table)
		db_doer('out',"notes_and_flashcards", "SELECT * FROM '#{table}'")
	end

	def select_from(table, col, amount)
		db_doer('out',"notes_and_flashcards", "SELECT * FROM '#{table}' WHERE #{col}='#{amount}'")
	end
end

	