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
	no_of_annual_leaves real,
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

CREATE TABLE shortLeaveDetails(
	id int identity(1,1),
	date Date,
	start_time varchar(10),
	end_time varchar(10),
	special_notes varchar(100),
	requester_id int,
	approval_id int,
	status varchar(15),
	constraint PK_shortLeaveDetails primary key(id),
	constraint FK1_shortLeaveDetails foreign key(requester_id) references userTable(user_id)
);

CREATE TABLE emergencyLeaveDetails(
	id int identity(1,1),
	reason varchar(300),
	requester_id int,
	approval_id int,
	status varchar(15),
	constraint PK_emergencyLeaveDetails primary key(id),
	constraint FK1_emergencyLeaveDetails foreign key(requester_id) references userTable(user_id)
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
	conference_id varchar(20),
	date varchar(15),
	time varchar(10),
	host_id int,
	scheduler_id int,
	constraint PK_VideoConference primary key(conference_id),
	constraint FK1_VideoConference foreign key(scheduler_id) references userTable(user_id),
	constraint FK2_VideoConference foreign key(host_id) references userTable(user_id)
);

CREATE TABLE VideoConferenceHasUser(
	c_id varchar(20),
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
	type varchar(30),
	requester_id int,
	constraint PK_Report primary key(report_id),
	constraint FK1_Report foreign key(u_id) references userTable(user_id),
	constraint FK2_Report foreign key(requester_id) references userTable(user_id)
);

CREATE TABLE Settings(
	settings_id int identity(1,1),
	no_of_working_hours_per_day int,
	no_of_annual_leaves real,
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
	id char(15),
	name varchar(20),
	date Date,
	duration real,
	comment varchar(50),
	editor_id int,
	constraint PK_CalendarEvent primary key(id),
	constraint FK_CalendarEvent foreign key(editor_id) references userTable(user_id)
);

CREATE TABLE ShortHolidayCalendarEvent(
	id char(15),
	name varchar(20),
	date Date,
	start_time varchar(6),
	end_time varchar(6),
	comment varchar(50),
	editor_id int,
	constraint PK_ShortHolidayCalendarEvent primary key(id),
	constraint FK_ShortHolidayCalendarEvent foreign key(editor_id) references userTable(user_id)
);

CREATE TABLE HolidayCalendarEventHasUser(
	calendar_event_id char(15),
	u_id int,
	constraint PK_HolidayCalendarEventHasUser primary key(calendar_event_id,u_id),
	constraint FK1_HolidayCalendarEventHasUser foreign key(calendar_event_id) references HolidayCalendarEvent(id),
	constraint FK2_HolidayCalendarEventHasUser foreign key(u_id) references userTable(user_id)
);

CREATE TABLE ShortHolidayCalendarEventHasUser(
	calendar_event_id char(15),
	u_id int,
	constraint PK_ShortHolidayCalendarEventHasUser primary key(calendar_event_id,u_id),
	constraint FK1_ShortHolidayCalendarEventHasUser foreign key(calendar_event_id) references ShortHolidayCalendarEvent(id),
	constraint FK2_ShortHolidayCalendarEventHasUser foreign key(u_id) references userTable(user_id)
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
	type varchar(15),
	duration real,
	special_note varchar(100),
	sender_id int,
	leave_type_id int,
	status varchar(15),
	approval_id int,
	constraint PK_Request primary key(request_id),
	constraint FK1_Request foreign key(leave_type_id) references Leave(id),
	constraint FK2_Request foreign key(sender_id) references userTable(user_id)
);

