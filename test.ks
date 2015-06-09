FOR THING IN SHIP:PARTS{
	FOR OTHERTHING IN THING:MODULES{
		SET MOD TO THING:GETMODULE(OTHERTHING).
		IF MOD:HASFIELD("sun exposure"){
			IF MOD:HASACTION("extend panel") {
				MOD:DOACTION("extend panel", True).
			}
		}
	}
}