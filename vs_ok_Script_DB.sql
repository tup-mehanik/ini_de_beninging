-- CREATE DATABASE --

USE master;
GO

CREATE DATABASE yah_ini_dee COLLATE Cyrillic_General_CI_AS;
GO

USE yah_ini_dee;
GO

-- VALIDATE DATA --

CREATE OR ALTER FUNCTION egnValidation(@egn NVARCHAR(10), @case BINARY(1))
RETURNS BINARY(1) AS
BEGIN
	IF LEN(@egn) <> 10 RETURN 0
	-- case 0 => student
	IF @case = 0 AND
			((CAST(SUBSTRING(@egn,3,1) AS INT)-4)*10 + (CAST(SUBSTRING(@egn,4,1) AS INT))) NOT BETWEEN 1 AND 12 AND
			((CAST(SUBSTRING(@egn,5,1) AS INT))*10 + (CAST(SUBSTRING(@egn,6,1) AS INT))) NOT BETWEEN 1 AND 31
		RETURN 0
	-- case 1 => adult / custodian
	IF @case = 1 AND
			(((CAST(SUBSTRING(@egn,3,1) AS INT))*10 + (CAST(SUBSTRING(@egn,4,1) AS INT))) NOT BETWEEN 1 AND 12 OR
			((CAST(SUBSTRING(@egn,3,1) AS INT)-4)*10 + (CAST(SUBSTRING(@egn,4,1) AS INT))) NOT BETWEEN 1 AND 12) AND
			((CAST(SUBSTRING(@egn,5,1) AS INT))*10 + (CAST(SUBSTRING(@egn,6,1) AS INT))) NOT BETWEEN 1 AND 31 
		RETURN 0
	RETURN 1
END
GO

CREATE OR ALTER FUNCTION ageValidation(@egn NVARCHAR(10))
RETURNS BINARY AS
BEGIN
	DECLARE @birthDate DATE, @day INT, @month INT, @year INT, @diffYears INT;
	IF(dbo.egnValidation(@egn, 0) = 0) RETURN 0
	SET @day = (CAST(SUBSTRING(@egn,5,1) AS INT))*10 + (CAST(SUBSTRING(@egn,6,1) AS INT))
	SET @month = (CAST(SUBSTRING(@egn,3,1) AS INT)-4)*10 + (CAST(SUBSTRING(@egn,4,1) AS INT))
	SET @year = 2000 + (CAST(SUBSTRING(@egn,1,1) AS INT))*10 + (CAST(SUBSTRING(@egn,2,1) AS INT))
	SET @birthDate = DATEFROMPARTS(@year, @month, @day)
	SET @diffYears = DATEDIFF(HOUR,@birthDate,GETDATE())/8766 
	IF(@diffYears < 16 OR @diffYears >= 18) RETURN 0
	RETURN 1
END
GO

-- CREATE TABLES --

CREATE TABLE Cities (
  [ID] INT NOT NULL IDENTITY(1,1),
  [Name] NVARCHAR(256) NOT NULL ,
  [Postal_Code] INT NOT NULL,
  CONSTRAINT PK_Cities PRIMARY KEY (ID),
  CONSTRAINT CHK_Code CHECK (LEN(Postal_Code) = 4)
);
GO

CREATE TABLE Documents (
  [ID] INT NOT NULL IDENTITY(1,1),
  [Type] NVARCHAR(256) NOT NULL,
  [File] NVARCHAR(256) NOT NULL,
  CONSTRAINT PK_Documents PRIMARY KEY (ID)
);
GO

CREATE TABLE Fields (
  [ID] INT NOT NULL IDENTITY(1,1),
  [Name] NVARCHAR(256) NOT NULL,
  CONSTRAINT PK_Fields PRIMARY KEY (ID) 
);
GO

CREATE TABLE Positions (
  [ID] INT NOT NULL IDENTITY(1,1),
  [Position_Name] NVARCHAR(256) NOT NULL,
  CONSTRAINT PK_Positions PRIMARY KEY (ID)
);
GO

CREATE TABLE Contract_Type (
  [ID] INT NOT NULL IDENTITY(1,1),
  [Type] NVARCHAR(256) NOT NULL,
  CONSTRAINT PK_Contract PRIMARY KEY (ID)
);
GO

