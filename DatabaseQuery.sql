USE master;

drop database if exists Hybrid_Attendance_System;

CREATE DATABASE Hybrid_Attendance_System;

USE Hybrid_Attendance_System;

CREATE TABLE userTable(
	user_id int identity(1,1),
	name varchar(75),
	nic varchar(15),
	email varchar(70),
	password varchar(70),
	address varchar(100),
	telephone varchar(13),
	profile_pic varchar(200),
	type int,
	no_of_annual_leaves int,
	constraint PK_user primary key(user_id)
);

CREATE TABLE pendingUserTable(
	pending_user_id int identity(1,1),
	name varchar(75),
	nic varchar(15),
	email varchar(70),
	password varchar(70),
	address varchar(100),
	telephone varchar(13),
	profile_pic varchar(200),
	type int,
	no_of_annual_leaves int,
	status varchar(15),
        confirm int,
	constraint PK_pending_user primary key(pending_user_id)
);

CREATE TABLE blackListedEmails(
	email varchar(50),
	constraint PK_blackListedEmails primary key(email)
);

CREATE TABLE Attendance(
	id int identity(1,1),
	date Date,
	in_time Time,
	out_time Time,
	type varchar(10),
	u_id int,
	constraint PK_Attendance primary key(id),
	constraint FK_Attendance foreign key(u_id) references userTable(user_id)
);

CREATE TABLE VideoConference(
	conference_id int identity(1,1),
	date Date,
	time Time,
	host_id varchar(10),
	scheduler_id int,
	constraint PK_VideoConference primary key(conference_id),
	constraint FK_VideoConference foreign key(scheduler_id) references userTable(user_id)
);

CREATE TABLE VideoConferenceHasUser(
	c_id int,
	u_id int,
	constraint PK_VCHU primary key(c_id,u_id),
	constraint FK1_VideoConferenceHasUser foreign key(u_id) references userTable(user_id),
	constraint FK2_VideoConferenceHasUser foreign key(c_id) references VideoConference(conference_id)
);

CREATE TABLE Report(
	report_id int identity(1,1),
	start_date Date,
	end_date Date,
	u_id int,
	constraint PK_Report primary key(report_id),
	constraint FK_Report foreign key(u_id) references userTable(user_id)
);

CREATE TABLE Settings(
	settings_id int identity(1,1),
	no_of_working_hours_per_day int,
	no_of_annual_leaves int,
	no_of_working_days_per_week int,
	admin_id int,
	constraint PK_Settings primary key(settings_id),
	constraint FK_Settings foreign key(admin_id) references userTable(user_id)
);

CREATE TABLE Notification(
	id int identity(1,1),
	date Date,
	time Time,
	message varchar(100),
	sender_id int,
	receiver_id int,
	constraint PK_Notification primary key(id),
	constraint FK1_Notification foreign key(sender_id) references userTable(user_id),
	constraint FK2_Notification foreign key(receiver_id) references userTable(user_id)
);

CREATE TABLE HolidayCalendarEvent(
	id int identity(1,1),
	name varchar(20),
	date Date,
	time Time,
	comment varchar(50),
	editor_id int,
	constraint PK_CalendarEvent primary key(id),
	constraint FK_CalendarEvent foreign key(editor_id) references userTable(user_id)
);

CREATE TABLE HolidayCalendarEventHasUser(
	calendar_event_id int,
	u_id int,
	constraint PK_HolidayCalendarEventHasUser primary key(calendar_event_id,u_id),
	constraint FK1_HolidayCalendarEventHasUser foreign key(calendar_event_id) references HolidayCalendarEvent(id),
	constraint FK2_HolidayCalendarEventHasUser foreign key(u_id) references userTable(user_id)
);

CREATE TABLE SMS(
	id int identity(1,1),
	messsage varchar(100),
	admin_id int,
	constraint PK_SMS primary key(id),
	constraint FK_SMS foreign key(admin_id) references userTable(user_id)
);

CREATE TABLE SMSHasUser(
	sms_id int,
	user_id int,
	constraint PK_SMSHasUser primary key(sms_id,user_id),
	constraint FK1_SMSHasUser foreign key(sms_id) references SMS(id),
	constraint FK2_SMSHasUser foreign key(user_id) references userTable(user_id)
);

CREATE TABLE Leave(
	id int identity(1,1),
	type varchar(20),
	admin_id int,
	constraint PK_Leave primary key(id),
	constraint FK_Leave foreign key(admin_id) references userTable(user_id)
);

CREATE TABLE Request(
	request_id int identity(1,1),
	date Date,
	time Time,
	status varchar(10),
	sender_id int,
	leave_type_id int,
	approval_id int,
	constraint PK_Request primary key(request_id),
	constraint FK1_Request foreign key(sender_id) references userTable(user_id),
	constraint FK2_Request foreign key(leave_type_id) references Leave(id),
	constraint FK3_Request foreign key(approval_id) references userTable(user_id)
);

CREATE TABLE LeaveDetails(
	leave_id int identity(1,1),
	date Date,
	type varchar(15),
	duration real,
	special_note varchar(100),
	status varchar(15),
	approval_id int,
	leave_type_id int,
	constraint PK_LeaveDetails primary key(leave_id),
	constraint FK1_LeaveDetails foreign key(approval_id) references userTable(user_id),
	constraint FK2_LeaveDetails foreign key(leave_type_id) references Leave(id)
);

