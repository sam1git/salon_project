#!/bin/bash
PSQL="psql -X -U freecodecamp -d salon --tuples-only -c "
touch null.txt
#Commenting out the command below for tests to run.
#echo "$($PSQL "TRUNCATE customers, appointments")" > null.txt 2>&1

echo -e "\n~~~ Welcome to NOFO salon ~~~\n"

DETAILS() {
  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | sed 's\^ *\\; s\ *$\\')
    if [[ -z $SERVICE_NAME_SELECTED ]]
    then MAIN_MENU "Invalid entry. Enter valid number."
    else
      echo -e "\nYes, I can help you get set-up for $SERVICE_NAME_SELECTED appointment.\nPlease enter your phone number:"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed 's\^ *\\; s\ *$\\')
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nPlease enter you name:"
        read CUSTOMER_NAME
        echo "$($PSQL "INSERT INTO customers(name,phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")" >> null.txt 2>&1
      fi
      echo -e "\nHi $CUSTOMER_NAME, please enter appointment time:"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      echo "$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")" >> null.txt 2>&1
      echo "I have put you down for a $SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  else MAIN_MENU "Invalid entry. Enter valid number."
  fi
}

MAIN_MENU() {
  if [[ $1 ]]
  then echo -e "$1\n"
  else echo "Please enter the corresponding digit from following options:"
  fi
  echo "$($PSQL "SELECT * FROM services" | sed 's\ |\)\; s\^ *\\; s\ *$\\')"
  DETAILS
}

MAIN_MENU

rm null.txt