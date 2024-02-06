# import logging
# import json
# from forex_python.converter import CurrencyRates

# logger = logging.getLogger()
# logger.setLevel(logging.INFO)

# GET FUNCTION BELOW FROM PROJECT 2
db_config = {
    'host': os.environ['DB_HOST'],
    'port': os.environ['DB_PORT'],
    'user': os.environ['DB_USER'],
    'password': os.environ['DB_PASSWORD'],
    'database': os.environ['DB_NAME']
}

def lambda_handler(event, context):
    
    # Gets the entire request and puts it in JSON format
    body = json.loads(json.dumps(event))
    print(body)
    
    
    
  # Gets specifically the form data from the request and stores it as a dictionary in python
    data = { k: v
        for k, item in parse_qs(body["body"]).items()
        for v in item
    }
    
    # {'id': '21', 'joke': 'Loki cool?', 'answer': 'no'}
    
    dish = data["dish"]
    ingredients = data["ingredients"]
    
    # # Connect to the MySQL Database
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    
    # # Execute a create table function to make the table in case it doesnt exist
    # cursor.execute(
    #     "create table if not exists music(id int primary key auto_increment, title varchar(50), length varchar(50), genre varchar(50), artist varchar(50), album varchar(50))"
    # )
    
    # # Inserts data into RDS database
    query = "select dish,answer from menu_table ORDER BY RAND() LIMIT 1; values (%s, %s)"
    query = "select * from menu_table (dish, ingredients) values (%s, %s)"
    query = "select from menu_table (dish, ingredients) values (%s, %s)"
    cursor.execute(query, (dish, ingredients))
    
    # # Commit the transaction and close the connection
    connection.commit()
    cursor.close()
    connection.close()
    
    print(data)
    
    return {
        'statusCode': 200,
        'body': json.dumps(data)
    }

# POST FUNCTION BELOW FROM PROJECT 2

import json
from urllib.parse import parse_qs
import mysql.connector
import os

db_config = {
    'host': os.environ['DB_HOST'],
    'port': os.environ['DB_PORT'],
    'user': os.environ['DB_USER'],
    'password': os.environ['DB_PASSWORD'],
    'database': os.environ['DB_NAME']
}

def lambda_handler(event, context):
    print(event)
    # Gets the entire request and puts it in JSON format
    body = json.loads(json.dumps(event))
    print(body)
    

    
  # Gets specifically the form data from the request and stores it as a dictionary in python
    data = { k: v
        for k, item in parse_qs(body["body"]).items()
        for v in item
    }
    
    # {'id': '21', 'joke': 'Loki cool?', 'answer': 'no'}
    
    #number = data["number"]
    name = data["name"]
    email = data["email"]
    
    # # Connect to the MySQL Database
    connection = mysql.connector.connect(**db_config)
    cursor = connection.cursor()
    
    # # Execute a create table function to make the table in case it doesnt exist
    # cursor.execute(
    #     "create table if not exists music(id int primary key auto_increment, title varchar(50), length varchar(50), genre varchar(50), artist varchar(50), album varchar(50))"
    # )
    
    # # Inserts data into RDS database
    query = "insert into subscriber_table (name, email) values (%s, %s)"
    cursor.execute(query, (name, email))
    
    # # Commit the transaction and close the connection
    connection.commit()
    cursor.close()
    connection.close()
    
    print(data)
    
    return {
        'statusCode': 200,
        'body': json.dumps(data)
    }




# def lambda_handler(event, context):
#     """
#     The Lambda handler function that gets invoked when the API endpoint is hit
#     """
#     amount = event['queryStringParameters']['amount']
#     fromCurrency = event['queryStringParameters']['fromCurrency']
#     toCurrency = event['queryStringParameters']['toCurrency']
#     logger.info('## Input Parameters: %s, %s, %s', amount, fromCurrency, toCurrency)
#     res = convert_currency(amount, fromCurrency, toCurrency)
#     logger.info('## Currency result: %s', res)
#     response = {
#         "statusCode": 200,
#         "body": json.dumps({'result': res}),
#     }
#     logger.info('## Response returned: %s', response)
#     return response


# def convert_currency(amount: float, fromCurrency: str, toCurrency: str) -> float:
#     """
#     Function to convert an amount from one currency to another
#     """
#     c = CurrencyRates()
#     res = c.convert(fromCurrency, toCurrency, float(amount))
#     return float(res)