CREATE TABLE LeaveDetails(
	leave_id int identity(1,1),
	date Date,
	type varchar(15),
	duration real,
	special_note varchar(100),
	sender_id int,
	leave_type_id int,
	approval_id int,
	constraint PK_LeaveDetails primary key(leave_id),
	constraint FK2_LeaveDetails foreign key(leave_type_id) references Leave(id),
	constraint FK3_LeaveDetails foreign key(sender_id) references userTable(user_id)
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
SELECT u.user_id,ld.type,ld.date,ld.duration,ld.special_note,l.type leaveType
FROM LeaveDetails ld,userTable u,Leave l
WHERE ld.sender_id=u.user_id and ld.leave_type_id=l.id

CREATE VIEW ShortLeaveCalendarEvents
AS
SELECT u.user_id,sld.date,sld.start_time,sld.end_time,sld.special_notes
FROM ShortLeaveDetails sld,userTable u
WHERE sld.requester_id=u.user_id and sld.status='Approved'

CREATE VIEW HolidayCalendarEvents
AS
SELECT u.user_id,hce.name,hce.date,hce.duration,hce.comment
FROM HolidayCalendarEvent hce,userTable u,HolidayCalendarEventHasUser hcehu
WHERE hcehu.u_id=u.user_id and hcehu.calendar_event_id=hce.id

CREATE VIEW ShortHolidayCalendarEvents
AS
SELECT u.user_id,shce.name,shce.date,shce.start_time,shce.end_time,shce.comment
FROM ShortHolidayCalendarEvent shce,userTable u,ShortHolidayCalendarEventHasUser shcehu
WHERE shcehu.u_id=u.user_id and shcehu.calendar_event_id=shce.id

CREATE VIEW PendingRequests
AS
SELECT r.request_id,u.name,r.date,u.nic,u.profile_pic,l.type,r.type duration_type,r.special_note,r.duration
FROM Request r,userTable u,Leave l
WHERE r.leave_type_id=l.id and r.sender_id=u.user_id and r.status='Pending'

CREATE VIEW PendingShortLeaveRequests
AS
SELECT s.id,u.name,u.nic,u.profile_pic,s.date,s.start_time,s.end_time,s.special_notes
FROM shortLeaveDetails s, userTable u
WHERE s.requester_id=u.user_id and s.status='Pending'

CREATE VIEW pendingEmergencyLeaves
AS
SELECT u.name,u.nic,u.profile_pic,eld.reason,eld.id,u.user_id
FROM emergencyLeaveDetails eld, userTable u
WHERE eld.requester_id=u.user_id and eld.status='Pending'

CREATE FUNCTION CalendarEventsByUser(@user_id int)
RETURNS @myTable TABLE(
	eventName varchar(75),
	date Date,
	duration real,
	comment varchar(50),
	type varchar(20)
)
AS
BEGIN
	INSERT INTO @myTable
	SELECT lce.leaveType,lce.date,lce.duration,lce.special_note,lce.type
	FROM LeaveCalendarEvents lce
	WHERE lce.user_id=@user_id
	INSERT INTO @myTable
	SELECT hce.name,hce.date,hce.duration,hce.comment,'Holiday'
	FROM HolidayCalendarEvents hce
	WHERE hce.user_id=@user_id
	RETURN
END

CREATE FUNCTION ShortCalendarEventsByUser(@user_id int)
RETURNS @myTable TABLE(
	eventName varchar(75),
	date Date,
	startTime varchar(6),
	endTime varchar(6),
	comment varchar(50)
)
AS
BEGIN
	INSERT INTO @myTable
	SELECT 'Short Leave',slce.date,slce.start_time,slce.end_time,slce.special_notes
	FROM ShortLeaveCalendarEvents slce
	WHERE slce.user_id=@user_id
	INSERT INTO @myTable
	SELECT shce.name,shce.date,shce.start_time,shce.end_time,shce.comment
	FROM ShortHolidayCalendarEvents shce
	WHERE shce.user_id=@user_id
	RETURN
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
SELECT * FROM Request
SELECT * FROM userTable
UPDATE userTable SET no_of_annual_leaves=20 WHERE user_id=1
UPDATE Request SET status='Approved' WHERE request_id=4
SELECT * FROM LeaveDetails
DROP TRIGGER ApproveLeave
CREATE TRIGGER ApproveLeave
ON Request
INSTEAD OF UPDATE
AS
BEGIN
	DECLARE @id int
	DECLARE @status varchar(15)
	SELECT @id=request_id,@status=status FROM inserted
	IF @status='Approved'
	BEGIN
		DECLARE @date DATE
		DECLARE @type varchar(15)
		DECLARE @duration real
		DECLARE @special_note varchar(100)
		DECLARE @sender_id int
		DECLARE @leave_type_id int
		DECLARE @approval_id int
		SELECT @date=date,@type=type,@duration=duration,@special_note=special_note,@sender_id=sender_id,@leave_type_id=leave_type_id,@approval_id=approval_id FROM inserted
		INSERT INTO LeaveDetails VALUES(@date,@type,@duration,@special_note,@sender_id,@leave_type_id,@approval_id)
		UPDATE userTable SET no_of_annual_leaves=(no_of_annual_leaves-@duration) WHERE user_id=@sender_id
	END
	DELETE FROM Request WHERE request_id=@id
END