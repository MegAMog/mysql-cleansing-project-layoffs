import utils.path as path
import os

import pandas as pd

import sqlalchemy
from dotenv import load_dotenv


csv_file=os.path.join(path.data_dir, "layoffs.csv")

#1. Extract raw data into DataFrame object
data = pd.read_csv(csv_file)


#2. Load raw data into table

# Load .env variables
load_dotenv()

host_name = "localhost"
database_name = os.environ.get("MYSQL_DATABASE")
user_name = os.environ.get("MYSQL_USER")
user_password = os.environ.get("MYSQL_USER_PASSWORD")

conn_string = f"mysql+pymysql://{user_name}:{user_password}@{host_name}:3307/{database_name}"
engine = sqlalchemy.create_engine(conn_string)

table_name='raw_layoffs'
with engine.connect() as connection:
    try:
        data.to_sql(
            table_name, 
            con=connection, 
            if_exists='append', 
            index=False,
            method='multi')
        
        print(f"Data has been successfully uploaded to {table_name}.\n")

    except sqlalchemy.exc.IntegrityError:
        print(f"Failed to insert into {table_name} due to unique constraint violation.\n")

    except sqlalchemy.exc.StatementError:
        print(f"Failed to insert into {table_name} due to data type mismatch.\n")
    
    except sqlalchemy.exc.SQLAlchemyError as ex:
        print('Failed to insert due to SQLAlchemy error:', ex)