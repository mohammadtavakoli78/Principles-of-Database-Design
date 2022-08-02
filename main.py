import mysql.connector
import prettytable
from prettytable import PrettyTable

mydb = mysql.connector.connect(
  host="localhost",
  user="root",
  password="",
  database="librarySystemManager"
)

mycursor = mydb.cursor()

id = ''

menu = "1) Login \n" \
           "2) Create Account \n" \
           "3) Get Information \n" \
           "4) Search a book \n" \
           "5) Reserve a book \n" \
           "6) Return Book \n" \
           "7) Increase Balance \n" \
           "8) Add a book \n" \
           "9) Add book to store \n" \
           "10) Get history of users \n" \
           "11) Search users \n" \
           "12) Get Inbox \n" \
           "13) Get Receive and return history \n" \
           "14) Get History of delay return book \n" \
           "15) Exit From LibraryManagementSystem \n"

res = ''

exitSystem = False

print("**** Welcome to LibraryManagementSystem ***\n\n\n")

while not exitSystem:
    print(menu)
    user_input = input()

    if user_input == '1':
        print("Enter your username : ")
        username = input()
        print("Enter your password : ")
        password = input()
        args = (username, password, res)
        resProc = mycursor.callproc('login', args)
        mydb.commit()
        if resProc[2] == 'user login successfully':
            id = username
        print(resProc[2]+"\n\n")
    elif user_input == '2':
        print("Enter your username : ")
        username = input()
        print("Enter your password : ")
        password = input()
        print("Enter your name : ")
        name = input()
        print("Enter your lastName : ")
        lastName = input()
        print("Enter your address : ")
        address = input()
        print("Enter your role : ")
        role = input()
        print("Enter your userType : ")
        userType = input()
        print("Enter your balance : ")
        balance = input()
        args = (username, password, name, lastName, address, role, userType, balance, False, res)
        resProc = mycursor.callproc('create_account', args)
        mydb.commit()
        print(resProc[9]+'\n\n')
    elif user_input == '3':
        print("Enter your username : ")
        username = input()
        args = (username, res)
        resProc = mycursor.callproc('get_information', args)
        mydb.commit()
        table = PrettyTable()
        table.field_names = ['username', 'create_account_time', 'name', 'lastName', 'address', 'role',
                             'userType', 'balance', 'isLogin']
        for result in mycursor.stored_results():
          rows = result.fetchall()
        for row in rows:
          table.add_row(row)
        print(table)
    elif user_input == '4':
        print("Enter your word : ")
        word = input()
        args = (word, res)
        resProc = mycursor.callproc('search_books', args)
        mydb.commit()
        table = PrettyTable()
        table.field_names = ['title', 'category', 'pages', 'price', 'edition',
                             'publishDate']
        for result in mycursor.stored_results():
            rows = result.fetchall()
        for row in rows:
            table.add_row(row)
        print(table)
    elif user_input == '5':
        print("Enter your username : ")
        username = input()
        print("Enter bookID : ")
        bookId = input()
        print("Enter book edition : ")
        edition = input()
        print("Enter allowedDays : ")
        allowedDays = input()
        args = (username, bookId, edition, allowedDays, res)
        resProc = mycursor.callproc('get_book', args)
        mydb.commit()
        print(resProc[4])
    elif user_input == '6':
        print("Enter your username : ")
        username = input()
        print("Enter bookID : ")
        bookId = input()
        print("Enter book edition : ")
        edition = input()
        print("Enter reserveStartDate : ")
        reserveStartDate = input()
        delay = ''
        args = (username, bookId, edition, reserveStartDate, res, delay)
        resProc = mycursor.callproc('return_book', args)
        mydb.commit()
        print(resProc[5])
    elif user_input == '7':
        print("Enter your username : ")
        username = input()
        print("Enter Balance : ")
        balance = input()
        args = (username, balance, res)
        resProc = mycursor.callproc('increase_balance', args)
        mydb.commit()
        print(resProc[2])
    elif user_input == '8':
        print("Enter BookId : ")
        bookId = input()
        print("Enter BookTitle : ")
        bookTitle = input()
        print("Enter BookCategory : ")
        bookCategory = input()
        print("Enter BookPages : ")
        bookPages = input()
        print("Enter BookPublisherId : ")
        bookPublisherId = input()
        print("Enter BookPrice : ")
        bookPrice = input()
        print("Enter BookEdition : ")
        bookEdition = input()
        print("Enter Author : ")
        author = input()
        print("Enter BookPublishDate : ")
        bookPublishDate = input()

        args = (bookId, bookTitle, bookCategory, bookPages, bookPublisherId, bookPrice, bookEdition, author, bookPublishDate, res)
        resProc = mycursor.callproc('add_book', args)
        mydb.commit()
        print(resProc[9])
    elif user_input == '9':
        print("Enter BookId : ")
        bookId = input()
        print("Enter BookEdition : ")
        bookEdition = input()
        print("Enter NumberOfBooks : ")
        number = input()
        args = (bookId, bookEdition, number, res)
        resProc = mycursor.callproc('add_book_to_store', args)
        mydb.commit()
        print(resProc[3])
    elif user_input == '10':
        print("Enter your username : ")
        username = input()
        print("Enter PageNumber : ")
        pageNumber = input()
        args = (username, pageNumber, res)
        resProc = mycursor.callproc('get_history', args)
        mydb.commit()
        if resProc[2] == 'history of users actions returned successfully':
            table = PrettyTable()
            table.field_names = ['username', 'bookId', 'edition', 'startDate', 'returnDate', 'allowedDays',
                                 'price', 'result']
            for result in mycursor.stored_results():
                rows = result.fetchall()
            for row in rows:
                table.add_row(row)
            print(table)
        else:
            print(resProc[2])
    elif user_input == '11':
        print("Enter your username : ")
        username = input()
        print("Enter PageNumber : ")
        pageNumber = input()
        print("Enter word : ")
        word = input()
        args = (username, pageNumber, word, res)
        resProc = mycursor.callproc('search_users', args)
        mydb.commit()
        if resProc[3] != 'you are not allowed to get information of users':
            table = PrettyTable()
            table.field_names = ['username', 'password', 'create_account_time', 'name', 'lastName', 'address',
                                 'role', 'userType', 'balance', 'isLogin']
            for result in mycursor.stored_results():
                rows = result.fetchall()
            for row in rows:
                table.add_row(row)
            print(table)
        else:
            print(resProc[3])
    elif user_input == '12':
        print("Enter your username : ")
        username = input()
        print("Enter PageNumber : ")
        pageNumber = input()
        args = (username, pageNumber, res)
        resProc = mycursor.callproc('get_inbox', args)
        mydb.commit()
        if resProc[2] != 'you are not allowed to get inbox':
            table = PrettyTable()
            table.field_names = ['username', 'bookId', 'date', 'result', 'withDelay']
            for result in mycursor.stored_results():
                rows = result.fetchall()
            for row in rows:
                table.add_row(row)
            print(table)
        else:
            print(resProc[2])
    elif user_input == '13':
        print("Enter your username : ")
        username = input()
        print("Enter PageNumber : ")
        pageNumber = input()
        args = (username, pageNumber, res)
        resProc = mycursor.callproc('get_history_receive_return', args)
        mydb.commit()
        if resProc[2] == 'history of users actions returned successfully':
            table = PrettyTable()
            table.field_names = ['username', 'bookId', 'edition', 'startDate', 'returnDate', 'allowedDays',
                                 'price', 'result']
            for result in mycursor.stored_results():
                rows = result.fetchall()
            for row in rows:
                table.add_row(row)
            print(table)
        else:
            print(resProc[2])
    elif user_input == '14':
        print("Enter your username : ")
        username = input()
        print("Enter PageNumber : ")
        pageNumber = input()
        args = (username, pageNumber, res)
        resProc = mycursor.callproc('get_history_of_delay', args)
        mydb.commit()
        if resProc[2] == 'history of users actions returned successfully':
            table = PrettyTable()
            table.field_names = ['username', 'bookId', 'edition', 'startDate', 'returnDate', 'allowedDays',
                                 'price', 'result']
            for result in mycursor.stored_results():
                rows = result.fetchall()
            for row in rows:
                table.add_row(row)
            print(table)
        else:
            print(resProc[2])
    elif user_input == '15':
        exitSystem = True

