use librarysystemmanager;


create trigger tr_reserve_book after insert on history
    for each row
    insert into inbox
    values (NEW.username, NEW.bookId, NEW.startDate, NEW.result, false);





create trigger tr_return_book after update on history
    for each row
    if DATEDIFF(NEW.returnDate, OLD.startDate) >= OLD.allowedDays then
        insert into inbox
        values (NEW.username, NEW.bookId, NEW.returnDate, OLD.result, 1);
    else
        insert into inbox
        values (NEW.username, NEW.bookId, NEW.returnDate, OLD.result, 0);
    end if;
