DROP TABLE Employee;
DROP TABLE Review;
DROP TABLE Ticket;
DROP TABLE Customer;
DROP TABLE Cinema;
DROP TABLE Movie;
DROP TABLE Theater;


CREATE TABLE Cinema (
	CinemaID INT PRIMARY KEY,
	Nome VARCHAR (100) NOT NULL,
	Indirizzo VARCHAR (255) NOT NULL,
	Phone VARCHAR (20)
);

CREATE TABLE Theater (
	TheaterID INT PRIMARY KEY,
	CinemaID INT,
	Nome VARCHAR(50) NOT NULL,
	Capacity INT NOT NULL,
	ScreenType VARCHAR(50),
	FOREIGN KEY (CinemaID) REFERENCES Cinema(CinemaID)
);CREATE TABLE Movie (
	MovieID INT PRIMARY KEY,
	Title VARCHAR(255) NOT NULL,
	Director VARCHAR(100),
	ReleaseDate DATE,
	DurationMinutes INT,
	Rating VARCHAR(5)
);CREATE TABLE Showtime (
	ShowtimeID INT PRIMARY KEY,
	MovieID INT,
	TheaterID INT,
	ShowDateTime DATETIME NOT NULL,
	Price DECIMAL(5,2) NOT NULL,
	FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
	FOREIGN KEY (TheaterID) REFERENCES Theater(TheaterID)
);CREATE TABLE Customer (
	CustomerID INT PRIMARY KEY,
	FirstName VARCHAR(50) NOT NULL,	LastName VARCHAR(50) NOT NULL,
	Email VARCHAR(100),
	PhoneNumber VARCHAR(20)
);CREATE TABLE Ticket (
	TicketID INT PRIMARY KEY,
	ShowtimeID INT,
	SeatNumber VARCHAR(10) NOT NULL,
	PurchasedDateTime DATETIME NOT NULL,
	CustomerID INT,
	FOREIGN KEY (ShowtimeID) REFERENCES Showtime(ShowtimeID),
	FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);CREATE TABLE Review (
	ReviewID INT PRIMARY KEY,
	MovieID INT,
	CustomerID INT,
	ReviewText TEXT,
	Rating INT CHECK (Rating >= 1 AND Rating <= 5),
	ReviewDate DATETIME NOT NULL,
	FOREIGN KEY (MovieID) REFERENCES Movie(MovieID),
	FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);CREATE TABLE Employee (
	EmployeeID INT PRIMARY KEY,
	CinemaID INT,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Position VARCHAR(50),
	HireDate DATE,
	FOREIGN KEY (CinemaID) REFERENCES Cinema(CinemaID)
);
INSERT INTO Cinema (CinemaID, Nome, Indirizzo, Phone)
VALUES
(1, 'Cinema Paradiso', 'Via Roma 123', '06 1234567'),
(2, 'Cinema inferno', 'Via Napoli 222', '+ 06 8574635');

INSERT INTO Theater (TheaterID, CinemaID, Nome, Capacity, ScreenType)
VALUES
(1, 1, 'Sala 1', 100, '2D'),
(2, 1, 'Sala 2', 80, '3D'),
(3, 2, 'Sala 3', 150, 'IMAX'),
(4, 2, 'Sala 4', 120, '2D');

INSERT INTO Movie (MovieID, Title, Director, ReleaseDate, DurationMinutes, Rating)
VALUES
(1, 'The Shawshank Redemption', 'Frank Darabont', '1994-09-23', 142, '4'),
(2, 'Inception', 'Christopher Nolan', '2010-07-16', 148, '4'),
(3, 'Pulp Fiction', 'Quentin Tarantino', '1994-10-14', 154, '5');

INSERT INTO Showtime (ShowtimeID, MovieID, TheaterID, ShowDateTime, Price)
VALUES
(1, 1, 1, '2024-03-2 18:00:00', 10.00),
(2, 2, 3, '2024-03-2 20:00:00', 12.50),
(3, 3, 2, '2024-03-2 19:30:00', 11.00);

INSERT INTO Customer (CustomerID, FirstName, LastName, Email, PhoneNumber)
VALUES
(1, 'Mario', 'Rossi', 'mrossi@example.com', '3334657889'),
(2, 'Valerio', 'Bianchi', 'valbianch@example.com', '336970699');

