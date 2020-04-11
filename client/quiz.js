var questionImage = document.getElementById('question-image');

var option1Button = document.getElementById('option-1-button');
var option2Button = document.getElementById('option-2-button');
var option3Button = document.getElementById('option-3-button');
var option4Button = document.getElementById('option-4-button');

optionButtons = [option1Button, option2Button, option3Button, option4Button]

var allOptions = {};
var optionKeys = [];

// Event handlers

// fetch questions on 
document.addEventListener("DOMContentLoaded", function() {
    fetchQuestion();
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

// Helpers

function fetchQuestion() {
    fetch('/question', {
        method: 'POST',
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
}

function answerButtonPressed(buttonNumber) {
    answerKey = optionKeys[buttonNumber]
    
    console.log(answerKey);

    fetch('/answer', {
        method: 'POST',
        body: JSON.stringify({
            answer: answerKey,
        })
    })
    .then((response) => response.json())
    .then((data) => {
        if (data.correct) {
            alert("Correct answer!");
        }
        else {
            alert("Wrong answer");
        }
    });
}