CREATE TABLE Property_Custodians (
  [ID] INT NOT NULL IDENTITY(1,1),
  [First_Name] NVARCHAR(50) NOT NULL,
  [Middle_Name] NVARCHAR(50) NOT NULL,
  [Surname] NVARCHAR(50) NOT NULL,
  [EGN] NVARCHAR(10) NOT NULL,
  [Phone] NVARCHAR(10) NOT NULL,
  [Email] NVARCHAR(100) NOT NULL,
  CONSTRAINT PK_Custodians PRIMARY KEY (ID),
  CONSTRAINT CHK_Cus_EGN CHECK (dbo.egnValidation(EGN,1) = 1),
  --CONSTRAINT CHK_Cus_Phone CHECK (Phone LIKE '[0-9]' AND LEN(Phone) <= 10),
  CONSTRAINT CHK_Cus_Email CHECK (Email LIKE '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%')
);
GO

CREATE TABLE Contact_People (
  [ID] INT NOT NULL IDENTITY(1,1),
  [First_Name] NVARCHAR(50) NOT NULL,
  [Middle_Name] NVARCHAR(50) NOT NULL,
  [Surname] NVARCHAR(50) NOT NULL,
  [Phone] NVARCHAR(10) NOT NULL,
  [Email] NVARCHAR(100) NOT NULL,
  CONSTRAINT PK_Contacts PRIMARY KEY (ID),
  --CONSTRAINT CHK_Con_Phone CHECK (Phone LIKE '[0-9]' AND LEN(Phone) <= 10),
  CONSTRAINT CHK_Con_Email CHECK (Email LIKE '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%')
);
GO

CREATE TABLE Login_Data (
  [ID] INT NOT NULL IDENTITY(1,1),
  [Email] NVARCHAR(256) NOT NULL,
  [Password] NVARCHAR(256) NOT NULL,
  [Type] INT NOT NULL,
  [Link_ID] INT NOT NULL,
  CONSTRAINT PK_Login PRIMARY KEY (ID),
  CONSTRAINT CHK_Log_Email CHECK (Email LIKE '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%')
);
GO

CREATE TABLE Uploads (
  [ID] INT NOT NULL IDENTITY(1,1),
  [Application_ID] INT NOT NULL,
  [File] NVARCHAR(256) NOT NULL,
  CONSTRAINT PK_Uploads PRIMARY KEY (ID)
);
GO

CREATE TABLE Employers (
  [ID] INT NOT NULL IDENTITY(1,1),
  [Employer_Name] NVARCHAR(200) NOT NULL,
  [UIC] NVARCHAR(15) NOT NULL,
  [Custodian_ID] INT NOT NULL DEFAULT 1,
  [Email] NVARCHAR(100) NOT NULL,
  [City_ID] INT NOT NULL,
  [Registered_Seat] NVARCHAR(200) NOT NULL,
  [Contact_ID] INT NOT NULL DEFAULT 1,
  CONSTRAINT PK_Employers PRIMARY KEY (ID),
  CONSTRAINT FK_Emp_Custodians FOREIGN KEY (Custodian_ID) REFERENCES Property_Custodians(ID)
		ON DELETE SET DEFAULT
		ON UPDATE CASCADE,
  CONSTRAINT FK_Emp_Cities FOREIGN KEY (City_ID) REFERENCES Cities(ID),
  CONSTRAINT FK_Emp_Contacts FOREIGN KEY (Contact_ID) REFERENCES Contact_People(ID)
		ON DELETE SET DEFAULT
		ON UPDATE CASCADE,
  CONSTRAINT CHK_Employer_Email CHECK (Email LIKE '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%')
);
GO

CREATE TABLE Schools (
  [ID] INT NOT NULL IDENTITY(1,1),
  [Name] NVARCHAR(256) NOT NULL,
  [City_ID] INT NOT NULL DEFAULT 3,
  [Phone] NVARCHAR(10) NOT NULL,
  [Email] NVARCHAR(256) NOT NULL,
  CONSTRAINT PK_Schools PRIMARY KEY (ID),
  --CONSTRAINT CHK_Sch_Phone CHECK (Phone LIKE '[0-9]' AND LEN(Phone) <= 10),
  CONSTRAINT CHK_Sch_Email CHECK (Email LIKE '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%'),
  CONSTRAINT FK_Sch_Cities FOREIGN KEY (City_ID) REFERENCES Cities(ID)
);
GO

