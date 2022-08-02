use librarysystemmanager;


create procedure check_account (in username varchar(255),in password varchar(255),out result varchar(255))
begin
    if length(username) >=6  and username REGEXP '^[A-Za-z0-9]+$' and length(password) >= 8 and password REGEXP '[A-Za-z]' and password REGEXP '[0-9]' then
        set result = 'success';
    else
        set result = 'failed';
    end if;
end;





create procedure create_account(in username varchar(255),in password varchar(255),
                                in name varchar(255),in lastName varchar(255),in address varchar(255),
                                in role varchar(255),in userType varchar(255),
                                in balance varchar(255),in isLogin bool,out result varchar(255))
begin
    call check_account(username, password,@res);
    if @res = 'success' and (not exists(select * from user where user.username = username)) then
        insert into user(username, password, name, lastName, address, role, userType, balance, isLogin)
        value(userName, md5(password), name, lastName, address, role, userType, balance, isLogin);
        set result = 'account create successfully';
    else
        set result = 'account creation was failed';
    end if;
end;





create procedure login(in useName varchar(255),in pass varchar(255),out result varchar(255))
begin
    declare res varchar(255);
    if exists(select * from user where username = useName and password = md5(pass)) then
        update user set isLogin = 1 where username = useName;
        set result = 'user login successfully';
    else
        set result = 'user login was failed';
    end if;
end;





create procedure get_information(in useName varchar(255),out result bool)
begin
    select username, create_account_time, name, lastName, address, role, userType, balance, isLogin
    from user
    where user.username = useName;
    set result = 1;
end;





create procedure search_books(in word varchar(255),out result bool)
begin
    select title, category, pages, price, edition, publishDate
    from book
    where title like word or book.authorName like word or edition like word or publishDate like word
    order by title;
    set result = 1;
end;





create procedure get_book(in useName varchar(255),in book_Id varchar(255),in book_edition varchar(2),in allowedDays varchar(5),out result varchar(255))
begin
    declare bookCategory varchar(255);
    declare personType varchar(255);
    declare band varchar(255);
    declare bookPrice varchar(10);
    declare userBalance varchar(255);
    declare numberOfBook varchar(255);
    declare minesBalance varchar(10);

    set minesBalance = '0';

    select category
    from book
    where book.bookId = book_Id
    into bookCategory;

    select price
    from book
    where book.bookId = book_Id
    into bookPrice;

    select number
    from store
    where store.bookId = book_Id and store.edition = book_edition
    into numberOfBook;

    select userType
    from user
    where user.username = useName
    into personType;

    select balance
    from user
    where user.username = useName
    into userBalance;

    select COUNT(*)
    from history
    where DATEDIFF(current_timestamp, history.returnDate) <= 60 and DATEDIFF(history.returnDate, history.startDate) >= history.allowedDays and history.username = useName
    into band;

    if personType = 'ordinary' then
        if bookCategory != 'educational' and bookCategory != 'reference' then
            if band < 4 then
                if CAST(userBalance AS UNSIGNED ) > bookPrice * (5/100) then
                    if numberOfBook >= 1 then
                        set result = 'book reserved successfully';

                        update store
                        set store.number = store.number-1
                        where store.bookId = book_Id and store.edition = book_edition;

                        update user
                        set balance = user.balance - bookPrice * (5/100)
                        where user.username = useName;

                        set minesBalance = bookPrice * (5/100);

                    else
                        set result = 'this book is not available is store';
                    end if;
                else
                    set result = 'your balance is not enough';
                end if;
            else
                set result = 'you are banded';
            end if;
        else
            set result = 'you are not allowed to reserve this book';
        end if;
    end if;

    if personType = 'student' then
        if bookCategory != 'reference' then
            if band < 4 then
                if CAST(userBalance AS UNSIGNED ) > bookPrice * (5/100) then
                    if numberOfBook >= 1 then
                        set result = 'book reserved successfully';

                        update store
                        set store.number = store.number-1
                        where store.bookId = book_Id and store.edition = book_edition;

                        update user
                        set balance = user.balance - bookPrice * (5/100)
                        where user.username = useName;

                        set minesBalance = bookPrice * (5/100);

                    else
                        set result = 'this book is not available is store';
                    end if;
                else
                    set result = 'your balance is not enough';
                end if;
            else
                set result = 'you are banded';
            end if;
        else
            set result = 'you are not allowed to reserve this book';
        end if;
    end if;

    if personType = 'professor' then
        if band < 4 then
            if CAST(userBalance AS UNSIGNED ) > bookPrice * (5/100) then
                if numberOfBook >= 1 then
                    set result = 'book reserved successfully';

                    update store
                    set store.number = store.number-1
                    where store.bookId = book_Id and store.edition = book_edition;

                    update user
                    set balance = user.balance - bookPrice * (5/100)
                    where user.username = useName;

                    set minesBalance = bookPrice * (5/100);

                else
                    set result = 'this book is not available is store';
                end if;
            else
                set result = 'your balance is not enough';
            end if;
        else
            set result = 'you are banded';
        end if;
    end if;

    insert into history
    values (useName, book_Id, book_edition, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, allowedDays, minesBalance, result);

end;





