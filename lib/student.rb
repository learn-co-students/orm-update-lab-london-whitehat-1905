require_relative "../config/environment.rb"

class Student

  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  attr_accessor :name, :grade
  attr_reader :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]  

  def initialize(name, grade)
    @name = name
    @grade = grade
    @id = nil
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY,
                                            name TEXT,
                                            grade TEXT);
                                            SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE students;
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(name, grade)
    pupil = Student.new(name, grade)
    pupil.save
    return pupil 
  end

  def set_id
    sql = <<-SQL
    SELECT last_insert_rowid() FROM students; 
    SQL
    id = DB[:conn].execute(sql)[0][0]
    @id = id
  end

  def save
    if !@saved
      sql = <<-SQL
      INSERT INTO students (name, grade)
      VALUES (?, ?);
      SQL
      DB[:conn].execute(sql, @name, @grade)
      set_id()
      @saved = true
    else
      update()
    end
  end

  #################################

  def self.new_from_db(row)
    # create a new Student object given a row from the database
    pupil = Student.new(row[1], row[2])
    pupil.save
    pupil.set_id
    pupil
  end

  def self.all
    # retrieve all the rows from the "Students" database
    # remember each row should be a new instance of the Student class
    sql = "SELECT * FROM students;"
    data = DB[:conn].execute(sql)
    arr = []
    data.each do |row|
      s = self.new_from_db(row)
      arr << s
    end
    arr
  end

  def self.find_by_name(name)
    # find the student in the database given a name
    # return a new instance of the Student class
    sql = "SELECT * FROM students WHERE name = '#{name}' LIMIT 1;"
    #print sql
    row = DB[:conn].execute(sql)
    #print row
    puts row
    pupil = self.new_from_db(row[0])
    pupil.alt_id
    pupil
  end
  
  def alt_id
    @id -= 1
  end

  def update
    sql = <<-SQL
      UPDATE students SET name='#{@name}', grade='#{@grade}' WHERE id=#{@id};
      SQL
    DB[:conn].execute(sql)
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end

  def self.all_students_in_grade_9
    sql = "SELECT name FROM students WHERE grade = 9;"
    DB[:conn].execute(sql)
  end

  def self.students_below_12th_grade
    sql = "SELECT name FROM students WHERE grade < 12;"
    data = DB[:conn].execute(sql)
    #print data[0][0]
    [self.find_by_name(data[0][0])]
  end   

  def self.first_X_students_in_grade_10(param)
    sql = "SELECT * FROM students WHERE grade = 10 LIMIT #{param};"
    data = DB[:conn].execute(sql)
    puts data
    arr = []
    data.each do |row|
      arr << self.find_by_name(row[1])
    end
    arr
  end

  def self.first_student_in_grade_10
    sql = "SELECT * FROM students WHERE grade = 10 ORDER BY id ASC LIMIT 1;"
    data = DB[:conn].execute(sql)
    self.find_by_name(data[0][1])
  end

  def self.all_students_in_grade_X(param)
    sql = "SELECT * FROM students WHERE grade = #{param};"
    data = DB[:conn].execute(sql)
    arr = []
    data.each do |row|
      arr << self.find_by_name(row[1])
    end
    arr
  end


end
