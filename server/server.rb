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

$current_sessions = {}

# Endpoints

get '/' do
    content_type 'text/html'
    send_file File.join(settings.public_folder, 'index.html')
end

post '/session' do
    session_id = createSession()

    return {session_id: session_id}.to_json
end

post '/question' do
    data = JSON.parse(request.body.read, symbolize_names: true)
    session_id = data[:session_id]

    result = createMultipleChoiceQuestion(session_id)
    return result.to_json
end

post '/answer' do
    data = JSON.parse(request.body.read, symbolize_names: true)
    answer = data[:answer].to_sym
    session_id = data[:session_id].to_s

    result = checkAnswer(session_id, answer)

    return result.to_json
end

# Helpers

def createSession()
    session_id = rand(100000)

    session_ids = $current_sessions.keys
    
    while (session_ids.include?(session_id))
        session_id = rand(100000)
    end
    
    $current_sessions[session_id.to_s] = {
        answered_questions: Set[],
        answers_tested: []
    }

    return session_id
end

def createMultipleChoiceQuestion(session_id)    
    choices = []

    # grab this current user's session specific details
    current_session_object = grabSessionObjectById(session_id)

    answered_questions_for_session = current_session_object[:answered_questions]
    answers_tested_for_session = current_session_object[:answers_tested]

    choices[0] = selectDedupedAnswerKey(answered_questions_for_session)
    correct_answer = choices[0]
    
    answers_tested_for_session.push(correct_answer)
    
    for i in 1..3
        choices[i] = selectDedupedOptionKey(answered_questions_for_session, choices)
    end
    choices = choices.shuffle

    result = {
        image: CONSTANTS[:FLAGS][correct_answer.to_sym][:image_url],
        options: {
            choices[0].to_sym => CONSTANTS[:FLAGS][choices[0]][:name] ,
            choices[1].to_sym => CONSTANTS[:FLAGS][choices[1]][:name] ,
            choices[2].to_sym => CONSTANTS[:FLAGS][choices[2]][:name] ,
            choices[3].to_sym => CONSTANTS[:FLAGS][choices[3]][:name] ,
        }
    }
    return result
end

def selectDedupedAnswerKey(answered_questions_for_session)
    all_keys = CONSTANTS[:FLAGS].keys

    unanswered_array = all_keys - answered_questions_for_session.to_a

    selected_key = unanswered_array.sample
    return selected_key
end

def selectDedupedOptionKey(answered_questions_for_session, current_choices)
    all_keys = CONSTANTS[:FLAGS].keys
    selected_key = all_keys.sample

    unanswered_array = all_keys - (answered_questions_for_session.to_a + current_choices)

    selected_key = unanswered_array.sample
    return selected_key
end

def currentQuestionAnswer(session_id)
    answers_tested_for_session = grabSessionObjectById(session_id)[:answers_tested]
    return answers_tested_for_session[-1]
end

def updateAnsweredQuestionsForSession(session_id, answer)
    answered_questions_for_session = grabSessionObjectById(session_id)[:answered_questions]
    answered_questions_for_session.add(answer)
end


def checkAnswer(session_id, answer)
    result = {
        correct: false,
    }

    if (answer == currentQuestionAnswer(session_id))
        result = {
            correct: true,
        }

        updateAnsweredQuestionsForSession(session_id, answer)
        puts "Answer CORRECT!!"
    else
        puts "Answer wrong"
    end

    return result
end

def grabSessionObjectById(session_id)
    return $current_sessions[session_id.to_s]
end

# test my question/answer code