#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]; then
  NEW_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id='$USER_ID'")
  BEST_GAME=$($PSQL "SELECT MIN(tries) FROM games WHERE user_id='$USER_ID'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(($RANDOM % 1000 + 1))
TRY=0
FOUND=0
echo Guess the secret number between 1 and 1000:
read GUESS
((TRY++))

if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
  echo "That is not an integer, guess again:"
  read GUESS
  ((TRY++))
fi

while [ $FOUND -eq 0 ];
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    read GUESS
    ((TRY++))
  elif [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
    read GUESS
    ((TRY++))
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
    read GUESS
    ((TRY++))
  else
    INSERT_TRIES=$($PSQL "INSERT INTO GAMES(user_id, tries) VALUES('$USER_ID', '$TRY')")
    FOUND=1
    echo "You guessed it in $TRY tries. The secret number was $SECRET_NUMBER. Nice job!"
  fi
done