----ТУК Е МАЗАЛОТО

CREATE TABLE Addresses_Employers (
  [ID] INT NOT NULL IDENTITY(1,1),
  [Employer_ID] INT NOT NULL,
  [City_ID] INT NOT NULL DEFAULT 3,
  [Address] NVARCHAR(256) NOT NULL,
  --CONSTRAINT PK_Addresses PRIMARY KEY (Employer_ID, ID),
  CONSTRAINT PK_Addresses PRIMARY KEY (ID),
  CONSTRAINT FK_Adr_Employers FOREIGN KEY (Employer_ID) REFERENCES Employers(ID)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
  CONSTRAINT FK_Adr_Cities FOREIGN KEY (City_ID) REFERENCES Cities(ID)
);
GO

----ТУК Е МАЗАЛОТО

CREATE TABLE Advertisements (
  [ID] INT NOT NULL IDENTITY(1,1),
  [Position_ID] INT NOT NULL,
  --[Employer_ID] INT NOT NULL,
  [Address_ID] INT NOT NULL DEFAULT 1,
  [Field_ID] INT NOT NULL,
  [Post_Date] DATE NOT NULL DEFAULT GETDATE(),
  [Is_Valid] BINARY(1) NOT NULL,
  [Salary] MONEY NOT NULL,
  [Contract_ID] INT NOT NULL,
  [Views] INT NOT NULL DEFAULT 0,
  CONSTRAINT PK_Adverts PRIMARY KEY (ID),
  --CONSTRAINT FK_Adresses FOREIGN KEY (Employer_ID, Address_ID) REFERENCES Addresses_Employers(Employer_ID, ID),
  CONSTRAINT FK_Adv_Adresses FOREIGN KEY (Address_ID) REFERENCES Addresses_Employers(ID)
		ON DELETE SET DEFAULT
		ON UPDATE CASCADE,
  CONSTRAINT FK_Adv_Positions FOREIGN KEY (Position_ID) REFERENCES Positions(ID),
  CONSTRAINT FK_Adv_Fields FOREIGN KEY (Field_ID) REFERENCES Fields(ID),
  CONSTRAINT FK_Adv_Contracts FOREIGN KEY (Contract_ID) REFERENCES Contract_Type(ID)
);
GO

CREATE TABLE Students (
  [ID] INT NOT NULL IDENTITY(1,1),
  [First_Name] NVARCHAR(50) NOT NULL,
  [Middle_Name] NVARCHAR(50) NOT NULL,
  [Surname] NVARCHAR(50) NOT NULL,
  [EGN] NVARCHAR(10) NOT NULL,
  [Phone] NVARCHAR(10) NOT NULL,
  [Email] NVARCHAR(100) NOT NULL,
  [City_ID] INT NOT NULL DEFAULT 3,
  [Address] NVARCHAR(256) NOT NULL,
  [School_ID] INT NOT NULL,
  CONSTRAINT PK_Students PRIMARY KEY (ID),
  CONSTRAINT CHK_Stu_Age CHECK (dbo.ageValidation(EGN) = 1),
  --CONSTRAINT CHK_Stu_Phone CHECK (Phone LIKE '[0-9]' AND LEN(Phone) <= 10),
  CONSTRAINT CHK_Stu_Email CHECK (Email LIKE '[a-z,0-9,_,-]%@[a-z,0-9,_,-]%.[a-z][a-z]%'),
  CONSTRAINT FK_Stu_Cities FOREIGN KEY (City_ID) REFERENCES Cities(ID),
  CONSTRAINT FK_Stu_Schools FOREIGN KEY (School_ID) REFERENCES Schools(ID)
);
GO

