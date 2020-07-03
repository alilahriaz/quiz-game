var questionImage = document.getElementById('question-image');

var option1Button = document.getElementById('option-1-button');
var option2Button = document.getElementById('option-2-button');
var option3Button = document.getElementById('option-3-button');
var option4Button = document.getElementById('option-4-button');

optionButtons = [option1Button, option2Button, option3Button, option4Button]

var allOptions = {};
var optionKeys = [];
var session_id = null;

// Event handlers

// fetch questions on 
document.addEventListener("DOMContentLoaded", function() {
    fetchSession();
});

option1Button.addEventListener('click', (e) => {
    e.preventDefault();

    answerButtonPressed(0);
});
option2Button.addEventListener('click', (e) => {
    e.preventDefault();

    answerButtonPressed(1);
});
option3Button.addEventListener('click', (e) => {
    e.preventDefault();

    answerButtonPressed(2);
});
option4Button.addEventListener('click', (e) => {
    e.preventDefault();

    answerButtonPressed(3);
});

questionNumberLabel = document.getElementById('question-number-label');
correctAnswerLabel = document.getElementById('correct-answer-label');

// Helpers

function fetchSession() {
    fetch('/session', {
        method: 'POST',
    })
    .then((response) => response.json())
    .then((data) => {
        session_id = data.session_id;
        console.log("Session ID is", session_id);
        fetchQuestion();
    });
}

function fetchQuestion() {
    var body = JSON.stringify({
        session_id: session_id,
    });
    console.log("Body is", body);


    fetch('/question', {
        method: 'POST',
        body: JSON.stringify({
            session_id: session_id,
        })
    })
    .then((response) => response.json())
    .then((data) => {
        console.log(data);
        setupUIWithData(data);
    });
}

function setupUIWithData(data) {
    questionImage.src = data["image"];

    allOptions = data.options;
    optionKeys = [];
    
    console.log("MCQs:")
    console.log(allOptions)

    counter = 0;
    for (optionKey in allOptions) {
        optionKeys[counter] = optionKey

        var optionText = allOptions[optionKey];
        optionButtons[counter].innerHTML = optionText;
        
        counter++;
    }
    questionNumberLabel.innerHTML = 'Question ' + data.question_number;
}

function answerButtonPressed(buttonNumber) {
    answerKey = optionKeys[buttonNumber]
    
    console.log(answerKey);

    fetch('/answer', {
        method: 'POST',
        body: JSON.stringify({
            session_id: session_id,
            answer: answerKey,
        })
    })
    .then((response) => response.json())
    .then((data) => {
        if (data.correct) {
            alert("Correct answer! :)");
        }
        else {
            alert("Sorry, wrong answer :(\nCorrect answer is " + data.correct_answer);
        }

        if (data.complete) {
            alert("Congrats! Quiz Complete!\nYour score is " + data.score + " / " + data.total_questions)
            location.reload();
        }
        else {
            fetchQuestion();
        }
    });
}