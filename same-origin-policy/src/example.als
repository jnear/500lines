/**
  *  example.als
  *    A model of an Email application
  */
module example

open analysis

/**
	* Components
	*/

// Instantiations of servers, browser, and script

// Trusted email server
one sig EmailServer extends Server {}
// Document loaded from the email server
one sig InboxPage extends Document {}{
  domain.first = EmailDomain
  content.first = MyInboxInfo
}
one sig InboxScript extends Script {} {
	context = InboxPage
}

// A malicious server providing an ad service
one sig EvilServer extends Server {}
// Document loaded from the evil ad server
one sig AdBanner extends Document {}{
	domain.first = EvilDomain
	no CriticalData & content.first 
}
// An evil script running inside the ad 
one sig EvilScript extends Script {}

// Trusted calender server
one sig CalendarServer extends Server {}
one sig CalendarPage extends Document {}{
  domain.first = CalendarDomain
  content.first = MySchedule
}
// Trusted scripts
one sig CalendarScript extends Script {}{
	context = CalendarPage
}

// The victim user's browser
one sig MyBrowser extends Browser {}

// Domain instances
// Conceptually represent "email.abc.com", "calendar.abc.com", "www.evil.com" 
one sig EmailDomain, CalendarDomain, EvilDomain extends Domain {}

// Resource representing the information in the user's inbox (list of emails, etc)
one sig MyInboxInfo in Resource {}
// Resource representing my schedule on the calendar
one sig MySchedule in Resource {}
// Cookie used to authenticate the user by the email and calendar apps
one sig MyCookie in Cookie {}{
	domains = EmailDomain + CalendarDomain
}

one sig HTTP extends Protocol {}

/**
	* Requests
	*/

// Request for getting the inbox of the user
sig GetInboxInfo in HttpRequest {}{
  to in EmailServer
  -- cookie must be provided for the request to succeed
  MyCookie in sentCookies
}

// Get user info
sig GetSchedule in HttpRequest {}{
  to in CalendarServer
  MyCookie in sentCookies
}

fact SecurityAssumptions {
	-- designate trusted modules
	EmailServer + MyBrowser + CalendarServer + 
		InboxScript + CalendarScript + BlogServer in TrustedModule
	EvilScript + EvilServer in MaliciousModule
	CriticalData = MyInboxInfo + MyCookie + MySchedule
    -- assume malicious modules initially don't have access to critical data
	no initData[MaliciousModule] & CriticalData
	-- and trusted modules don't already contain malicious data
	no initData[TrustedModule] & MaliciousData
   -- to disallow EmailDomain or CalenderDomain being mapped to EvilServer, 
   -- in reality, this attack is possible, but will be ruled out here
	Dns.map = EmailDomain -> EmailServer + CalendarDomain -> CalendarServer 
					+ BlogDomain -> BlogServer + EvilDomain -> EvilServer 
}

run {} for 3

/* Restrictions */

-- you can comment out any of these facts if you prefer

// Restrict calls to be only of one kind
-- leave uncommented the kind of call you want to see only
pred asm1 {
	#Call = 2
	one XmlHttpRequest
	one ReadDom
	no CorsRequest
	MyInboxInfo in EvilServer.accesses.last
	EvilScript.context = AdBanner
}
run asm1 for 3 but 2 Call

pred asm2 {
	Call in XmlHttpRequest
	Call.from = EvilScript
	Call.to = EmailServer
	GetInboxInfo = Call
	some sentCookies
	one Cookie
	MyInboxInfo in EvilScript.accesses.last
	EvilScript.context = AdBanner
}
run asm2 for 2 but 1 Call

one sig Leak extends Callback {}
pred jsonpAttack {
	one GetSchedule
	one ExecCallback
	ExecCallback.to in EvilScript
	MySchedule in EvilScript.accesses.last
   	GetSchedule in JsonpRequest
	one Cookie
	no MyInboxInfo & MySchedule
	EvilScript.context = AdBanner
}
run jsonpAttack for 3 but 2 Call, 3 Resource

pred postmessageAttack {
	one PostMessage
	one ReceiveMessage
	PostMessage.from in EvilScript
	ReceiveMessage.to in InboxScript
	some MaliciousData & InboxScript.accesses.last 
	no MyInboxInfo & MySchedule
	no Port
	EvilScript.context = AdBanner
}
run postmessageAttack for 3 but 3 Time, 2 Call//, 2 Resource

pred corsAttack {
	GetSchedule in CorsRequest
	GetSchedule.from = EvilScript
	MySchedule in EvilScript.accesses.last
	no MyInboxInfo & MySchedule
	no Port
	no body
	one resources
	EvilScript.context = AdBanner
}
run corsAttack for 3 but 2 Time, 1 Call

one sig BlogDomain, ParentDomain extends Domain {}
one sig BlogServer extends Server {}{
  no accesses.first
}
one sig BlogPage extends Document {}{
	domain.first = BlogDomain
    no content.first
}

pred setdomainAttack {
	subsumes = 
		ParentDomain -> EmailDomain + ParentDomain -> CalendarDomain + 
		ParentDomain -> BlogDomain + (Domain <: iden)
	EvilScript.context = BlogPage
//	MySchedule in EvilScript.accesses.last
		
}
run setdomainAttack for 7 but 5 Domain, 5 Time, 4 Call

/* Helper functions for visualization */

fun currentCall: Call -> Time {
  {c: Call, t: Time | c.start = t }
}

fun relevantModules : DataflowModule -> Time {
  {m: DataflowModule, t: Time | m in currentCall.t.(from + to) }
}