CREATE TABLE Applications (
	[ID] INT NOT NULL IDENTITY(1,1),
	[Student_ID] INT NOT NULL,
	[Adverts_ID] INT NOT NULL,
  CONSTRAINT PK_Applicats PRIMARY KEY (ID),
  CONSTRAINT FK_Apl_Students FOREIGN KEY (Student_ID) REFERENCES Students(ID)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
  CONSTRAINT FK_Apl_Adverts FOREIGN KEY (Adverts_ID) REFERENCES Advertisements(ID)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);
GO

-- INSERT TEST DATA --

INSERT INTO [dbo].[Cities]([Name], [Postal_code])
VALUES ('Айтос',8500),
    ('Аксаково',9154),
    ('Алфатар',7570),
    ('Антоново',7970),
    ('Априлци',5641),
    ('Ардино',6750),
    ('Асеновград',4230),
    ('Ахелой',8217),
    ('Ахтопол',8280),
    ('Балчик',9600),
    ('Банкя',1320),
    ('Банско',2770),
    ('Баня',4360),
    ('Батак',4580),
    ('Батановци',2340),
    ('Белене',5930),
    ('Белица',2780),
    ('Белово',4470),
    ('Белоградчик',3900),
    ('Белослав',9178),
    ('Берковица',3500),
    ('Благоевград',2700),
    ('Бобов дол',2670),
    ('Бобошево',2660),
    ('Божурище',2227),
    ('Бойчиновци',3430),
    ('Болярово',8720),
    ('Борово',7174),
    ('Ботевград',2140),
    ('Брацигово',4579),
    ('Брегово',3790),
    ('Брезник',2360),
    ('Брезово',4160),
    ('Брусарци',3680),
    ('Бургас',8000),
    ('Бухово',1830),
    ('Българово',8110),
    ('Бяла',9101),
    ('Бяла',7100),
    ('Бяла Слатина',3200),
    ('Бяла Черква',5220),
    ('Варна',9000),
    ('Велики Преслав',9850),
    ('Велико Търново',5000),
    ('Велинград',4600),
    ('Ветово',7080),
    ('Ветрен',4480),
    ('Видин',3700),
    ('Враца',3000),
    ('Вълчедръм',3650),
    ('Вълчи дол',9280),
    ('Върбица',9870),
    ('Вършец',3540),
    ('Габрово',5300),
    ('Генерал Тошево',9500),
    ('Главиница',7630),
    ('Глоджево',7040),
    ('Годеч',2240),
    ('Горна Оряховица',5100),
    ('Гоце Делчев',2900),
    ('Грамада',3830),
    ('Гулянци',5960),
    ('Гурково',6199),
    ('Гълъбово',6280),
    ('Две могили',7150),
    ('Дебелец',5030),
    ('Девин',4800),
    ('Девня',9160),
    ('Джебел',6850),
    ('Димитровград',6400),
    ('Димово',3750),
    ('Добринище',2777),
    ('Добрич',9300),
    ('Долна баня',2040),
    ('Долна Митрополия',5855),
    ('Долна Оряховица',5130),
    ('Долни Дъбник',5870),
    ('Долни чифлик',9120),
    ('Доспат',4831),
    ('Драгоман',2210),
    ('Дряново',5370),
    ('Дулово',7650),
    ('Дунавци',3740),
    ('Дупница',2600),
    ('Дългопол',9250),
    ('Елена',5070),
    ('Елин Пелин',2100),
    ('Елхово',8700),
    ('Етрополе',2180),
    ('Завет',7330),
    ('Земен',2440),
    ('Златарица',5090),
    ('Златица',2080),
    ('Златоград',4980),
    ('Ивайловград',6570),
    ('Игнатиево',9143),
    ('Искър',5868),
    ('Исперих',7400),
    ('Ихтиман',2050),
    ('Каблешково',8210),
    ('Каварна',9650),
    ('Казанлък',6100),
    ('Калофер',4370),
    ('Камено',8120),
    ('Каолиново',9960),
    ('Карлово',4300),
    ('Карнобат',8400),
    ('Каспичан',9930),
    ('Кермен',8870),
    ('Килифарево',5050),
    ('Китен',8183),
    ('Клисура',4341),
    ('Кнежа',5835),
    ('Козлодуй',3320),
    ('Койнаре',5986),
    ('Копривщица',2077),
    ('Костандово',4644),
    ('Костенец',2030),
    ('Костинброд',2230),
    ('Котел',8970),
    ('Кочериново',2640),
    ('Кресна',2840),
    ('Криводол',3060),
    ('Кричим',4220),
    ('Крумовград',6900),
    ('Крън',6140),
    ('Кубрат',7300),
    ('Куклен',4101),
    ('Кула',3800),
    ('Кърджали',6600),
    ('Кюстендил',2500),
    ('Левски',5900),
    ('Летница',5570),
    ('Ловеч',5500),
    ('Лозница',7290),
    ('Лом',3600),
    ('Луковит',5770),
    ('Лъки',4241),
    ('Любимец',6550),
    ('Лясковец',5140),
    ('Мадан',4900),
    ('Маджарово',6480),
    ('Малко Търново',8162),
    ('Мартен',7058),
    ('Мездра',3100),
    ('Мелник',2820),
    ('Меричлери',6430),
    ('Мизия',3330),
    ('Момин проход',2035),
    ('Момчилград',6800),
    ('Монтана',3400),
    ('Мъглиж',6180),
    ('Неделино',4990),
    ('Несебър',8230),
    ('Николаево',6190),
    ('Никопол',5940),
    ('Нова Загора',8900),
    ('Нови Искър',1280),
    ('Нови пазар',9900),
    ('Обзор',8250),
    ('Омуртаг',7900),
    ('Опака',7840),
    ('Оряхово',3300),
    ('Павел баня',6155),
    ('Павликени',5200),
    ('Пазарджик',4400),
    ('Панагюрище',4500),
    ('Перник',2300),
    ('Перущица',4225),
    ('Петрич',2850),
    ('Пещера',4550),
    ('Пирдоп',2070),
    ('Плачковци',5360),
    ('Плевен',5800),
    ('Плиска',9920),
    ('Пловдив',4000),
    ('Полски Тръмбеш',5180),
    ('Поморие',8200),
    ('Попово',7800),
    ('Пордим',5898),
    ('Правец',2161),
    ('Приморско',8180),
    ('Провадия',9200),
    ('Първомай',4270),
    ('Раднево',6260),
    ('Радомир',2400),
    ('Разград',7200),
    ('Разлог',2760),
    ('Ракитово',4640),
    ('Раковски',4150),
    ('Рила',2630),
    ('Роман',3130),
    ('Рудозем',4960),
    ('Русе',7000),
    ('Садово',4122),
    ('Самоков',2000),
    ('Сандански',2800),
    ('Сапарева баня',2650),
    ('Свети Влас',8256),
    ('Свиленград',6500),
    ('Свищов',5250),
    ('Своге',2260),
    ('Севлиево',5400),
    ('Сеново',7038),
    ('Септември',4490),
    ('Силистра',7500),
    ('Симеоновград',6490),
    ('Симитли',2730),
    ('Славяново',5840),
    ('Сливен',8800),
    ('Сливница',2200),
    ('Сливо поле',7060),
    ('Смолян',4700),
    ('Смядово',9820),
    ('Созопол',8130),
    ('Сопот',4330),
    ('София',1000),
    ('Средец',8300),
    ('Стамболийски',4210),
    ('Стара Загора',6000),
    ('Стражица',5150),
    ('Стралджа',8680),
    ('Стрелча',4530),
    ('Суворово',9170),
    ('Сунгурларе',8470),
    ('Сухиндол',5240),
    ('Съединение',4190),
    ('Сърница',4633),
    ('Твърдица',8890),
    ('Тервел',9450),
    ('Тетевен',5700),
    ('Тополовград',6560),
    ('Троян',5600),
    ('Трън',2460),
    ('Тръстеник',5857),
    ('Трявна',5350),
    ('Тутракан',7600),
    ('Търговище',7700),
    ('Угърчин',5580),
    ('Хаджидимово',2933),
    ('Харманли',6450),
    ('Хасково',6300),
    ('Хисаря',4180),
    ('Цар Калоян',7280),
    ('Царево',8260),
    ('Чепеларе',4850),
    ('Червен бряг',5980),
    ('Черноморец',8142),
    ('Чипровци',3460),
    ('Чирпан',6200),
    ('Шабла',9680),
    ('Шивачево',8895),
    ('Шипка',6150),
    ('Шумен',9700),
    ('Ябланица',5750),
    ('Якоруда',2790),
    ('Ямбол',8600);
