# require 'dotenv'
require 'rubygems'
require 'sinatra'

# Dotenv.load

set :static, true
set :public_folder, 'client'
# set :views, File.join(File.dirname(__FILE__), ENV['STATIC_DIR'])
set :port, 4242

countries_file = File.read(File.join('server', 'formatted_countries_file.json'))
countries_hash = JSON.parse(countries_file, symbolize_names: true)

CONSTANTS = {
    FLAGS: countries_hash,
}

ANSWERED_LIMIT = 8

$answered_questions = Set[]
$current_sessions = Set[]
$answers_tested = []

# Endpoints

get '/' do
    # "hello this is up"

    content_type 'text/html'
    send_file File.join(settings.public_folder, 'index.html')
end

post '/session' do
    session_id = createSession()

    return {session_id: session_id}.to_json
end

post '/question' do
    result = createMultipleChoiceQuestion()
    return result.to_json
end

post '/answer' do
    data = JSON.parse(request.body.read, symbolize_names: true)
    answer = data[:answer].to_sym
    puts "Player's answer was"
    puts answer

    result = checkAnswer(answer)

    return result.to_json
end

# Helpers

def createSession()
    session_id = rand(100000)

    while ($current_sessions.include?(session_id))
        session_id = rand(100000)
    end
    
    $current_sessions.add(:session_id)
    return session_id
end

def createMultipleChoiceQuestion()    
    all_keys = CONSTANTS[:FLAGS].keys
    choices = []

    choices[0] = selectDedupedAnswerKey()
    correct_answer = choices[0]
    $answers_tested.push(correct_answer)

    puts "Question's answer is"
    puts correct_answer
    
    for i in 1..3
        choices[i] = selectDedupedOptionKey(correct_answer, choices)
    end
    puts "Choices before shuffle"
    puts choices
    choices = choices.shuffle
    puts "Choices after shuffle"
    puts choices

    result = {
        image: CONSTANTS[:FLAGS][correct_answer.to_sym][:image_url],
        options: {
            choices[0].to_sym => CONSTANTS[:FLAGS][choices[0]][:name] ,
            choices[1].to_sym => CONSTANTS[:FLAGS][choices[1]][:name] ,
            choices[2].to_sym => CONSTANTS[:FLAGS][choices[2]][:name] ,
            choices[3].to_sym => CONSTANTS[:FLAGS][choices[3]][:name] ,
        }
    }
    # puts result
    puts "image is"
    puts result[:image]
    return result
end

def selectDedupedAnswerKey()
    all_keys = CONSTANTS[:FLAGS].keys
    selected_key = all_keys.sample

    # Answer key should NOT be already an answer
    while ($answered_questions.include?(selected_key))
        selected_key = all_keys.sample
    end
    return selected_key
end

def selectDedupedOptionKey(answer, current_choices)
    all_keys = CONSTANTS[:FLAGS].keys
    selected_key = all_keys.sample

    # check if the random key is NOT the right answer and was NOT already an answer and is NOT an existing choice
    while(answer == selected_key || $answered_questions.include?(selected_key) || current_choices.include?(selected_key)) 
        selected_key = all_keys.sample
    end
    return selected_key
end

def currentQuestionAnswer()
    return $answers_tested[-1]
end


def checkAnswer(answer)
    result = {
        correct: false,
    }

    if (answer == currentQuestionAnswer())
        result = {
            correct: true,
        }

        $answered_questions.add(answer)
        puts "Player answered CORRECTLY!!"
    else
        puts "Player answered incorrectly"
    end

    return result
end

# test my question/answer code
# createMultipleChoiceQuestion()
# checkAnswer($questions_sent[-1])
# fix deduping logic