create procedure return_book(in useName varchar(255),in book_id varchar(255),in book_edition varchar(2),in reserveStartDate timestamp,out delay bool,out result varchar(255))
begin

    declare reserveAllowedDays varchar(10);

    select allowedDays
    from history
    where history.username = useName and history.bookId = book_id and history.edition = book_edition and history.startDate = reserveStartDate
    into reserveAllowedDays;

    if exists(select * from history where username = useName and bookId = book_id and edition = book_edition) then
        update history
        set returnDate = CURRENT_TIMESTAMP, result = 'book returned successfully'
        where history.username = useName and history.bookId = book_id and history.edition = book_edition and history.startDate = reserveStartDate;

        update store
        set number = number + 1
        where bookId = book_id and edition = book_edition;

        if DATEDIFF(current_timestamp, reserveStartDate) >= reserveAllowedDays then
            set delay = 1;
        else
            set delay = 0;
        end if;

        set result = 'book returned successfully';
    else
        set result = 'book is not exist in store';
    end if;
end;





create procedure increase_balance(in useName varchar(255),in userBalance varchar(255),out result varchar(255))
begin
    if exists(select * from user where username = useName) then
        if CAST(userBalance AS UNSIGNED) >= 0  then
            set result = 'balance increased successfully';
            update user
            set balance = balance + userBalance
            where username = useName;
        else
            set result = 'balance is not valid';
        end if;
    else
        set result = 'user with this username not exists';
    end if;
end;





create procedure add_book(in book_id varchar(255),in book_title varchar(255),in book_category varchar(255),
                        in book_pages varchar(5),in book_publisherId varchar(255),in book_price varchar(10),in book_edition varchar(2),
                        in book_author varchar(255),in book_publishDate timestamp,out result varchar(255))
begin
    if not exists(select * from book where bookId = book_id and edition = book_edition) then
        insert into book
        values (book_id, book_title, book_category, book_pages, book_publisherId, book_price, book_edition, book_author,
                book_publishDate);
        set result = 'book added successfully';
    else
        set result = 'book already exists';
    end if;
end;





create procedure add_book_to_store(in book_id varchar(255),in book_edition varchar(2),in bookNumber varchar(255),out result varchar(255))
begin
    if exists(select * from book where bookId = book_id and edition = book_edition) then
        set result = 'book added to store successfully';
        if exists(select * from store where bookId = book_id and edition = book_edition) then
            update store
            set number = number + bookNumber
            where bookId = book_id and edition = book_edition;
        else
            insert into store
            values (book_id, book_edition, bookNumber);
        end if;
    else
        set result = 'book is not exists';
    end if;
end;





create procedure get_history(in useName varchar(255),in pageNumber int(5),out result varchar(255))
begin
    declare userRole varchar(255);
    declare bookOffset int(5);

    set bookOffset = 5 * (pageNumber - 1);

    select role
    from user
    where username = useName
    into userRole;

    if userRole = 'admin' or userRole = 'superAdmin' then
        select *
        from history
        where history.result = 'book reserved successfully'
        order by history.startDate DESC
        limit 5
        offset bookOffset;
        set result = 'history of users actions returned successfully';
    else
        set result = 'you are not allowed to get history of users actions';
    end if;

end;





create procedure search_users(in useName varchar(255),in pageNumber int(5),in word varchar(255),out result varchar(255))
begin
    declare userRole varchar(255);
    declare bookOffset int(5);

    set bookOffset = 5 * (pageNumber - 1);

    select role
    from user
    where username = useName
    into userRole;

    if userRole = 'admin' or userRole = 'superAdmin' then
        if not exists(select * from user where username = word) then
            select *
            from user
            where user.lastName like word
            order by lastName
            limit 5
            offset bookOffset;
        else
            select *
            from user
            where user.username like word;
        end if;
        set result = 'users information returned successfully';
    else
        set result = 'you are not allowed to get information of users';
    end if;
end;





create procedure get_inbox(in useName varchar(255),in pageNumber int(5),out result varchar(255))
begin
    declare userRole varchar(255);
    declare bookOffset int(5);

    set bookOffset = 5 * (pageNumber - 1);

    select role
    from user
    where username = useName
    into userRole;

    if userRole = 'admin' or userRole = 'superAdmin' then
        select *
        from inbox
        where inbox.result = 'book reserved successfully'
        order by inbox.date DESC
        limit 5
        offset bookOffset;
        set result = 'inbox returned successfully';
    else
        set result = 'you are not allowed to get inbox';
    end if;

end;





create procedure get_history_receive_return(in useName varchar(255),in pageNumber int(5),out result varchar(255))
begin
    declare userRole varchar(255);
    declare bookOffset int(5);

    set bookOffset = 5 * (pageNumber - 1);

    select role
    from user
    where username = useName
    into userRole;

    if userRole = 'admin' or userRole = 'superAdmin' then
        select *
        from history
        order by history.startDate DESC
        limit 5
        offset bookOffset;
        set result = 'history of users actions returned successfully';
    else
        set result = 'you are not allowed to get history of users actions';
    end if;

end;





create procedure get_history_of_delay(in useName varchar(255),in pageNumber int(5),out result varchar(255))
begin
    declare userRole varchar(255);
    declare bookOffset int(5);

    set bookOffset = 5 * (pageNumber - 1);

    select role
    from user
    where username = useName
    into userRole;

    if userRole = 'admin' or userRole = 'superAdmin' then
        select *
        from history
        where DATEDIFF(history.returnDate, history.startDate) >= history.allowedDays
        order by DATEDIFF(history.returnDate, history.startDate) DESC
        limit 5
        offset bookOffset;
        set result = 'history of users actions returned successfully';
    else
        set result = 'you are not allowed to get history of users actions';
    end if;

end;