GO

INSERT INTO [dbo].[Documents]([Type], [File])
VALUES ('Съгласие за обработка на лични данни','gdpr.docs'),
	('Съгласие на родител','parent.docs'),
	('Примерен трудов договор','contract.pdf'),
	('Образец на заявление','application.pdf'),
	('Образец на мотивационно писмо','letter.pdf');
GO

INSERT INTO [dbo].[Fields]([Name])
VALUES ('Търговия и продажби'),
    ('Автомобилна промишленост'),
    ('Електротехника'),
    ('Машиностроене'),
    ('Дървообработване и производство на мебели'),
    ('Металообработване и металургия'),
    ('Производство на текстил и облекло'),
    ('Фармация и козметика'),
    ('Химия, горива и хартия'),
    ('Хранителна промишленост'),
    ('Заведения, хотели и туризъм'),
    ('Администрация и бизнес'),
    ('Инженерство и техника'),
    ('Куриерски услуги'),
    ('Центрове за обслужване на клиенти'),
    ('Архитектура и строителство'),
    ('Счетоводство и финанси'),
    ('Физически/ръчен труд'),
    ('Ремонти и монтажни дейности'),
    ('Маркетинг и реклама'),
    ('Спорт'),
    ('Почистване и домакински услуги'),
    ('Образование, курсове и преводи'),
    ('Енергетика и комунални услуги'),
    ('Сигурност и охрана'),
    ('Изследователска и развойна дейност'),
    ('Дизайн и изкуство'),
    ('Селско и горско стопанство'),
    ('Медии, издателство'),
    ('Морски и речен транспорт'),
    ('Организации с нестопанска цел');
