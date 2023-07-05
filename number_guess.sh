#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --tuples-only -c"

echo "Enter your username:"
read USERNAME
USERCLEAN=$(echo -e "$USERNAME" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

if (( ${#USERNAME} < 23 ))
then
  ENTRYCHECK=$($PSQL "SELECT * FROM users WHERE username = '$USERNAME';")

  if [[ -z $ENTRYCHECK ]]
  
  # Empty query, new user
  then
    echo "Welcome, $USERCLEAN! It looks like this is your first time here."
    NEWUSER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  
  # Query worked, old user
  else
    echo $ENTRYCHECK | while read USERNAME PIPE GAMES PIPE PB
    do
      echo "Welcome back, $USERCLEAN! You have played $GAMES games, and your best game took $PB guesses."
    done

  fi

  RNDM=$(( $RANDOM % 1000 + 1 ))
  COUNT=1

  echo -e "Guess the secret number between 1 and 1000:"
  read GUESS

  while [[ $GUESS != $RNDM ]]
  do
    if ! [[ $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      read GUESS
    else
      if (( $GUESS > $RNDM ))
      then
        echo -e "It's lower than that, guess again:"
        read GUESS
        ((COUNT=COUNT+1))
      fi

      if (( $GUESS < $RNDM ))
      then
        echo -e "It's higher than that, guess again:"
        read GUESS
        ((COUNT=COUNT+1))
      fi
    fi
  done

  PBCHECK=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

  if (( $PBCHECK == 0 ))
  then
    NOOB=$($PSQL "UPDATE users SET games_played = (games_played + 1), best_game = $COUNT WHERE username = '$USERNAME'")
  else
    FINISHED=$($PSQL "UPDATE users SET games_played = (games_played + 1), best_game = (SELECT MIN(x) FROM (VALUES (best_game),($COUNT)) AS value(x)) WHERE username = '$USERNAME'")
  fi
  echo -e "You guessed it in $COUNT tries. The secret number was $RNDM. Nice job!"

fi