CREATE TABLE LeaveCalendarEvent(
	id int identity(1,1),
	name varchar(20),
	date Date,
	time Time,
	comment varchar(50),
	leave_id int,
	user_id int,
	constraint PK_LeaveCalendarEvent primary key(id),
	constraint FK1_LeaveCalendarEvent foreign key(leave_id) references LeaveDetails(leave_id),
	constraint FK2_LeaveCalendarEvent foreign key(user_id) references userTable(user_id)
);

CREATE VIEW LeaveCalendarEvents
AS
SELECT u.user_id,u.name,lce.date,lce.time,lce.comment
FROM LeaveCalendarEvent lce,userTable u
WHERE lce.user_id=u.user_id

CREATE VIEW HolidayCalendarEvents
AS
SELECT u.user_id,u.name,hce.date,hce.time,hce.comment
FROM HolidayCalendarEvent hce,userTable u,HolidayCalendarEventHasUser hcehu
WHERE hcehu.u_id=u.user_id and hcehu.calendar_event_id=hce.id

CREATE VIEW PendingRequests
AS
SELECT u.name,r.date,r.time,u.nic,l.type
FROM Request r,userTable u,Leave l
WHERE r.leave_type_id=l.id and r.sender_id=u.user_id and r.status='Pending'

CREATE FUNCTION CalendarEventsByUser(@user_id char(10))
RETURNS @myTable TABLE(
	userId int,
	userName varchar(30),
	date Date,
	time Time,
	comment varchar(50)
)
AS
BEGIN
	INSERT INTO @myTable
	SELECT lce.user_id,lce.name,lce.date,lce.time,lce.comment
	FROM LeaveCalendarEvents lce
	WHERE lce.user_id=@user_id

	INSERT INTO @myTable
	SELECT hce.user_id,hce.name,hce.date,hce.time,hce.comment
	FROM HolidayCalendarEvents hce
	WHERE hce.user_id=@user_id

	RETURN
END

CREATE TRIGGER AddLeave
ON Request
AFTER UPDATE
AS
BEGIN
	DECLARE @date Date
	DECLARE @time Time
	DECLARE @approval_id char(10)
	DECLARE @leave_type_id char(10)
	SELECT @date=date,@time=time,@approval_id=approval_id,@leave_type_id=leave_type_id
	FROM inserted
	INSERT INTO LeaveDetails VALUES(@date,@time,@approval_id,@leave_type_id)
END

CREATE FUNCTION AttendHours(@userId int,@start_date date,@end_date date)
RETURNS REAL
AS
BEGIN
	DECLARE @workHours REAL
	SELECT @workHours=sum(DATEDIFF(SECOND,@start_date ,@end_date )*1.00  / (60*60))
	FROM Attendance
	WHERE u_id=@userId and date>@start_date and date<@end_date and type='Attend'
	RETURN @workHours
END

CREATE FUNCTION BreakHours(@userId int,@start_date date,@end_date date)
RETURNS REAL
AS
BEGIN
	DECLARE @breakHours REAL
	SELECT @breakHours=sum(DATEDIFF(SECOND,@start_date ,@end_date )*1.00  / (60*60))
	FROM Attendance
	WHERE u_id=@userId and date>@start_date and date<@end_date and type='Break'
	RETURN @breakHours
END

CREATE PROC WorkingHours 
@user_id int,
@start_date date,
@end_date date,
@workHours REAL OUT
AS
BEGIN
	DECLARE @attendTime REAL
	DECLARE @breakTime REAL

	EXEC @attendTime = AttendHours @user_id,@start_date,@end_date
	EXEC @breakTime = BreakHours @user_id,@start_date,@end_date
	SET @workHours=@attendTime-@breakTime
END

CREATE TRIGGER SettingsUpdate
ON Settings
AFTER UPDATE
AS
BEGIN
	DECLARE @oldNoOfLeaves INT
	DECLARE @newNoOfLeaves INT
	SELECT @oldNoOfLeaves=no_of_annual_leaves
	FROM deleted
	SELECT @newNoOfLeaves=no_of_annual_leaves
	FROM inserted
	UPDATE userTable SET no_of_annual_leaves=@newNoOfLeaves
	WHERE no_of_annual_leaves=@oldNoOfLeaves
END

CREATE TRIGGER NewUserAdd
ON pendingUserTable
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @status varchar(15)
	DECLARE @email varchar(70)
	SELECT @email=email,@status=status FROM inserted
	IF @status='Approved'
	BEGIN
		DECLARE @name varchar(75)
		DECLARE @nic varchar(15)
		DECLARE @password varchar(70)
		DECLARE @address varchar(100)
		DECLARE @telephone varchar(13)
		DECLARE @profile_pic varchar(200)
		DECLARE @type int
		DECLARE @no_of_annual_leaves int
		SELECT @name=name,@nic=nic,@password=password,@address=address,@telephone=telephone,@profile_pic=profile_pic,@type=type,@no_of_annual_leaves=no_of_annual_leaves FROM inserted
		INSERT INTO userTable VALUES(@name,@nic,@email,@password,@address,@telephone,@profile_pic,@type,@no_of_annual_leaves)
		DELETE FROM pendingUserTable WHERE email=@email
	END
	ELSE IF @status='Rejected'
	BEGIN
		INSERT INTO blackListedEmails VALUES(@email)
		DELETE FROM pendingUserTable WHERE email=@email
	END
END
