use librarysystemmanager;

create table user
(
	username varchar(255) NOT NULL,
    password varchar(255) NOT NULL ,
    create_account_time timestamp DEFAULT CURRENT_TIMESTAMP,
    name varchar(255) NOT NULL ,
    lastName varchar(255) NOT NULL ,
    address varchar(255),
    role varchar(255) NOT NULL ,
    userType varchar(255),
    balance varchar(255) ,
    isLogin bool DEFAULT false,
    primary key (username)
);

create table author
(
    authorId varchar(255) ,
    authorName varchar(255) NOT NULL ,
    primary key (authorId)
);

create table publisher
(
    publisherId varchar(255) ,
    publisherName varchar(255) NOT NULL ,
    address varchar(255),
    url varchar(255),
    primary key (publisherId)
);

create table book
(
	bookId varchar(255),
    title varchar(255) NOT NULL ,
    category varchar(255) NOT NULL ,
    pages varchar(5) NOT NULL ,
    publisherId varchar(255) NOT NULL ,
    price varchar(10) NOT NULL ,
    edition varchar(2) NOT NULL ,
    authorName varchar(255) NOT NULL ,
    publishDate timestamp NOT NULL ,
    primary key (bookId, edition),
    foreign key (publisherId) references publisher(publisherId)
);

create table store
(
    bookId varchar(255) NOT NULL ,
    edition varchar(2) NOT NULL ,
    number varchar(255) NOT NULL ,
    primary key (bookId, edition),
    foreign key (bookId) references book(bookId)
);

create table history
(
    username varchar(255),
    bookId varchar(255),
    edition varchar(2),
    startDate timestamp,
    returnDate timestamp DEFAULT CURRENT_TIMESTAMP ,
    allowedDays varchar(5) NOT NULL ,
    price varchar(10),
    result varchar(255) NOT NULL ,
    primary key (username, bookId, startDate, edition),
    foreign key (username) references user(username),
    foreign key (bookId, edition) references book(bookId, edition)
);

create table inbox
(
    username varchar(255) NOT NULL ,
    bookId varchar(255) NOT NULL ,
    date timestamp DEFAULT CURRENT_TIMESTAMP,
    result varchar(255),
    withDelay bool,
    primary key (username, bookId, date, withDelay),
    foreign key (username) references user(username),
    foreign key (bookId) references book(bookId)
);