GO

INSERT INTO [dbo].[Positions]([Position_Name])
VALUES ('помощник автомонтьор'),
    ('помощник готвач'),
    ('касиер'),
    ('помощник касиер'),
    ('служител в магазин'),
    ('техници по поддръжка'),
    ('служител в склад'),
    ('хардуерен инжинер'),
    ('софтуерен инфинер'),
    ('аниматор'),
    ('помощник фармацефт'),
    ('рецепционист'),
    ('стажант счетоводител'),
    ('сервитьор'),
    ('барман'),
    ('камериерка'),
    ('помощен персонал');
GO

INSERT INTO [dbo].[Contract_Type]([Type])
VALUES ('безсрочен'),
	('2 седмици'),
	('1 месец'),
	('2 месеца'),
	('3 месеца'),
	('6 месеца'),
	('1 година'),
	('друг срочен'),
	('по договаряне');
GO

INSERT INTO [dbo].[Property_Custodians]([First_Name], [Middle_Name], [Surname], [EGN], [Phone], [Email])
VALUES ('-','-','-','1001019999','0000000000','xxx@xx.xxx'),
	('Йовка','Йонкова','Ангелова','9812167894','0019884783','y.angelova@au.com'),
    ('Силвия','Петкова','Радева','9611235739','0127369123','s.radeva@au.com'),
    ('Филип','Иванов','Младенов','9103180289','0937298128','f.mladenov@au.com'),
    ('Борис','Мартинов','Димитров','8903113829','0397199412','b.dimitrov@au.com'),
    ('Младен','Димитров','Стоянов','8501290182','0489791286','m.stoyanov@au.com'),
    ('Огнян','Стоянов','Колев','7808052945','0129836983','o.kolev@au.com');
GO

INSERT INTO [dbo].[Contact_People]([First_Name], [Middle_Name], [Surname], [Phone], [Email])
VALUES ('-','-','-','0000000000','xxx@xx.xxx'),
	('Валентина ','Радева','Йонкова','0827438368','v.yonkova@au.com'),
    ('Бранимира ','Младенов','Фейз','0384713984','b.feyz@au.com'),
    ('Трендафил ','Стоянов','Калайджиев','0329082137','t.kalaydzhiev@au.com'),
    ('Стефани ','Миркова','Радева','0829391283','s.radeva2@au.com'),
    ('Петър ','Танев','Димитров','0476872356','p.dimitrov@au.com'),
    ('Константин ','Петков','Йонков','0283764719','k.yonkov@au.com');
