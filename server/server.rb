# require 'dotenv'
require 'rubygems'
require 'sinatra'

# Dotenv.load

set :static, true
# set :public_folder, File.join(File.dirname(__FILE__), ENV['STATIC_DIR'])
# set :views, File.join(File.dirname(__FILE__), ENV['STATIC_DIR'])
set :port, 4242

CONSTANTS = {
    FLAGS: {
        uk: {
            name: "England",
            image_url: "https://www.countryflags.io/en/flat/64.png",
        },
        us: {
            name: "United States of America",
            image_url: "https://www.countryflags.io/us/flat/64.png",
        },
        pk: {
            name: "Pakistan",
            image_url: "https://www.countryflags.io/pk/flat/64.png",
        },
        in: {
            name: "India",
            image_url: "https://www.countryflags.io/in/flat/64.png",
        },
        de: {
            name: "Germany",
            image_url: "https://www.countryflags.io/de/flat/64.png",
        },
        be: {
            name: "Belgium",
            image_url: "https://www.countryflags.io/be/flat/64.png",
        },
        cn: {
            name: "China",
            image_url: "https://www.countryflags.io/cn/flat/64.png",
        },
        ru: {
            name: "Russia",
            image_url: "https://www.countryflags.io/ru/flat/64.png",
        },
        ar: {
            name: "Argentine",
            image_url: "https://www.countryflags.io/ar/flat/64.png",
        },
        fr: {
            name: "France",
            image_url: "https://www.countryflags.io/fr/flat/64.png",
        },
        ie: {
            name: "Ireland",
            image_url: "https://www.countryflags.io/ie/flat/64.png",
        },
        ng: {
            name: "Nigeria",
            image_url: "https://www.countryflags.io/ng/flat/64.png",
        },
        gh: {
            name: "Ghana",
            image_url: "https://www.countryflags.io/gh/flat/64.png",
        },
        es: {
            name: "Spain",
            image_url: "https://www.countryflags.io/es/flat/64.png",
        },
        pt: {
            name: "Russia",
            image_url: "https://www.countryflags.io/pt/flat/64.png",
        },
        pl: {
            name: "Poland",
            image_url: "https://www.countryflags.io/pl/flat/64.png",
        },
        et: {
            name: "Ethiopia",
            image_url: "https://www.countryflags.io/et/flat/64.png",
        },
        it: {
            name: "Italy",
            image_url: "https://www.countryflags.io/it/flat/64.png",
        },
        ca: {
            name: "Canada",
            image_url: "https://www.countryflags.io/ca/flat/64.png",
        },
        mx: {
            name: "Mexico",
            image_url: "https://www.countryflags.io/mx/flat/64.png",
        },
        au: {
            name: "Australia",
            image_url: "https://www.countryflags.io/au/flat/64.png",
        },
    },
}

$answered_questions = Set[]
$questions_sent = []

# Endpoints

get '/' do
    "hello this is up"
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

def createMultipleChoiceQuestion()    
    all_keys = CONSTANTS[:FLAGS].keys
    questions = []

    questions[0] = selectDedupedAnswerKey()
    answer = questions[0]
    $questions_sent.push(answer)

    puts "Question's answer is"
    puts answer
    
    for i in 1..3
        questions[i] = selectDedupedOptionKey(questions[0])
    end
    questions.shuffle

    result = {
        image: CONSTANTS[:FLAGS][answer.to_sym][:image_url],
        options: [
            {questions[0].to_sym => CONSTANTS[:FLAGS][questions[0].to_sym] },
            {questions[1].to_sym => CONSTANTS[:FLAGS][questions[1].to_sym] },
            {questions[2].to_sym => CONSTANTS[:FLAGS][questions[2].to_sym] },
            {questions[3].to_sym => CONSTANTS[:FLAGS][questions[3].to_sym] },
        ]
    }
    # puts result
    return result
end

def selectDedupedAnswerKey()
    all_keys = CONSTANTS[:FLAGS].keys
    selected_key = all_keys.sample

    # Answer key should NOT be already an answer
    while ($answered_questions.include?(selected_key))
        selected_key = selected_key = all_keys.sample
    end
    return selected_key
end

def selectDedupedOptionKey(answer)
    all_keys = CONSTANTS[:FLAGS].keys
    selected_key = all_keys.sample

    # check if the random key is NOT the right answer and was NOT already an answer
    while(answer == selected_key || $answered_questions.include?(selected_key)) 
        selected_key = all_keys.sample
    end
    return selected_key
end

def lastQuestionsAnswer()
    return $questions_sent[-1]
end


def checkAnswer(answer)
    result = {
        correct: false,
    }

    if (answer == lastQuestionsAnswer())
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

