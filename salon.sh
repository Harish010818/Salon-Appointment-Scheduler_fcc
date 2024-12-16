#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n" 

MAIN_MENU() {

  #print if not service not available 
  if [[ $1 ]] 
    then
      echo -e "\n$1"
  fi

   #display services       
   MENU_LIST=$($PSQL "SELECT * FROM services")
   echo "$MENU_LIST" | while read SERVICE_ID BAR NAME
   do
      echo "$SERVICE_ID) $NAME"
   done

  
  read SERVICE_ID_SELECTED 
  SERVICE_AVAILABLE=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  #if service not available
  if [[ -z $SERVICE_AVAILABLE ]]
     then
       MAIN_MENU "I could not find that service. What would you like today?"
   else
      echo -e "\nWhat's your phone number?\n"
      read CUSTOMER_PHONE
  
      HAVING_PHONE=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")
      
      # adding new customer
      if [[ -z $HAVING_PHONE ]]
        then
          echo -e "\nI don't have a record for that phone number, what's your name?\n"
          read CUSTOMER_NAME    
          NAME_PHONE_INSERTED=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
          APPOINTMENT 

        else 
          # scheduling appointment for existing customer
          APPOINTMENT 
     fi        

 fi            
}

APPOINTMENT(){
    SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like your $(echo $SERVICE | sed -r 's/^ *| *$//g'), $(echo $NAME | sed -r 's/^ *| *$//g')?\n"

    read SERVICE_TIME
    TIME_INSERTED=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $(echo $SERVICE | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $NAME | sed -r 's/^ *| *$//g')." 
}

MAIN_MENU