# args = ('aaaaaaaa', 'mohammad', res)
# resProc = mycursor.callproc('check_account', args)

# args = ('mohammad1378', '13781125', 'mohammad', 'ta', 'tehran', 'admin', '', '1000', False, res)
# resProc = mycursor.callproc('create_account', args)
# mydb.commit()


# args = ('mohammad', res)
# resProc = mycursor.callproc('get_information', args)
# mydb.commit()
# table = PrettyTable()
# table.field_names = ['username', 'create_account_time', 'name', 'lastName', 'address', 'role',
#                      'userType', 'balance', 'isLogin']
# for result in mycursor.stored_results():
#   rows = result.fetchall()
# for row in rows:
#   table.add_row(row)
# print(table)


# args = ('mohammad', res)
# resProc = mycursor.callproc('search_books', args)
# mydb.commit()
# table = PrettyTable()
# table.field_names = ['title', 'category', 'pages', 'price', 'edition',
#                      'publishDate']
# for result in mycursor.stored_results():
#   rows = result.fetchall()
# for row in rows:
#   table.add_row(row)
# print(table)

# args = ('alireza', '1', '1', '20', res)
# resProc = mycursor.callproc('get_book', args)
# mydb.commit()
# print(resProc[4])

# delay = ''
# args = ('alireza', '1', '1', '2021-02-10 15:32:06', res, delay)
# resProc = mycursor.callproc('return_book', args)
# mydb.commit()
# print(resProc[5])

