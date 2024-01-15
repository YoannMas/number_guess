#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

GUESSING_GAME() {
  echo -e "\nEnter your username:"
  read USERNAME
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  if [[ -z $USER_ID ]]
  then
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  else
    GAMES_HISTORY=$($PSQL "SELECT COUNT(user_id), MIN(score) FROM games WHERE user_id = $USER_ID")
    echo $GAMES_HISTORY | while IFS=" |" read TOTAL_GAMES BEST_SCORE
    do
      echo -e "\nWelcome back, $USERNAME! You have played $TOTAL_GAMES games, and your best game took $BEST_SCORE guesses."
    done
  fi
  echo -e "\nGuess the secret number between 1 and 1000:"
  read TENTATIVE
  SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))
  NB_OF_TENTATIVES=1
  while [[ $TENTATIVE != $SECRET_NUMBER ]]
  do
    if [[ ! $TENTATIVE =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
      read TENTATIVE
    elif [[ $TENTATIVE -lt $SECRET_NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"
      read TENTATIVE
    else
      echo -e "\nIt's lower than that, guess again:"
      read TENTATIVE
    fi
    ((NB_OF_TENTATIVES++))
  done
  echo -e "\nYou guessed it in $NB_OF_TENTATIVES tries. The secret number was $SECRET_NUMBER. Nice job!"
  INSERT_GAME_RETURN=$($PSQL "INSERT INTO games(score, user_id) VALUES($NB_OF_TENTATIVES, $USER_ID)")
}

GUESSING_GAME
