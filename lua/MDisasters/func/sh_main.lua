function convert_AngleToVector(angle)
   return angle:Forward()
end
   
function convert_VectorToAngle(vector)
   return vector:Angle()
end

function GetPhysicsMultiplier()

	return (200/3) / ( 1 / ( engine.TickInterval() ) )
end

function HitChance(chance)
	if (SERVER) then 
	
		return math.random() < ( math.Clamp(chance * GetPhysicsMultiplier(),0,100)/100)
	elseif (CLIENT) then 
	
		return math.random() < ( math.Clamp(chance * GetFrameMultiplier(),0,100)/100)

	
	end
end