# args = ('mohammad', '12500', res)
# resProc = mycursor.callproc('increase_balance', args)
# mydb.commit()
# print(resProc[2])

# args = ('1', '1', '1', res)
# resProc = mycursor.callproc('add_book_to_store', args)
# mydb.commit()
# print(resProc[3])

# args = ('5', 'ronaldo', 'sport', '360', '1', '50000', '1', 'kazem', '2021-02-10 07:47:14', res)
# resProc = mycursor.callproc('add_book', args)
# mydb.commit()
# print(resProc[9])

# args = ('mohammad', '1', res)
# resProc = mycursor.callproc('get_history', args)
# mydb.commit()
# print(resProc[2])

# args = ('mohammad1378', 1, res)
# resProc = mycursor.callproc('get_history', args)
# mydb.commit()
# if resProc[2] == 'history of users actions returned successfully':
#   table = PrettyTable()
#   table.field_names = ['username', 'bookId', 'edition', 'startDate', 'returnDate', 'allowedDays',
#                        'price', 'result']
#   for result in mycursor.stored_results():
#     rows = result.fetchall()
#   for row in rows:
#     table.add_row(row)
#   print(table)
# else:
#   print(resProc[2])

# args = ('mohammad1378', 1, 'tavakoli', res)
# resProc = mycursor.callproc('search_users', args)
# mydb.commit()
# if resProc[3] != 'you are not allowed to get information of users':
#   table = PrettyTable()
#   table.field_names = ['username', 'password', 'create_account_time', 'name', 'lastName', 'address',
#                        'role', 'userType', 'balance', 'isLogin']
#   for result in mycursor.stored_results():
#     rows = result.fetchall()
#   for row in rows:
#     table.add_row(row)
#   print(table)
# else:
#   print(resProc[3])

# args = ('mohammad1378', 1, res)
# resProc = mycursor.callproc('get_inbox', args)
# mydb.commit()
# if resProc[2] != 'you are not allowed to get inbox':
#   table = PrettyTable()
#   table.field_names = ['username', 'bookId', 'date', 'result', 'withDelay']
#   for result in mycursor.stored_results():
#     rows = result.fetchall()
#   for row in rows:
#     table.add_row(row)
#   print(table)
# else:
#   print(resProc[2])
