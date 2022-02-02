use yah_ini_dee
go

--Обява по зададено ID на фирма
create or alter function udf_Adverts_Employer( @EmpID int)
returns @Empl_Ad_info table
(
	EmployerN nvarchar(50),
	Addr nvarchar(50),
	FieldN nvarchar(50),
	PosN nvarchar(50),
	Salary money,
	ContrType nvarchar(50),
	ViewsC int
)
as
begin
declare @num int;
insert into @Empl_Ad_info(EmployerN,Addr,FieldN,PosN,Salary,ContrType,ViewsC)
	select e.Employer_Name,ae.Address,f.Name,p.Position_Name,cast(a.Salary as money),c.Type,a.Views
	from Addresses_Employers ae
	inner join Employers e
	on e.ID=ae.Employer_ID
	inner join Advertisements a
	on a.Address_ID=ae.ID
	inner join Fields f
	on a.Field_ID=f.ID
	inner join Positions p
	on a.Position_ID=p.ID
	inner join Contract_Type c
	on a.Contract_ID=c.ID
	--where e.ID=3
	where e.ID=@EmpID
return
end
go
select * from udf_Adverts_Employer(2);
go

--Брой обяви по област
create or alter function udf_FieldNum(@FieID int)
returns @FieldAds table 
(
		FieldName nvarchar(50),
		AdsCount int
)
as
begin
insert into @FieldAds(FieldName,AdsCount)
	select f.Name,count(*)
	from Fields f
	inner join Advertisements a
	on f.ID=a.Field_ID
	group by f.Name
return
end
go
select * from udf_FieldNum(15);
go

--Информация за работодател и всички кандидати за работа на въпросния работодател
create or alter function udf_Empl_Appl_Inf(@EmpId int)
returns @Employers_Applicants table
(
	Employer_Name nvarchar(50),
	Name_of_Student nvarchar(150),
	Position_Name nvarchar(50)
)
as
begin
insert into @Employers_Applicants(Employer_Name,Name_of_Student,Position_Name)
	select e.Employer_Name,s.First_Name+' '+s.Middle_Name+' '+s.Surname as [Name_of_Student], p.Position_Name  
	from Employers e
	inner join Addresses_Employers ae
	on e.ID=ae.Employer_ID
	inner join Advertisements a
	on ae.ID=a.Address_ID
	inner join Positions p
	on a.Position_ID=p.ID
	inner join Applications appl
	on a.ID=appl.Adverts_ID
	inner join Students s
	on appl.Student_ID=s.ID
	--where e.ID=2
	where e.ID=@EmpId
return
end
go
select * from udf_Empl_Appl_Inf(2);

---Информация за всички обяви по зададено ID на област
go
create or alter function Fields_Ads(@FieId int)
returns @Field_Specified_Advertisements table
(
	Employer_Name nvarchar(50),
	Position_Name nvarchar(100),
	Field_Name nvarchar(100),
	Address nvarchar(150),
	Post_Date date,
	Salary money,
	Contract_Type nvarchar(50),
	Views_Count int
)
as
begin
insert into @Field_Specified_Advertisements(Employer_Name,Position_Name, Field_Name,Address,Post_Date,Salary ,Contract_Type,Views_Count)
	select e.Employer_Name,p.Position_Name,f.Name as [Field_Name], ae.Address, a.Post_Date,cast(a.Salary as money) as [Salary], c.Type, a.Views
	from Advertisements a
	inner join Fields f
	on f.ID=a.Field_ID
	inner join Positions p
	on a.Position_ID=p.ID
	inner join Addresses_Employers ae
	on ae.ID=a.Address_ID
	inner join Employers e
	on e.ID=ae.Employer_ID
	inner join Contract_Type c
	on c.ID=a.Contract_ID
	where f.ID=@FieId;
return
end
go
select * from Fields_Ads(11)
go

--Връща брой обяви по ID на дадена област
create or alter function udf_Field_Ads_Count(@FieID int)
returns int
as
begin
	declare @res int;
	set @res = (select count(*) from Fields_Ads(@FieID));
	return @res;
end
go
--select * from udf_Field_Ads_Count(2)
go

--Получаване на всичката информация по кандидатури по дадена обява по зададено ID на ученик
create or alter function udf_get_all_app_info_student (@StudentID INT)
returns table as
return
(
	select ID as [AdvertisementID],
	(select Employer_Name from Employers where ID = (select Employer_ID from Addresses_Employers where ID = ads.Address_ID)) as [Employer],
	(select Position_Name from Positions where ID = ads.Position_ID) as [Position],
	(select Name from Fields where ID = ads.Field_ID) as [Field],
	Salary,
	(select Type from Contract_Type where ID = ads.Contract_ID) as [Contract Type]
	from Advertisements as ads
	where ID in (select Adverts_ID from Applications where Student_ID=@StudentID)
)

