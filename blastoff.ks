RUN LIBS.

DECLARE PARAMETER DESIRED_ORBIT.

IF DESIRED_ORBIT < 90000 {
	PRINT "Unable to achieve orbits of altitude less than 90,000".
	PRINT "Assuming 90,000 as target instead".
	SET DESIRED_ORBIT TO 90000.
}

SAS ON.

PRINT "Main throttle up.  1 second to stabilize it.".
LOCK STEERING TO UP.
LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.
WAIT 1. // give throttle time to adjust.

UNTIL SHIP:MAXTHRUST > 0 {
    WAIT 0.5. // pause half a second between stage attempts.
    PRINT "Stage activated.".
    STAGE. // same as hitting the spacebar.
}

UNTIL SHIP:APOAPSIS > DESIRED_ORBIT {
	DROP_DEAD_ENGINES().
	AIM_FOR_ORBIT(DESIRED_ORBIT, 300).
	THROTTLE_FOR_ATMOSPHERE(40).
	WAIT 0.1.
}

LOCK STEERING TO FORWARD().
LOCK THROTTLE TO 1.

UNTIL SHIP:PERIAPSIS > 72000 {
	DROP_DEAD_ENGINES().
}

PRINT "Operation complete.".
PRINT "You may want to circularize your orbit though.".

//set throttle to 0 just in case.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS OFF.