INSERT INTO Ticket (TicketID, ShowtimeID, SeatNumber, PurchasedDateTime, CustomerID)
VALUES
(1, 1, 'A1', '2024-03-01 15:30:00', 1),
(2, 2, 'B5', '2024-03-01 10:45:00', 2);

INSERT INTO Review (ReviewID, MovieID, CustomerID, ReviewText, Rating, ReviewDate)
VALUES
(1, 1, 1, 'Bellissimo film,uno dei migliori!', 5, '2024-03-01 09:15:00'),
(2, 2, 2, 'Film dell''anno.', 4, '2024-03-01 22:30:00');

INSERT INTO Employee (EmployeeID, CinemaID, FirstName, LastName, Position, HireDate)
VALUES
(1, 1, 'Franco', 'Rossi', 'Manager', '2020-01-15'),
(2, 2, 'Luca', 'Gialli', 'Cassiere', '2022-03-01');SELECT * FROM Showtime;CREATE VIEW FilmsInProgrammation AS
	SELECT
		Movie.Title AS FilmTitle,
		Showtime.ShowDateTime AS StartDate,
		Movie.DurationMinutes AS Duration,
		Movie.Rating AS AgeRating
	FROM
		Movie
	JOIN
		Showtime ON Movie.MovieID = Showtime.MovieID;

SELECT * FROM FilmsInProgrammation;


CREATE VIEW AvailableSeatsForShow AS
	SELECT
		Showtime.ShowtimeID,
		Theater.Capacity AS TotalSeats,
		(Theater.Capacity - COUNT(Ticket.TicketID)) AS AvailableSeats
	FROM
		Showtime
	JOIN
		Theater ON Showtime.TheaterID = Theater.TheaterID
	LEFT JOIN
		Ticket ON Showtime.ShowtimeID = Ticket.ShowtimeID
	GROUP BY
		Showtime.ShowtimeID, Theater.Capacity;

SELECT * FROM AvailableSeatsForShow;

CREATE VIEW TotalEarningsPerMovie AS

	SELECT 
		Title, Price * (SELECT COUNT(*) 
	FROM 
		Ticket 
	WHERE 
		Showtime.ShowtimeID = Ticket.ShowtimeID) AS Total 
	FROM 
		Movie 
	JOIN 
		Showtime ON Movie.MovieID = Showtime.MovieID
	JOIN 
		Ticket ON ShowTime.ShowtimeID = Ticket.ShowtimeID;

SELECT * FROM TotalEarningsPerMovie;


CREATE VIEW RecentReviews AS

	SELECT 
		Title, Review.Rating, ReviewText, ReviewDate AS reviewDate 
	FROM 
		Review
	JOIN
		Movie ON Review.MovieID = Movie.MovieID;
 
SELECT * FROM RecentReviews
	ORDER BY reviewDate;

DROP PROCEDURE PurchaseTicket
CREATE PROCEDURE PurchaseTicket 
	@TicketID INT,
	@ShowtimeID INT,
	@SeatNumber VARCHAR(10),
	@CustomerID INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION

        IF EXISTS (SELECT 1 FROM Ticket WHERE ShowtimeID = @ShowtimeID AND SeatNumber = @SeatNumber)
        BEGIN
            THROW 51000, 'Il posto specificato non è disponibile per lo spettacolo.', 1;
        END

        
        INSERT INTO Ticket (TicketID,ShowtimeID, SeatNumber, PurchasedDateTime, CustomerID)
        VALUES (@TicketID, @ShowtimeID, @SeatNumber, GETDATE(), @CustomerID);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;

EXEC PurchaseTicket @TicketID =3, @ShowtimeID = 1,@SeatNumber = '3',@CustomerID =1;
EXEC PurchaseTicket @TicketID =4, @ShowtimeID = 2,@SeatNumber = '5',@CustomerID =1;
EXEC PurchaseTicket @TicketID =5, @ShowtimeID = 2,@SeatNumber = '6',@CustomerID =1;
EXEC PurchaseTicket @TicketID =6, @ShowtimeID = 2,@SeatNumber = '6',@CustomerID =1;
EXEC PurchaseTicket @TicketID =7, @ShowtimeID = 2,@SeatNumber = 'T6',@CustomerID =3;

SELECT * FROM Ticket;