GO

INSERT INTO [dbo].[Employers]([Employer_Name], [UIC], [Custodian_ID], [City_ID], [Registered_Seat], [Contact_ID], [Email])
VALUES ('Сторми хилс','3487182974619',1,3,'ул. "Васил Априлов" № 31',1,'contact@stormyh.com'),
    ('Хюве фарма','2173577236498',2,3,'ул. "Вярност" № 28',2,'huevefarma@gmail.com'),
    ('Комерс ООД','3473647371931',3,5,'ул. "Васил Левски" № 16',3,'komerscon@au.com'),
    ('Съни ООД','1371094792783',4,1,'бул. "Цариградско шосе" № 234, ет. 10',4,'applic@sunny.bg'),
    ('Хепи холидейз','3418138390435',5,3,'ул. "Иван Вазов" № 22, ет. 3',5,'applications@happyholidays.com'),
    ('Сурфритикат ООД','7826345656836',6,9,'ул. "Лудогорец" № 19',6,'surfi@surfrutikat.bg');
GO

INSERT INTO [dbo].[Schools]([Name], [Phone], [Email])
VALUES ('СУ "Гео Милев"','052751120','sou_g.milev@abv.bg'),
    ('СУ "Димчо Дебелянов"','052612964','su.debelianovvarna@souddeb.com'),
    ('СУ "Елин Пелин"','052613156','su.elinpelin.varna@elinpelinvarna.com'),
    ('СУ "Любен Каравелов"','052370423','soulkaravelov@abv.bg'),
    ('СУ "Неофит Бозвели"','052751083','n.bozveli1981@gmail.com'),
    ('СУ "Пейо Крачолов Яворов"','052510544','yavorov_varna@abv.bg'),
    ('СУ "Свети Климент Охридски"','052620544','suklimentvarna@gmail.com'),
    ('VII СУ "Найден Геров"','052302228','school@7suvarna.com'),
    ('СУЕО "Александър Сергеевич Пушкин"','052609696','pushkin@sueovarna.com'),
    ('СУХНИ "Константин Преславски“','052622337','nghni_varna@abv.bg'),
    ('I ЕГ','052301235','firstls@1eg.eu'),
    ('IV ЕГ "Фредерик ЖолиоКюри"','052385320','4egvarna@4egvarna.com'),
    ('ГПЧЕ „Йоан Екзарх“','052302376','veg_varna@abv.bg'),
    ('МГ "Др Петър Берон"','052302106','mg.varna@mgberon.com'),
    ('III ПМГ "Акад. Методий Попов"','052620291','pmg3@abv.bg'),
    ('ПГГСД "Николай Хайтов','052745991','tehsilva@vizicomp.com'),
    ('ПГИ "Др Иван Богоров"','052747830','pgibogorov@pgivarna.com'),
    ('ВМГ "Свети Николай Чудотворец"','052370437','vmg_varna@abv.bg'),
    ('ВТГ "Георги Стойков Раковски"','052620414','vtg.gsr@gmail.com'),
    ('Професионална гимназия по електроника','052745875','te_varna@mail.bg'),
    ('ПГСАГ "Васил Левски"','052756756','tcc_varna@yahoo.com'),
    ('ПГТ "Проф. др Асен Златаров"','052642671','pgt_varna@abv.bg'),
    ('ПГТМД','052302430','pgtmd_varna@abv.bg'),
    ('ПГХХВТ "Дмитрий Иванович Менделеев"','0879823610','pgh_hvt@abv.bg'),
    ('Професионална техническа гимназия','052741363','ptgvarna@abv.bg'),
    ('Професионална гимназия по компютърно моделиране и компютърни системи','0888005610','office@itpgvarna.bg');
GO

