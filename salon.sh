#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  SERVICES_RESULT=$($PSQL "SELECT * FROM services;")

  # List Services
  if [[ ! -z $1 ]]
  then
    echo $1
  fi

  # Display service
  echo "$SERVICES_RESULT" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  
  MAKE_APPOINTMENT
}

MAKE_APPOINTMENT() {
  # Ask for input
  echo -e "\nWhat do you want"
  read SERVICE_ID_SELECTED
  
  # Search for the service
  SERVICE_REQUEST_RESULT=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED';")
  # Return to main menu if the service is not found
  if [[ -z $SERVICE_REQUEST_RESULT ]]
  then
    MAIN_MENU "Please enter a valid service number"
  else 
    # ask for phone number
    echo "You want to make an appointment for $SERVICE_REQUEST_RESULT"
    echo -e "\nwhat is your phone number?"
    read CUSTOMER_PHONE

    # Search for existing customer
    CUSTOMER_QUERY_RESULT=$($PSQL "SELECT * FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_QUERY_RESULT ]]
    then
      echo -e "\nWelcome New Customer, what is your name?"
      read CUSTOMER_NAME
      CREATE_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    echo -e "\nWhen do you want to have the service?"
    read SERVICE_TIME
    CREATE_APT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED';")
    TRIMED_SERVICE_NAME=$(echo "$SERVICE_NAME" | sed -E 's/^\s*(\w*)\s*$/\1/g')
    TRIMED_CUSTOMER_NAME=$(echo "$CUSTOMER_NAME" | sed -E 's/^\s*(\w*)\s*$/\1/g')
    echo -e "\nI have put you down for a $TRIMED_SERVICE_NAME at $SERVICE_TIME, $TRIMED_CUSTOMER_NAME."
  fi
}

MAIN_MENU