go
select * from udf_get_all_app_info_student(1)
go

---Айди на обява -> информация за всички кандидатствали ученици
create or alter function udf_Ad_Applicants(@AdvId int)
returns @Applicants_cert_Adv table
(
		Position_Name nvarchar(50),
		Applicant_Name nvarchar(50),
		School_Name nvarchar(50),
		EGN nvarchar(10),
		Email_of_Applicant nvarchar(256),
		Phone_of_Applicant nvarchar(10)
)
as
begin
insert into @Applicants_cert_Adv(Position_Name,Applicant_Name,School_Name,EGN,Email_of_Applicant,Phone_of_Applicant)
	select p.Position_Name,s.First_Name+' '+s.Middle_Name+' '+s.Surname as [Name_of_Student], sc.Name as [School_Name],s.EGN,s.Email,s.Phone 
	from Advertisements a
	inner join Positions p
	on a.Position_ID=p.ID
	inner join Applications ap
	on ap.Adverts_ID=a.ID
	inner join Students s
	on s.ID=ap.Student_ID
	inner join Schools sc
	on s.School_ID=sc.ID
	where a.ID=@AdvId
return
end
go
select * from udf_Ad_Applicants(2)
go

--ID Advertisements count of applicants
create or alter function udf_Ad_Applicants_Count(@AdvId int)
returns int
as
begin
	declare @res int;
	set @res = (select count(*) from udf_Ad_Applicants(@AdvId));
	return @res;
end
go


--Помощно вю за следващата функция
Create or alter view V_EmployerID_AdID as
	select e.ID as [eID],a.ID as [aID]
	from Employers e
	inner join Addresses_Employers ae
	on e.ID=ae.Employer_ID
	inner join Advertisements a
	on a.Address_ID=ae.ID
go
select * from V_EmployerID_AdID;
go
--Работодатели и бройка обяви, които са публикували
create or alter function udf_Employers_Count_Of_Ads()
returns @Employers_Ads table
(
	Employer_Name nvarchar(50),
	AdCount int
)
as
begin
	insert into @Employers_Ads(Employer_Name,AdCount)
	select e.Employer_Name,count(*)
	from Employers e
	inner join V_EmployerID_AdID v
	on v.eID=e.ID
	group by e.Employer_Name
return
end
go
select * from udf_Employers_Count_Of_Ads()
go

--таблица извеждаща всички валидни обяви
create or alter function udf_get_valid_ads()
returns table as
return
(
	select * from Advertisements
	where Is_Valid = 1
)
go
select * from udf_get_valid_ads()
go

--функция извеждаща броя на всички валидни обяви
create or alter function udf_get_number_of_valid_ads()
returns table as
return
(
	select count(Is_Valid) as number_of_active_offers from Advertisements
	where Is_Valid = 1
)
go
select * from udf_get_number_of_valid_ads()
go

--изкарваща таблица с всички обяви по даден град
create or alter function udf_ads_by_city(@city nvarchar(256))
returns table as 
return
(
	select * from Advertisements ads
	where @city= (select Name from Cities where ID = (select City_ID from Addresses_Employers where ID = ads.Address_ID))
)
go
select * from udf_ads_by_city('Варна')
go

--Функция, която по зададено айди на ученик връща информация за лица за контакт, позиция и име на фирма
create or alter function udf_Student_Contact_Info(@StudID int)
returns @Inform table
(
	Position_Name nvarchar(50),
	Employer_Name nvarchar(50),
	Contact_Name nvarchar(50),
	Phone_Number nvarchar(50)
)
as
begin
insert into @Inform(Position_Name,Employer_Name,Contact_Name,Phone_Number)
	select p.Position_Name, e.Employer_Name, c.First_Name+' '+c.Middle_Name+' '+c.Surname as [Име на лице за контакт], c.Phone as [Phone_number]
	from Applications a
	inner join Advertisements ads
	on a.Adverts_ID=ads.ID
	inner join Students s
	on s.ID=a.Student_ID
	inner join Addresses_Employers ae
	on ae.ID=ads.Address_ID
	inner join Employers e
	on ae.Employer_ID=e.ID
	inner join Contact_People c
	on c.ID = e.Contact_ID
	inner join Positions p
	on ads.Position_ID=p.ID
	where s.ID=@StudID
return
end

go
select * from udf_Student_Contact_Info(2);
go

--изкарваща ID на град по името му
create or alter function udf_cityID_by_name(@city nvarchar(256))
returns int as 
begin
	declare @city_ID int;
	set @city_ID = (select ID from Cities where Name= @city)
	return @city_ID
end
go

select dbo.udf_cityID_by_name('Варна') as [asd]