INSERT INTO [dbo].[Addresses_Employers]([Employer_ID], [Address], [City_ID])
VALUES (1,'-',42),
	(2,'ул. "Поп Ставри" № 31',42),
    (2,'ул. "Рачо Kовача" № 1А',42),
    (3,'ул. "Петко Стайнов" № 12',42),
    (3,'бул. "Княз Борис" № 1 Б',42),
    (4,'ул. "Цар Асен" бл. 1, ет. 3',42),
    (4,'бул. "Сливница" № 10',42),
    (4,'ул. "Русе" № 21, ет. 13, № 2',42),
    (5,'бул. "Мария Луиза" № 24, ет. 10',42),
    (5,'ул. "Иван Вазов" № 22, ет. 2',42),
    (6,'ул. "Перуника" бл. 13, вх. А, ап. 3',42),
    (6,'бул. "Васил Левски" № 11',42);
GO

INSERT INTO [dbo].[Advertisements]([Position_ID], [Address_ID], [Field_ID], [Is_Valid], [Salary], [Contract_ID])
VALUES (15,1,11,1,'700',5),
    (2,3,10,1,'650',4),
    (6,5,3,0,'850',8),
    (7,4,18,1,'550',5),
    (1,2,2,0,'800',1),
    (11,6,8,1,'1150',5),
    (8,2,13,0,'900',9),
    (10,5,11,1,'500',3),
    (9,4,13,1,'1100',9),
    (12,2,11,0,'1000',9),
    (5,6,1,1,'450',6),
    (16,1,11,1,'400',7);
GO

INSERT INTO [dbo].[Students]([First_Name], [Middle_Name], [Surname], [EGN], [Phone], [Email], [Address], [School_ID])
VALUES ('Петър','Динков','Петров','0641109123','0652613435','p.petrov@au.com','кв. Бриз 3, № 21',1),
    ('Мартина','Пацова','Иванова','0551256756','0682937552','m.ivanova@au.com','кв. Люляк, № 12',7),
    ('Валя','Сливенова','Христова','0451267879','0487238104','v.hristova@au.com','кв. Сила, № 29',15),
    ('Кера','Магфиданова','Кикова','0452272378','0382923849','k.kikova@au.com','кв. Чайка, № 8',26),
    ('Гергана','Мирчева','Петрова','0541293738','0785757875','g.petrova@au.com','кв. Лилия, № 19',3),
    ('Милена','Кръстева','Димова','0552302839','0897556556','m.dimova@au.com','кв. Зюмбюл, № 3',4),
    ('Спас','Валентинов','Монев','0641111129','0675456436','s.monev@au.com','кв. Надежда, № 8',9),
    ('Диян','Емилиянов','Кръстев','0550105029','0768543287','d.krastev@au.com','кв. Дружба, № 9',14),
    ('Емилия','Димтрова','Йовчева','0543017898','0785688768','e.yovcheva@au.com','кв. Надежда, № 10',23),
    ('Димитър','Давидов','Георгиев','0550261001','0745388976','d.georgiev@au.com','кв. Слава, № 4',22),
    ('Станислав','Кристиянов','Станев','0452057843','0930298472','s.stanev@au.com','кв. Победа, № 15',15),
    ('Калоян','Миленов','Танев','0444043982','0983138702','k.tanev@au.com','кв. Слава, № 10',14),
    ('Стела','Станиславова','Берова','0446279071','0821894761','s.berova@au.com','кв. Любов, № 8',17),
    ('Джеймс','Петков','Беис','0549129924','0281978843','d.petkov@au.com','кв. Щастие, № 19',14),
    ('Хелена','Владимирова','Миркова','0543142891','0872366452','h.mirkova@au.com','кв. Младост, № 27',13),
    ('Кристин','Керанова','Васева','0549102330','0231673482','k.vaseva@au.com','кв. Младост 2, № 9',5);
GO

INSERT INTO [dbo].[Applications]([Student_ID], [Adverts_ID])
VALUES (1,2),
	(1,5),
	(1,7),
	(3,12),
	(1,5),
	(2,11),
	(2,7),
	(4,5),
	(5,10),
	(13,9),
	(6,10),
	(6,7),
	(2,11),
	(1,8),
	(6,5),
	(2,9),
	(1,8),
	(12,8),
	(5,3),
	(8,5),
	(8,11),
	(7,10),
	(11,12),
	(11,4),
	(10,5),
	(9,7),
	(14,8),
	(12,1),
	(13,2),
	(14,3),
	(15,3),
	(16,5),
	(16,6);
GO