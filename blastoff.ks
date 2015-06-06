DECLARE FUNCTION DROP_DEAD_ENGINES {
	LIST ENGINES IN EngList.
	SET FlameOut TO 0.
	SET AnyOn TO 0.
	FOR Eng IN EngList {
		IF Eng:FLAMEOUT {
			SET FlameOut TO FlameOut + 1.
		}
		IF Eng:IGNITION {
			SET AnyOn TO 1.
		}
	}

	IF FlameOut > 0 {
		PRINT "One or more engines have exhausted their fuel.".
		PRINT "Initiating next stage.".
		STAGE.
	} ELSE IF AnyOn = 0 {
		PRINT "There are no active engines!".
		PRINT "Initiating next stage.".
		STAGE.
	}
}

DECLARE FUNCTION AIM_FOR_ORBIT {
	DECLARE PARAMETER DESIRED_ALTITUDE.
	DECLARE PARAMETER SOFTNESS.

	SET STEERING_ANGLE TO -MIN(MAX(90.0 - ((DESIRED_ALTITUDE - APOAPSIS)/SOFTNESS), 1),179.0).

	LOCK STEERING TO UP + R(0, STEERING_ANGLE, 0).
}

DECLARE FUNCTION THROTTLE_FOR_ATMOSPHERE {
	DECLARE PARAMETER SOFTNESS.

	IF ALTITUDE > 70000{
		LOCK THROTTLE TO 1.0.
	} ELSE {
		SET TARGET_VEL TO ALTITUDE * ALTITUDE * 0.000001321 - ALTITUDE * 0.000813 + 277.496.

		LOCK THROTTLE TO MAX(MIN(1, (TARGET_VEL - AIRSPEED)/SOFTNESS), 0).
	}
}

DECLARE FUNCTION APOAPSIS_SPEED {
	RETURN SQRT(BODY:MU / (APOAPSIS + BODY:RADIUS) - BODY:MU / (ALTITUDE + BODY:RADIUS) + 0.5 * VELOCITY:ORBIT:MAG * VELOCITY:ORBIT:MAG).
}

DECLARE FUNCTION PERIAPSIS_SPEED {
	RETURN SQRT(BODY:MU / (PERIAPSIS + BODY:RADIUS) - BODY:MU / (ALTITUDE + BODY:RADIUS) + 0.5 * VELOCITY:ORBIT:MAG * VELOCITY:ORBIT:MAG).
}

DECLARE FUNCTION BURN_DURATION_FOR_DELTA_V{
	DECLARE PARAMETER DELTA_V.
	SET M TO MASS.
	SET DM TO 0.

	LIST ENGINES IN EngList.

	FOR Eng in EngList {
		IF Eng:IGNITION {
			SET DM TO DM + Eng:MAXTHRUST/(Eng:VISP * 9.81).
		}
	}

	RETURN (M - constant():e ^ (LN(M) - DELTA_V * DM / MAXTHRUST))/DM.
}

SET DESIRED_ORBIT TO 90000.

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

LOCK STEERING TO UP + R(0, -90, 0).
LOCK THROTTLE TO 0.0.

WAIT 3.

STAGE. // same as hitting the spacebar.

WAIT 3.

STAGE. // same as hitting the spacebar.

WAIT 1.

SET DESIRED_SPEED TO SQRT(Constant():G * Kerbin:Mass / (APOAPSIS + Kerbin:Radius)).

SET CURRENT_SPEED TO APOAPSIS_SPEED().

SET DV TO DESIRED_SPEED - CURRENT_SPEED.

SET BURN_DURATION TO BURN_DURATION_FOR_DELTA_V(DV).

WAIT UNTIL ETA:APOAPSIS < BURN_DURATION/2.

LOCK THROTTLE TO 1.0.

WAIT UNTIL PERIAPSIS > DESIRED_ORBIT.

PRINT "Performing one more periapsis burn to touch up the orbit".

LOCK THROTTLE TO 0.0.
LOCK STEERING TO UP + R(0, 90, 0).

SET BURN_DURATION TO BURN_DURATION_FOR_DELTA_V(PERIAPSIS_SPEED() - DESIRED_SPEED).

WAIT UNTIL ETA:PERIAPSIS < BURN_DURATION/2.

LOCK THROTTLE TO 1.0.

WAIT BURN_DURATION.

LOCK THROTTLE TO 0.0.

PRINT "Operation complete.".
PRINT "3 seconds until program exits.".

WAIT 3.