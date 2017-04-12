require 'sqlite3'
require 'singleton'
require 'byebug'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super('questions.db')
    self.type_translation = true
    self.results_as_hash = true
  end

end

class User

  attr_accessor :fname, :lname
  attr_reader :id
  def initialize(options)
    @id = options['id']
    @fname = options['fname']
    @lname = options['lname']
  end

  def self.find_by_name(fname, lname)
    name = QuestionsDatabase.instance.execute(<<-SQL, fname, lname)
      SELECT *
      FROM users
      WHERE fname = ? AND
            lname = ?
    SQL

    return nil unless name.length > 0
    User.new(name.first)
  end

  def authored_questions
    Question::find_by_author_id(@id)
  end

  def authored_replies
    Reply::find_by_user_id(@id)
  end

  def followed_questions
    QuestionFollow::followed_questions_for_user_id(@id)
  end


end

class Question

  attr_accessor :title, :body, :user_id
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @title = options['title']
    @body = options['body']
    @user_id = options['user_id']
  end

  def self.find_by_author_id(author_id)
    question = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        questions
      WHERE
        user_id = ?
    SQL
    return nil unless question.length > 0

    question.map {|quest| Question.new(quest)}
  end

  def author
    QuestionsDatabase.instance.execute(<<-SQL, @user_id)
      SELECT
        fname, lname
      FROM
        users
      WHERE
        @user_id = id
      SQL
  end

  def replies
    Reply::find_by_question_id(@id)
  end

  def followers
    QuestionFollow::followers_for_question_id(@id)
  end



end

class Reply

  attr_accessor :question_id, :parent_id, :response, :user_id

  def initialize(options)
    @id = options['id']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @response = options['response']
    @user_id = options['user_id']
  end

  def self.find_by_user_id(user_id)
    reply = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT
        *
      FROM
        replies
      WHERE
        user_id = ?
    SQL
    return nil unless reply.length > 0
    reply.map {|rep| Reply.new(rep)}
  end

  def self.find_by_question_id(question_id)
    replies = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT *
      FROM replies
      WHERE question_id = ?
   SQL

   return nil unless replies.length > 0
   replies.map { |rep| Reply.new(rep) }
  end

  def author
    QuestionsDatabase.instance.execute(<<-SQL, @user_id)
      SELECT
        fname, lname
      FROM
        users
      WHERE
        @user_id = id
      SQL
  end

  def question
    QuestionsDatabase.instance.execute(<<-SQL, @question_id)
      SELECT
        title, body
      FROM
        questions
      WHERE
        @question_id = id
      SQL
  end

  def parent_reply
    QuestionsDatabase.instance.execute(<<-SQL, @id)
      SELECT
        response
      FROM
        replies
      WHERE
        @id = id
      SQL
  end


  def child_replies
    QuestionsDatabase.instance.execute(<<-SQL, @parent_id)
      SELECT
        response
      FROM
        replies
      WHERE
        @parent_id = parent_id
      SQL
  end

end

class QuestionFollow
  attr_accessor :follower, :question_id
  attr_reader :id

  def initialize(options)
    @id = options['id']
    @follower = options['follower']
    @question_id = options['question_id']
  end

  def self.followers_for_question_id(question_id)
    followers = QuestionsDatabase.instance.execute(<<-SQL, question_id)
    SELECT *
    FROM users
    JOIN question_follows ON question_follows.follower = users.id
    WHERE follower = ?
    SQL
    followers.map {|follower| User.new(follower)}
  end

  def self.followed_questions_for_user_id(user_id)
    user_followers = QuestionsDatabase.instance.execute(<<-SQL, user_id)
      SELECT *
      FROM questions
      JOIN question_follows ON questions.user_id = question_follows.follower
      WHERE follower = ?
    SQL

    user_followers.map {|follower| Question.new(follower)}
  end


end

r2 = Reply.new('id' => 2, 'question_id' => 1, 'parent_id' => 1, 'response' => 'blah blah blah', 'user_id' => 1)
r1 = Reply.new('id' => 1, 'question_id' => 1, 'parent_id' => nil, 'response' => 'blah blah blah', 'user_id' => 1)
q = Question.new('id' => 1, 'title'  => 'blah', 'body' => 'blhablah', 'user_id' => 1)
a= User.new('id'=>1, 'fname'=>'Brandon', 'lname'=>'Chui')
